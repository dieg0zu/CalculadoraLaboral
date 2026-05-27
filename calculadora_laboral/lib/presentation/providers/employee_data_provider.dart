import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/employee_data.dart';
import '../../core/constants/legal_parameters.dart';

/// StateNotifier que gestiona el estado del formulario de datos del empleado.
///
/// Es la única fuente de verdad de los inputs de la UI. Todos los providers
/// de cálculo derivan de este estado. Cuando el usuario modifica cualquier
/// campo, Riverpod propaga automáticamente la actualización a toda la cadena.
class EmployeeDataNotifier extends StateNotifier<EmployeeData> {
  EmployeeDataNotifier() : super(const EmployeeData(grossSalary: 0.0));

  void updateGrossSalary(double value) {
    state = state.copyWith(grossSalary: value.clamp(0, 999999));
  }

  void updateFamilyAllowance(bool value) {
    state = state.copyWith(hasFamilyAllowance: value);
  }

  void updatePensionSystem(PensionSystem system) {
    state = state.copyWith(pensionSystem: system);
  }

  void updateAfpType(AfpType afpType) {
    state = state.copyWith(afpType: afpType);
  }

  void updateCommissionType(AfpCommissionType type) {
    state = state.copyWith(commissionType: type);
  }

  void updateOvertimeHours25(int hours) {
    state = state.copyWith(overtimeHours25: hours.clamp(0, 999));
  }

  void updateOvertimeHours35(int hours) {
    state = state.copyWith(overtimeHours35: hours.clamp(0, 999));
  }

  void updateWorkedMonths(int months) {
    state = state.copyWith(workedMonths: months.clamp(0, 12));
  }

  void updateWorkedDays(int days) {
    state = state.copyWith(workedDays: days.clamp(0, 30));
  }

  void updateHasEps(bool value) {
    state = state.copyWith(hasEps: value);
  }

  void updateCurrentMonth(int month) {
    state = state.copyWith(currentMonth: month.clamp(1, 12));
  }

  /// Resetea todos los campos a sus valores por defecto
  void reset() {
    state = const EmployeeData(grossSalary: 0.0);
  }
}

/// Provider global del estado del formulario.
/// Toda la app observa este provider para mantenerse sincronizada.
final employeeDataProvider =
    StateNotifierProvider<EmployeeDataNotifier, EmployeeData>(
  (ref) => EmployeeDataNotifier(),
);
