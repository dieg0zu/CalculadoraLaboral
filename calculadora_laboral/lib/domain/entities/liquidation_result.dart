/// Resultado del cálculo de liquidación básica por cese.
class LiquidationResult {
  final double truncatedCts;
  final double truncatedVacations;
  final double truncatedGratification;
  final double truncatedExtraBonus;
  final double totalLiquidation;
  final int workedMonths;
  final int workedDays;

  const LiquidationResult({
    required this.truncatedCts,
    required this.truncatedVacations,
    required this.truncatedGratification,
    required this.truncatedExtraBonus,
    required this.totalLiquidation,
    required this.workedMonths,
    required this.workedDays,
  });
}
