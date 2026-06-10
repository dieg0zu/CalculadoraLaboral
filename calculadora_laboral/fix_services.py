import os

files = [
    'lib/presentation/widgets/inputs/gratification_inputs_panel.dart',
    'lib/presentation/widgets/inputs/cts_inputs_panel.dart'
]

for file in files:
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()

    if "import 'package:flutter/services.dart';" not in content:
        content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:flutter/services.dart';")

    with open(file, 'w', encoding='utf-8') as f:
        f.write(content)

print("Added services.dart imports")
