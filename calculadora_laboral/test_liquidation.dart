import 'package:calculadora_laboral/domain/entities/employee_data.dart';
import 'package:calculadora_laboral/domain/usecases/calculate_liquidation.dart';
import 'package:calculadora_laboral/core/constants/legal_parameters.dart';

void main() {
  final data = EmployeeData(
    grossSalary: 1025.0,
    regime: CompanyRegime.general,
    hasFamilyAllowance: false,
    startDate: DateTime(2025, 2, 2),
    endDate: DateTime(2026, 6, 11),
    hasTakenVacations: true,
    takenVacationDays: 28,
    pendingBonuses: 683.65,
  );

  final usecase = CalculateLiquidationUseCase();
  final result = usecase(data);

  print("Total To Pay: ${result.totalToPay}");
  print("Gratification: ${result.netGratification}");
  print("CTS: ${result.netCtsInLiquidation}");
  print("Vacations: ${result.netVacations}");
  print("Pending Salary: ${result.netPendingSalary}");
  print("Extra Payments: ${result.extraPayments}");
}
