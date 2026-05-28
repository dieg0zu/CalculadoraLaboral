import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/legal_parameters.dart';
import '../../providers/employee_data_provider.dart';

class CtsInputsPanel extends ConsumerStatefulWidget {
  const CtsInputsPanel({super.key});

  @override
  ConsumerState<CtsInputsPanel> createState() => _CtsInputsPanelState();
}

class _CtsInputsPanelState extends ConsumerState<CtsInputsPanel> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _hasBonuses = false;
  bool _hasOvertime = false;

  void _calculateTimeFromDates() {
    if (_startDate == null || _endDate == null) return;
    
    // Si la fecha final es antes que la inicial, la reiniciamos
    if (_endDate!.isBefore(_startDate!)) {
      ref.read(ctsDataProvider.notifier).updateWorkedMonths(0);
      ref.read(ctsDataProvider.notifier).updateWorkedDays(0);
      return;
    }

    int months = 0;
    int days = 0;

    // Lógica comercial peruana (meses de 30 días)
    DateTime current = _startDate!;
    while (current.year < _endDate!.year || 
          (current.year == _endDate!.year && current.month < _endDate!.month)) {
      if (current.day == 1) {
        months++;
        current = DateTime(current.year, current.month + 1, 1);
      } else {
        days += 30 - current.day + 1;
        current = DateTime(current.year, current.month + 1, 1);
      }
    }
    
    if (current.month == _endDate!.month && current.year == _endDate!.year) {
      if (current.day == 1) {
        if (_endDate!.day == 30 || _endDate!.day == 31 || (_endDate!.month == 2 && _endDate!.day >= 28)) {
          months++;
        } else {
          days += _endDate!.day;
        }
      } else {
        int maxDays = 30; // comercial
        int diff = _endDate!.day - current.day + 1;
        days += diff;
      }
    }

    months += days ~/ 30;
    days = days % 30;

    months = months.clamp(0, 6);

    ref.read(ctsDataProvider.notifier).updateWorkedMonths(months);
    ref.read(ctsDataProvider.notifier).updateWorkedDays(days);
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime(2026, 1, 1),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
      helpText: 'Seleccionar Fecha de Inicio',
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
      _calculateTimeFromDates();
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime(2026, 6, 30),
      firstDate: _startDate ?? DateTime(2000),
      lastDate: DateTime(2030),
      helpText: 'Seleccionar Fecha de Fin',
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
      _calculateTimeFromDates();
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(ctsDataProvider);
    final notifier = ref.read(ctsDataProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. RÉGIMEN
          Padding(
            padding: const EdgeInsets.all(20),
            child: DropdownButtonFormField<CompanyRegime>(
              value: data.regime,
              decoration: InputDecoration(
                labelText: 'Régimen de la Empresa',
                prefixIcon: const Icon(Icons.business_rounded, color: Color(0xFF007AFF)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
              items: CompanyRegime.values.map((regime) {
                return DropdownMenuItem(
                  value: regime,
                  child: Text(regime.displayName),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) notifier.updateRegime(val);
              },
            ),
          ),

          if (data.regime != null) const Divider(height: 1),

          // 2. SUELDO BRUTO
          if (data.regime != null)
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextFormField(
                initialValue: data.grossSalary == 0 ? '' : data.grossSalary.toStringAsFixed(0),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Sueldo Bruto Mensual',
                  prefixIcon: const Icon(Icons.attach_money_rounded, color: Color(0xFF007AFF)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onChanged: (v) => notifier.updateGrossSalary(double.tryParse(v) ?? 0),
              ),
            ),

          if (data.grossSalary > 0) ...[
            const Divider(height: 1),

            // 3. FECHAS DE INICIO Y FIN
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _selectStartDate,
                      borderRadius: BorderRadius.circular(16),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Fecha Inicio',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          _startDate == null 
                              ? 'Inicio' 
                              : DateFormat('dd/MM/yy').format(_startDate!),
                          style: TextStyle(
                            color: _startDate == null ? Colors.black54 : Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _selectEndDate,
                      borderRadius: BorderRadius.circular(16),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Fecha Fin',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          _endDate == null 
                              ? 'Fin' 
                              : DateFormat('dd/MM/yy').format(_endDate!),
                          style: TextStyle(
                            color: _endDate == null ? Colors.black54 : Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // 4. BONOS (3 o mas veces)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFF007AFF)),
                      const SizedBox(width: 12),
                      const Expanded(child: Text('¿Recibió bonos 3 o más veces?', style: TextStyle(fontSize: 15))),
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(value: true, label: Text('Sí')),
                          ButtonSegment(value: false, label: Text('No')),
                        ],
                        selected: {_hasBonuses},
                        onSelectionChanged: (set) {
                          setState(() => _hasBonuses = set.first);
                          if (!set.first) notifier.updateSemesterTotalBonuses(0);
                        },
                        showSelectedIcon: false,
                      ),
                    ],
                  ),
                  if (_hasBonuses)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: TextFormField(
                        initialValue: data.semesterTotalBonuses == 0 ? '' : data.semesterTotalBonuses.toStringAsFixed(0),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Suma TOTAL percibida en el semestre',
                          prefixIcon: const Icon(Icons.monetization_on_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onChanged: (v) => notifier.updateSemesterTotalBonuses(double.tryParse(v) ?? 0),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),

            // 5. HORAS EXTRAS (3 o mas veces)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.timer_rounded, color: Color(0xFF007AFF)),
                      const SizedBox(width: 12),
                      const Expanded(child: Text('¿Realizó horas extra 3 o más veces?', style: TextStyle(fontSize: 15))),
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(value: true, label: Text('Sí')),
                          ButtonSegment(value: false, label: Text('No')),
                        ],
                        selected: {_hasOvertime},
                        onSelectionChanged: (set) {
                          setState(() => _hasOvertime = set.first);
                          if (!set.first) notifier.updateSemesterTotalOvertime(0);
                        },
                        showSelectedIcon: false,
                      ),
                    ],
                  ),
                  if (_hasOvertime)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: TextFormField(
                        initialValue: data.semesterTotalOvertime == 0 ? '' : data.semesterTotalOvertime.toStringAsFixed(0),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Monto TOTAL percibido en el semestre',
                          prefixIcon: const Icon(Icons.monetization_on_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onChanged: (v) => notifier.updateSemesterTotalOvertime(double.tryParse(v) ?? 0),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
