import re

file_path = 'lib/domain/entities/employee_data.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

if 'final bool hasInvalidDates;' not in content:
    content = content.replace('final bool? overtimeMeetRegularity;', 'final bool? overtimeMeetRegularity;\n\n  /// Indica si las fechas ingresadas son invalidas\n  final bool hasInvalidDates;')
    content = content.replace('this.overtimeMeetRegularity,', 'this.overtimeMeetRegularity,\n    this.hasInvalidDates = false,')
    content = content.replace('overtimeMeetRegularity: overtimeMeetRegularity ?? this.overtimeMeetRegularity,', 'overtimeMeetRegularity: overtimeMeetRegularity ?? this.overtimeMeetRegularity,\n      hasInvalidDates: hasInvalidDates ?? this.hasInvalidDates,')
    content = content.replace('bool? overtimeMeetRegularity,', 'bool? overtimeMeetRegularity,\n    bool? hasInvalidDates,')

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

provider_path = 'lib/presentation/providers/employee_data_provider.dart'
with open(provider_path, 'r', encoding='utf-8') as f:
    provider_content = f.read()

if 'void updateHasInvalidDates(bool val)' not in provider_content:
    provider_content = provider_content.replace('void updateOvertimeMeetRegularity(bool val) {', 'void updateHasInvalidDates(bool val) {\n    state = state.copyWith(hasInvalidDates: val);\n  }\n\n  void updateOvertimeMeetRegularity(bool val) {')

with open(provider_path, 'w', encoding='utf-8') as f:
    f.write(provider_content)

# Update CTS panel to use hasInvalidDates
cts_path = 'lib/presentation/widgets/inputs/cts_inputs_panel.dart'
with open(cts_path, 'r', encoding='utf-8') as f:
    cts_content = f.read()

cts_content = cts_content.replace('''    if (effectiveEnd.isBefore(effectiveStart)) {
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
    }''', '''    if (effectiveEnd.isBefore(effectiveStart)) {
      notifier.updateHasInvalidDates(true);
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
    } else {
      notifier.updateHasInvalidDates(false);
    }''')

with open(cts_path, 'w', encoding='utf-8') as f:
    f.write(cts_content)

# Update Gratification panel
grat_path = 'lib/presentation/widgets/inputs/gratification_inputs_panel.dart'
with open(grat_path, 'r', encoding='utf-8') as f:
    grat_content = f.read()

grat_content = grat_content.replace('''    if (effectiveEnd.isBefore(effectiveStart)) {
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
    }''', '''    if (effectiveEnd.isBefore(effectiveStart)) {
      notifier.updateHasInvalidDates(true);
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
    } else {
      notifier.updateHasInvalidDates(false);
    }''')

with open(grat_path, 'w', encoding='utf-8') as f:
    f.write(grat_content)

# Update cts_screen.dart and gratification_screen.dart
for screen_path in ['lib/presentation/screens/cts_screen.dart', 'lib/presentation/screens/gratification_screen.dart']:
    with open(screen_path, 'r', encoding='utf-8') as f:
        screen_content = f.read()
    
    screen_content = screen_content.replace('''                if (data.regime == null) {''', '''                if (data.hasInvalidDates || data.workedMonths == 0 && data.workedDays == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, ingresa fechas válidas y asegúrate que no haya errores.')),
                  );
                  return;
                }

                if (data.regime == null) {''')
    
    with open(screen_path, 'w', encoding='utf-8') as f:
        f.write(screen_content)

print("Done")
