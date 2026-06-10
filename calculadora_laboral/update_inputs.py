import os
import re

directory = r'lib/presentation/widgets/inputs'
for filename in os.listdir(directory):
    if filename.endswith('.dart'):
        filepath = os.path.join(directory, filename)
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            
        original_content = content
        
        # Add import if not present
        if 'package:flutter/services.dart' not in content:
            content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:flutter/services.dart';")
            
        # Add input formatters to TextFormFields that don't have them yet
        if 'FilteringTextInputFormatter' not in content:
            # Replace keyboardType with keyboardType + inputFormatters for number inputs
            content = re.sub(
                r'(keyboardType:\s*(?:const\s*)?TextInputType\.number(?:WithOptions\([^)]*\))?,)',
                r'\1\n              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r\'^\\d*\\.?\\d*\'))],',
                content
            )
            
        if content != original_content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f'Updated {filename}')
