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

    // 1. Base Remunerativa General (Sueldo Básico + Asignación Familiar si corresponde)
    final double baseRemunerativa = baseSalary + familyAmt;

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

    // ═════════════════════════════════════════════════════════════════════════
    // FUNCIÓN 1: Sueldo del Mes de Cese
    //
    //   if (isCurrentMonthSalaryAlreadyPaid) {
    //     return 0.00   ← ya pagado en planilla normal; no se duplica
    //   } else {
    //     return (baseRemunerativa / 30) × diasTrabajadosMesCese
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
        ? 0.0                                         // ← ya pagado; excluir de liquidación
        : (baseRemunerativa / 30) * diasMesCese;      // ← proporcional a los días trabajados

    // ═════════════════════════════════════════════════════════════════════════
    // FUNCIÓN 2: Gratificación Trunca
    //   brutoGrati  = ((baseRemunerativa + overtimeAverage) / 6) × mesesTotalesConFraccion
    //   bonoGrati   = brutoGrati × bonoRate  (aplicado de forma independiente)
    //   netGrati    = brutoGrati + bonoGrati
    // ═════════════════════════════════════════════════════════════════════════
    final DateTime gratPeriodStart = endDate.month <= 6
        ? DateTime(endDate.year, 1, 1)
        : DateTime(endDate.year, 7, 1);
    final DateTime gratCompStart   = startDate.isAfter(gratPeriodStart)
        ? startDate
        : gratPeriodStart;

    final int diasGrati = endDate.isBefore(gratCompStart)
        ? 0
        : endDate.difference(gratCompStart).inDays + 1;
    final double mesesTotalesConFraccionGrati = diasGrati / 30.0;

    final double brutoGrati = ((baseRemunerativa + overtimeAvg + bonusesAvg) / 6) * mesesTotalesConFraccionGrati;

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
    //   Base Computable CTS = baseRemunerativa + (baseRemunerativa / 6) + variablesAvg
    //     └─ El 1/6 representa la gratificación ordinaria (Art. 9, D.Leg. 650)
    //   mesesTotalesConFraccion = diasCeseCts / 30
    //   netCTS = (baseComputableCTS / 12) × mesesTotalesConFraccion
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

    // Base computable CTS incluye 1/6 de la gratificación ordinaria y la asignación familiar en baseRemunerativa
    final double baseComputableCTS =
        baseRemunerativa + (baseRemunerativa / 6) + overtimeAvg + bonusesAvg;
    final double mesesTotalesConFraccionCTS = diasCeseCts / 30.0;
    double netCtsInLiquidation = (baseComputableCTS / 12) * mesesTotalesConFraccionCTS;
    if (isMype) netCtsInLiquidation /= 2;

    // ═════════════════════════════════════════════════════════════════════════
    // FUNCIÓN 4: Vacaciones Truncas
    //   netVacations = (baseRemunerativa / vacDivisor) × mesesTotalesConFraccion
    //
    // Desarrollo de la equivalencia:
    //   diasVacGanados = totalDiasRelacion × tasaVac        (vacaciones acumuladas)
    //   diasVacPorPagar = ceil(max(0, diasVacGanados − diasGozados))
    //
    //   El resultado correcto es: (baseRemunerativa / 30) × diasVacPorPagar
    //   Expresado en notación mensual:
    //     vacDivisor = 12 (general, 30 días vac/año → 1 mes sueldo/año)
    //     vacDivisor = 24 (MYPE,    15 días vac/año → 0.5 mes sueldo/año)
    //
    //   Para que (baseRemunerativa / vacDivisor) × mesesTotalesConFraccion = (baseRemunerativa / 30) × dias:
    //     mesesTotalesConFraccion = diasVacPorPagar × vacDivisor / 30
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
    // mesesTotalesConFraccion calibrado para que la fórmula mensual = la fórmula diaria
    final double mesesTotalesConFraccionVac = diasVacPorPagar * vacDivisor / 30.0;

    final double netVacations = (baseRemunerativa / vacDivisor) * mesesTotalesConFraccionVac;
    // Verificación: (baseRemunerativa / vacDivisor) × (diasVacPorPagar × vacDivisor / 30)
    //             = (baseRemunerativa / 30) × diasVacPorPagar  ✓

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
}
