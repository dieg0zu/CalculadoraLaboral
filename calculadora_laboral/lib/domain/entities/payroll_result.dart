import 'pension_detail.dart';

/// Output completo del motor de cálculo mensual.
///
/// Representa la "boleta de pago" desagregada en ingresos y deducciones.
class PayrollResult {
  // ── Ingresos ───────────────────────────────────────────────────────
  final double grossSalary;
  final double familyAllowance;
  final double overtimePay25;
  final double overtimePay35;
  final double totalEarnings;

  // ── Deducciones ────────────────────────────────────────────────────
  final PensionDetail pensionDetail;
  final double fifthCategoryRetention;
  final double totalDeductions;

  // ── Resultado ──────────────────────────────────────────────────────
  final double netSalary;

  // ── Costos del empleador ───────────────────────────────────────────
  final double employerHealthCost;

  const PayrollResult({
    required this.grossSalary,
    required this.familyAllowance,
    required this.overtimePay25,
    required this.overtimePay35,
    required this.totalEarnings,
    required this.pensionDetail,
    required this.fifthCategoryRetention,
    required this.totalDeductions,
    required this.netSalary,
    required this.employerHealthCost,
  });
}
