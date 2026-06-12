import 'package:flutter/material.dart';
import '../../domain/entities/liquidation_result.dart';
import '../../core/utils/currency_formatter.dart';

class LiquidationResultScreen extends StatelessWidget {
  final LiquidationResult result;

  const LiquidationResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Resultado de Liquidación', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Tarjeta Principal (Total Neto) ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'TOTAL NETO A RECIBIR',
                      style: textTheme.titleSmall?.copyWith(
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w700,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      CurrencyFormatter.format(result.totalToPay),
                      style: textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 38,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

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
                  if (result.netGratification > 0)
                    _buildDetailRow('Gratificación Trunca + Bono', result.netGratification),
                  if (result.netCtsInLiquidation > 0)
                    _buildDetailRow('CTS Trunca', result.netCtsInLiquidation),
                  if (result.netVacations > 0)
                    _buildDetailRow('Vacaciones no gozadas', result.netVacations),
                  if (result.extraPayments > 0)
                    _buildDetailRow('Otros pagos pendientes', result.extraPayments),
                  // Retención pensionaria centralizada (AFP/ONP)
                  if (result.pensionDeduction > 0) ...[
                    const Divider(color: Colors.white24, height: 24),
                    _buildDeductionRow(
                      'Retención AFP/ONP (sueldo + vacaciones + otros)',
                      result.pensionDeduction,
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

              // ── Botón Volver ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.refresh_rounded, size: 22),
                  label: const Text('Volver a calcular'),
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
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
        color: isInformative ? Colors.blue.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isInformative ? Colors.blue.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.1),
        ),
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
                  style: TextStyle(
                    color: isInformative ? Colors.white70 : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
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
                color: isInformative
                    ? Colors.white60
                    : (isBold ? Colors.white : Colors.white70),
                fontSize: isBold ? 16 : 15,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
          Text(
            CurrencyFormatter.format(value),
            style: TextStyle(
              color: isInformative
                  ? Colors.blueAccent.shade100
                  : (isBold ? Colors.white : Colors.white),
              fontSize: isBold ? 16 : 15,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
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
                color: Color(0xFFFBBF24), // amber-400
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Text(
            '− ${CurrencyFormatter.format(value)}',
            style: const TextStyle(
              color: Color(0xFFFBBF24),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
