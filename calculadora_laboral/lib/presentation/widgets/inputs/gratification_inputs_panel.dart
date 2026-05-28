import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/legal_parameters.dart';
import '../../providers/employee_data_provider.dart';

class GratificationInputsPanel extends ConsumerStatefulWidget {
  const GratificationInputsPanel({super.key});

  @override
  ConsumerState<GratificationInputsPanel> createState() => _GratificationInputsPanelState();
}

class _GratificationInputsPanelState extends ConsumerState<GratificationInputsPanel> {
  DateTime? _startDate;
  bool _hasBonuses = false;
  bool _hasOvertime = false;

  void _calculateTimeFromDate(DateTime date) {
    // Calculamos hasta el 30 de Junio del año de la fecha seleccionada o actual
    final targetYear = date.year < 2026 ? 2026 : date.year;
    final startOfSemester = DateTime(targetYear, 1, 1);
    final endOfSemester = DateTime(targetYear, 6, 30);

    final effectiveStart = date.isBefore(startOfSemester) ? startOfSemester : date;
    
    if (effectiveStart.isAfter(endOfSemester)) {
      ref.read(gratificationDataProvider.notifier).updateWorkedMonths(0);
      ref.read(gratificationDataProvider.notifier).updateWorkedDays(0);
      return;
    }

    int months = 0;
    int days = 0;

    // Lógica simplificada comercial peruana (meses de 30 días)
    DateTime current = effectiveStart;
    while (current.year < endOfSemester.year || 
          (current.year == endOfSemester.year && current.month < endOfSemester.month)) {
      // Si empieza el día 1, cuenta como mes completo
      if (current.day == 1) {
        months++;
        current = DateTime(current.year, current.month + 1, 1);
      } else {
        // Fracción del primer mes
        days += 30 - current.day + 1;
        current = DateTime(current.year, current.month + 1, 1);
      }
    }
    
    if (current.month == endOfSemester.month && current.year == endOfSemester.year) {
      if (current.day == 1) {
        months++;
      } else {
        days += 30 - current.day + 1;
      }
    }

    // Convertir exceso de días a meses
    months += days ~/ 30;
    days = days % 30;

    months = months.clamp(0, 6);

    ref.read(gratificationDataProvider.notifier).updateWorkedMonths(months);
    ref.read(gratificationDataProvider.notifier).updateWorkedDays(days);
  }

  Future<void> _selectDate() async {
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
      _calculateTimeFromDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(gratificationDataProvider);
    final notifier = ref.read(gratificationDataProvider.notifier);

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
          // 1. RÉGIMEN (Aparece primero)
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

          // Separador condicional
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
                  hintText: 'Ingrese el sueldo neto', // Requerido por el usuario en vez de "Sueldo bruto" (?) Mantenemos texto solicitado.
                  prefixIcon: const Icon(Icons.attach_money_rounded, color: Color(0xFF007AFF)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onChanged: (v) {
                  final parsed = double.tryParse(v) ?? 0;
                  notifier.updateGrossSalary(parsed);
                },
              ),
            ),

          if (data.grossSalary > 0) ...[
            const Divider(height: 1),

            // 3. FECHA DE INICIO
            Padding(
              padding: const EdgeInsets.all(20),
              child: InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(16),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Fecha de Inicio',
                    prefixIcon: const Icon(Icons.calendar_today_rounded, color: Color(0xFF007AFF)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    _startDate == null 
                        ? 'Seleccionar' 
                        : DateFormat('dd/MM/yyyy').format(_startDate!),
                    style: TextStyle(
                      color: _startDate == null ? Colors.black54 : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            const Divider(height: 1),

            // 4. ASIGNACIÓN FAMILIAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.family_restroom_rounded, color: Color(0xFF007AFF)),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('¿Tiene hijos? (Asignación familiar)', style: TextStyle(fontSize: 15))),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: true, label: Text('Sí')),
                      ButtonSegment(value: false, label: Text('No')),
                    ],
                    selected: {data.hasFamilyAllowance ?? false},
                    onSelectionChanged: (set) => notifier.updateFamilyAllowance(set.first),
                    showSelectedIcon: false,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // 5. BONOS O COMISIONES
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFF007AFF)),
                      const SizedBox(width: 12),
                      const Expanded(child: Text('¿Recibe Bonos o Comisiones?', style: TextStyle(fontSize: 15))),
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(value: true, label: Text('Sí')),
                          ButtonSegment(value: false, label: Text('No')),
                        ],
                        selected: {_hasBonuses},
                        onSelectionChanged: (set) {
                          setState(() => _hasBonuses = set.first);
                          if (!set.first) notifier.updateBonuses(0);
                        },
                        showSelectedIcon: false,
                      ),
                    ],
                  ),
                  if (_hasBonuses)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: TextFormField(
                        initialValue: data.bonuses == 0 ? '' : data.bonuses.toStringAsFixed(0),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Ingresar monto de bonos',
                          prefixIcon: const Icon(Icons.monetization_on_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onChanged: (v) => notifier.updateBonuses(double.tryParse(v) ?? 0),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),

            // 6. HORAS EXTRAS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.timer_rounded, color: Color(0xFF007AFF)),
                      const SizedBox(width: 12),
                      const Expanded(child: Text('¿Realizó Horas Extra?', style: TextStyle(fontSize: 15))),
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(value: true, label: Text('Sí')),
                          ButtonSegment(value: false, label: Text('No')),
                        ],
                        selected: {_hasOvertime},
                        onSelectionChanged: (set) {
                          setState(() => _hasOvertime = set.first);
                          if (!set.first) {
                            notifier.updateOvertimeHours25(0);
                            notifier.updateOvertimeHours35(0);
                          }
                        },
                        showSelectedIcon: false,
                      ),
                    ],
                  ),
                  if (_hasOvertime)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: data.overtimeHours25 == 0 ? '' : data.overtimeHours25.toString(),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Hora extra al 25%',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onChanged: (v) => notifier.updateOvertimeHours25(int.tryParse(v) ?? 0),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              initialValue: data.overtimeHours35 == 0 ? '' : data.overtimeHours35.toString(),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Hora extra al 35%',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onChanged: (v) => notifier.updateOvertimeHours35(int.tryParse(v) ?? 0),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // 7. REGLA DE REGULARIDAD
            if (_hasBonuses || _hasOvertime) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.rule_rounded, color: Color(0xFF007AFF)),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('¿Percibido ≥ 3 meses?', style: TextStyle(fontSize: 15)),
                          Text('Requisito legal', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: true, label: Text('Sí')),
                        ButtonSegment(value: false, label: Text('No')),
                      ],
                      selected: {data.variablesMeetRegularity},
                      onSelectionChanged: (set) => notifier.updateVariablesMeetRegularity(set.first),
                      showSelectedIcon: false,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
