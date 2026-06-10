import re

files_with_dates = [
    'lib/presentation/widgets/inputs/cts_inputs_panel.dart',
    'lib/presentation/widgets/inputs/gratification_inputs_panel.dart'
]

# 1. ADD MASK FORMATTER IMPORT AND STATE VARIABLES
mask_import = "import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';\n"

for file in files_with_dates:
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()

    if "package:mask_text_input_formatter" not in content:
        content = content.replace("import 'package:intl/intl.dart';", "import 'package:intl/intl.dart';\n" + mask_import)

    state_vars_old = '''  DateTime? _startDate;
  DateTime? _endDate;'''
    
    state_vars_new = '''  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  final _dateMaskFormatter = MaskTextInputFormatter(
    mask: 'dD/mM/yyyy', 
    filter: { 
      "d": RegExp(r'[0-3]'),
      "D": RegExp(r'[0-9]'),
      "m": RegExp(r'[0-1]'),
      "M": RegExp(r'[0-9]'),
      "y": RegExp(r'[0-9]')
    },
    type: MaskAutoCompletionType.lazy
  );

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  void _parseManualDate(String val, bool isStart) {
    try {
      if (val.length == 10) {
        final parts = val.split('/');
        if (parts.length == 3) {
          int d = int.parse(parts[0]);
          int m = int.parse(parts[1]);
          int y = int.parse(parts[2]);
          if (y < 100) y += 2000;
          final date = DateTime(y, m, d);
          setState(() {
            if (isStart) _startDate = date;
            else _endDate = date;
          });
          _calculateTimeFromDates();
        }
      }
    } catch (_) {}
  }
'''
    if "_dateMaskFormatter" not in content:
        content = content.replace(state_vars_old, state_vars_new)

    # Replace setState for picked dates
    set_start_old = '''setState(() {
        _startDate = picked;
      });'''
    set_start_new = '''setState(() {
        _startDate = picked;
        _startDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });'''
    content = content.replace(set_start_old, set_start_new)

    set_end_old = '''setState(() {
        _endDate = picked;
      });'''
    set_end_new = '''setState(() {
        _endDate = picked;
        _endDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });'''
    content = content.replace(set_end_old, set_end_new)

    # Replace InkWell with TextFormField for Start Date
    inkwell_start_old = '''InkWell(
                onTap: _selectStartDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _startDate == null ? 'Seleccionar' : DateFormat('dd/MM/yyyy').format(_startDate!),
                        style: TextStyle(color: _startDate == null ? const Color(0xFF64748B) : textDark, fontSize: 14),
                      ),
                      const Icon(Icons.calendar_today_rounded, color: Color(0xFF64748B), size: 20),
                    ],
                  ),
                ),
              )'''
    
    inkwell_start_new = '''TextFormField(
                controller: _startDateController,
                keyboardType: TextInputType.datetime,
                inputFormatters: [_dateMaskFormatter],
                style: const TextStyle(fontSize: 16, color: textDark),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'DD/MM/YYYY',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today_rounded, color: Color(0xFF64748B), size: 20),
                    onPressed: _selectStartDate,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryBlue, width: 1.5)),
                ),
                onChanged: (val) => _parseManualDate(val, true),
              )'''
    content = content.replace(inkwell_start_old, inkwell_start_new)

    # Replace InkWell with TextFormField for End Date
    inkwell_end_old = '''InkWell(
                onTap: _selectEndDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _endDate == null ? 'Seleccionar' : DateFormat('dd/MM/yyyy').format(_endDate!),
                        style: TextStyle(color: _endDate == null ? const Color(0xFF64748B) : textDark, fontSize: 14),
                      ),
                      const Icon(Icons.calendar_today_rounded, color: Color(0xFF64748B), size: 20),
                    ],
                  ),
                ),
              )'''

    inkwell_end_new = '''TextFormField(
                controller: _endDateController,
                keyboardType: TextInputType.datetime,
                inputFormatters: [_dateMaskFormatter],
                style: const TextStyle(fontSize: 16, color: textDark),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'DD/MM/YYYY',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today_rounded, color: Color(0xFF64748B), size: 20),
                    onPressed: _selectEndDate,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryBlue, width: 1.5)),
                ),
                onChanged: (val) => _parseManualDate(val, false),
              )'''
    content = content.replace(inkwell_end_old, inkwell_end_new)

    # Fix grossSalary formatter
    gross_salary_old = '''initialValue: data.grossSalary == 0 ? '' : data.grossSalary.toStringAsFixed(0),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontSize: 16, color: textDark),'''
    
    gross_salary_new = '''initialValue: data.grossSalary == 0 ? '' : CurrencyTextInputFormatter.currency(locale: 'es', symbol: '', decimalDigits: 2).formatDouble(data.grossSalary),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [CurrencyTextInputFormatter.currency(locale: 'es', symbol: '', decimalDigits: 2)],
                style: const TextStyle(fontSize: 16, color: textDark),'''
    content = content.replace(gross_salary_old, gross_salary_new)

    # Fix onChanged for grossSalary to remove commas and dots properly
    onchange_old = '''onChanged: (v) => notifier.updateGrossSalary(double.tryParse(v) ?? 0),'''
    onchange_new = '''onChanged: (v) => notifier.updateGrossSalary(double.tryParse(v.replaceAll('.', '').replaceAll(',', '.')) ?? 0),'''
    content = content.replace(onchange_old, onchange_new)

    with open(file, 'w', encoding='utf-8') as f:
        f.write(content)

print("Done updating dates and gross salary in CTS and Gratification")
