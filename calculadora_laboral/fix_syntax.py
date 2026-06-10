import re

file_path = 'lib/domain/entities/employee_data.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Fix syntax error in EmployeeData
content = content.replace('''      hasInvalidDates: hasInvalidDates ?? this.hasInvalidDates,
    this.hasInvalidDates = false,
      isCurrentlyWorking: isCurrentlyWorking ?? this.isCurrentlyWorking,''', '''      hasInvalidDates: hasInvalidDates ?? this.hasInvalidDates,
      isCurrentlyWorking: isCurrentlyWorking ?? this.isCurrentlyWorking,''')

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

# Fix EmployeeDataProvider
provider_path = 'lib/presentation/providers/employee_data_provider.dart'
with open(provider_path, 'r', encoding='utf-8') as f:
    provider_content = f.read()

if 'void updateHasInvalidDates(bool val)' not in provider_content:
    provider_content = provider_content.replace('void updateOvertimeMeetRegularity(bool meet) {', 'void updateHasInvalidDates(bool val) {\n    state = state.copyWith(hasInvalidDates: val);\n  }\n\n  void updateOvertimeMeetRegularity(bool meet) {')

with open(provider_path, 'w', encoding='utf-8') as f:
    f.write(provider_content)

# Fix vacation_liquidation_result_screen undefined liquidationResultProvider
vac_path = 'lib/presentation/screens/vacation_liquidation_result_screen.dart'
with open(vac_path, 'r', encoding='utf-8') as f:
    vac_content = f.read()

# Since liquidationResultProvider is undefined, let me check what was the original name or just import the provider.
# Actually I might not have broken it, but it might be just `liquidationDataProvider`.
# Let's see what is inside it by using grep or something. We'll leave it for now if we can't guess it.
# Wait! I didn't edit vacation_liquidation_result_screen.dart!
# But let's check its contents.

print("Done")
