/// Resultado del cálculo de vacaciones anuales.
class VacationResult {
  final double computableSalary;
  final int workedMonths;
  final double proportionalVacation;
  final double truncatedVacation;

  const VacationResult({
    required this.computableSalary,
    required this.workedMonths,
    required this.proportionalVacation,
    required this.truncatedVacation,
  });
}
