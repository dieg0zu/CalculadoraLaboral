import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/legal_parameters.dart';
import '../../providers/employee_data_provider.dart';

class NetSalaryInputsPanel extends ConsumerStatefulWidget {
  const NetSalaryInputsPanel({super.key});

  @override
  ConsumerState<NetSalaryInputsPanel> createState() => _NetSalaryInputsPanelState();
}

class _NetSalaryInputsPanelState extends ConsumerState<NetSalaryInputsPanel> {
  @override
  Widget build(BuildContext context) {
    final data = ref.watch(netSalaryDataProvider);
    final notifier = ref.read(netSalaryDataProvider.notifier);

    // Color tokens from the image
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
            color: Colors.black.withOpacity(0.02),
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
            // 1. SUELDO BRUTO
            const Text(
              'Sueldo Bruto Mensual (S/)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: data.grossSalary == 0 ? '' : CurrencyTextInputFormatter.currency(locale: 'es', symbol: '', decimalDigits: 2).formatDouble(data.grossSalary),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'-')), CurrencyTextInputFormatter.currency(locale: 'es', symbol: '', decimalDigits: 2)],
              style: const TextStyle(fontSize: 16, color: textDark),
              decoration: InputDecoration(
                filled: true,
                fillColor: lightBlueBg,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: primaryBlue, width: 1.5),
                ),
              ),
              onChanged: (v) => notifier.updateGrossSalary(double.tryParse(v.replaceAll('.', '').replaceAll(',', '.')) ?? 0),
            ),
            const SizedBox(height: 20),

            // 2. ASIGNACIÓN FAMILIAR (Radio buttons)
            const Text(
              '¿Tienes hijos? (Asignación Familiar)',
              style: TextStyle(
                fontSize: 14,
                color: textDark,
              ),
            ),
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

            // 3. SISTEMA DE PENSIONES (Caja Gris)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: lightGreyBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined, size: 16, color: Color(0xFF64748B)),
                      const SizedBox(width: 8),
                      const Text(
                        'Sistema de Pensiones',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  const Text('Régimen', style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
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
                        hint: const Text('Seleccionar', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                        isExpanded: true,
                        icon: const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        items: PensionSystem.values.map((sys) {
                          return DropdownMenuItem(value: sys, child: Text(sys.displayName, style: const TextStyle(fontSize: 14)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            notifier.updatePensionSystem(val);
                            if (val == PensionSystem.afp) {
                              // Se asume siempre mixta como pidió el usuario
                              notifier.updateCommissionType(AfpCommissionType.mixta);
                            }
                          }
                        },
                      ),
                    ),
                  ),

                  if (data.pensionSystem == PensionSystem.afp) ...[
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
                          value: data.afpType, // Default to null initially as per user request
                          hint: const Text('Seleccionar', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                          isExpanded: true,
                          icon: const Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          items: AfpType.values.map((afp) {
                            return DropdownMenuItem(value: afp, child: Text(afp.displayName, style: const TextStyle(fontSize: 14)));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              notifier.updateAfpType(val);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 4. EPS (Caja Azul Clara con Switch)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: lightBlueBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('¿Afiliado a EPS?', style: TextStyle(fontSize: 14, color: textDark)),
                          Text('Empresa Prestadora de Salud', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        ],
                      ),
                      Switch(
                        value: data.healthInsurance == HealthInsurance.eps,
                        activeColor: Colors.white,
                        activeTrackColor: primaryBlue,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: const Color(0xFFCBD5E1),
                        onChanged: (val) {
                          if (val) {
                            notifier.updateHealthInsurance(HealthInsurance.eps);
                          } else {
                            notifier.updateHealthInsurance(HealthInsurance.essalud);
                            notifier.updateEpsCost(0);
                          }
                        },
                      ),
                    ],
                  ),
                  if (data.healthInsurance == HealthInsurance.eps) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: data.epsCost == 0 ? '' : CurrencyTextInputFormatter.currency(locale: 'es', symbol: '', decimalDigits: 2).formatDouble(data.epsCost),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'-')), CurrencyTextInputFormatter.currency(locale: 'es', symbol: '', decimalDigits: 2)],
                      style: const TextStyle(fontSize: 14, color: textDark),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Costo de plan (S/)',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: primaryBlue),
                        ),
                      ),
                      onChanged: (v) => notifier.updateEpsCost(double.tryParse(v.replaceAll('.', '').replaceAll(',', '.')) ?? 0),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
