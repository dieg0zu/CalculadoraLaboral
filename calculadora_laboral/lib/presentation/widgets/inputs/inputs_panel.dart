import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/legal_parameters.dart';
import '../../providers/employee_data_provider.dart';

/// Panel de inputs compartido por todos los tabs.
///
/// [showWorkedTimeFields] — si false, oculta los campos de meses y días
/// (usado en la pantalla de Sueldo Neto donde se asume un mes completo).
class InputsPanel extends ConsumerStatefulWidget {
  final bool showBonuses;
  final bool showPensionSystem;
  final bool showEps;
  final bool showWorkedTimeFields;
  final bool showWorkedDays;

  const InputsPanel({
    super.key,
    this.showBonuses = true,
    this.showPensionSystem = true,
    this.showEps = true,
    this.showWorkedTimeFields = true,
    this.showWorkedDays = true,
  });

  @override
  ConsumerState<InputsPanel> createState() => _InputsPanelState();
}

class _InputsPanelState extends ConsumerState<InputsPanel> {
  late TextEditingController _salaryController;
  late TextEditingController _bonusesController;
  late TextEditingController _overtime25Controller;
  late TextEditingController _overtime35Controller;
  late TextEditingController _monthsController;
  late TextEditingController _daysController;
  late TextEditingController _epsCostController;

  bool _hasOvertime = false;

  @override
  void initState() {
    super.initState();
    final data = ref.read(employeeDataProvider);
    _salaryController = TextEditingController(
        text: data.grossSalary > 0 ? data.grossSalary.toStringAsFixed(2) : '');
    _bonusesController = TextEditingController(
        text: data.bonuses > 0 ? data.bonuses.toStringAsFixed(2) : '');
    _overtime25Controller = TextEditingController(
        text: data.overtimeHours25 > 0 ? data.overtimeHours25.toString() : '');
    _overtime35Controller = TextEditingController(
        text: data.overtimeHours35 > 0 ? data.overtimeHours35.toString() : '');
    _monthsController = TextEditingController(
        text: data.workedMonths > 0 ? data.workedMonths.toString() : '');
    _daysController = TextEditingController(
        text: data.workedDays > 0 ? data.workedDays.toString() : '');
    _epsCostController = TextEditingController(
        text: data.epsCost > 0 ? data.epsCost.toStringAsFixed(2) : '');
    _hasOvertime =
        data.overtimeHours25 > 0 || data.overtimeHours35 > 0;
  }

