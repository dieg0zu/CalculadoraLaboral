import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/payroll_providers.dart';
import '../providers/employee_data_provider.dart';
import '../../core/utils/currency_formatter.dart';

class CtsResultScreen extends ConsumerWidget {
  const CtsResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(ctsResultProvider);
    final data = ref.watch(ctsDataProvider);
    final textTheme = Theme.of(context).textTheme;

    final isWorking = data.isCurrentlyWorking ?? true;
    final hasDeposit = result.ctsDepositadaBanco > 0;

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
            if (isWorking) ...[
              _buildBannerCard(
                title: 'CTS PROYECTADA A DEPOSITAR',
                amount: result.totalCts,
                color1: const Color(0xFF007AFF),
                color2: const Color(0xFF0056B3),
                icon: Icons.account_balance_rounded,
                textTheme: textTheme,
              ),
            ] else ...[
              if (hasDeposit) ...[
                _buildBannerCard(
                  title: 'CTS DEPOSITADA EN BANCO',
                  amount: result.ctsDepositadaBanco,
                  color1: const Color(0xFF007AFF),
                  color2: const Color(0xFF0056B3),
                  icon: Icons.account_balance_rounded,
                  textTheme: textTheme,
                ),
                const SizedBox(height: 16),
                _buildBannerCard(
                  title: 'CTS TRUNCA (LIQUIDACIÓN)',
                  amount: result.ctsTruncaLiquidacion,
                  color1: const Color(0xFF10B981),
                  color2: const Color(0xFF059669),
                  icon: Icons.monetization_on_rounded,
                  textTheme: textTheme,
                ),
              ] else ...[
                _buildBannerCard(
                  title: 'CTS TRUNCA (LIQUIDACIÓN)',
                  amount: result.ctsTruncaLiquidacion,
                  color1: const Color(0xFF10B981),
                  color2: const Color(0xFF059669),
                  icon: Icons.monetization_on_rounded,
                  textTheme: textTheme,
                ),
              ],
            ],
            
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

  Widget _buildBannerCard({
    required String title,
    required double amount,
    required Color color1,
    required Color color2,
    required IconData icon,
    required TextTheme textTheme,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color1, color2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color1.withValues(alpha: 0.35),
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
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  CurrencyFormatter.format(amount),
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
            child: Icon(
              icon,
              color: Colors.white,
              size: 38,
            ),
          ),
        ],
      ),
    );
  }
}