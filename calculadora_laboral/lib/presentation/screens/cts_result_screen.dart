import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/payroll_providers.dart';
import '../widgets/results/section_card.dart';
import '../widgets/results/result_row_widget.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/theme/app_theme.dart';

class CtsResultScreen extends ConsumerWidget {
  const CtsResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(ctsResultProvider);
    final textTheme = Theme.of(context).textTheme;

    // Desglose oculto por solicitud del usuario
    const bool _showBreakdown = false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado de CTS'),
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
            // ── Banner principal azul ─────────────────────────────────
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
                          'DEPÓSITO DE CTS',
                          style: TextStyle(
                            fontSize: 12,
                            letterSpacing: 2.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          CurrencyFormatter.format(result.totalCts),
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
                      Icons.account_balance_rounded,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (_showBreakdown) ...[
              SectionCard(
                title: 'DESGLOSE DEL CÁLCULO',
                icon: Icons.calculate_outlined,
                children: [
                  ResultRow(
                    label: 'Remuneración computable',
                    subtitle: 'Incluye 1/6 de gratificación',
                    amount: result.computableSalary,
                    type: ResultRowType.neutral,
                  ),
                  ResultRow(
                    label: 'Tiempo laborado computable',
                    subtitle: '${result.completedMonths} meses y ${result.additionalDays} días',
                    amount: 0, // No es un monto, lo usamos para el subtítulo
                    type: ResultRowType.neutral,
                  ),
                  ResultRow(
                    label: 'Total CTS a depositar',
                    amount: result.totalCts,
                    type: ResultRowType.total,
                    isLast: true,
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],

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
