import re

# Fix liquidation_screen.dart
path_screen = 'lib/presentation/screens/liquidation_screen.dart'
with open(path_screen, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace('calculateLiquidationUseCase.execute(data)', 'calculateLiquidationUseCase(data)')

with open(path_screen, 'w', encoding='utf-8') as f:
    f.write(content)

# Fix liquidation_result_screen.dart
path_res = 'lib/presentation/screens/liquidation_result_screen.dart'
with open(path_res, 'r', encoding='utf-8') as f:
    content = f.read()

if "import '../../domain/entities/liquidation_result.dart';" not in content:
    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport '../../domain/entities/liquidation_result.dart';")

with open(path_res, 'w', encoding='utf-8') as f:
    f.write(content)

print("Done")
