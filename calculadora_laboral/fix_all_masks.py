import os

files_to_update = [
    'lib/presentation/widgets/inputs/cts_inputs_panel.dart',
    'lib/presentation/widgets/inputs/gratification_inputs_panel.dart'
]

for file_path in files_to_update:
    if not os.path.exists(file_path):
        continue
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # The exact string is: inputFormatters: [MaskTextInputFormatter(mask: '##/##/####', filter: { "#": RegExp(r'[0-9]') })],
    # We want to replace the first occurrence with _startDateMaskFormatter and the second with _endDateMaskFormatter
    
    parts = content.split("inputFormatters: [MaskTextInputFormatter(mask: '##/##/####', filter: { \"#\": RegExp(r'[0-9]') })],")
    
    if len(parts) >= 3:
        content = parts[0] + "inputFormatters: [_startDateMaskFormatter]," + parts[1] + "inputFormatters: [_endDateMaskFormatter]," + "inputFormatters: [MaskTextInputFormatter(mask: '##/##/####', filter: { \"#\": RegExp(r'[0-9]') })],".join(parts[2:])
        
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
