import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/payroll_providers.dart';
import '../providers/employee_data_provider.dart';
import '../widgets/results/section_card.dart';
import '../widgets/results/result_row_widget.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/legal_parameters.dart';

/// Pantalla que muestra ÚNICAMENTE el resultado del cálculo del Sueldo Neto.
/// Se abre como una nueva ventana después de hacer clic en "Calcular ahora".
class NetSalaryResultScreen extends ConsumerWidget {
  const NetSalaryResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(netSalaryDataProvider);
    final result = ref.watch(payrollResultProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado del Cálculo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Banner principal azul (Sueldo Neto) ─────────────────
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF007AFF), Color(0xFF0056B3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.kBlue.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SUELDO NETO A PAGAR',
                          style: TextStyle(
                            fontSize: 12,
                            letterSpacing: 2.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          CurrencyFormatter.format(result.netSalary),
                          style: textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 38,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Resumen compacto (Tarjeta blanca) ───────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE4E7ED)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  _SummaryRow(
                      label: 'Ingresos brutos',
                      value: CurrencyFormatter.format(result.totalEarnings)),
                  const SizedBox(height: 10),
                  _SummaryRow(
                      label: 'Total deducciones',
                      value: '− ${CurrencyFormatter.format(result.totalDeductions)}',
                      valueColor: const Color(0xFF555566)),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Color(0xFFEAECF0)),
                  ),
                  _SummaryRow(
                      label: 'Sueldo neto',
                      value: CurrencyFormatter.format(result.netSalary),
                      isBold: true,
                      valueColor: AppTheme.kBlue),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Desglose de Deducciones ─────────────────────────────
            SectionCard(
              title: 'DESGLOSE DE DEDUCCIONES',
              icon: Icons.receipt_long_outlined,
              children: [
                ResultRow(
                  label: result.pensionDetail.systemName,
                  amount: result.pensionDetail.totalRetention,
                  type: ResultRowType.deduction,
                ),
                if (result.pensionDetail.fondoAporte > 0) ...[
                  ResultRow(
                    label: '  • Aporte al fondo (10%)',
                    amount: result.pensionDetail.fondoAporte,
                    type: ResultRowType.deduction,
                  ),
                  ResultRow(
                    label: '  • Comisión AFP',
                    amount: result.pensionDetail.afpCommission,
                    type: ResultRowType.deduction,
                  ),
                  ResultRow(
                    label: '  • Prima de seguro',
                    amount: result.pensionDetail.insurancePremium,
                    type: ResultRowType.deduction,
                  ),
                ],
                if (result.fifthCategoryRetention > 0)
                  ResultRow(
                    label: 'Retención 5ta Categoría',
                    subtitle: 'Proyección anual ÷ 12',
                    amount: result.fifthCategoryRetention,
                    type: ResultRowType.deduction,
                  ),
                if (data.epsCost > 0)
                  ResultRow(
                    label: 'Descuento Plan EPS',
                    amount: data.epsCost,
                    type: ResultRowType.deduction,
                  ),
                ResultRow(
                  label: 'Total deducciones',
                  amount: result.totalDeductions,
                  type: ResultRowType.total,
                  isLast: true,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Costo del Empleador ─────────────────────────────────
            SectionCard(
              title: 'COSTOS DEL EMPLEADOR',
              icon: Icons.business_center_rounded,
              children: [
                ResultRow(
                  label: data.healthInsurance.displayName,
                  subtitle: data.healthInsurance == HealthInsurance.sis 
                      ? 'Costo fijo mensual' 
                      : 'Aporte obligatorio (9%)',
                  amount: result.employerHealthCost,
                  type: ResultRowType.income,
                  isLast: true,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ── Botón Volver a calcular ─────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.refresh_rounded, size: 22),
                label: const Text('Volver a calcular'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: isBold ? AppTheme.kTextPrimary : AppTheme.kTextSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? (isBold ? AppTheme.kTextPrimary : const Color(0xFF1A1A2E)),
          ),
        ),
      ],
    );
  }
}
