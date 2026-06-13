import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/employee_data.dart';
import '../../core/constants/legal_parameters.dart';

class LiquidationDataNotifier extends StateNotifier<EmployeeData> {
  LiquidationDataNotifier() : super(const EmployeeData(grossSalary: 0.0));

  void updateGrossSalary(double salary) {
    state = state.copyWith(grossSalary: salary);
  }

  void updateHasFamilyAllowance(bool hasAllowance) {
    state = state.copyWith(hasFamilyAllowance: hasAllowance);
  }

  void updateStartDate(DateTime? date) {
    state = state.copyWith(startDate: date);
  }

  void updateEndDate(DateTime? date) {
    state = state.copyWith(endDate: date);
  }

  void updateHasTakenVacations(bool hasTaken) {
    state = state.copyWith(hasTakenVacations: hasTaken);
  }

  void updateTakenVacationDays(int days) {
    state = state.copyWith(takenVacationDays: days);
  }

  void updateRegime(CompanyRegime regime) {
    state = state.copyWith(regime: regime);
  }

  void updatePensionSystem(PensionSystem? system) {
    state = state.copyWith(
      pensionSystem: system,
      clearPensionSystem: system == null,
    );
  }

  void updateAfpType(AfpType? type) {
    state = state.copyWith(
      afpType: type,
      clearAfpType: type == null,
    );
  }

  void updateCommissionType(AfpCommissionType? type) {
    state = state.copyWith(
      commissionType: type,
      clearCommissionType: type == null,
    );
  }

  void updateHealthInsurance(HealthInsurance? insurance) {
    state = state.copyWith(healthInsurance: insurance);
  }

  void updateBonusesMeetRegularity(bool meets) {
    state = state.copyWith(bonusesMeetRegularity: meets);
  }

  void updateHasInvalidDates(bool val) {
    state = state.copyWith(hasInvalidDates: val);
  }

  void updateSemesterTotalBonuses(double amount) {
    state = state.copyWith(semesterTotalBonuses: amount);
  }

  void updateSemesterTotalOvertime(double amount) {
    state = state.copyWith(semesterTotalOvertime: amount);
  }

  void updateCurrentMonthOvertime(double amount) {
    state = state.copyWith(currentMonthOvertime: amount);
  }

  void updateOvertimeMeetRegularity(bool meets) {
    state = state.copyWith(overtimeMeetRegularity: meets);
  }

  void updateBonuses(double bonuses) {
    state = state.copyWith(bonuses: bonuses);
  }

  void updateOvertimeHours(int hours25, int hours35) {
    state = state.copyWith(
      overtimeHours25: hours25,
      overtimeHours35: hours35,
    );
  }

  void updatePendingBonuses(double amount) {
    state = state.copyWith(pendingBonuses: amount);
  }

  void updateIsCurrentMonthSalaryAlreadyPaid(bool alreadyPaid) {
    state = state.copyWith(isCurrentMonthSalaryAlreadyPaid: alreadyPaid);
  }
}

final liquidationDataProvider = StateNotifierProvider<LiquidationDataNotifier, EmployeeData>((ref) {
  return LiquidationDataNotifier();
});
