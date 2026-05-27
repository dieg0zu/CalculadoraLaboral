import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/payroll_providers.dart';
import '../widgets/results/section_card.dart';
import '../widgets/results/result_row_widget.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/theme/app_theme.dart';

class GratificationResultScreen extends ConsumerWidget {
  const GratificationResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(gratificationResultProvider);
    final textTheme = Theme.of(context).textTheme;

    // Desglose oculto por solicitud del usuario
    const bool _showBreakdown = false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado de Gratificación'),
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
                        Text(
                          'GRATIFICACIÓN ${result.semester.toUpperCase()}',
                          style: const TextStyle(
                            fontSize: 12,
                            letterSpacing: 2.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          CurrencyFormatter.format(result.totalGratification),
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
                      Icons.card_giftcard_rounded,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Nota legal ────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE4E7ED)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 18, color: AppTheme.kTextSecondary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Las gratificaciones están exoneradas de aportes al sistema '
                      'pensionario (ONP/AFP) por Ley 29351, prorrogada indefinidamente.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.kTextSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (_showBreakdown) ...[
              SectionCard(
                title: 'DESGLOSE DE GRATIFICACIÓN',
                icon: Icons.receipt_long_rounded,
                children: [
                  ResultRow(
                    label: 'Remuneración computable',
                    subtitle: 'Sueldo bruto + Asig. familiar',
                    amount: result.computableSalary,
                    type: ResultRowType.neutral,
                  ),
                  ResultRow(
                    label: 'Gratificación base',
                    subtitle: '(Rem. comp. / 6) × ${result.completedMonths} meses',
                    amount: result.baseGratification,
                    type: ResultRowType.income,
                  ),
                  ResultRow(
                    label: result.usedEps
                        ? 'Bonif. extraord. Ley 29351 (EPS 6.75%)'
                        : 'Bonif. extraord. Ley 29351 (EsSalud 9%)',
                    subtitle: 'Pagada por el empleador al trabajador',
                    amount: result.extraordinaryBonus,
                    type: ResultRowType.income,
                  ),
                  ResultRow(
                    label: 'Total a recibir',
                    amount: result.totalGratification,
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
