import 'package:calculadora_laboral/domain/entities/employee_data.dart';
import 'package:calculadora_laboral/domain/usecases/calculate_liquidation.dart';
import 'package:calculadora_laboral/core/constants/legal_parameters.dart';

void main() {
  final usecase = CalculateLiquidationUseCase();

  // Test 1: Start date 2026-02-02
  final data1 = EmployeeData(
    grossSalary: 1220.0,
    regime: CompanyRegime.general,
    hasFamilyAllowance: false,
    startDate: DateTime(2026, 2, 2),
    endDate: DateTime(2026, 5, 5),
    hasTakenVacations: false,
    takenVacationDays: 0,
    pendingBonuses: 0,
    pensionSystem: PensionSystem.onp,
  );
  final res1 = usecase(data1);

  print("Total To Pay: ${res1.totalToPay}");
  print("Gratification 2026-02-02: ${res1.netGratification}");
  print("CTS: ${res1.netCtsInLiquidation}");
  print("Vacations: ${res1.netVacations}");
  print("Pending Salary: ${res1.netPendingSalary}");
  print("Extra Payments: ${res1.extraPayments}");
}
