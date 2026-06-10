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

    double regularVariablesAvg = 0;
    if (data.overtimeMeetRegularity == true) {
      regularVariablesAvg += data.semesterTotalOvertime / 6;
    }
    
    if (data.bonusesMeetRegularity == true) {
      regularVariablesAvg += data.semesterTotalBonuses / 6;
    }

    // El 1/6 de gratificación
    double sixthOfGratification = 0.0;
    if (data.hasLastGratification == true) {
      sixthOfGratification = data.lastGratificationAmount / 6;
    }
    
    final computableSalary = data.grossSalary + familyAllowance + regularVariablesAvg + sixthOfGratification;

    final regimeMultiplier = switch (data.regime) {
      CompanyRegime.general => 1.0,
      CompanyRegime.small => 0.5,
      CompanyRegime.micro => 0.0,
      CompanyRegime.intern => 0.0,
      null => 1.0,
    };

    final completedMonths = data.workedMonths;
    final additionalDays = data.workedDays;

    final bool trabajoSemestreCompleto = completedMonths >= 6;

    double totalCts = 0.0;
    double ctsForMonths = 0.0;
    double ctsForDays = 0.0;

    if (trabajoSemestreCompleto) {
      // Fórmula simplificada
      totalCts = (computableSalary / 2) * regimeMultiplier;
      ctsForMonths = totalCts;
    } else {
      // Fórmula proporcional
      final totalDays = (completedMonths * 30) + additionalDays;
      totalCts = (computableSalary / 360) * totalDays * regimeMultiplier;
      
      // Para mostrar el desglose (aunque el total se calcula proporcional)
      ctsForMonths = (computableSalary / 12) * completedMonths * regimeMultiplier;
      ctsForDays = (computableSalary / 360) * additionalDays * regimeMultiplier;
    }

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
