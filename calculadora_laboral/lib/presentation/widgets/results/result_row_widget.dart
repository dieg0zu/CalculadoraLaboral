import 'package:flutter/material.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/theme/app_theme.dart';

enum ResultRowType { income, deduction, total, neutral }

/// Widget de fila de resultado reutilizable para todas las tarjetas.
///
/// Muestra un concepto (label) y su monto, con colores semánticos:
/// - Ingresos: verde
/// - Deducciones: rojo/naranja
/// - Total: color primario destacado
/// - Neutral: color de texto estándar
class ResultRow extends StatelessWidget {
  final String label;
  final double amount;
  final ResultRowType type;
  final String? subtitle;
  final bool isLast;

  const ResultRow({
    super.key,
    required this.label,
    required this.amount,
    this.type = ResultRowType.neutral,
    this.subtitle,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Colores por tipo de fila
    final amountColor = switch (type) {
      ResultRowType.income => const Color(0xFF1A1A2E),      // texto oscuro
      ResultRowType.deduction => const Color(0xFF555566),   // gris medio
      ResultRowType.total => AppTheme.kBlue,                // azul
      ResultRowType.neutral => const Color(0xFF333344),
    };

    final labelStyle = type == ResultRowType.total
        ? textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          )
        : textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF555566),
          );

    final amountStyle = type == ResultRowType.total
        ? textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: amountColor,
          )
        : textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: amountColor,
          );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: labelStyle),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                type == ResultRowType.deduction
                    ? '- ${CurrencyFormatter.format(amount)}'
                    : CurrencyFormatter.format(amount),
                style: amountStyle,
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Color(0xFFEEEEEE),
          ),
      ],
    );
  }
}
