import re
import os

files = [
    'lib/presentation/widgets/inputs/liquidation_inputs_panel.dart',
    'lib/presentation/widgets/inputs/cts_inputs_panel.dart',
    'lib/presentation/widgets/inputs/gratification_inputs_panel.dart'
]

# 1. Update Dates
for file in files:
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()

    # Add import
    if "date_validation_formatter.dart" not in content:
        content = content.replace("import 'package:intl/intl.dart';", "import 'package:intl/intl.dart';\nimport 'date_validation_formatter.dart';")

    # Replace MaskTextInputFormatter instantiations
    mask_pattern = r"MaskTextInputFormatter\([^)]*\)"
    content = re.sub(mask_pattern, "DateTextFormatter()", content)

    with open(file, 'w', encoding='utf-8') as f:
        f.write(content)

# 2. Update Negative Numbers in Money fields across all input panels
all_files = files + [
    'lib/presentation/widgets/inputs/net_salary_inputs_panel.dart',
    'lib/presentation/widgets/inputs/inputs_panel.dart'
]

for file in all_files:
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # We want to add FilteringTextInputFormatter.deny(RegExp(r'-')), before CurrencyTextInputFormatter
    # Let's find [CurrencyTextInputFormatter.currency
    content = content.replace(
        "[CurrencyTextInputFormatter.currency",
        "[FilteringTextInputFormatter.deny(RegExp(r'-')), CurrencyTextInputFormatter.currency"
    )
    
    # Also for inputs_panel.dart, it uses FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')) for some.
    # It already blocks negative numbers because it starts with \d+ !
    
    with open(file, 'w', encoding='utf-8') as f:
        f.write(content)

print("Done patching dates and negative signs!")
