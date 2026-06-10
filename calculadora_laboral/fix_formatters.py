import os
import re

files = [
    'lib/presentation/widgets/inputs/liquidation_inputs_panel.dart',
    'lib/presentation/widgets/inputs/net_salary_inputs_panel.dart',
    'lib/presentation/widgets/inputs/cts_inputs_panel.dart',
    'lib/presentation/widgets/inputs/gratification_inputs_panel.dart',
    'lib/presentation/widgets/inputs/inputs_panel.dart'
]

for file in files:
    if not os.path.exists(file):
        continue
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Update CurrencyTextInputFormatter
    content = content.replace("CurrencyTextInputFormatter.currency(locale: 'es', symbol: '')", 
                              "CurrencyTextInputFormatter.currency(locale: 'es', symbol: '', decimalDigits: 2)")
    
    # 2. Update Date Masks in liquidation, cts, gratification
    mask_old = r'''mask: '##/##/####', 
    filter: { "#": RegExp(r'[0-9]') },'''
    mask_new = r'''mask: 'dD/mM/yyyy', 
    filter: { 
      "d": RegExp(r'[0-3]'),
      "D": RegExp(r'[0-9]'),
      "m": RegExp(r'[0-1]'),
      "M": RegExp(r'[0-9]'),
      "y": RegExp(r'[0-9]')
    },'''
    content = content.replace(mask_old, mask_new)
    
    # Fix regex filtering for negative numbers (in case)
    # The digitsOnly filter already prevents negative numbers.

    with open(file, 'w', encoding='utf-8') as f:
        f.write(content)

print("Done fixing formatters!")
