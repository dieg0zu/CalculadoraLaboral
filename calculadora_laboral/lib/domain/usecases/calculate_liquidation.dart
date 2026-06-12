import '../entities/employee_data.dart';
import '../entities/liquidation_result.dart';
import '../../core/constants/legal_parameters.dart';
import 'calculate_pension_retention.dart';

/// Calcula la liquidación por cese del trabajador.
///
/// Incluye los beneficios truncos al momento del cese y los pendientes:
/// - Gratificación Trunca (y su bono extraordinario)
/// - CTS (informativo en banco + saldo trunco a pagar)
/// - Vacaciones (cálculo histórico)
/// - Sueldo pendiente (del mes de cese)
/// - Bonos pendientes (passthrough)
final class CalculateLiquidationUseCase {
  final CalculatePensionRetentionUseCase _pension;

  const CalculateLiquidationUseCase({
    CalculatePensionRetentionUseCase? pension,
  }) : _pension = pension ?? const CalculatePensionRetentionUseCase();

  LiquidationResult call(EmployeeData data) {
    if (data.startDate == null || data.endDate == null) {
      return LiquidationResult(
        netGratification: 0,
        ctsInBank: 0,
        netCtsInLiquidation: 0,
        netVacations: 0,
        netPendingSalary: 0,
        extraPayments: data.pendingBonuses,
        pensionDeduction: 0,
        totalToPay: data.pendingBonuses,
      );
    }

    final startDate = data.startDate!;
    final endDate = data.endDate!;
    final baseSalary = data.grossSalary;

    final hasFamilyAllocation = data.hasFamilyAllowance == true;
    final familyAllowanceAmount =
        hasFamilyAllocation ? LegalParameters.kFamilyAllowance : 0.0;

    // ── Promedio semestral de variables regulares ──────────────────────────────
    // Sólo entra en la base computable de GRATIFICACIÓN y en el RCB general.
    //
    // «semesterTotalOvertime» = suma de horas extra de los meses ANTERIORES
    // del semestre (excluyendo el mes de cese). El promedio se divide entre 6
    // (duración del semestre completo) independientemente de cuántos meses se
    // trabajaron — criterio de regularidad laboral peruana (Ley 27735).
    //
    // Prueba de escritorio:
    //   hasRegularOvertime=true, historicalOvertimeSum=295.08
    //   → overtimeAverage = 295.08 / 6 = 49.18
    //   → gratComputableBase = 1,220.00 + 49.18 = 1,269.18  ✓
    final bool hasRegularOvertime = data.overtimeMeetRegularity == true;
    final double overtimeAverage =
        hasRegularOvertime ? data.semesterTotalOvertime / 6 : 0.0;

    // Promedio de bonos/comisiones regulares (mismo criterio de regularidad)
    final bool hasRegularBonuses = data.bonusesMeetRegularity == true;
    final double bonusesAverage =
        hasRegularBonuses ? data.semesterTotalBonuses / 6 : 0.0;

    // ── Ingresos directos del mes de cese ────────────────────────────────────
    // «currentMonthOvertime» = horas extra devengadas únicamente en el mes de cese.
    // Se suma como ingreso del mes actual: NO entra en el promedio semestral
    // y, por tanto, NO infla la base de gratificación trunca.
    // Sí entra en la base imponible de AFP/ONP (Paso F).
    //
    // Prueba de escritorio:
    //   currentMonthOvertime=196.02, pendingBonuses=0.0
    //   → extraPayments = 196.02 + 0.0 = 196.02  ✓
    final double extraPayments = data.currentMonthOvertime + data.pendingBonuses;

    final isMype = data.regime == CompanyRegime.small ||
        data.regime == CompanyRegime.micro ||
        data.regime == CompanyRegime.intern;
    final hasGozadoVacaciones = data.hasTakenVacations == true;
    final diasGozadosVacaciones = data.takenVacationDays.toDouble();

    // --- Paso A: Remuneración Computable Base (RCB) para gratificación y CTS ---
    // = sueldo base + asignación familiar + promedios de variables regulares históricas.
    // NO incluye currentMonthOvertime (ese va directamente a extraPayments).
    final double rcb =
        baseSalary + familyAllowanceAmount + overtimeAverage + bonusesAverage;

    // --- Paso B: Gratificación Trunca ---
    int mesesCompletosGrati = 0;
    DateTime gratPeriodStart = endDate.month <= 6 
        ? DateTime(endDate.year, 1, 1) 
        : DateTime(endDate.year, 7, 1);
    DateTime gratCompStart = startDate.isAfter(gratPeriodStart) ? startDate : gratPeriodStart;
    
    // Contar meses calendario completos
    DateTime currentMonth = DateTime(gratCompStart.year, gratCompStart.month, 1);
    final endMonth = DateTime(endDate.year, endDate.month, 1);
    while (!currentMonth.isAfter(endMonth)) {
      final lastDayOfMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
      final isStartValid = gratCompStart.isBefore(currentMonth) || 
                           (gratCompStart.year == currentMonth.year && gratCompStart.month == currentMonth.month && gratCompStart.day == 1);
      final isEndValid = endDate.isAfter(DateTime(currentMonth.year, currentMonth.month, lastDayOfMonth)) || 
                         (endDate.year == currentMonth.year && endDate.month == currentMonth.month && endDate.day == lastDayOfMonth);
      
      if (isStartValid && isEndValid) {
        mesesCompletosGrati++;
      }
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
    }

    double brutoGrati = (rcb / 6) * mesesCompletosGrati;
    // Bonificación extraordinaria Ley 29351: 9% EsSalud o 6.75% EPS
    final double gratiBonoRate = switch (data.healthInsurance) {
      HealthInsurance.eps || HealthInsurance.both =>
        LegalParameters.kGratBonifEpsRate,
      _ => LegalParameters.kGratBonifEsSaludRate,
    };
    double bonoGrati = brutoGrati * gratiBonoRate;
    double netGratification = brutoGrati + bonoGrati;
    if (isMype) netGratification = netGratification / 2;

    // --- Paso C: CTS Trunca (Tramo del semestre en curso) ---
    // Base CTS trunca = baseSalary únicamente (sin variables ni 1/6 de grati).
    // Las variables y el 1/6 aplican al cálculo semestral regular, no al tramo trunco de liquidación.
    // Definir inicio del semestre CTS (Mayo-Octubre o Noviembre-Abril)
    DateTime ctsPeriodStart = endDate.month >= 5 && endDate.month <= 10
        ? DateTime(endDate.year, 5, 1)
        : DateTime(endDate.month < 5 ? endDate.year - 1 : endDate.year, 11, 1);

    DateTime ctsCompStart = startDate.isAfter(ctsPeriodStart) ? startDate : ctsPeriodStart;
    // Días reales del calendario del tramo de cese
    final diasCeseCts = endDate.difference(ctsCompStart).inDays + 1;

    // Base computable CTS trunca: sueldo base exclusivamente (sin 1/6 de grati).
    // El 1/6 aplica al cálculo semestral depositado en banco, no al tramo trunco de liquidación.
    double netCtsInLiquidation = (baseSalary / 360) * diasCeseCts;
    if (isMype) netCtsInLiquidation = netCtsInLiquidation / 2;

    // --- Paso D: Sueldo Pendiente del Mes de Cese ---
    // Días reales trabajados en el mes de cese
    DateTime startOfMonth = DateTime(endDate.year, endDate.month, 1);
    DateTime monthCompStart = startDate.isAfter(startOfMonth) ? startDate : startOfMonth;
    final diasMesReal = endDate.difference(monthCompStart).inDays + 1;

    // Se expone el BRUTO: la retención AFP/ONP es informativa (se descuenta en el recibo
    // del empleador pero no reduce el monto a pagar al trabajador en la liquidación).
    final netPendingSalary = (baseSalary / 30) * diasMesReal;

    // --- Paso E: Pozo Histórico de Vacaciones ---
    // Base vacacional = sueldo base (sin variables ni asignación familiar).
    // Los días ganados se redondean al techo (ceil) para no perjudicar al trabajador.
    // Se expone el BRUTO; la retención pensionaria es informativa.
    final totalDiasReal = endDate.difference(startDate).inDays + 1;
    final tasaVacaciones = isMype ? (15.0 / 360.0) : (30.0 / 360.0);
    final diasGanadosRaw = totalDiasReal * tasaVacaciones;

    double diasPorPagarRaw = diasGanadosRaw;
    if (hasGozadoVacaciones) {
      diasPorPagarRaw = diasGanadosRaw - diasGozadosVacaciones;
    }
    // Ceil: fracción de día se redondea al entero superior; mínimo 0
    final diasPorPagar = diasPorPagarRaw < 0 ? 0.0 : diasPorPagarRaw.ceil().toDouble();

    // Base computable vacacional: sueldo base exclusivamente
    final netVacations = (baseSalary / 30) * diasPorPagar;

    // --- Paso F: Retención Pensionaria Centralizada ---
    // Conceptos GRAVADOS con AFP/ONP: sueldo pendiente + vacaciones + extras del mes.
    // Conceptos EXONERADOS:
    //   - Gratificación trunca (Ley 29351 — inafecta a pensión indefinidamente)
    //   - CTS trunca (beneficio social, no remuneración del mes)
    final double basePension = netPendingSalary + netVacations + extraPayments;
    final double pensionDeduction =
        basePension > 0 ? _pension(data, basePension).totalRetention : 0.0;

    // --- Control de suma y salida ---
    // totalToPay = suma de brutos − retención pensionaria
    final double sumaBrutos =
        netGratification + netCtsInLiquidation + netPendingSalary + netVacations + extraPayments;
    final double totalToPay = sumaBrutos - pensionDeduction;

    return LiquidationResult(
      netGratification: netGratification,
      ctsInBank: 0.0,
      netCtsInLiquidation: netCtsInLiquidation,
      netVacations: netVacations,
      netPendingSalary: netPendingSalary,
      extraPayments: extraPayments,
      pensionDeduction: pensionDeduction,
      totalToPay: totalToPay,
    );
  }
}
