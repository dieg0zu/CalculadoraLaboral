import 'package:flutter/material.dart';
import '../../domain/entities/liquidation_result.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/shared/banner_ad_widget.dart';

class LiquidationResultScreen extends StatelessWidget {
  final LiquidationResult result;

  const LiquidationResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    const bool showDetails = false;

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
            // ── Tarjeta Principal (Total Neto) ──
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
              child: Column(
                children: [
                  const Text(
                    'TOTAL NETO A RECIBIR',
                    style: TextStyle(
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyFormatter.format(result.totalToPay),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 34,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

              if (showDetails) ...[
                // ── Desglose de la Liquidación ──
              const Text(
                'Desglose de la Liquidación',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),

              _buildDetailCard(
                title: 'Conceptos Brutos',
                icon: Icons.attach_money_rounded,
                iconColor: Colors.greenAccent,
                children: [
                  if (result.netPendingSalary > 0)
                    _buildDetailRow('Sueldo del mes de cese', result.netPendingSalary),
                  if (result.currentMonthOvertimeResult > 0)
                    _buildDetailRow('HH.EE. del mes de cese', result.currentMonthOvertimeResult),
                  if (result.netGratification > 0)
                    _buildDetailRow('Gratificación Trunca + Bono', result.netGratification),
                  if (result.netCtsInLiquidation > 0)
                    _buildDetailRow('CTS Trunca', result.netCtsInLiquidation),
                  if (result.netVacations > 0)
                    _buildDetailRow('Vacaciones no gozadas', result.netVacations),
                  // Retención pensionaria centralizada (AFP/ONP)
                  if (result.pensionDeduction > 0) ...[
                    const Divider(color: Colors.white24, height: 24),
                    _buildDeductionRow(
                      'Retención AFP/ONP (sueldo + HH.EE. + vacaciones)',
                      result.pensionDeduction,
                    ),
                  ],
                  if (result.epsDeduction > 0) ...[
                    if (result.pensionDeduction == 0) const Divider(color: Colors.white24, height: 24),
                    _buildDeductionRow(
                      'Deducción EPS',
                      result.epsDeduction,
                    ),
                  ],
                  if (result.otherDeductions > 0) ...[
                    if (result.pensionDeduction == 0 && result.epsDeduction == 0) const Divider(color: Colors.white24, height: 24),
                    _buildDeductionRow(
                      'Otras Deducciones al cese',
                      result.otherDeductions,
                    ),
                  ],
                  const Divider(color: Colors.white24, height: 24),
                  _buildDetailRow('Total Neto a Recibir', result.totalToPay, isBold: true),
                ],
              ),

              if (result.ctsInBank > 0) ...[
                const SizedBox(height: 24),
                _buildDetailCard(
                  title: 'Información CTS en Banco',
                  icon: Icons.account_balance_rounded,
                  iconColor: Colors.blueAccent,
                  isInformative: true,
                  children: [
                    const Text(
                      'Este monto corresponde al periodo CTS que ya cortó y debe ser depositado directamente a su cuenta bancaria, no se entrega en efectivo en la liquidación.',
                      style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('CTS a depositar en banco', result.ctsInBank, isInformative: true),
                  ],
                ),
              ],
              const SizedBox(height: 32),
              ],

              // ── Botón Volver ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.refresh_rounded, size: 22),
                  label: const Text('Volver a calcular'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(height: 24),
              const BannerAdWidget(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      );
    }

  Widget _buildDetailCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
    bool isInformative = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.kTextPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    double value, {
    bool isBold = false,
    bool isInformative = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isBold ? AppTheme.kTextPrimary : AppTheme.kTextSecondary,
                fontSize: isBold ? 14 : 13,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            CurrencyFormatter.format(value),
            style: TextStyle(
              color: isInformative
                  ? Colors.blueAccent
                  : (isBold ? AppTheme.kTextPrimary : const Color(0xFF1A1A2E)),
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Fila de deducción: valor en ámbar con signo "−" para distinguirlo
  /// claramente de los conceptos positivos.
  Widget _buildDeductionRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFD97706),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '− ${CurrencyFormatter.format(value)}',
            style: const TextStyle(
              color: Color(0xFFD97706),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
