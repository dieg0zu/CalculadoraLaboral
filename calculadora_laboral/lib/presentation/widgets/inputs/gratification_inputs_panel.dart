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
  DateTime? _endDate;

  void _calculateTimeFromDates() {
    if (_startDate == null) return;
    
    final data = ref.read(gratificationDataProvider);
    final notifier = ref.read(gratificationDataProvider.notifier);
    
    final isCurrentlyWorking = data.isCurrentlyWorking ?? true;
    final DateTime referenceDate = isCurrentlyWorking ? DateTime.now() : (_endDate ?? DateTime.now());

    DateTime startOfSemester;
    DateTime endOfSemester;

    if (referenceDate.month >= 1 && referenceDate.month <= 7) {
      // Semestre Enero - Junio (Se deposita en Julio)
      startOfSemester = DateTime(referenceDate.year, 1, 1);
      endOfSemester = DateTime(referenceDate.year, 6, 30);
    } else {
      // Semestre Julio - Diciembre (Se deposita en Diciembre)
      startOfSemester = DateTime(referenceDate.year, 7, 1);
      endOfSemester = DateTime(referenceDate.year, 12, 31);
    }

    final effectiveEnd = isCurrentlyWorking ? endOfSemester : (_endDate ?? DateTime.now());
    
    // Si sigue laborando, acotamos al inicio del semestre. Si ya cesó, permitimos calcular toda la liquidación.
    final effectiveStart = isCurrentlyWorking && _startDate!.isBefore(startOfSemester) 
        ? startOfSemester 
        : _startDate!;

    if (effectiveEnd.isBefore(effectiveStart)) {
      notifier.updateWorkedMonths(0);
      notifier.updateWorkedDays(0);
      return;
    }

    int months = 0;
    
    // Para gratificación, solo se cuentan meses calendario completos.
    // Un mes es completo si el ingreso fue el día 1 (o antes) y el cese fue el último día del mes (o después).
    DateTime currentMonth = DateTime(effectiveStart.year, effectiveStart.month, 1);
    final endMonth = DateTime(effectiveEnd.year, effectiveEnd.month, 1);
    
    while (!currentMonth.isAfter(endMonth)) {
      final lastDayOfMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
      
      final isStartValid = effectiveStart.isBefore(currentMonth) || 
                           (effectiveStart.year == currentMonth.year && 
                            effectiveStart.month == currentMonth.month && 
                            effectiveStart.day <= 1);
                            
      final isEndValid = effectiveEnd.isAfter(DateTime(currentMonth.year, currentMonth.month, lastDayOfMonth)) ||
                         (effectiveEnd.year == currentMonth.year && 
                          effectiveEnd.month == currentMonth.month && 
                          effectiveEnd.day >= lastDayOfMonth);
                          
      if (isStartValid && isEndValid) {
        months++;
      }
      
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
    }

    notifier.updateWorkedMonths(months);
    notifier.updateWorkedDays(0); // La gratificación no paga fracción de días
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
      initialDate: _endDate ?? DateTime(2026, 6, 30),
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
    final data = ref.watch(gratificationDataProvider);
    final notifier = ref.read(gratificationDataProvider.notifier);

    const primaryBlue = Color(0xFF005CEE);
    const lightBlueBg = Color(0xFFF2F6FE);
    const borderColor = Color(0xFFC7D9FA);
    const lightGreyBg = Color(0xFFF2F4F7);
    const textDark = Color(0xFF1E293B);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. RÉGIMEN (Dropdown)
            const Text('Régimen de la Empresa', style: TextStyle(fontSize: 14, color: textDark)),
            const SizedBox(height: 8),
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<CompanyRegime>(
                  value: data.regime,
                  hint: const Text('Seleccionar', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                  isExpanded: true,
                  icon: const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  items: CompanyRegime.values.map((regime) {
                    return DropdownMenuItem(value: regime, child: Text(regime.displayName, style: const TextStyle(fontSize: 14)));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) notifier.updateRegime(val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            if (data.regime == CompanyRegime.micro || data.regime == CompanyRegime.intern) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF87171)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        data.regime == CompanyRegime.micro 
                          ? 'Por ley, los trabajadores de Microempresa no tienen derecho a Gratificación.'
                          : 'Por ley, los Practicantes no tienen derecho a Gratificación (reciben media subvención adicional cada 6 meses, no entra en este cálculo).',
                        style: const TextStyle(color: Color(0xFF991B1B), fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (data.regime == CompanyRegime.general || data.regime == CompanyRegime.small) ...[
              const Divider(height: 1),
              const SizedBox(height: 20),

            // 2. SUELDO BRUTO
              const Text('Sueldo Bruto Mensual (S/)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primaryBlue)),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: data.grossSalary == 0 ? '' : data.grossSalary.toStringAsFixed(0),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontSize: 16, color: textDark),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: lightBlueBg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: borderColor)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryBlue, width: 1.5)),
                ),
                onChanged: (v) => notifier.updateGrossSalary(double.tryParse(v) ?? 0),
              ),
              const SizedBox(height: 20),

              // 3. FECHA DE INICIO
              const Text('Fecha de Inicio', style: TextStyle(fontSize: 14, color: textDark)),
              const SizedBox(height: 8),
              InkWell(
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
              ),
              const SizedBox(height: 20),

              // 4. SIGUE TRABAJANDO
              const Text('¿Sigue trabajando actualmente?', style: TextStyle(fontSize: 14, color: textDark)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<bool>(
                        value: true,
                        groupValue: data.isCurrentlyWorking,
                        activeColor: primaryBlue,
                        onChanged: (val) {
                          notifier.updateIsCurrentlyWorking(val ?? true);
                          _calculateTimeFromDates();
                        },
                      ),
                      const Text('Sí', style: TextStyle(color: textDark)),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<bool>(
                        value: false,
                        groupValue: data.isCurrentlyWorking,
                        activeColor: primaryBlue,
                        onChanged: (val) {
                          notifier.updateIsCurrentlyWorking(val ?? false);
                          _calculateTimeFromDates();
                        },
                      ),
                      const Text('No', style: TextStyle(color: textDark)),
                    ],
                  ),
                ],
              ),
              
              if (data.isCurrentlyWorking == false) ...[
                const SizedBox(height: 12),
                const Text('Fecha de Fin (Cese)', style: TextStyle(fontSize: 14, color: textDark)),
                const SizedBox(height: 8),
                InkWell(
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
                ),
              ],
              const SizedBox(height: 20),

              // 5. ASIGNACIÓN FAMILIAR
              const Text('¿Tienes hijos? (Asignación Familiar)', style: TextStyle(fontSize: 14, color: textDark)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<bool>(
                        value: true,
                        groupValue: data.hasFamilyAllowance,
                        activeColor: primaryBlue,
                        onChanged: (val) => notifier.updateFamilyAllowance(val ?? true),
                      ),
                      const Text('Sí', style: TextStyle(color: textDark)),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<bool>(
                        value: false,
                        groupValue: data.hasFamilyAllowance,
                        activeColor: primaryBlue,
                        onChanged: (val) => notifier.updateFamilyAllowance(val ?? false),
                      ),
                      const Text('No', style: TextStyle(color: textDark)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 6. BONOS / COMISIONES
              const Text('¿Recibió bonos/comisiones más de 3 veces en el semestre?', style: TextStyle(fontSize: 14, color: textDark)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<bool>(
                        value: true,
                        groupValue: data.bonusesMeetRegularity,
                        activeColor: primaryBlue,
                        onChanged: (val) => notifier.updateBonusesMeetRegularity(val ?? true),
                      ),
                      const Text('Sí', style: TextStyle(color: textDark)),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<bool>(
                        value: false,
                        groupValue: data.bonusesMeetRegularity,
                        activeColor: primaryBlue,
                        onChanged: (val) {
                          notifier.updateBonusesMeetRegularity(val ?? false);
                          notifier.updateBonuses(0);
                        },
                      ),
                      const Text('No', style: TextStyle(color: textDark)),
                    ],
                  ),
                ],
              ),
              if (data.bonusesMeetRegularity == true) ...[
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: data.bonuses == 0 ? '' : data.bonuses.toStringAsFixed(0),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 16, color: textDark),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Monto total del semestre (S/)',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryBlue, width: 1.5)),
                  ),
                  onChanged: (v) => notifier.updateBonuses(double.tryParse(v) ?? 0),
                ),
              ],
              const SizedBox(height: 20),

              // 7. HORAS EXTRAS
              const Text('¿Hizo horas extra más de 3 veces en el semestre?', style: TextStyle(fontSize: 14, color: textDark)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<bool>(
                        value: true,
                        groupValue: data.overtimeMeetRegularity,
                        activeColor: primaryBlue,
                        onChanged: (val) => notifier.updateOvertimeMeetRegularity(val ?? true),
                      ),
                      const Text('Sí', style: TextStyle(color: textDark)),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<bool>(
                        value: false,
                        groupValue: data.overtimeMeetRegularity,
                        activeColor: primaryBlue,
                        onChanged: (val) {
                          notifier.updateOvertimeMeetRegularity(val ?? false);
                          notifier.updateOvertimeHours25(0);
                          notifier.updateOvertimeHours35(0);
                        },
                      ),
                      const Text('No', style: TextStyle(color: textDark)),
                    ],
                  ),
                ],
              ),
              if (data.overtimeMeetRegularity == true) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: data.overtimeHours25 == 0 ? '' : data.overtimeHours25.toString(),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 16, color: textDark),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Horas 25%',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryBlue, width: 1.5)),
                        ),
                        onChanged: (v) => notifier.updateOvertimeHours25(int.tryParse(v) ?? 0),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        initialValue: data.overtimeHours35 == 0 ? '' : data.overtimeHours35.toString(),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 16, color: textDark),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Horas 35%',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryBlue, width: 1.5)),
                        ),
                        onChanged: (v) => notifier.updateOvertimeHours35(int.tryParse(v) ?? 0),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),

              // 8. SEGURO DE SALUD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: lightGreyBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.health_and_safety_outlined, size: 16, color: Color(0xFF64748B)),
                        SizedBox(width: 8),
                        Text(
                          'Seguro de Salud',
                          style: TextStyle(fontSize: 14, color: Color(0xFF475569), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<HealthInsurance>(
                          value: data.healthInsurance == HealthInsurance.sis ? null : data.healthInsurance,
                          hint: const Text('Seleccionar', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                          isExpanded: true,
                          icon: const Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          items: [
                            DropdownMenuItem(value: HealthInsurance.essalud, child: Text(HealthInsurance.essalud.displayName, style: const TextStyle(fontSize: 14))),
                            DropdownMenuItem(value: HealthInsurance.eps, child: Text(HealthInsurance.eps.displayName, style: const TextStyle(fontSize: 14))),
                            DropdownMenuItem(value: HealthInsurance.both, child: Text(HealthInsurance.both.displayName, style: const TextStyle(fontSize: 14))),
                          ],
                          onChanged: (val) {
                            if (val != null) notifier.updateHealthInsurance(val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
