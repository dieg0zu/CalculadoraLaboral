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

    // Se eliminaron bonos y horas extra según lo solicitado
    final totalEarnings = data.grossSalary + familyAllowance;

    // ── 2. Deducciones ─────────────────────────────────────────────
    // Si es EPS se resta el monto ingresado ANTES del cálculo neto final
    final epsDeduction = data.healthInsurance == HealthInsurance.eps ? data.epsCost : 0.0;
    
    // Calcula retención de pensión sobre el total
    final pensionDetail = _pension(data, totalEarnings);

    // Si el sueldo bruto supera 3200, calcula 5ta categoría
    final fifthResult = data.grossSalary > 3200 
        ? _fifthCategory(totalEarnings) 
        : const FifthCategoryResult(annualTaxableIncome: 0, annualTax: 0, monthlyRetention: 0, bracketDetails: []);

    final totalDeductions =
        pensionDetail.totalRetention + fifthResult.monthlyRetention + epsDeduction;

    // ── 3. Neto ────────────────────────────────────────────────────
    final netSalary = (totalEarnings - totalDeductions).clamp(0.0, double.infinity);

    // ── 4. Costo empleador ─────────────────────────────────────────
    final double employerHealthCost;
    if (data.healthInsurance == HealthInsurance.sis) {
      employerHealthCost = LegalParameters.kSisFixedCost;
    } else {
      // Tanto para EsSalud regular como EPS, el costo total del empleador sobre la remuneración es 9%.
      // (En EPS: 6.75% va a EsSalud y 2.25% a la EPS)
      employerHealthCost = data.grossSalary * LegalParameters.kEsSaludRate;
    }

    return PayrollResult(
      grossSalary: data.grossSalary,
      familyAllowance: familyAllowance,
      overtimePay25: 0, // Eliminado
      overtimePay35: 0, // Eliminado
      totalEarnings: totalEarnings,
      pensionDetail: pensionDetail,
      fifthCategoryRetention: fifthResult.monthlyRetention,
      totalDeductions: totalDeductions,
      netSalary: netSalary,
      employerHealthCost: employerHealthCost,
    );
  }
}