  @override
  void dispose() {
    _salaryController.dispose();
    _bonusesController.dispose();
    _overtime25Controller.dispose();
    _overtime35Controller.dispose();
    _monthsController.dispose();
    _daysController.dispose();
    _epsCostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(employeeDataProvider);
    final notifier = ref.read(employeeDataProvider.notifier);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Encabezado ─────────────────────────────────────────
            Row(
              children: [
                const Icon(Icons.tune_rounded,
                    color: Color(0xFF444444), size: 18),
                const SizedBox(width: 8),
                Text(
                  'Datos del trabajador',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.refresh_rounded, size: 15),
                  label: const Text('Limpiar'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF888888),
                    textStyle: const TextStyle(fontSize: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                  ),
                  onPressed: () {
                    notifier.reset();
                    _salaryController.text = '';
                    _bonusesController.text = '';
                    _overtime25Controller.text = '';
                    _overtime35Controller.text = '';
                    _monthsController.text = '';
                    _daysController.text = '';
                    _epsCostController.text = '';
                    setState(() => _hasOvertime = false);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Sueldo Bruto ────────────────────────────────────────
            TextFormField(
              controller: _salaryController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: 'Sueldo Bruto Mensual (incluir bonos si existiera)',
                hintText: 'Ingresar sueldo bruto',
                prefixIcon: const Icon(Icons.attach_money_rounded),
                prefixText: 'S/. ',
                helperText:
                    'RMV mínima: S/. ${LegalParameters.kRMV.toStringAsFixed(2)}',
              ),
              onChanged: (v) {
                final parsed = double.tryParse(v) ?? 0;
                notifier.updateGrossSalary(parsed);
              },
            ),
            const SizedBox(height: 14),

            // ── Régimen de empresa ──────────────────────────────────
            DropdownButtonFormField<CompanyRegime>(
              value: data.regime,
              hint: const Text('Seleccionar'),
              decoration: const InputDecoration(
                labelText: 'Régimen Laboral',
                prefixIcon: Icon(Icons.business_center_rounded),
              ),
              dropdownColor: Colors.white,
              items: CompanyRegime.values
                  .map((r) => DropdownMenuItem(
                        value: r,
                        child: Text(r.displayName),
                      ))
                  .toList(),
              onChanged: (v) => notifier.updateRegime(v!),
            ),

            if (data.regime != null) ...[
              const SizedBox(height: 14),

              if (widget.showBonuses) ...[
                // ── Bonos y Comisiones ──────────────────────────────────
                TextFormField(
                  controller: _bonusesController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Bonos / Comisiones',
                    hintText: 'Ingresar monto (opcional)',
                    prefixIcon: Icon(Icons.monetization_on_rounded),
                    prefixText: 'S/. ',
                    helperText: 'Promedio mensual o monto fijo',
                  ),
                  onChanged: (v) {
                    final parsed = double.tryParse(v) ?? 0;
                    notifier.updateBonuses(parsed);
                  },
                ),

                // Regla de Regularidad
                if (data.bonuses > 0 || _hasOvertime) ...[
                  const SizedBox(height: 14),
                  _SwitchTile(
                    title: '¿Percibido ≥ 3 meses?',
                    subtitle: 'Requisito para computar en CTS/Grati',
                    icon: Icons.rule_rounded,
                    value: data.variablesMeetRegularity,
                    onChanged: notifier.updateVariablesMeetRegularity,
                  ),
                ],
                const SizedBox(height: 14),
              ],

              // ── Asignación Familiar ─────────────────────────────────
              _SwitchTile(
                title: 'Asignación Familiar',
                subtitle:
                    'S/. ${LegalParameters.kFamilyAllowance.toStringAsFixed(2)} / mes (10% RMV)',
                icon: Icons.family_restroom_rounded,
                value: data.hasFamilyAllowance ?? false,
                onChanged: notifier.updateFamilyAllowance,
              ),
              const SizedBox(height: 14),

              if (widget.showPensionSystem) ...[
                // ── Sistema Pensionario ─────────────────────────────────
                DropdownButtonFormField<PensionSystem>(
                  value: data.pensionSystem,
                  hint: const Text('Seleccionar'),
                  decoration: const InputDecoration(
                    labelText: 'Sistema Pensionario',
                    prefixIcon: Icon(Icons.account_balance_rounded),
                  ),
                  dropdownColor: Colors.white,
                  items: PensionSystem.values
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(s.displayName),
                          ))
                      .toList(),
                  onChanged: (v) => notifier.updatePensionSystem(v!),
                ),

                // ── AFP (condicional) ───────────────────────────────────
                if (data.pensionSystem == PensionSystem.afp) ...[
                  const SizedBox(height: 14),
                  DropdownButtonFormField<AfpType>(
                value: data.afpType,
                hint: const Text('Seleccionar'),
                decoration: const InputDecoration(
                  labelText: 'AFP',
                  prefixIcon: Icon(Icons.business_rounded),
                ),
                dropdownColor: Colors.white,
                items: AfpType.values
                    .map((a) => DropdownMenuItem(
                          value: a,
                          child: Text(a.displayName),
                        ))
                    .toList(),
                onChanged: (v) {
                  notifier.updateAfpType(v!);
                  notifier.updateCommissionType(AfpCommissionType.mixta);
                },
              ),
                ],
              ],

              const SizedBox(height: 14),

            // ── Horas Extra — Toggle ────────────────────────────────
            _SwitchTile(
              title: '¿Realizó horas extra este mes?',
              subtitle: _hasOvertime
                  ? 'Ingresa las horas abajo'
                  : 'Activa para ingresar horas extra',
              icon: Icons.access_time_filled_rounded,
              value: _hasOvertime,
              onChanged: (val) {
                setState(() => _hasOvertime = val);
                if (!val) {
                  notifier.updateOvertimeHours25(0);
                  notifier.updateOvertimeHours35(0);
                  _overtime25Controller.text = '0';
                  _overtime35Controller.text = '0';
                }
              },
            ),

            // Campos de horas extra (condicional)
            if (_hasOvertime) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _overtime25Controller,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: const InputDecoration(
                        labelText: 'HH.EE al 25%',
                        prefixIcon: Icon(Icons.access_time_rounded),
                        suffixText: 'h',
                        helperText: 'Primeras horas',
                      ),
                      onChanged: (v) => notifier
                          .updateOvertimeHours25(int.tryParse(v) ?? 0),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _overtime35Controller,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: const InputDecoration(
                        labelText: 'HH.EE al 35%',
                        prefixIcon: Icon(Icons.more_time_rounded),
                        suffixText: 'h',
                        helperText: 'Horas adicionales',
                      ),
                      onChanged: (v) => notifier
                          .updateOvertimeHours35(int.tryParse(v) ?? 0),
                    ),
                  ),
                ],
              ),
            ],

            // ── Meses y Días (solo en tabs que lo necesitan) ────────
            if (widget.showWorkedTimeFields) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _monthsController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Número de meses trabajados',
                        prefixIcon: Icon(Icons.calendar_month_rounded),
                        helperText: 'En el semestre (0–6)',
                      ),
                      onChanged: (v) =>
                          notifier.updateWorkedMonths(int.tryParse(v) ?? 0),
                    ),
                  ),
                  if (widget.showWorkedDays) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _daysController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Días adicionales',
                          prefixIcon: Icon(Icons.today_rounded),
                          helperText: 'Del último mes (0–30)',
                        ),
                        onChanged: (v) =>
                            notifier.updateWorkedDays(int.tryParse(v) ?? 0),
                      ),
                    ),
                  ],
                ],
              ),
            ],

            if (widget.showEps) ...[
              const SizedBox(height: 14),

              // ── Seguro de Salud ───────────────────────────────────────
              DropdownButtonFormField<HealthInsurance>(
                value: data.healthInsurance,
                hint: const Text('Seleccionar'),
                decoration: const InputDecoration(
                  labelText: 'Seguro de Salud',
                  prefixIcon: Icon(Icons.health_and_safety_rounded),
                ),
                dropdownColor: Colors.white,
                items: HealthInsurance.values
                    .where((h) => data.regime == CompanyRegime.micro || h != HealthInsurance.sis)
                    .map((h) => DropdownMenuItem(
                          value: h,
                          child: Text(h.displayName),
                        ))
                    .toList(),
                onChanged: (v) => notifier.updateHealthInsurance(v!),
              ),

              if (data.healthInsurance == HealthInsurance.eps) ...[
                const SizedBox(height: 14),
                TextFormField(
                  controller: _epsCostController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Costo Plan Comercial (EPS)',
                    hintText: 'Monto a descontar al trabajador',
                    prefixIcon: Icon(Icons.payment_rounded),
                    prefixText: 'S/. ',
                  ),
                  onChanged: (v) {
                    final parsed = double.tryParse(v) ?? 0;
                    notifier.updateEpsCost(parsed);
                  },
                ),
              ],
            ],

          ], // Cierra if (data.regime != null)
          ], // Cierra children de Column
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets — paleta blanco/gris/negro
// ─────────────────────────────────────────────────────────────────────────────

class _SwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: value
            ? const Color(0xFF007AFF).withValues(alpha: 0.05)
            : const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? const Color(0xFF007AFF).withValues(alpha: 0.4)
              : const Color(0xFFDDE1E9),
        ),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: value ? const Color(0xFF1A1A2E) : const Color(0xFF555566),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: Color(0xFF888899)),
        ),
        secondary: Icon(
          icon,
          color: value ? const Color(0xFF007AFF) : const Color(0xFFAAAAAA),
        ),
        value: value,
        onChanged: onChanged,
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

/// Banner de ayuda "No estoy seguro" — gris neutro.
class _CommissionHelpBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCCCCCC)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ℹ️', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recomendación estadística',
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Si te afiliaste a la AFP después del año 2013, '
                  'o no recuerdas haber realizado un trámite para mantener '
                  'tu comisión antigua, tu comisión es la Mixta. '
                  'Este es el caso del 80% de los afiliados al SPP en el Perú.',
                  style: textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF555555),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    final container = ProviderScope.containerOf(context);
                    container
                        .read(employeeDataProvider.notifier)
                        .updateCommissionType(AfpCommissionType.mixta);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF007AFF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Seleccionar Comisión Mixta',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
