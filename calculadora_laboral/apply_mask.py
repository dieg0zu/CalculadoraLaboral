import os

files_to_update = [
    'lib/presentation/widgets/inputs/liquidation_inputs_panel.dart',
    'lib/presentation/widgets/inputs/cts_inputs_panel.dart',
    'lib/presentation/widgets/inputs/gratification_inputs_panel.dart'
]

for file_path in files_to_update:
    if not os.path.exists(file_path):
        continue
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    if "mask_text_input_formatter.dart" not in content:
        content = content.replace("import 'package:flutter/services.dart';", "import 'package:flutter/services.dart';\nimport 'package:mask_text_input_formatter/mask_text_input_formatter.dart';")
        
    old_formatter = "inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9/]'))],"
    new_formatter = "inputFormatters: [MaskTextInputFormatter(mask: '##/##/####', filter: { \"#\": RegExp(r'[0-9]') })],"
    content = content.replace(old_formatter, new_formatter)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
