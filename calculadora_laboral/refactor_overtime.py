import re
import os

# 1. Update EmployeeData
file_path = 'lib/domain/entities/employee_data.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

content = re.sub(r'\s*/// Horas extra con sobretasa.*?\n\s*final int overtimeHours25;', '', content)
content = re.sub(r'\s*/// Horas extra con sobretasa.*?\n\s*final int overtimeHours35;', '', content)
content = re.sub(r'\s*/// Bonos regulares y comisiones.*?\n\s*final double bonuses;', '', content)

content = content.replace('this.overtimeHours25 = 0,', '')
content = content.replace('this.overtimeHours35 = 0,', '')
content = content.replace('this.bonuses = 0.0,', '')

content = content.replace('int? overtimeHours25,', '')
content = content.replace('int? overtimeHours35,', '')
content = content.replace('double? bonuses,', '')

content = content.replace('overtimeHours25: overtimeHours25 ?? this.overtimeHours25,', '')
content = content.replace('overtimeHours35: overtimeHours35 ?? this.overtimeHours35,', '')
content = content.replace('bonuses: bonuses ?? this.bonuses,', '')

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

# 2. Update EmployeeDataProvider
provider_path = 'lib/presentation/providers/employee_data_provider.dart'
with open(provider_path, 'r', encoding='utf-8') as f:
    provider_content = f.read()

provider_content = re.sub(r'\s*void updateOvertimeHours\(int hours25, int hours35\) \{.*?\n\s*\}', '', provider_content, flags=re.DOTALL)
provider_content = re.sub(r'\s*void updateBonuses\(double amount\) \{.*?\n\s*\}', '', provider_content, flags=re.DOTALL)

with open(provider_path, 'w', encoding='utf-8') as f:
    f.write(provider_content)

# 3. Update calculate_cts.dart
cts_path = 'lib/domain/usecases/calculate_cts.dart'
with open(cts_path, 'r', encoding='utf-8') as f:
    cts_content = f.read()

cts_content = re.sub(r'if \(data\.overtimeMeetRegularity == true\) \{.*?\}', '''if (data.overtimeMeetRegularity == true) {
      regularVariablesAvg += data.semesterTotalOvertime / 6;
    }''', cts_content, flags=re.DOTALL)

cts_content = re.sub(r'if \(data\.bonusesMeetRegularity == true\) \{.*?\}', '''if (data.bonusesMeetRegularity == true) {
      regularVariablesAvg += data.semesterTotalBonuses / 6;
    }''', cts_content, flags=re.DOTALL)

with open(cts_path, 'w', encoding='utf-8') as f:
    f.write(cts_content)

# 4. Update calculate_gratification.dart
grat_path = 'lib/domain/usecases/calculate_gratification.dart'
with open(grat_path, 'r', encoding='utf-8') as f:
    grat_content = f.read()

grat_content = re.sub(r'if \(data\.overtimeMeetRegularity == true\) \{.*?\}', '''if (data.overtimeMeetRegularity == true) {
      regularVariablesAvg += data.semesterTotalOvertime / 6;
    }''', grat_content, flags=re.DOTALL)

grat_content = re.sub(r'if \(data\.bonusesMeetRegularity == true\) \{.*?\}', '''if (data.bonusesMeetRegularity == true) {
      regularVariablesAvg += data.semesterTotalBonuses / 6;
    }''', grat_content, flags=re.DOTALL)

with open(grat_path, 'w', encoding='utf-8') as f:
    f.write(grat_content)

# 5. Update calculate_liquidation.dart
liq_path = 'lib/domain/usecases/calculate_liquidation.dart'
with open(liq_path, 'r', encoding='utf-8') as f:
    liq_content = f.read()

liq_content = re.sub(r'if \(data\.overtimeMeetRegularity == true\) \{.*?\}', '''if (data.overtimeMeetRegularity == true) {
      regularVariablesAvg += data.semesterTotalOvertime / 6;
    }''', liq_content, flags=re.DOTALL)

liq_content = re.sub(r'if \(data\.bonusesMeetRegularity == true\) \{.*?\}', '''if (data.bonusesMeetRegularity == true) {
      regularVariablesAvg += data.semesterTotalBonuses / 6;
    }''', liq_content, flags=re.DOTALL)

with open(liq_path, 'w', encoding='utf-8') as f:
    f.write(liq_content)

# 6. Update UI Panels
panels = [
    'lib/presentation/widgets/inputs/cts_inputs_panel.dart',
    'lib/presentation/widgets/inputs/gratification_inputs_panel.dart',
    'lib/presentation/widgets/inputs/liquidation_inputs_panel.dart',
]

ui_overtime_replace = '''Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: data.semesterTotalOvertime == 0 ? '' : CurrencyTextInputFormatter.currency(locale: 'es', symbol: '').formatDouble(data.semesterTotalOvertime),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [CurrencyTextInputFormatter.currency(locale: 'es', symbol: '')],
                      style: const TextStyle(fontSize: 16, color: textDark),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Monto total en el semestre (S/)',
                        prefixText: 'S/ ',
                        prefixStyle: const TextStyle(color: textDark, fontSize: 16),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryBlue, width: 1.5)),
                      ),
                      onChanged: (v) => notifier.updateSemesterTotalOvertime(double.tryParse(v.replaceAll('.', '').replaceAll(',', '.')) ?? 0),
                    ),
                  ),
                ],
              )'''

ui_bonuses_replace = '''TextFormField(
                initialValue: data.semesterTotalBonuses == 0 ? '' : CurrencyTextInputFormatter.currency(locale: 'es', symbol: '').formatDouble(data.semesterTotalBonuses),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [CurrencyTextInputFormatter.currency(locale: 'es', symbol: '')],
                style: const TextStyle(fontSize: 16, color: textDark),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Monto total en el semestre (S/)',
                  prefixText: 'S/ ',
                  prefixStyle: const TextStyle(color: textDark, fontSize: 16),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryBlue, width: 1.5)),
                ),
                onChanged: (v) => notifier.updateSemesterTotalBonuses(double.tryParse(v.replaceAll('.', '').replaceAll(',', '.')) ?? 0),
              )'''

for panel in panels:
    with open(panel, 'r', encoding='utf-8') as f:
        panel_content = f.read()
    
    # Overtime replacement
    panel_content = re.sub(r"notifier\.updateOvertimeHours\(0, 0\);", "notifier.updateSemesterTotalOvertime(0);", panel_content)
    panel_content = re.sub(r"Row\(\s*children: \[\s*Expanded\(\s*child: TextFormField\(\s*initialValue: data\.overtimeHours25.*?\]\s*,\s*\)\s*,\s*const SizedBox\(width: 12\),\s*Expanded\(\s*child: TextFormField\(\s*initialValue: data\.overtimeHours35.*?\)\s*,\s*\)\s*,\s*\]\s*,\s*\)", ui_overtime_replace, panel_content, flags=re.DOTALL)
    
    # Bonuses replacement
    panel_content = re.sub(r"notifier\.updateBonuses\(0\);", "notifier.updateSemesterTotalBonuses(0);", panel_content)
    panel_content = re.sub(r"TextFormField\(\s*initialValue: data\.bonuses.*?onChanged: \(v\) => notifier\.updateBonuses.*?\)", ui_bonuses_replace, panel_content, flags=re.DOTALL)
    
    with open(panel, 'w', encoding='utf-8') as f:
        f.write(panel_content)

print("Done")
