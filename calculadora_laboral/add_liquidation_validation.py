import re

file_path = 'lib/presentation/widgets/inputs/liquidation_inputs_panel.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

missing_checks = '''    if (data.regime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona un régimen laboral.')),
      );
      return;
    }
    
    if (data.hasFamilyAllowance == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, indica si tienes hijos (Asignación Familiar).')),
      );
      return;
    }
    
    if (data.hasReceivedLastCts == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, indica si recibiste tu última CTS.')),
      );
      return;
    }
    
    if (data.grossSalary <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa un sueldo bruto válido.')),
      );
      return;
    }'''

content = content.replace('''    if (data.regime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona un régimen laboral.')),
      );
      return;
    }''', missing_checks)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Done")
