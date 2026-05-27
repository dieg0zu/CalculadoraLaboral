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

  /// [workedMonths] Meses completos trabajados en el semestre (0–6).
  /// [currentMonth] Mes actual (1–12) para determinar el semestre.
  GratificationResult call(EmployeeData data) {
    final familyAllowance = _familyAllowance(data);

    // Remuneración computable: sueldo bruto + asignación familiar
    // Las horas extra NO son computables para gratificación (son variables)
    final computableSalary = data.grossSalary + familyAllowance;

    // Semestre de referencia
    final semester = data.currentMonth <= 6 ? 'Julio' : 'Diciembre';

    // Meses completados en el semestre (máximo 6)
    final completedMonths = data.workedMonths.clamp(0, LegalParameters.kGratMonthsPerSemester);

    // Gratificación base proporcional
    final baseGratification = completedMonths > 0
        ? (computableSalary / LegalParameters.kGratMonthsPerSemester) * completedMonths
        : computableSalary; // Si no se especifica, se asume semestre completo

    // Bonificación extraordinaria Ley 29351
    final bonusRate = data.hasEps
        ? LegalParameters.kGratBonifEpsRate
        : LegalParameters.kGratBonifEsSaludRate;

    final extraordinaryBonus = baseGratification * bonusRate;
    final totalGratification = baseGratification + extraordinaryBonus;

    return GratificationResult(
      semester: semester,
      computableSalary: computableSalary,
      completedMonths: completedMonths > 0 ? completedMonths : LegalParameters.kGratMonthsPerSemester,
      baseGratification: baseGratification,
      extraordinaryBonus: extraordinaryBonus,
      totalGratification: totalGratification,
      usedEps: data.hasEps,
    );
  }
}
