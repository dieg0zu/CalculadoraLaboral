import re

with open('lib/presentation/widgets/inputs/cts_inputs_panel.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Add controllers and dispose
state_vars = """
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }
  
  void _parseManualDate(String val, bool isStart) {
    try {
      if (val.length >= 8) {
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
"""

if "_startDateController" not in content:
    content = content.replace("  DateTime? _endDate;", "  DateTime? _endDate;\n" + state_vars)

# Update showDatePicker to have locale
content = content.replace("helpText: 'Seleccionar Fecha de Inicio',", "helpText: 'Seleccionar Fecha de Inicio',\n      locale: const Locale('es', 'ES'),")
content = content.replace("helpText: 'Seleccionar Fecha de Fin',", "helpText: 'Seleccionar Fecha de Fin',\n      locale: const Locale('es', 'ES'),")

# Update setState for dates
content = content.replace("_startDate = picked;", "_startDate = picked;\n        _startDateController.text = DateFormat('dd/MM/yyyy').format(picked);")
content = content.replace("_endDate = picked;", "_endDate = picked;\n        _endDateController.text = DateFormat('dd/MM/yyyy').format(picked);")

# Update InkWell for Start Date
start_date_old = """              InkWell(
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
              ),"""

start_date_new = """              TextFormField(
                controller: _startDateController,
                keyboardType: TextInputType.datetime,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9/]'))],
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
              ),"""

content = content.replace(start_date_old, start_date_new)

# Update InkWell for End Date
end_date_old = """                InkWell(
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
                ),"""

end_date_new = """                TextFormField(
                  controller: _endDateController,
                  keyboardType: TextInputType.datetime,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9/]'))],
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
                ),"""

content = content.replace(end_date_old, end_date_new)

with open('lib/presentation/widgets/inputs/cts_inputs_panel.dart', 'w', encoding='utf-8') as f:
    f.write(content)
