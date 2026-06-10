import re
# EmployeeDataProvider
provider_path = 'lib/presentation/providers/employee_data_provider.dart'
with open(provider_path, 'r', encoding='utf-8') as f:
    content = f.read()

if 'void updateHasInvalidDates(bool val)' not in content:
    content = content.replace('void updateOvertimeMeetRegularity(bool meet) {', 'void updateHasInvalidDates(bool val) {\n    state = state.copyWith(hasInvalidDates: val);\n  }\n\n  void updateOvertimeMeetRegularity(bool meet) {')

with open(provider_path, 'w', encoding='utf-8') as f:
    f.write(content)

# LiquidationDataNotifier
liq_path = 'lib/presentation/providers/liquidation_data_provider.dart'
with open(liq_path, 'r', encoding='utf-8') as f:
    content = f.read()

if 'void updateHasInvalidDates(bool val)' not in content:
    content = content.replace('void updateOvertimeMeetRegularity(bool meets) {', 'void updateHasInvalidDates(bool val) {\n    state = state.copyWith(hasInvalidDates: val);\n  }\n\n  void updateSemesterTotalBonuses(double amount) {\n    state = state.copyWith(semesterTotalBonuses: amount);\n  }\n\n  void updateSemesterTotalOvertime(double amount) {\n    state = state.copyWith(semesterTotalOvertime: amount);\n  }\n\n  void updateOvertimeMeetRegularity(bool meets) {')

with open(liq_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Done")
