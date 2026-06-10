import re

files = [
    'lib/presentation/widgets/inputs/liquidation_inputs_panel.dart',
    'lib/presentation/widgets/inputs/net_salary_inputs_panel.dart',
    'lib/presentation/widgets/inputs/cts_inputs_panel.dart',
    'lib/presentation/widgets/inputs/gratification_inputs_panel.dart',
    'lib/presentation/widgets/inputs/inputs_panel.dart'
]

for file in files:
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find and replace double.tryParse(x) or double.tryParse(x) with the replaceAll logic.
    # Be careful not to replace things that are already replaced.
    
    # Simple regex to catch double.tryParse(v) or double.tryParse(val)
    # We will just replace it with double.tryParse(\1.replaceAll('.', '').replaceAll(',', '.'))
    # where \1 is v or val.
    
    content = re.sub(r"double\.tryParse\(([a-zA-Z]+)\)", r"double.tryParse(\1.replaceAll('.', '').replaceAll(',', '.'))", content)
    
    with open(file, 'w', encoding='utf-8') as f:
        f.write(content)

print("Done fixing double.tryParse")
