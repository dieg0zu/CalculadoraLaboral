import '../entities/employee_data.dart';
import '../entities/cts_result.dart';
import '../../core/constants/legal_parameters.dart';
import 'calculate_family_allowance.dart';

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

  const CalculateCtsUseCase({
    CalculateFamilyAllowanceUseCase? familyAllowance,
  })  : _familyAllowance =
            familyAllowance ?? const CalculateFamilyAllowanceUseCase();

  CtsResult call(EmployeeData data) {
    final familyAllowance = _familyAllowance(data);

    // Los bonos y horas extras ya representan la suma total del semestre
    // Se dividen entre 6 para obtener el promedio mensual
    final avgBonuses = data.semesterTotalBonuses / 6;
    final avgOvertime = data.semesterTotalOvertime / 6;
    final regularVariablesAvg = avgBonuses + avgOvertime;

    final ibc = data.grossSalary + familyAllowance + regularVariablesAvg;
    final sixthOfGratification = ibc / 6;
    final computableSalary = ibc + sixthOfGratification;

    final regimeMultiplier = switch (data.regime) {
      CompanyRegime.general => 1.0,
      CompanyRegime.small => 0.5,
      CompanyRegime.micro => 0.0,
      null => 1.0,
    };

    final completedMonths = data.workedMonths.clamp(0, LegalParameters.kCtsMonthsPerSemester);
    final additionalDays = data.workedDays.clamp(0, 30);

    final ctsForMonths = (computableSalary / 12) * completedMonths * regimeMultiplier;
    final ctsForDays = (computableSalary / LegalParameters.kCtsDaysPerYear) * additionalDays * regimeMultiplier;

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
