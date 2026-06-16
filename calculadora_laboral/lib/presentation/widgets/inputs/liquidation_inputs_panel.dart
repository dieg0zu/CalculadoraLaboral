import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
  late TextEditingController _epsCostController;

  DateTime? _startDate;
  DateTime? _endDate;
  bool? _hasCurrentMonthOvertime;

  @override
  void initState() {
    super.initState();
    _epsCostController = TextEditingController();
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _epsCostController.dispose();
    super.dispose();
  }

  /// Selector de fecha de inicio — solo calendario, sin texto manual.
  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime(DateTime.now().year - 1, 1, 1),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      helpText: 'Seleccionar Fecha de Inicio',
      locale: const Locale('es', 'ES'),
    );
    if (picked != null) {
      // Si ya hay fecha de cese y la nueva fecha de inicio es posterior, resetear cese.
      if (_endDate != null && picked.isAfter(_endDate!)) {
        setState(() {
          _endDate = null;
          _endDateController.text = '';
        });
      }
      setState(() {
        _startDate = picked;
        _startDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  /// Selector de fecha de cese — firstDate queda anclado a la fecha de inicio.
  Future<void> _selectEndDate() async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero selecciona la fecha de inicio.')),
      );
      return;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!,
      firstDate: _startDate!,         // ← Garantiza: cese ≥ inicio
      lastDate: DateTime.now().add(const Duration(days: 365)),
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

  void _onCalculatePressed() {
    final data = ref.read(liquidationDataProvider);

    if (_startDate == null ||
        _endDate == null ||
        _endDate!.isBefore(_startDate!) ||
        data.regime == null ||
        data.grossSalary <= 0 ||
        data.hasFamilyAllowance == null ||
        data.hasTakenVacations == null ||
        data.bonusesMeetRegularity == null ||
        (data.bonusesMeetRegularity == true && data.semesterTotalBonuses <= 0) ||
        data.overtimeMeetRegularity == null ||
        (data.overtimeMeetRegularity == true && data.semesterTotalOvertime <= 0) ||
        _hasCurrentMonthOvertime == null ||
        (_hasCurrentMonthOvertime == true && data.currentMonthOvertime <= 0) ||
        data.healthInsurance == null ||
        (data.healthInsurance == HealthInsurance.eps && data.epsCost <= 0) ||
        data.pensionSystem == null ||
        (data.pensionSystem == PensionSystem.afp && data.afpType == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, complete todos los campos')),
      );
      return;
    }

    // ── Todo OK → ejecutar cálculo ───────────────────────────────────
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
                          ? 'Por ley, los trabajadores de Microempresa en su liquidación solo reciben Vacaciones truncas (no aplica CTS ni Gratificación).'
                          : 'Por ley, los Practicantes en su liquidación solo reciben la media subvención proporcional (no aplica CTS ni Gratificación).',
                        style: const TextStyle(color: Color(0xFF991B1B), fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

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
              onChanged: (v) {
                final cleaned = v.replaceAll('.', '').replaceAll(',', '.');
                notifier.updateGrossSalary(double.tryParse(cleaned) ?? 0.0);
              },
            ),
            const SizedBox(height: 12),

            // ── Flag: ¿Sueldo del mes de cese ya pagado? ──────────────────
            // Resuelve el punto ciego de fin de mes: si la planilla normal
            // ya incluyó el sueldo de los días trabajados en el mes de cese,
            // activar este switch evita duplicarlo en la liquidación.
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: data.isCurrentMonthSalaryAlreadyPaid
                    ? const Color(0xFFFFF8E1)  // ámbar suave cuando activo
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: data.isCurrentMonthSalaryAlreadyPaid
                      ? const Color(0xFFFFB300)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                activeColor: const Color(0xFFFFB300),
                title: const Text(
                  'Sueldo del mes de cese ya pagado en planilla',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textDark),
                ),
                subtitle: Text(
                  data.isCurrentMonthSalaryAlreadyPaid
                      ? 'Activado → la línea "Sueldo mes de cese" mostrará S/ 0.00'
                      : 'Desactivado → se calculará proporcional a los días trabajados',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                value: data.isCurrentMonthSalaryAlreadyPaid,
                onChanged: (val) =>
                    notifier.updateIsCurrentMonthSalaryAlreadyPaid(val),
              ),
            ),
            const SizedBox(height: 20),

            // ── Fechas ──
            const Text('Fecha de inicio', style: TextStyle(color: textDark, fontSize: 14)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _startDateController,
              readOnly: true,   // ← Solo calendario, sin tipeo libre
              style: const TextStyle(fontSize: 16, color: textDark),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Toca el ícono para seleccionar',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today_rounded, color: Color(0xFF64748B), size: 20),
                  onPressed: _selectStartDate,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryBlue, width: 1.5)),
              ),
              onTap: _selectStartDate,
            ),
            const SizedBox(height: 20),

            const Text('Fecha de cese', style: TextStyle(color: textDark, fontSize: 14)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _endDateController,
              readOnly: true,   // ← Solo calendario, sin tipeo libre
              style: const TextStyle(fontSize: 16, color: textDark),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Toca el ícono para seleccionar',
                helperText: _startDate == null ? 'Selecciona primero la fecha de inicio' : null,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today_rounded, color: Color(0xFF64748B), size: 20),
                  onPressed: _selectEndDate,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryBlue, width: 1.5)),
              ),
              onTap: _selectEndDate,
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
                onChanged: (v) {
                  final cleaned = v.replaceAll('.', '').replaceAll(',', '.');
                  notifier.updateSemesterTotalBonuses(double.tryParse(cleaned) ?? 0.0);
                },
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
                onChanged: (v) {
                  final cleaned = v.replaceAll('.', '').replaceAll(',', '.');
                  notifier.updateSemesterTotalOvertime(double.tryParse(cleaned) ?? 0.0);
                },
              ),
              const SizedBox(height: 16),
            ],
            
            const Text(
              '¿Hizo horas extra en el mes del cese?',
              style: TextStyle(fontSize: 14, color: textDark),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: _hasCurrentMonthOvertime,
                      activeColor: primaryBlue,
                      onChanged: (val) {
                        setState(() => _hasCurrentMonthOvertime = true);
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
                      groupValue: _hasCurrentMonthOvertime,
                      activeColor: primaryBlue,
                      onChanged: (val) {
                        setState(() => _hasCurrentMonthOvertime = false);
                        notifier.updateCurrentMonthOvertime(0);
                      },
                    ),
                    const Text('No', style: TextStyle(color: textDark)),
                  ],
                ),
              ],
            ),
            if (_hasCurrentMonthOvertime == true) ...[
              const SizedBox(height: 12),
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
                  hintText: 'Ingrese el monto en soles',
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
                onChanged: (v) {
                  final cleaned = v.replaceAll('.', '').replaceAll(',', '.');
                  notifier.updateCurrentMonthOvertime(double.tryParse(cleaned) ?? 0.0);
                },
              ),
            ],
            const SizedBox(height: 24),
            
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
                          if (val != null) {
                            notifier.updateHealthInsurance(val);
                            if (val == HealthInsurance.essalud) {
                              notifier.updateEpsCost(0);
                              _epsCostController.text = '';
                            }
                          }
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
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,  // ← Sin negativos, sin decimales
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final days = int.tryParse(value);
                  if (days == null || days < 0) return 'Ingresa un número de días válido (≥ 0)';
                  // Máximo razonable: 30 días por año × 40 años
                  if (days > 1200) return 'El número de días parece excesivo';
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Ej. 15',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryBlue, width: 1.5)),
                  errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
                  focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
                ),
                onChanged: (val) {
                  final parsed = int.tryParse(val);
                  notifier.updateTakenVacationDays(parsed ?? 0);
                },
              ),
            ],
            const SizedBox(height: 32),

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
