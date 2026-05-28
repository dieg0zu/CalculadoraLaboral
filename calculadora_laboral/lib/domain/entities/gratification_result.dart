import '../../core/constants/legal_parameters.dart';

/// Resultado del cálculo de gratificación semestral.
class GratificationResult {
  final String semester;
  final double computableSalary;
  final int completedMonths;
  final int completedDays;
  final double baseGratification;
  final double gratiForMonths;
  final double gratiForDays;
  final double extraordinaryBonus;
  final double totalGratification;
  final HealthInsurance healthInsurance;

  const GratificationResult({
    required this.semester,
    required this.computableSalary,
    required this.completedMonths,
    required this.completedDays,
    required this.baseGratification,
    required this.gratiForMonths,
    required this.gratiForDays,
    required this.extraordinaryBonus,
    required this.totalGratification,
    this.healthInsurance = HealthInsurance.essalud,
  });
}
