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
        epsDeduction:              0,
        otherDeductions:           0,
        totalToPay:                0,
      );
    }

    // ═════════════════════════════════════════════════════════════════════════
    // 1. FIRMA GENÉRICA DEL CONTROLADOR (Variables dinámicas de la UI)
    // ═════════════════════════════════════════════════════════════════════════
    final double sueldoBasico = data.grossSalary;
    final bool tieneAsignacionFamiliar = data.hasFamilyAllowance == true;
    
    int mesesTruncos = data.workedMonths;
    int diasTruncos = data.workedDays;
    
    final DateTime start = data.startDate!;
    final DateTime end = data.endDate!;

    // Si la UI no llenó los inputs manuales, los derivamos de las fechas 
    // de forma comercial estricta para asegurar que tiempoCalculado > 0.
    if (mesesTruncos == 0 && diasTruncos == 0) {
      int startDay = start.day; if (startDay == 31) startDay = 30;
      int endDay = end.day; if (endDay == 31) endDay = 30;
      mesesTruncos = (end.year - start.year) * 12 + (end.month - start.month);
      diasTruncos = endDay - startDay + 1;
      if (diasTruncos < 0) {
        mesesTruncos--;
        diasTruncos += 30;
      }
      if (diasTruncos >= 30) {
        mesesTruncos += diasTruncos ~/ 30;
        diasTruncos = diasTruncos % 30;
      }
    }

    int diasTrabajadosMesCese = 0;
    final DateTime inicioMesCese = DateTime(end.year, end.month, 1);
    final DateTime desdeMesCese = start.isAfter(inicioMesCese) ? start : inicioMesCese;
    if (!end.isBefore(desdeMesCese)) {
      int startMesCeseDay = desdeMesCese.day; if (startMesCeseDay == 31) startMesCeseDay = 30;
      int endMesCeseDay = end.day; if (endMesCeseDay == 31) endMesCeseDay = 30;
      diasTrabajadosMesCese = endMesCeseDay - startMesCeseDay + 1;
      if (diasTrabajadosMesCese > 30) diasTrabajadosMesCese = 30;
    }

    final double horasExtraMes = data.currentMonthOvertime;
    final double promedioHorasExtraPasadas = data.overtimeMeetRegularity == true
        ? (data.semesterTotalOvertime / 6.0)
        : 0.0;
    
    final double bonusesAvg = data.bonusesMeetRegularity == true
        ? (data.semesterTotalBonuses / 6.0)
        : 0.0;

    // ═════════════════════════════════════════════════════════════════════════
    // 2. FACTOR DE TIEMPO COMERCIAL UNIFICADO
    // ═════════════════════════════════════════════════════════════════════════
    final double tiempoCalculado = _calculateTotalMonthsCommercial(mesesTruncos, diasTruncos);

    // ── VARIABLES BASE Y ESTADO ──────────────────────────────────────────────
    final double baseRemunerativa = sueldoBasico + (tieneAsignacionFamiliar ? LegalParameters.kFamilyAllowance : 0.0);
    final bool isMype = data.regime == CompanyRegime.small ||
                        data.regime == CompanyRegime.micro ||
                        data.regime == CompanyRegime.intern;
    final double diasGozados = data.takenVacationDays.toDouble();

    // Sueldo proporcional del mes de cese
    final double netPendingSalary = data.isCurrentMonthSalaryAlreadyPaid
        ? 0.0
        : (baseRemunerativa / 30.0) * diasTrabajadosMesCese;

    // ═════════════════════════════════════════════════════════════════════════
    // 3. PERSISTENCIA DE LAS FÓRMULAS BASE (Truncos independientes)
    // ═════════════════════════════════════════════════════════════════════════
    
    // Gratificación Trunca
    final double baseGratificacion = baseRemunerativa + promedioHorasExtraPasadas + bonusesAvg;
    final double gratBruta = (baseGratificacion / 6.0) * tiempoCalculado;
    final double bonoRate = switch (data.healthInsurance) {
      HealthInsurance.eps || HealthInsurance.both => LegalParameters.kGratBonifEpsRate,
      _ => LegalParameters.kGratBonifEsSaludRate,
    };
    double gratificacionTrunca = gratBruta * (1.0 + bonoRate);
    if (isMype) gratificacionTrunca /= 2;

    // CTS Trunca
    final double baseCts = baseRemunerativa + (baseRemunerativa / 6.0) + promedioHorasExtraPasadas + bonusesAvg;
    double ctsTrunca = (baseCts / 12.0) * tiempoCalculado;
    if (isMype) ctsTrunca /= 2;

    // Vacaciones Truncas
    final double baseVacaciones = baseRemunerativa;
    final double vacDivisor = isMype ? 24.0 : 12.0;
    final double totalVacationsEarned = (baseVacaciones / vacDivisor) * tiempoCalculado;
    final double valorDiasGozados = (baseVacaciones / 30.0) * diasGozados;
    double vacacionesTruncas = totalVacationsEarned - valorDiasGozados;
    if (vacacionesTruncas < 0) vacacionesTruncas = 0.0;

    // ═════════════════════════════════════════════════════════════════════════
    // 4. INTEGRIDAD DEL ESTADO Y LA UI (Totalizador)
    // ═════════════════════════════════════════════════════════════════════════
    final double basePension = netPendingSalary + horasExtraMes + vacacionesTruncas;
    final double pensionDeduction = basePension > 0
        ? _pension(data, basePension).totalRetention
        : 0.0;

    final bool hasEps = data.healthInsurance == HealthInsurance.eps || data.healthInsurance == HealthInsurance.both;
    final double epsDeduction = hasEps ? data.epsCost : 0.0;

    final double otrasDeducciones = data.otherDeductions;

    final double totalToPay = netPendingSalary
        + horasExtraMes
        + gratificacionTrunca
        + ctsTrunca
        + vacacionesTruncas
        - pensionDeduction
        - epsDeduction
        - otrasDeducciones;

    return LiquidationResult(
      netGratification:           gratificacionTrunca,
      ctsInBank:                  0.0,
      netCtsInLiquidation:        ctsTrunca,
      netVacations:               vacacionesTruncas,
      netPendingSalary:           netPendingSalary,
      currentMonthOvertimeResult: horasExtraMes,
      pensionDeduction:           pensionDeduction,
      epsDeduction:               epsDeduction,
      otherDeductions:            otrasDeducciones,
      totalToPay:                 totalToPay,
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Helper: Calcula el tiempo en "meses laborales" exactos.
  // Regla: totalMonths = completMeses + (diasRestantes / 30.0)
  //
  // Un mes laboral siempre se cuenta como 30 días, lo que evita desajustes
  // al dividir por 30 meses con 31 o 28 días.
  // ───────────────────────────────────────────────────────────────────────────
  static double _calculateTotalMonthsCommercial(int mesesCompletos, int diasRestantes) {
    return mesesCompletos + (diasRestantes / 30.0);
  }
}
