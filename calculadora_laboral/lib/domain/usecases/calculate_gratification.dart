import '../entities/employee_data.dart';
import '../entities/gratification_result.dart';
import '../../core/constants/legal_parameters.dart';
import 'calculate_family_allowance.dart';

/// Calcula la gratificación legal semestral.
///
/// Ley 27735 + Ley 29351:
/// - Se pagan DOS gratificaciones al año: julio y diciembre.
/// - Equivale a 1 sueldo completo si se trabajó todo el semestre.
/// - Si se trabajó parcialmente: (remComp / 6) × meses completos.
/// - La bonificación extraordinaria del 9% (EsSalud) o 6.75% (EPS) es
///   pagada por el empleador directamente al trabajador, NO descontable.
/// - Las gratificaciones están exoneradas de aportes pensionarios del trabajador
///   (Ley 29351 vigente hasta 2026 prorrogada indefinidamente).
final class CalculateGratificationUseCase {
  final CalculateFamilyAllowanceUseCase _familyAllowance;

  const CalculateGratificationUseCase({
    CalculateFamilyAllowanceUseCase? familyAllowance,
  }) : _familyAllowance =
            familyAllowance ?? const CalculateFamilyAllowanceUseCase();

  GratificationResult call(EmployeeData data) {
    final familyAllowance = _familyAllowance(data);

    double regularVariablesAvg = 0;
    if (data.overtimeMeetRegularity == true) {
      regularVariablesAvg += data.semesterTotalOvertime / 6;
    }
    
    if (data.bonusesMeetRegularity == true) {
      regularVariablesAvg += data.semesterTotalBonuses / 6;
    }

    // Remuneración computable: sueldo bruto + asignación familiar + promedio variables regulares
    final computableSalary = data.grossSalary + familyAllowance + regularVariablesAvg;

    // Multiplicador por régimen
    final regimeMultiplier = switch (data.regime) {
      CompanyRegime.general => 1.0,
      CompanyRegime.small => 0.5,
      CompanyRegime.micro => 0.0,
      CompanyRegime.intern => 0.0,
      null => 1.0,
    };

    // Semestre de referencia
    final semester = data.currentMonth <= 6 ? 'Julio' : 'Diciembre';

    // Meses completados
    final completedMonths = data.workedMonths;

    // Días completados (Siempre 0 para gratificación, ya que usa meses completos)
    final completedDays = 0;

    // Gratificación base proporcional por régimen
    final gratiForMonths = (computableSalary / LegalParameters.kGratMonthsPerSemester) * completedMonths * regimeMultiplier;
    final gratiForDays = 0.0;
    
    final baseGratification = completedMonths > 0 
        ? gratiForMonths 
        : 0.0;

    // Bonificación extraordinaria Ley 29351
    final double healthBonusRate;
    switch (data.healthInsurance) {
      case HealthInsurance.sis:
        healthBonusRate = 0.0;
      case HealthInsurance.eps:
      case HealthInsurance.both:
        healthBonusRate = LegalParameters.kGratBonifEpsRate;
      case HealthInsurance.essalud:
      case null:
        healthBonusRate = LegalParameters.kGratBonifEsSaludRate;
    }

    final extraordinaryBonus = (baseGratification * healthBonusRate).clamp(0.0, double.infinity);
    final totalGratification = baseGratification + extraordinaryBonus;

    return GratificationResult(
      semester: semester,
      computableSalary: computableSalary,
      completedMonths: completedMonths > 0 ? completedMonths : LegalParameters.kGratMonthsPerSemester,
      completedDays: completedDays,
      baseGratification: baseGratification,
      gratiForMonths: data.workedMonths > 0 ? gratiForMonths : baseGratification,
      gratiForDays: gratiForDays,
      extraordinaryBonus: extraordinaryBonus,
      totalGratification: totalGratification,
      healthInsurance: data.healthInsurance ?? HealthInsurance.essalud,
    );
  }
}
