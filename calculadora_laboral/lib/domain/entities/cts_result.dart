/// Resultado del cálculo de CTS semestral.
class CtsResult {
  final double grossSalary;
  final double familyAllowance;
  final double sixthOfGratification;
  final double computableSalary;
  final int completedMonths;
  final int additionalDays;
  final double ctsForMonths;
  final double ctsForDays;
  final double totalCts;

  const CtsResult({
    required this.grossSalary,
    required this.familyAllowance,
    required this.sixthOfGratification,
    required this.computableSalary,
    required this.completedMonths,
    required this.additionalDays,
    required this.ctsForMonths,
    required this.ctsForDays,
    required this.totalCts,
  });
}
