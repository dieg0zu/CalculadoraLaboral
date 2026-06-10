import re
file_path = 'lib/presentation/screens/vacation_liquidation_result_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace("final result = ref.watch(liquidationResultProvider);", "final result = null;")

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Done")
