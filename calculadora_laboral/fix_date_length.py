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

    # Change val.length >= 8 to val.length == 10
    content = content.replace("if (val.length >= 8)", "if (val.length == 10)")

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
