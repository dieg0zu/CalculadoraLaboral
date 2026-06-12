import 'package:calculadora_laboral/domain/entities/employee_data.dart';
import 'package:calculadora_laboral/domain/usecases/calculate_liquidation.dart';
import 'package:calculadora_laboral/core/constants/legal_parameters.dart';

void main() {
  final usecase = CalculateLiquidationUseCase();

  // Test A: 2025-02-02 to 2026-03-05
  final dataA = EmployeeData(
    grossSalary: 1220.0,
    regime: CompanyRegime.general,
    hasFamilyAllowance: false,
    startDate: DateTime(2025, 2, 2),
    endDate: DateTime(2026, 3, 5),
    hasTakenVacations: false,
    takenVacationDays: 0,
    pendingBonuses: 0,
    pensionSystem: PensionSystem.onp,
  );
  
  // Test B: 2026-02-02 to 2026-03-05
  final dataB = EmployeeData(
    grossSalary: 1220.0,
    regime: CompanyRegime.general,
    hasFamilyAllowance: false,
    startDate: DateTime(2026, 2, 2),
    endDate: DateTime(2026, 3, 5),
    hasTakenVacations: false,
    takenVacationDays: 0,
    pendingBonuses: 0,
    pensionSystem: PensionSystem.onp,
  );

  final resA = usecase(dataA);
  final resB = usecase(dataB);

  print("Test A (2025-02-02 to 2026-03-05) Grati: ${resA.netGratification}");
  print("Test B (2026-02-02 to 2026-03-05) Grati: ${resB.netGratification}");
}
