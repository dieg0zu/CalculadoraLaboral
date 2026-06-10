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

  void updateRegime(CompanyRegime regime) {
    // Si cambia el régimen y no es microempresa, pero el seguro es SIS, lo reseteamos a EsSalud
    HealthInsurance? currentInsurance = state.healthInsurance;
    if (regime != CompanyRegime.micro && currentInsurance == HealthInsurance.sis) {
      currentInsurance = HealthInsurance.essalud;
    }
    
    state = state.copyWith(
      regime: regime,
      healthInsurance: currentInsurance,
    );
  }

  void updateBonuses(double bonuses) {
    state = state.copyWith(bonuses: bonuses.clamp(0, 999999));
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

  void updateHealthInsurance(HealthInsurance insurance) {
    state = state.copyWith(healthInsurance: insurance);
  }

  void updateEpsCost(double cost) {
    state = state.copyWith(epsCost: cost.clamp(0, 999999));
  }

  void updateVariablesMeetRegularity(bool meet) {
    state = state.copyWith(variablesMeetRegularity: meet);
  }

  void updateBonusesMeetRegularity(bool meet) {
    state = state.copyWith(bonusesMeetRegularity: meet);
  }

  void updateHasInvalidDates(bool val) {
    state = state.copyWith(hasInvalidDates: val);
  }

  void updateOvertimeMeetRegularity(bool meet) {
    state = state.copyWith(overtimeMeetRegularity: meet);
  }

  void updateIsCurrentlyWorking(bool working) {
    state = state.copyWith(isCurrentlyWorking: working);
  }

  void updateStartDate(DateTime? date) {
    state = state.copyWith(startDate: date);
  }

  void updateEndDate(DateTime? date) {
    state = state.copyWith(endDate: date);
  }

  void updateCurrentMonth(int month) {
    state = state.copyWith(currentMonth: month.clamp(1, 12));
  }

  void updateSemesterTotalBonuses(double amount) {
    state = state.copyWith(semesterTotalBonuses: amount.clamp(0, 999999));
  }

  void updateSemesterTotalOvertime(double amount) {
    state = state.copyWith(semesterTotalOvertime: amount.clamp(0, 999999));
  }

  void updateHasLastGratification(bool hasIt) {
    state = state.copyWith(hasLastGratification: hasIt);
  }

  void updateLastGratificationAmount(double amount) {
    state = state.copyWith(lastGratificationAmount: amount.clamp(0, 999999));
  }

  /// Resetea todos los campos a sus valores por defecto
  void reset() {
    state = const EmployeeData(grossSalary: 0.0);
  }
}

/// Provider del estado para Sueldo Neto Mensual
final netSalaryDataProvider =
    StateNotifierProvider<EmployeeDataNotifier, EmployeeData>(
  (ref) => EmployeeDataNotifier(),
);

/// Provider global original (usado en Vacaciones/Liquidación)
final employeeDataProvider =
    StateNotifierProvider<EmployeeDataNotifier, EmployeeData>(
  (ref) => EmployeeDataNotifier(),
);

/// Provider independiente del estado para Gratificación
final gratificationDataProvider =
    StateNotifierProvider<EmployeeDataNotifier, EmployeeData>(
  (ref) => EmployeeDataNotifier(),
);

/// Provider independiente del estado para CTS
final ctsDataProvider =
    StateNotifierProvider<EmployeeDataNotifier, EmployeeData>(
  (ref) => EmployeeDataNotifier(),
);