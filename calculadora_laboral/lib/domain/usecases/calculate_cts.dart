import '../entities/employee_data.dart';
import '../entities/cts_result.dart';
import '../../core/constants/legal_parameters.dart';
import 'calculate_family_allowance.dart';
import 'calculate_gratification.dart';

/// Calcula la CTS (Compensación por Tiempo de Servicios) semestral.
///
/// DS 001-97-TR (TUO de la Ley de CTS):
///
/// Remuneración computable =
///   Sueldo bruto + Asignación familiar + (1/6 de la gratificación semestral)
///
/// CTS semestral =
///   (Rem. computable / 12) × meses completos
///   + (Rem. computable / 360) × días adicionales
///
/// Nota: Las horas extra son computable solo si son habituales
/// (percibidas en al menos 3 meses del semestre). Para el MVP se
/// excluyen (caso conservador).
final class CalculateCtsUseCase {
  final CalculateFamilyAllowanceUseCase _familyAllowance;
  final CalculateGratificationUseCase _gratification;

  const CalculateCtsUseCase({
    CalculateFamilyAllowanceUseCase? familyAllowance,
    CalculateGratificationUseCase? gratification,
  })  : _familyAllowance =
            familyAllowance ?? const CalculateFamilyAllowanceUseCase(),
        _gratification =
            gratification ?? const CalculateGratificationUseCase();

  CtsResult call(EmployeeData data) {
    final familyAllowance = _familyAllowance(data);
    final gratResult = _gratification(data);

    // Sexto de la gratificación semestral (componente CTS)
    final sixthOfGratification =
        gratResult.baseGratification / LegalParameters.kGratMonthsPerSemester;

    // Remuneración computable CTS
    final computableSalary =
        data.grossSalary + familyAllowance + sixthOfGratification;

    // Meses y días
    final completedMonths =
        data.workedMonths.clamp(0, LegalParameters.kCtsMonthsPerSemester);
    final additionalDays = data.workedDays.clamp(0, 30);

    // CTS por meses completos
    final ctsForMonths = (computableSalary / 12) * completedMonths;

    // CTS por días adicionales
    final ctsForDays =
        (computableSalary / LegalParameters.kCtsDaysPerYear) * additionalDays;

    final totalCts = ctsForMonths + ctsForDays;

    return CtsResult(
      grossSalary: data.grossSalary,
      familyAllowance: familyAllowance,
      sixthOfGratification: sixthOfGratification,
      computableSalary: computableSalary,
      completedMonths: completedMonths,
      additionalDays: additionalDays,
      ctsForMonths: ctsForMonths,
      ctsForDays: ctsForDays,
      totalCts: totalCts,
    );
  }
}
