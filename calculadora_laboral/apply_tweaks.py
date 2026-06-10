import os

with open('lib/presentation/providers/liquidation_data_provider.dart', 'r', encoding='utf-8') as f:
    content = f.read()
content = content.replace('super(const EmployeeData(grossSalary: 1025.0));', 'super(const EmployeeData(grossSalary: 0.0));')
with open('lib/presentation/providers/liquidation_data_provider.dart', 'w', encoding='utf-8') as f:
    f.write(content)

with open('lib/domain/entities/employee_data.dart', 'r', encoding='utf-8') as f:
    content = f.read()
content = content.replace('this.hasReceivedLastCts = true,', 'this.hasReceivedLastCts,')
with open('lib/domain/entities/employee_data.dart', 'w', encoding='utf-8') as f:
    f.write(content)

with open('lib/presentation/widgets/inputs/liquidation_inputs_panel.dart', 'r', encoding='utf-8') as f:
    content = f.read()
content = content.replace("prefixText: 'S/ ',", "hintText: 'Ingresa tu sueldo bruto',\n                prefixText: 'S/ ',")
with open('lib/presentation/widgets/inputs/liquidation_inputs_panel.dart', 'w', encoding='utf-8') as f:
    f.write(content)

with open('lib/main.dart', 'r', encoding='utf-8') as f:
    content = f.read()
content = content.replace("'🇵🇪 2025'", "'🇵🇪 2026'")
with open('lib/main.dart', 'w', encoding='utf-8') as f:
    f.write(content)
