import '../entities/employee_data.dart';
import '../entities/vacation_result.dart';
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

    // Remuneración computable = sueldo bruto + asig. familiar
    final computableSalary = data.grossSalary + familyAllowance;

    // Meses trabajados para el cálculo (máximo 12 para año completo)
    final workedMonths = data.workedMonths.clamp(0, 12);

    // Vacaciones anuales completas (12 meses = 1 sueldo completo)
    final proportionalVacation = workedMonths > 0
        ? (computableSalary / 12) * workedMonths
        : computableSalary;

    // Vacaciones truncas = proporcionales al tiempo no gozado
    // (igual a las proporcionales en cálculo de liquidación)
    final truncatedVacation = proportionalVacation;

    return VacationResult(
      computableSalary: computableSalary,
      workedMonths: workedMonths > 0 ? workedMonths : 12,
      proportionalVacation: proportionalVacation,
      truncatedVacation: truncatedVacation,
    );
  }
}
