import os

# 1. liquidation_inputs_panel.dart
file_liq = 'lib/presentation/widgets/inputs/liquidation_inputs_panel.dart'
with open(file_liq, 'r', encoding='utf-8') as f:
    content_liq = f.read()

liq_check = '''  void _onCalculatePressed() {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa fechas válidas (DD/MM/YYYY).')),
      );
      return;
    }
    
    if (_endDate!.year < _startDate!.year) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El año de la fecha de fin no puede ser anterior al año de inicio.')),
      );
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La fecha de cese no puede ser anterior a la fecha de inicio.')),
      );
      return;
    }'''

content_liq = content_liq.replace('''  void _onCalculatePressed() {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa fechas válidas (DD/MM/YYYY).')),
      );
      return;
    }''', liq_check)

with open(file_liq, 'w', encoding='utf-8') as f:
    f.write(content_liq)


# 2. cts_inputs_panel.dart
file_cts = 'lib/presentation/widgets/inputs/cts_inputs_panel.dart'
with open(file_cts, 'r', encoding='utf-8') as f:
    content_cts = f.read()

cts_check = '''    if (effectiveEnd.isBefore(effectiveStart)) {
      if (!isCurrentlyWorking && effectiveEnd.year < effectiveStart.year) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El año de la fecha de fin no puede ser anterior al año de inicio.')),
        );
      } else if (!isCurrentlyWorking) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La fecha de fin no puede ser anterior a la fecha de inicio.')),
        );
      }
      notifier.updateWorkedMonths(0);
      notifier.updateWorkedDays(0);
      return;
    }'''

content_cts = content_cts.replace('''    if (effectiveEnd.isBefore(effectiveStart)) {
      notifier.updateWorkedMonths(0);
      notifier.updateWorkedDays(0);
      return;
    }''', cts_check)

with open(file_cts, 'w', encoding='utf-8') as f:
    f.write(content_cts)


# 3. gratification_inputs_panel.dart
file_grat = 'lib/presentation/widgets/inputs/gratification_inputs_panel.dart'
with open(file_grat, 'r', encoding='utf-8') as f:
    content_grat = f.read()

content_grat = content_grat.replace('''    if (effectiveEnd.isBefore(effectiveStart)) {
      notifier.updateWorkedMonths(0);
      notifier.updateWorkedDays(0);
      return;
    }''', cts_check)

with open(file_grat, 'w', encoding='utf-8') as f:
    f.write(content_grat)

print("Done")
