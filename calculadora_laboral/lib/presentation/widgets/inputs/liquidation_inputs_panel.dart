import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'date_validation_formatter.dart';

import '../../../core/constants/legal_parameters.dart';
import '../../providers/liquidation_data_provider.dart';

class LiquidationInputsPanel extends ConsumerStatefulWidget {
  final Function(DateTime startDate, DateTime endDate) onCalculate;

  const LiquidationInputsPanel({super.key, required this.onCalculate});

  @override
  ConsumerState<LiquidationInputsPanel> createState() => _LiquidationInputsPanelState();
}

class _LiquidationInputsPanelState extends ConsumerState<LiquidationInputsPanel> {
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  final _startDateMaskFormatter = DateTextFormatter();
  
  final _endDateMaskFormatter = DateTextFormatter();


  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime(2026, 1, 1),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
      helpText: 'Seleccionar Fecha de Inicio',
      locale: const Locale('es', 'ES'),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _startDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2000),
      lastDate: DateTime(2030),
      helpText: 'Seleccionar Fecha de Cese',
      locale: const Locale('es', 'ES'),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
        _endDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }
  
  void _parseManualDate(String val, bool isStart) {
    try {
      if (val.length == 10) {
        // try parsing
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
        }
      }
    } catch (_) {}
  }

  void _onCalculatePressed() {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa la fecha de inicio.')),
      );
      return;
    }
    
    if (_endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa la fecha de cese.')),
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
    }
    
    final data = ref.read(liquidationDataProvider);
    
    if (data.regime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona un régimen laboral.')),
      );
      return;
    }
    
    if (data.grossSalary <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa un sueldo bruto válido.')),
      );
      return;
    }
    
    if (data.hasFamilyAllowance == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, indica si tienes hijos (Asignación Familiar).')),
      );
      return;
    }
    



    if (data.hasTakenVacations == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, indica si ha gozado de días de descanso vacacional.')),
      );
      return;
    }

    if (data.bonusesMeetRegularity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, indica si recibiste bonos/comisiones.')),
      );
      return;
    }
    
    if (data.bonusesMeetRegularity == true && data.semesterTotalBonuses <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa el monto total de bonos/comisiones.')),
      );
      return;
    }
    
    if (data.overtimeMeetRegularity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, indica si hiciste horas extras.')),
      );
      return;
    }

    if (data.overtimeMeetRegularity == true && data.semesterTotalOvertime <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa el monto total de horas extras.')),
      );
      return;
    }
    


    if (data.healthInsurance == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona un seguro de salud.')),
      );
      return;
    }

    if (data.pensionSystem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona un sistema de pensión.')),
      );
      return;
    }
    if (data.pensionSystem == PensionSystem.afp && data.afpType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona una AFP.')),
      );
      return;
    }

    widget.onCalculate(_startDate!, _endDate!);
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(liquidationDataProvider);
    final notifier = ref.read(liquidationDataProvider.notifier);
    final isAfp = data.pensionSystem == PensionSystem.afp;

    const primaryBlue = Color(0xFF005CEE);
    const lightBlueBg = Color(0xFFF2F6FE);
    const borderColor = Color(0xFFC7D9FA);
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
            // ── Régimen ──
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
                  items: const [
                    DropdownMenuItem(value: CompanyRegime.general, child: Text('General', style: TextStyle(fontSize: 14))),
                    DropdownMenuItem(value: CompanyRegime.small, child: Text('Pequeña Empresa', style: TextStyle(fontSize: 14))),
                    DropdownMenuItem(value: CompanyRegime.micro, child: Text('Microempresa', style: TextStyle(fontSize: 14))),
                    DropdownMenuItem(value: CompanyRegime.intern, child: Text('Practicante', style: TextStyle(fontSize: 14))),
                  ],
                  onChanged: (val) {
                    if (val != null) notifier.updateRegime(val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Sueldo Bruto ──
            const Text('Sueldo Bruto Mensual (S/)', style: TextStyle(color: primaryBlue, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: data.grossSalary == 0 ? '' : CurrencyTextInputFormatter.currency(locale: 'es', symbol: '', decimalDigits: 2).formatDouble(data.grossSalary),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'-')), CurrencyTextInputFormatter.currency(locale: 'es', symbol: '', decimalDigits: 2)],
              style: const TextStyle(fontSize: 16, color: textDark),
              decoration: InputDecoration(
                filled: true,
                fillColor: lightBlueBg,
                hintText: 'Ingresa tu sueldo bruto',
                prefixText: 'S/ ',
                prefixStyle: const TextStyle(color: textDark, fontSize: 16),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: borderColor)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryBlue, width: 1.5)),
              ),
              onChanged: (v) => notifier.updateGrossSalary(double.tryParse(v.replaceAll('.', '').replaceAll(',', '.')) ?? 0),
            ),
            const SizedBox(height: 20),

            // ── Fechas ──
            const Text('Fecha de inicio', style: TextStyle(color: textDark, fontSize: 14)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _startDateController,
              keyboardType: TextInputType.datetime,
              inputFormatters: [_startDateMaskFormatter],
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
            ),
            const SizedBox(height: 20),

            const Text('Fecha de cese', style: TextStyle(color: textDark, fontSize: 14)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _endDateController,
              keyboardType: TextInputType.datetime,
              inputFormatters: [_endDateMaskFormatter],
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
            ),
            const SizedBox(height: 20),

            // ── ¿Tiene hijos? ──
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
                      onChanged: (val) => notifier.updateHasFamilyAllowance(val ?? true),
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
                      onChanged: (val) => notifier.updateHasFamilyAllowance(val ?? false),
                    ),
                    const Text('No', style: TextStyle(color: textDark)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Bonos / Comisiones ──
            const Text('¿Recibiste bonos/comisiones más de 3 veces en el semestre?', style: TextStyle(fontSize: 14, color: textDark)),
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
                        notifier.updateSemesterTotalBonuses(0);
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
                initialValue: data.semesterTotalBonuses == 0 ? '' : CurrencyTextInputFormatter.currency(locale: 'es', symbol: '', decimalDigits: 2).formatDouble(data.semesterTotalBonuses),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'-')), CurrencyTextInputFormatter.currency(locale: 'es', symbol: '', decimalDigits: 2)],
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
              ),
              const SizedBox(height: 16),
            ],

            // ── Horas Extras ──
            const Text('¿Hiciste horas extras más de 3 veces en el semestre?', style: TextStyle(fontSize: 14, color: textDark)),
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
                        // Al marcar "No", limpiar la suma histórica (promedio → 0)
                        notifier.updateSemesterTotalOvertime(0);
                      },
                    ),
                    const Text('No', style: TextStyle(color: textDark)),
                  ],
                ),
              ],
            ),
            // Campo condicional: suma histórica del semestre (excluye mes de cese)
            if (data.overtimeMeetRegularity == true) ...[
              const SizedBox(height: 12),
              const Text(
                'Suma de HH.EE. de meses anteriores del semestre (excl. mes de cese)',
                style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 6),
              TextFormField(
                key: const ValueKey('semesterTotalOvertime'),
                initialValue: data.semesterTotalOvertime == 0
                    ? ''
                    : CurrencyTextInputFormatter.currency(locale: 'es', symbol: '', decimalDigits: 2)
                        .formatDouble(data.semesterTotalOvertime),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'-')),
                  CurrencyTextInputFormatter.currency(locale: 'es', symbol: '', decimalDigits: 2),
                ],
                style: const TextStyle(fontSize: 16, color: textDark),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'S/ 0.00 — suma total de los meses previos',
                  prefixText: 'S/ ',
                  prefixStyle: const TextStyle(color: textDark, fontSize: 16),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryBlue, width: 1.5),
                  ),
                ),
                onChanged: (v) => notifier.updateSemesterTotalOvertime(
                  double.tryParse(v.replaceAll('.', '').replaceAll(',', '.')) ?? 0,
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Campo siempre visible: horas extra del mes de cese
            const Text(
              'Horas extra del mes de cese (ingreso directo, S/)',
              style: TextStyle(fontSize: 14, color: textDark),
            ),
            const SizedBox(height: 6),
            TextFormField(
              key: const ValueKey('currentMonthOvertime'),
              initialValue: data.currentMonthOvertime == 0
                  ? ''
                  : CurrencyTextInputFormatter.currency(locale: 'es', symbol: '', decimalDigits: 2)
                      .formatDouble(data.currentMonthOvertime),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'-')),
                CurrencyTextInputFormatter.currency(locale: 'es', symbol: '', decimalDigits: 2),
              ],
              style: const TextStyle(fontSize: 16, color: textDark),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'S/ 0.00 — dejar en 0 si no hubo HH.EE. este mes',
                prefixText: 'S/ ',
                prefixStyle: const TextStyle(color: textDark, fontSize: 16),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: primaryBlue, width: 1.5),
                ),
              ),
              onChanged: (v) => notifier.updateCurrentMonthOvertime(
                double.tryParse(v.replaceAll('.', '').replaceAll(',', '.')) ?? 0.0,
              ),
            ),
            const SizedBox(height: 16),
            // ── Caja Gris: Sistema de Pensión y Salud ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.work_outline_rounded, size: 16, color: Color(0xFF64748B)),
                      const SizedBox(width: 8),
                      const Text(
                        'Sistema de Pensión y Salud',
                        style: TextStyle(fontSize: 14, color: Color(0xFF475569), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  
                  const Text('Seguro de Salud', style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
                  const SizedBox(height: 4),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<HealthInsurance>(
                        value: data.healthInsurance,
                        hint: const Text('Seleccionar', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                        isExpanded: true,
                        icon: const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        items: const [
                          DropdownMenuItem(value: HealthInsurance.essalud, child: Text('EsSalud', style: TextStyle(fontSize: 14))),
                          DropdownMenuItem(value: HealthInsurance.eps, child: Text('EPS', style: TextStyle(fontSize: 14))),
                          DropdownMenuItem(value: HealthInsurance.sis, child: Text('Ambos (EPS + EsSalud)', style: TextStyle(fontSize: 14))),
                        ],
                        onChanged: (val) {
                          if (val != null) notifier.updateHealthInsurance(val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text('Sistema de Pensión', style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
                  const SizedBox(height: 4),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<PensionSystem>(
                        value: data.pensionSystem,
                        hint: const Text('Seleccionar ONP o AFP', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                        isExpanded: true,
                        icon: const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        items: const [
                          DropdownMenuItem(value: PensionSystem.onp, child: Text('ONP', style: TextStyle(fontSize: 14))),
                          DropdownMenuItem(value: PensionSystem.afp, child: Text('AFP', style: TextStyle(fontSize: 14))),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            notifier.updatePensionSystem(val);
                            if (val == PensionSystem.afp) {
                              notifier.updateCommissionType(AfpCommissionType.mixta);
                            }
                          }
                        },
                      ),
                    ),
                  ),

                  if (isAfp) ...[
                    const SizedBox(height: 12),
                    const Text('Entidad AFP', style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
                    const SizedBox(height: 4),
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<AfpType>(
                          value: data.afpType,
                          hint: const Text('Selecciona tu AFP', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                          isExpanded: true,
                          icon: const Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          items: const [
                            DropdownMenuItem(value: AfpType.habitat, child: Text('Habitat', style: TextStyle(fontSize: 14))),
                            DropdownMenuItem(value: AfpType.integra, child: Text('Integra', style: TextStyle(fontSize: 14))),
                            DropdownMenuItem(value: AfpType.prima, child: Text('Prima', style: TextStyle(fontSize: 14))),
                            DropdownMenuItem(value: AfpType.profuturo, child: Text('Profuturo', style: TextStyle(fontSize: 14))),
                          ],
                          onChanged: (val) {
                            if (val != null) notifier.updateAfpType(val);
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── ¿Ha gozado vacaciones? ──
            const Text('¿Ha gozado de días de descanso vacacional desde que ingresó a la empresa?', style: TextStyle(fontSize: 14, color: textDark)),
            const SizedBox(height: 8),
            Row(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: data.hasTakenVacations,
                      activeColor: primaryBlue,
                      onChanged: (val) => notifier.updateHasTakenVacations(val ?? true),
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
                      groupValue: data.hasTakenVacations,
                      activeColor: primaryBlue,
                      onChanged: (val) {
                        if (val != null) {
                          notifier.updateHasTakenVacations(val);
                          notifier.updateTakenVacationDays(0);
                        }
                      },
                    ),
                    const Text('No', style: TextStyle(color: textDark)),
                  ],
                ),
              ],
            ),
            if (data.hasTakenVacations == true) ...[
              const SizedBox(height: 16),
              const Text('Indique el número total de días de vacaciones que ya se tomó en toda su relación laboral:', style: TextStyle(color: textDark, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                keyboardType: TextInputType.number,
                initialValue: data.takenVacationDays == 0 ? '' : data.takenVacationDays.toString(),
                decoration: InputDecoration(
                  hintText: 'Ej. 15',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryBlue, width: 1.5)),
                ),
                onChanged: (val) => notifier.updateTakenVacationDays(int.tryParse(val) ?? 0),
              ),
            ],
            const SizedBox(height: 16),

            // ── Bonos Pendientes (Liquidación) ──
            const Text('Bonos pendientes a pagar (opcional)', style: TextStyle(color: textDark, fontSize: 14)),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: data.pendingBonuses == 0 ? '' : CurrencyTextInputFormatter.currency(locale: 'es', symbol: '', decimalDigits: 2).formatDouble(data.pendingBonuses),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'-')), CurrencyTextInputFormatter.currency(locale: 'es', symbol: '', decimalDigits: 2)],
              style: const TextStyle(fontSize: 16, color: textDark),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Monto a pagar (S/)',
                prefixText: 'S/ ',
                prefixStyle: const TextStyle(color: textDark, fontSize: 16),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryBlue, width: 1.5)),
              ),
              onChanged: (val) => notifier.updatePendingBonuses(double.tryParse(val.replaceAll('.', '').replaceAll(',', '.')) ?? 0.0),
            ),
            const SizedBox(height: 24),

            // ── Botón Calcular ──
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _onCalculatePressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  'Calcular Liquidación',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
