import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/payroll_result.dart';
import '../../domain/entities/gratification_result.dart';
import '../../domain/entities/cts_result.dart';
import '../../domain/entities/vacation_result.dart';
import '../../domain/entities/liquidation_result.dart';
import '../../domain/usecases/calculate_net_salary.dart';
import '../../domain/usecases/calculate_gratification.dart';
import '../../domain/usecases/calculate_cts.dart';
import '../../domain/usecases/calculate_vacation.dart';
import '../../domain/usecases/calculate_liquidation.dart';
import 'employee_data_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Instancias singleton de los casos de uso (stateless, reutilizables)
// ─────────────────────────────────────────────────────────────────────────────

final _netSalaryUseCase = Provider((_) => const CalculateNetSalaryUseCase());
final _gratificationUseCase = Provider((_) => const CalculateGratificationUseCase());
final _ctsUseCase = Provider((_) => const CalculateCtsUseCase());
final _vacationUseCase = Provider((_) => const CalculateVacationUseCase());
final _liquidationUseCase = Provider((_) => const CalculateLiquidationUseCase());

// ─────────────────────────────────────────────────────────────────────────────
// Providers de resultados (computed — se recalculan en tiempo real)
// ─────────────────────────────────────────────────────────────────────────────

/// Resultado mensual completo: neto, ingresos, deducciones.
/// Se recalcula automáticamente cada vez que cambia [employeeDataProvider].
final payrollResultProvider = Provider<PayrollResult>((ref) {
  final data = ref.watch(employeeDataProvider);
  final useCase = ref.watch(_netSalaryUseCase);
  return useCase(data);
});

/// Resultado de gratificación semestral.
final gratificationResultProvider = Provider<GratificationResult>((ref) {
  final data = ref.watch(employeeDataProvider);
  final useCase = ref.watch(_gratificationUseCase);
  return useCase(data);
});

/// Resultado de CTS semestral.
final ctsResultProvider = Provider<CtsResult>((ref) {
  final data = ref.watch(employeeDataProvider);
  final useCase = ref.watch(_ctsUseCase);
  return useCase(data);
});

/// Resultado de vacaciones.
final vacationResultProvider = Provider<VacationResult>((ref) {
  final data = ref.watch(employeeDataProvider);
  final useCase = ref.watch(_vacationUseCase);
  return useCase(data);
});

/// Resultado de liquidación básica por cese.
final liquidationResultProvider = Provider<LiquidationResult>((ref) {
  final data = ref.watch(employeeDataProvider);
  final useCase = ref.watch(_liquidationUseCase);
  return useCase(data);
});
