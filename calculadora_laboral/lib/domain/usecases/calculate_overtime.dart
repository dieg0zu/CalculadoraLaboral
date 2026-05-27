import '../entities/employee_data.dart';
import '../../core/constants/legal_parameters.dart';

/// Resultado del cálculo de horas extra.
final class OvertimeResult {
  /// Pago por HH.EE con sobretasa 25%
  final double pay25;

  /// Pago por HH.EE con sobretasa 35%
  final double pay35;

  /// Total HH.EE en el mes
  double get total => pay25 + pay35;

  const OvertimeResult({required this.pay25, required this.pay35});
}

/// Calcula el pago por horas extraordinarias.
///
/// Decreto Legislativo 854:
/// - Las primeras 2 horas extra diarias se pagan con sobretasa del 25%
///   sobre el valor hora ordinaria.
/// - Las horas adicionales a las 2 primeras se pagan con sobretasa del 35%.
///
/// Para el MVP se simplifica: el usuario ingresa el total de horas mensuales
/// al 25% y al 35% por separado.
///
/// Valor hora ordinaria = Sueldo Bruto / 30 días / 8 horas
final class CalculateOvertimeUseCase {
  const CalculateOvertimeUseCase();

  OvertimeResult call(EmployeeData data) {
    if (data.grossSalary <= 0) {
      return const OvertimeResult(pay25: 0, pay35: 0);
    }

    // Valor de la hora ordinaria
    final hourlyRate = data.grossSalary /
        LegalParameters.kWorkDaysPerMonth /
        LegalParameters.kWorkHoursPerDay;

    // HH.EE al 25%: valor hora * (1 + sobretasa) * cantidad horas
    final pay25 = hourlyRate *
        (1 + LegalParameters.kOvertimeRate25) *
        data.overtimeHours25;

    // HH.EE al 35%: valor hora * (1 + sobretasa) * cantidad horas
    final pay35 = hourlyRate *
        (1 + LegalParameters.kOvertimeRate35) *
        data.overtimeHours35;

    return OvertimeResult(pay25: pay25, pay35: pay35);
  }
}
