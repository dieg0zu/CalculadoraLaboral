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

  /// [isTruncated] Si es true, representa gratificación trunca (descarta días).
  GratificationResult call(EmployeeData data, {bool isTruncated = false}) {
    final familyAllowance = _familyAllowance(data);

    // Valor de ingresos variables regulares (horas extra, comisiones)
    // Según MTPE, solo se computan si se percibieron al menos 3 veces en el semestre
    double regularVariablesAvg = 0;
    if (data.variablesMeetRegularity) {
      if (data.overtimeHours25 > 0 || data.overtimeHours35 > 0) {
        final hourlyRate = data.grossSalary / 30 / 8;
        regularVariablesAvg += (data.overtimeHours25 * hourlyRate * 1.25);
        regularVariablesAvg += (data.overtimeHours35 * hourlyRate * 1.35);
      }
      regularVariablesAvg += data.bonuses;
    }

    // Remuneración computable: sueldo bruto + asignación familiar + promedio variables regulares
    final computableSalary = data.grossSalary + familyAllowance + regularVariablesAvg;

    // Multiplicador por régimen
    final regimeMultiplier = switch (data.regime) {
      CompanyRegime.general => 1.0,
      CompanyRegime.small => 0.5,
      CompanyRegime.micro => 0.0,
      null => 1.0,
    };

    // Semestre de referencia
    final semester = data.currentMonth <= 6 ? 'Julio' : 'Diciembre';

    // Meses completados en el semestre (máximo 6)
    final completedMonths = data.workedMonths.clamp(0, LegalParameters.kGratMonthsPerSemester);

    // Días completados (descartados si es trunca)
    final completedDays = isTruncated ? 0 : data.workedDays.clamp(0, 30);

    // Gratificación base proporcional por régimen
    final gratiForMonths = (computableSalary / LegalParameters.kGratMonthsPerSemester) * completedMonths * regimeMultiplier;
    final gratiForDays = (computableSalary / (LegalParameters.kGratMonthsPerSemester * 30)) * completedDays * regimeMultiplier;
    
    // Si no se especifica tiempo, se asume semestre completo
    final baseGratification = (data.workedMonths > 0 || data.workedDays > 0) 
        ? (gratiForMonths + gratiForDays)
        : (computableSalary * regimeMultiplier);

    // Bonificación extraordinaria Ley 29351
    final double healthBonusRate;
    switch (data.healthInsurance) {
      case HealthInsurance.sis:
        healthBonusRate = 0.0;
      case HealthInsurance.eps:
        healthBonusRate = LegalParameters.kGratBonifEpsRate;
      case HealthInsurance.essalud:
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
      healthInsurance: data.healthInsurance,
    );
  }
}
