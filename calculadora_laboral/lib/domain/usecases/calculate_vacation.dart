import '../entities/employee_data.dart';
import '../entities/vacation_result.dart';
import '../../core/constants/legal_parameters.dart';
import 'calculate_family_allowance.dart';

/// Calcula la remuneración vacacional.
///
/// Decreto Legislativo 713:
/// - Por cada año de servicios el trabajador tiene derecho a 30 días de
///   vacaciones pagadas.
/// - La remuneración vacacional equivale al sueldo mensual completo.
/// - Vacaciones proporcionales: si no completó el año, se calcula
///   en función de los meses trabajados.
final class CalculateVacationUseCase {
  final CalculateFamilyAllowanceUseCase _familyAllowance;

  const CalculateVacationUseCase({
    CalculateFamilyAllowanceUseCase? familyAllowance,
  }) : _familyAllowance =
            familyAllowance ?? const CalculateFamilyAllowanceUseCase();

  VacationResult call(EmployeeData data) {
    final familyAllowance = _familyAllowance(data);

    // Valor de ingresos variables regulares (horas extra, comisiones)
    double regularVariablesAvg = 0;
    if (data.variablesMeetRegularity) {
      if (data.overtimeHours25 > 0 || data.overtimeHours35 > 0) {
        final hourlyRate = data.grossSalary / 30 / 8;
        regularVariablesAvg += (data.overtimeHours25 * hourlyRate * 1.25);
        regularVariablesAvg += (data.overtimeHours35 * hourlyRate * 1.35);
      }
      regularVariablesAvg += data.bonuses;
    }

    // Remuneración computable = sueldo bruto + asig. familiar + promedio variables regulares
    final computableSalary = data.grossSalary + familyAllowance + regularVariablesAvg;

    // Meses y días trabajados
    final workedMonths = data.workedMonths.clamp(0, 12);
    final workedDays = data.workedDays.clamp(0, 30);
    final totalDaysWorked = (workedMonths * 30) + workedDays;

    // Multiplicador de régimen para vacaciones
    // General: 1.0 (30 días por año)
    // Small/Micro: 0.5 (15 días por año)
    final regimeMultiplier = (data.regime == CompanyRegime.small || data.regime == CompanyRegime.micro) ? 0.5 : 1.0;

    // Vacaciones proporcionales usando 360 como divisor absoluto
    final proportionalVacation = totalDaysWorked > 0
        ? (computableSalary / 360) * totalDaysWorked * regimeMultiplier
        : (computableSalary * regimeMultiplier); // Asumir 1 año completo si no ingresa tiempo

    final truncatedVacation = proportionalVacation;

    return VacationResult(
      computableSalary: computableSalary,
      workedMonths: workedMonths > 0 ? workedMonths : 12,
      workedDays: workedDays,
      totalDaysWorked: totalDaysWorked > 0 ? totalDaysWorked : 360,
      proportionalVacation: proportionalVacation,
      truncatedVacation: truncatedVacation,
    );
  }
}
