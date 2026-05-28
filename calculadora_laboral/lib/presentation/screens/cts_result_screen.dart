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
            // ── Aviso Importante ─────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF87171)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, color: Color(0xFFDC2626)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Aviso: Este cálculo asume que aún no se le ha depositado la CTS correspondiente a este periodo. Si ya se le depositó y cesa sus labores poco después, este monto NO es adicional; solo le correspondería el cálculo por los días extra trabajados después de su último depósito.',
                      style: const TextStyle(color: Color(0xFF991B1B), fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

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
