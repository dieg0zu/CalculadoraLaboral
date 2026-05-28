/// Resultado del cálculo de vacaciones anuales.
class VacationResult {
  final double computableSalary;
  final int workedMonths;
  final int workedDays;
  final int totalDaysWorked;
  final double proportionalVacation;
  final double truncatedVacation;

  const VacationResult({
    required this.computableSalary,
    required this.workedMonths,
    required this.workedDays,
    required this.totalDaysWorked,
    required this.proportionalVacation,
    required this.truncatedVacation,
  });
}
