import '../entities/employee_data.dart';
import '../entities/liquidation_result.dart';
import '../../core/constants/legal_parameters.dart';
import 'calculate_pension_retention.dart';

/// Calcula la liquidación por cese del trabajador.
///
/// ## REGLAS DE CÁLCULO (abstractas y universales)
///
/// ### FUNCIÓN 1 — Sueldo del Mes de Cese
///   netPendingSalary = (baseSalary / 30) × diasTrabajadosEnMesCese
///   → Si diasTrabajados = 0, retorna 0.00 obligatoriamente.
///
/// ### FUNCIÓN 2 — Gratificación Trunca
///   brutoGrati  = (RCB / 6) × mesesCompletosSemestre
///   bonoGrati   = brutoGrati × bonoRate   ← se aplica de forma independiente
///   netGrati    = brutoGrati + bonoGrati
///
/// ### FUNCIÓN 3 — CTS Trunca
///   baseComputableCTS  = baseSalary + (baseSalary / 6) + asig.familiar + variablesAvg
///   netCTS             = (baseComputableCTS / 12) × mesesProporcionales
///   donde mesesProporcionales = diasCeseCts / 30  (puede ser fraccionario)
///
/// ### FUNCIÓN 4 — Vacaciones Truncas
///   netVacations = (baseSalary / vacDivisor) × mesesEquivalentes
///   vacDivisor       = 12 (general, 30 días/año) | 24 (MYPE, 15 días/año)
///   mesesEquivalentes = diasVacPendientesCeil / 30
///
/// ### FUNCIÓN 5 — Retención Pensionaria
///   basePension = netPendingSalary + currentMonthOvertime + netVacations
///   EXCLUIDOS: Gratificación trunca (Ley 29351) y CTS trunca (beneficio social)
///
/// ### TOTALIZADOR
///   totalToPay = netPendingSalary + currentMonthOvertime
///              + netGratification + netCtsInLiquidation + netVacations
///              − pensionDeduction
///
/// El baseSalary completo y el semesterTotalOvertime son VARIABLES DE REFERENCIA
/// para las fórmulas de los truncos. NUNCA se suman directamente al totalizador.
final class CalculateLiquidationUseCase {
  final CalculatePensionRetentionUseCase _pension;

  const CalculateLiquidationUseCase({
    CalculatePensionRetentionUseCase? pension,
  }) : _pension = pension ?? const CalculatePensionRetentionUseCase();

