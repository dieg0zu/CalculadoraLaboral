import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/employee_data_provider.dart';
import '../../core/constants/legal_parameters.dart';
import '../../core/theme/app_theme.dart';
import 'net_salary_result_screen.dart';

/// Tab 1 — Sueldo Neto Mensual.
///
/// Formulario de datos para el cálculo. Al darle a calcular, abre una nueva ventana
/// con el resultado final.
class NetSalaryScreen extends ConsumerWidget {
  const NetSalaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: _FormCard(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Formulario principal — caja blanca
// ─────────────────────────────────────────────────────────────────────────────

class _FormCard extends ConsumerStatefulWidget {
  const _FormCard();

  @override
  ConsumerState<_FormCard> createState() => _FormCardState();
}

class _FormCardState extends ConsumerState<_FormCard> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _salaryCtrl;
  late TextEditingController _ot25Ctrl;
  late TextEditingController _ot35Ctrl;
  bool _hasOvertime = false;

  @override
  void initState() {
    super.initState();
    final d = ref.read(employeeDataProvider);
    _salaryCtrl = TextEditingController(
        text: d.grossSalary > 0 ? d.grossSalary.toStringAsFixed(2) : '');
    _ot25Ctrl = TextEditingController(
        text: d.overtimeHours25 > 0 ? d.overtimeHours25.toString() : '');
    _ot35Ctrl = TextEditingController(
        text: d.overtimeHours35 > 0 ? d.overtimeHours35.toString() : '');
    _hasOvertime = d.overtimeHours25 > 0 || d.overtimeHours35 > 0;
  }

  @override
  void dispose() {
    _salaryCtrl.dispose();
    _ot25Ctrl.dispose();
    _ot35Ctrl.dispose();
    super.dispose();
  }

  void _onCalculate() {
    if (_formKey.currentState?.validate() ?? false) {
      final data = ref.read(employeeDataProvider);
      
      // Validación extra
      if (data.pensionSystem == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecciona un sistema pensionario')),
        );
        return;
      }
      if (data.pensionSystem == PensionSystem.afp) {
        if (data.afpType == null || data.commissionType == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, selecciona tu AFP y tipo de comisión')),
          );
          return;
        }
      }

      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const NetSalaryResultScreen()),
      );
    }
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              Text(
                'Datos del trabajador',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.kTextPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Completa los campos para calcular el sueldo neto',
                style: TextStyle(fontSize: 12, color: AppTheme.kTextSecondary),
              ),
              const SizedBox(height: 20),

              // ── 1. Sueldo Bruto ──────────────────────────────────────
              TextFormField(
                controller: _salaryCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Sueldo Bruto Mensual',
                  hintText: 'Ingrese el sueldo bruto',
                  prefixText: 'S/. ',
                  prefixIcon: Icon(Icons.attach_money_rounded),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Campo requerido';
                  final parsed = double.tryParse(val) ?? 0;
                  if (parsed <= 0) return 'Ingrese un monto válido';
                  return null;
                },
                onChanged: (v) =>
                    notifier.updateGrossSalary(double.tryParse(v) ?? 0),
              ),
              const SizedBox(height: 16),

              // ── 2. Sistema Pensionario ───────────────────────────────
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
                validator: (val) => val == null ? 'Requerido' : null,
                onChanged: (v) => notifier.updatePensionSystem(v!),
              ),
              const SizedBox(height: 16),

              // ── 3. AFP y Tipo de comisión (condicional) ──────────────
              if (data.pensionSystem == PensionSystem.afp) ...[
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
                  validator: (val) => val == null ? 'Requerido' : null,
                  onChanged: (v) => notifier.updateAfpType(v!),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<AfpCommissionType>(
                  value: data.commissionType,
                  hint: const Text('Seleccionar'),
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Comisión AFP',
                    prefixIcon: Icon(Icons.percent_rounded),
                  ),
                  dropdownColor: Colors.white,
                  items: AfpCommissionType.values
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c.displayName),
                          ))
                      .toList(),
                  validator: (val) => val == null ? 'Requerido' : null,
                  onChanged: (v) => notifier.updateCommissionType(v!),
                ),

                // Ayuda "No estoy seguro"
                if (data.commissionType == AfpCommissionType.noSabe) ...[
                  const SizedBox(height: 10),
                  _CommissionHint(),
                ],

                const SizedBox(height: 16),
              ],

              // ── 4. Asignación Familiar ────────────────────────────────
              _ToggleField(
                icon: Icons.family_restroom_rounded,
                label: '¿Tiene asignación familiar?',
                subtitle:
                    'S/. ${LegalParameters.kFamilyAllowance.toStringAsFixed(2)} / mes',
                value: data.hasFamilyAllowance,
                onChanged: notifier.updateFamilyAllowance,
              ),
              const SizedBox(height: 12),

              // ── 5. Horas Extra ───────────────────────────────────────
              _ToggleField(
                icon: Icons.access_time_filled_rounded,
                label: '¿Realizó horas extra este mes?',
                subtitle: _hasOvertime
                    ? 'Ingresa la cantidad abajo'
                    : 'Activa para ingresar horas',
                value: _hasOvertime,
                onChanged: (val) {
                  setState(() => _hasOvertime = val);
                  if (!val) {
                    notifier.updateOvertimeHours25(0);
                    notifier.updateOvertimeHours35(0);
                    _ot25Ctrl.clear();
                    _ot35Ctrl.clear();
                  }
                },
              ),

              if (_hasOvertime) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _ot25Ctrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                          labelText: 'HH.EE 25%',
                          hintText: '0',
                          prefixIcon: Icon(Icons.access_time_rounded),
                          suffixText: 'h',
                        ),
                        onChanged: (v) =>
                            notifier.updateOvertimeHours25(int.tryParse(v) ?? 0),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _ot35Ctrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                          labelText: 'HH.EE 35%',
                          hintText: '0',
                          prefixIcon: Icon(Icons.more_time_rounded),
                          suffixText: 'h',
                        ),
                        onChanged: (v) =>
                            notifier.updateOvertimeHours35(int.tryParse(v) ?? 0),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),

              // ── 6. EPS ──────────────────────────────────────────────
              _ToggleField(
                icon: Icons.health_and_safety_rounded,
                label: '¿Empresa con EPS?',
                subtitle: 'Bonif. ext. 6.75% en lugar de 9% EsSalud',
                value: data.hasEps,
                onChanged: notifier.updateHasEps,
              ),

              const SizedBox(height: 24),

              // ── Botón Calcular ───────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.calculate_rounded, size: 20),
                  label: const Text('Calcular ahora'),
                  onPressed: _onCalculate,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets auxiliares
// ─────────────────────────────────────────────────────────────────────────────

/// Toggle con estilo de tarjeta interna (switch + label)
class _ToggleField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleField({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: value
            ? AppTheme.kBlue.withValues(alpha: 0.05)
            : const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? AppTheme.kBlue.withValues(alpha: 0.4)
              : const Color(0xFFDDE1E9),
        ),
      ),
      child: SwitchListTile(
        secondary: Icon(
          icon,
          color: value ? AppTheme.kBlue : AppTheme.kTextHint,
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: value ? AppTheme.kTextPrimary : AppTheme.kTextSecondary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: AppTheme.kTextHint),
        ),
        value: value,
        onChanged: onChanged,
        dense: true,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

/// Hint compacto para "No estoy seguro" en comisión AFP
class _CommissionHint extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFCC02).withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 15)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Si te afiliaste después del 2013 o no recuerdas haber '
                  'hecho un trámite para cambiar tu comisión, probablemente '
                  'tengas la Comisión Mixta (80% de afiliados).',
                  style: TextStyle(fontSize: 12, color: Color(0xFF5C3D00)),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => ref
                      .read(employeeDataProvider.notifier)
                      .updateCommissionType(AfpCommissionType.mixta),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.kBlue,
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
