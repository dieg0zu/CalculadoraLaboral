import '../entities/employee_data.dart';
import '../entities/payroll_result.dart';
import '../entities/pension_detail.dart';
import '../../core/constants/legal_parameters.dart';
import 'calculate_family_allowance.dart';
import 'calculate_overtime.dart';
import 'calculate_pension_retention.dart';
import 'calculate_fifth_category.dart';

/// Caso de uso principal del motor de cálculo.
///
/// Orquesta todos los sub-casos de uso y produce un [PayrollResult] completo.
/// Este es el único punto de entrada para la capa de presentación.
///
/// Pipeline de transformación:
///   EmployeeData
///     → familyAllowance
///     → overtimeResult
///     → totalEarnings
///     → pensionDetail
///     → fifthCategoryResult
///     → netSalary
///     → PayrollResult
final class CalculateNetSalaryUseCase {
  final CalculateFamilyAllowanceUseCase _familyAllowance;
  final CalculateOvertimeUseCase _overtime;
  final CalculatePensionRetentionUseCase _pension;
  final CalculateFifthCategoryUseCase _fifthCategory;

  const CalculateNetSalaryUseCase({
    CalculateFamilyAllowanceUseCase? familyAllowance,
    CalculateOvertimeUseCase? overtime,
    CalculatePensionRetentionUseCase? pension,
    CalculateFifthCategoryUseCase? fifthCategory,
  })  : _familyAllowance = familyAllowance ?? const CalculateFamilyAllowanceUseCase(),
        _overtime = overtime ?? const CalculateOvertimeUseCase(),
        _pension = pension ?? const CalculatePensionRetentionUseCase(),
        _fifthCategory = fifthCategory ?? const CalculateFifthCategoryUseCase();

  PayrollResult call(EmployeeData data) {
    // ── 1. Ingresos ────────────────────────────────────────────────
    final familyAllowance = _familyAllowance(data);
    final overtimeResult = _overtime(data);

    final totalEarnings = data.grossSalary +
        familyAllowance +
        overtimeResult.pay25 +
        overtimeResult.pay35;

    // ── 2. Deducciones ─────────────────────────────────────────────
    final pensionDetail = _pension(data, totalEarnings);
    final fifthResult = _fifthCategory(totalEarnings);

    final totalDeductions =
        pensionDetail.totalRetention + fifthResult.monthlyRetention;

    // ── 3. Neto ────────────────────────────────────────────────────
    final netSalary = (totalEarnings - totalDeductions).clamp(0.0, double.infinity);

    // ── 4. Costo empleador ─────────────────────────────────────────
    final employerEsSalud = data.grossSalary *
        (data.hasEps ? LegalParameters.kEpsRate : LegalParameters.kEsSaludRate);

    return PayrollResult(
      grossSalary: data.grossSalary,
      familyAllowance: familyAllowance,
      overtimePay25: overtimeResult.pay25,
      overtimePay35: overtimeResult.pay35,
      totalEarnings: totalEarnings,
      pensionDetail: pensionDetail,
      fifthCategoryRetention: fifthResult.monthlyRetention,
      totalDeductions: totalDeductions,
      netSalary: netSalary,
      employerEsSalud: employerEsSalud,
    );
  }
}
