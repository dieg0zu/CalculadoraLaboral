/// Resultado del cálculo de gratificación semestral.
class GratificationResult {
  final String semester;
  final double computableSalary;
  final int completedMonths;
  final double baseGratification;
  final double extraordinaryBonus;
  final double totalGratification;
  final bool usedEps;

  const GratificationResult({
    required this.semester,
    required this.computableSalary,
    required this.completedMonths,
    required this.baseGratification,
    required this.extraordinaryBonus,
    required this.totalGratification,
    this.usedEps = false,
  });
}
