import os
import re

files_to_process = [
    'lib/presentation/widgets/inputs/cts_inputs_panel.dart',
    'lib/presentation/widgets/inputs/gratification_inputs_panel.dart',
    'lib/presentation/widgets/inputs/liquidation_inputs_panel.dart',
    'lib/presentation/widgets/inputs/net_salary_inputs_panel.dart'
]

for file_path in files_to_process:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    if 'currency_text_input_formatter' not in content:
        content = content.replace(
            "import 'package:flutter/services.dart';",
            "import 'package:flutter/services.dart';\nimport 'package:currency_text_input_formatter/currency_text_input_formatter.dart';"
        )

    content = content.replace(
        "inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\\d*\\.?\\d*'))],",
        "inputFormatters: [CurrencyTextInputFormatter.currency(locale: 'es', symbol: '')],"
    )

    content = content.replace(
        "double.tryParse(v)",
        "double.tryParse(v.replaceAll('.', '').replaceAll(',', '.'))"
    )

    def repl_initial_value(m):
        var_name = m.group(1)
        return f"initialValue: {var_name} == 0 ? '' : CurrencyTextInputFormatter.currency(locale: 'es', symbol: '').formatDouble({var_name}),"
    
    content = re.sub(r"initialValue:\s*([\w\.]+)\s*==\s*0\s*\?\s*''\s*:\s*[\w\.]+\.toStringAsFixed\(\d+\),", repl_initial_value, content)

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

print('Done')
