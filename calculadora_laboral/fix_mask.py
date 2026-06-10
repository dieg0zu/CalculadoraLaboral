import re
import os

files_to_update = [
    'lib/presentation/widgets/inputs/liquidation_inputs_panel.dart',
    'lib/presentation/widgets/inputs/cts_inputs_panel.dart',
    'lib/presentation/widgets/inputs/gratification_inputs_panel.dart'
]

state_vars_insert = """
  final _startDateMaskFormatter = MaskTextInputFormatter(
    mask: '##/##/####', 
    filter: { "#": RegExp(r'[0-9]') },
    type: MaskAutoCompletionType.lazy
  );
  
  final _endDateMaskFormatter = MaskTextInputFormatter(
    mask: '##/##/####', 
    filter: { "#": RegExp(r'[0-9]') },
    type: MaskAutoCompletionType.lazy
  );
"""

for file_path in files_to_update:
    if not os.path.exists(file_path):
        continue
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Insert formatters if not already there
    if "_startDateMaskFormatter" not in content:
        content = content.replace(
            "final _endDateController = TextEditingController();",
            "final _endDateController = TextEditingController();\n" + state_vars_insert
        )

    # Replace inline formatters in the build method
    # Note: there might be two occurrences, one for start and one for end. We need to distinguish them.
    # Start date usually has _startDateController and _selectStartDate
    
    # We will use regex to find the TextFormField with _startDateController
    pattern_start = r"(controller:\s*_startDateController,.*?)inputFormatters:\s*\[MaskTextInputFormatter\([^\]]+\)\],"
    content = re.sub(pattern_start, r"\1inputFormatters: [_startDateMaskFormatter],", content, flags=re.DOTALL)
    
    # End date usually has _endDateController and _selectEndDate
    pattern_end = r"(controller:\s*_endDateController,.*?)inputFormatters:\s*\[MaskTextInputFormatter\([^\]]+\)\],"
    content = re.sub(pattern_end, r"\1inputFormatters: [_endDateMaskFormatter],", content, flags=re.DOTALL)

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