  LiquidationResult call(EmployeeData data) {
    // ── Guardia de fechas ─────────────────────────────────────────────────────
    if (data.startDate == null || data.endDate == null) {
      return const LiquidationResult(
        netGratification:          0,
        ctsInBank:                 0,
        netCtsInLiquidation:       0,
        netVacations:              0,
        netPendingSalary:          0,
        currentMonthOvertimeResult: 0,
        pensionDeduction:          0,
        totalToPay:                0,
      );
    }

    final startDate  = data.startDate!;
    final endDate    = data.endDate!;

    // VARIABLE DE REFERENCIA — tasa diaria y base; NUNCA se agrega al total.
    final double baseSalary = data.grossSalary;

    final bool hasFamily      = data.hasFamilyAllowance == true;
    final double familyAmt    = hasFamily ? LegalParameters.kFamilyAllowance : 0.0;

    final bool isMype         = data.regime == CompanyRegime.small ||
                                data.regime == CompanyRegime.micro ||
                                data.regime == CompanyRegime.intern;

    final bool hasGozadoVac   = data.hasTakenVacations == true;
    final double diasGozados  = data.takenVacationDays.toDouble();

    // ── VARIABLES DE REFERENCIA (promedios para la base computable) ──────────
    //
    // overtimeAverage = historicalOvertimeSum / 6
    //   • Entra en el RCB de gratificación y en la base CTS.
    //   • NUNCA va al totalizador directamente.
    //
    // Prueba de escritorio (caso real):
    //   semesterTotalOvertime = 295.08  → overtimeAverage = 49.18
    //   RCB = 1,220.00 + 49.18 = 1,269.18
    final double overtimeAvg  = data.overtimeMeetRegularity == true
        ? data.semesterTotalOvertime / 6
        : 0.0;

    final double bonusesAvg   = data.bonusesMeetRegularity == true
        ? data.semesterTotalBonuses / 6
        : 0.0;

    // Ingreso directo del mes de cese — SÍ va al totalizador y a la base AFP/ONP
    final double curMonthOT   = data.currentMonthOvertime;

    // ── RCB (base para gratificación, no es ingreso directo) ─────────────────
    final double rcb = baseSalary + familyAmt + overtimeAvg + bonusesAvg;

    // ═════════════════════════════════════════════════════════════════════════
    // FUNCIÓN 1: Sueldo del Mes de Cese
    //
    //   if (isCurrentMonthSalaryAlreadyPaid) {
    //     return 0.00   ← ya pagado en planilla normal; no se duplica
    //   } else {
    //     return (baseSalary / 30) × diasTrabajadosMesCese
    //   }
    //
    // diasTrabajadosMesCese = 0  cuando endDate < inicioMesCese (caso borde)
    // Si diasTrabajados = 0 y el flag = false → retorna 0.00 de igual forma.
    // ═════════════════════════════════════════════════════════════════════════
    final DateTime inicioMesCese   = DateTime(endDate.year, endDate.month, 1);
    final DateTime desdeMesCese    = startDate.isAfter(inicioMesCese) ? startDate : inicioMesCese;
    final int diasMesCese          = endDate.isBefore(desdeMesCese)
        ? 0
        : endDate.difference(desdeMesCese).inDays + 1;

    final double netPendingSalary = data.isCurrentMonthSalaryAlreadyPaid
        ? 0.0                                   // ← ya pagado; excluir de liquidación
        : (baseSalary / 30) * diasMesCese;      // ← proporcional a los días trabajados

    // ═════════════════════════════════════════════════════════════════════════
    // FUNCIÓN 2: Gratificación Trunca
    //   brutoGrati  = (RCB / 6) × mesesCompletosSemestre
    //   bonoGrati   = brutoGrati × bonoRate  (aplicado de forma independiente)
    //   netGrati    = brutoGrati + bonoGrati
    //
    // "Mes completo" = el trabajador laboró desde el 1° hasta el último día
    // del mes dentro del semestre corriente (Ene-Jun para julio; Jul-Dic para dic).
    // ═════════════════════════════════════════════════════════════════════════
    final DateTime gratPeriodStart = endDate.month <= 6
        ? DateTime(endDate.year, 1, 1)
        : DateTime(endDate.year, 7, 1);
    final DateTime gratCompStart   = startDate.isAfter(gratPeriodStart)
        ? startDate
        : gratPeriodStart;

    final int mesesCompletosGrati = _mesesCompletos(gratCompStart, endDate);

    final double brutoGrati = (rcb / 6) * mesesCompletosGrati;

    final double bonoRate = switch (data.healthInsurance) {
      HealthInsurance.eps || HealthInsurance.both => LegalParameters.kGratBonifEpsRate,
      _ => LegalParameters.kGratBonifEsSaludRate,
    };
    // Bono aplicado de forma independiente (no sobre el total, solo sobre el bruto)
    final double bonoGrati = brutoGrati * bonoRate;
    double netGratification = brutoGrati + bonoGrati;
    if (isMype) netGratification /= 2;

    // ═════════════════════════════════════════════════════════════════════════
    // FUNCIÓN 3: CTS Trunca
    //   Base Computable CTS = baseSalary + (baseSalary / 6) + familyAmt + variablesAvg
    //     └─ El 1/6 representa la gratificación ordinaria (Art. 9, D.Leg. 650)
    //   mesesProporcionales = diasCeseCts / 30  (puede ser fraccionario)
    //   netCTS = (baseComputableCTS / 12) × mesesProporcionales
    //
    // Equivalencia directa:  (baseComputableCTS / 12) × (d/30) = (baseComputableCTS / 360) × d
    // Periodos: May 1–Oct 31 ó Nov 1–Abr 30
    // ═════════════════════════════════════════════════════════════════════════
    final DateTime ctsPeriodStart = (endDate.month >= 5 && endDate.month <= 10)
        ? DateTime(endDate.year, 5, 1)
        : DateTime(endDate.month < 5 ? endDate.year - 1 : endDate.year, 11, 1);
    final DateTime ctsCompStart = startDate.isAfter(ctsPeriodStart)
        ? startDate
        : ctsPeriodStart;

    final int diasCeseCts = endDate.isBefore(ctsCompStart)
        ? 0
        : endDate.difference(ctsCompStart).inDays + 1;

    // Base computable CTS incluye 1/6 de la gratificación ordinaria
    final double baseComputableCTS =
        baseSalary + (baseSalary / 6) + familyAmt + overtimeAvg + bonusesAvg;
    final double mesesPropCTS = diasCeseCts / 30.0;
    double netCtsInLiquidation = (baseComputableCTS / 12) * mesesPropCTS;
    if (isMype) netCtsInLiquidation /= 2;

    // ═════════════════════════════════════════════════════════════════════════
    // FUNCIÓN 4: Vacaciones Truncas
    //   netVacations = (baseSalary / vacDivisor) × mesesEquivalentes
    //
    // Desarrollo de la equivalencia:
    //   diasVacGanados = totalDiasRelacion × tasaVac        (vacaciones acumuladas)
    //   diasVacPorPagar = ceil(max(0, diasVacGanados − diasGozados))
    //
    //   El resultado correcto es: (baseSalary / 30) × diasVacPorPagar
    //   Expresado en notación mensual:
    //     vacDivisor = 12 (general, 30 días vac/año → 1 mes sueldo/año)
    //     vacDivisor = 24 (MYPE,    15 días vac/año → 0.5 mes sueldo/año)
    //
    //   Para que (baseSalary / vacDivisor) × mesesEquivalentes = (baseSalary / 30) × dias:
    //     mesesEquivalentes = diasVacPorPagar × vacDivisor / 30
    //
    //   Ejemplo régimen general: dias=8, vacDivisor=12
    //     mesesEquiv = 8 × 12 / 30 = 3.2
    //     netVac = (1220/12) × 3.2 = 325.33 ✓  = (1220/30) × 8 = 325.33 ✓
    //
    // El ceil protege al trabajador ante fracciones (días parciales).
    // ═════════════════════════════════════════════════════════════════════════
    final int totalDiasRelacion = endDate.difference(startDate).inDays + 1;
    final double tasaVac        = isMype ? (15.0 / 360.0) : (30.0 / 360.0);
    final double diasVacGanados = totalDiasRelacion * tasaVac;

    double diasVacPendientes = hasGozadoVac
        ? diasVacGanados - diasGozados
        : diasVacGanados;
    if (diasVacPendientes < 0) diasVacPendientes = 0;

    final double diasVacPorPagar = diasVacPendientes.ceil().toDouble();
    // vacDivisor define cuántos meses de sueldo corresponden a 1 año de vacaciones:
    //   12 → general (30 días/año = 1 mes sueldo)
    //   24 → MYPE    (15 días/año = 0.5 mes sueldo)
    final double vacDivisor = isMype ? 24.0 : 12.0;
    // mesesEquivalentes calibrado para que la fórmula mensual = la fórmula diaria
    final double mesesEquivalentes = diasVacPorPagar * vacDivisor / 30.0;

    final double netVacations = (baseSalary / vacDivisor) * mesesEquivalentes;
    // Verificación: (baseSalary / vacDivisor) × (diasVacPorPagar × vacDivisor / 30)
    //             = (baseSalary / 30) × diasVacPorPagar  ✓

    // ═════════════════════════════════════════════════════════════════════════
    // FUNCIÓN 5: Retención Pensionaria (AFP / ONP)
    //   Base GRAVADA = sueldo mes cese + HH.EE. mes cese + vacaciones truncas
    //   EXONERADOS:
    //     • Gratificación trunca (Ley 29351 — inafecta indefinidamente)
    //     • CTS trunca           (beneficio social, no remuneración del mes)
    // ═════════════════════════════════════════════════════════════════════════
    final double basePension = netPendingSalary + curMonthOT + netVacations;
    final double pensionDeduction = basePension > 0
        ? _pension(data, basePension).totalRetention
        : 0.0;

    // ═════════════════════════════════════════════════════════════════════════
    // TOTALIZADOR: Suma Lineal Estricta de las Tarjetas de la UI
    //
    //   + Sueldo del mes de cese          (= 0 si diasMesCese = 0)
    //   + HH.EE. del mes de cese          (ingreso directo)
    //   + Gratificación trunca + Bono     (exonerada de pensión)
    //   + CTS trunca                      (beneficio social)
    //   + Vacaciones no gozadas           (gravada con pensión)
    //   − Retención AFP/ONP
    //
    //   baseSalary ordinario completo → EXCLUIDO
    //   semesterTotalOvertime         → EXCLUIDO
    // ═════════════════════════════════════════════════════════════════════════
    final double totalToPay = netPendingSalary
        + curMonthOT
        + netGratification
        + netCtsInLiquidation
        + netVacations
        - pensionDeduction;

    return LiquidationResult(
      netGratification:           netGratification,
      ctsInBank:                  0.0,
      netCtsInLiquidation:        netCtsInLiquidation,
      netVacations:               netVacations,
      netPendingSalary:           netPendingSalary,
      currentMonthOvertimeResult: curMonthOT,
      pensionDeduction:           pensionDeduction,
      totalToPay:                 totalToPay,
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Helper: cuenta los meses calendario COMPLETOS en el rango [compStart, endDate].
  //
  // Un mes se considera "completo" si el trabajador estuvo presente desde el
  // primer día hasta el último día de ese mes dentro del periodo evaluado.
  // ───────────────────────────────────────────────────────────────────────────
  static int _mesesCompletos(DateTime compStart, DateTime endDate) {
    int count = 0;
    DateTime mes = DateTime(compStart.year, compStart.month, 1);
    final mesLimite = DateTime(endDate.year, endDate.month, 1);

    while (!mes.isAfter(mesLimite)) {
      final ultimoDia = DateTime(mes.year, mes.month + 1, 0).day;

      // El trabajador cubre el primer día del mes si:
      //   (a) compStart es anterior al mes, o
      //   (b) compStart es exactamente el día 1 del mes
      final bool cubrePrimerDia = compStart.isBefore(mes) ||
          (compStart.year  == mes.year  &&
           compStart.month == mes.month &&
           compStart.day   == 1);

      // El trabajador cubre el último día si:
      //   (a) endDate es posterior al mes, o
      //   (b) endDate cae en el último día del mes
      final bool cubreUltimoDia =
          endDate.isAfter(DateTime(mes.year, mes.month, ultimoDia)) ||
          (endDate.year  == mes.year  &&
           endDate.month == mes.month &&
           endDate.day   >= ultimoDia);

      if (cubrePrimerDia && cubreUltimoDia) count++;
      mes = DateTime(mes.year, mes.month + 1, 1);
    }
    return count;
  }
}
