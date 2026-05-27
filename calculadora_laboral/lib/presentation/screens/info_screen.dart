import 'package:flutter/material.dart';
import '../../core/constants/legal_parameters.dart';
import '../../core/utils/currency_formatter.dart';

/// Tab 5 — Información legal y parámetros vigentes
///
/// Muestra los valores de la clase LegalParameters de forma amigable,
/// sirviendo como referencia para el usuario.
class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.gavel_rounded, color: Colors.white, size: 32),
                const SizedBox(height: 12),
                Text(
                  'Parámetros Legales 2025',
                  style: textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Valores vigentes del marco legal peruano para el cálculo de planillas.',
                  style: textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Remuneraciones Base ───────────────────────────────────
          _InfoSection(
            title: 'Remuneraciones de referencia',
            icon: Icons.payments_rounded,
            items: [
              _InfoItem('RMV (Remuneración Mínima Vital)',
                  CurrencyFormatter.format(LegalParameters.kRMV),
                  'DS 003-2025-TR'),
              _InfoItem('UIT (Unidad Impositiva Tributaria)',
                  CurrencyFormatter.format(LegalParameters.kUIT),
                  'RS 000-2025-EF'),
              _InfoItem('Asignación Familiar',
                  CurrencyFormatter.format(LegalParameters.kFamilyAllowance),
                  '10% de la RMV — Ley 25129'),
            ],
          ),

          // ── Aportes Empleador ─────────────────────────────────────
          _InfoSection(
            title: 'Aportes del empleador',
            icon: Icons.business_rounded,
            items: [
              _InfoItem('EsSalud',
                  CurrencyFormatter.formatPercent(LegalParameters.kEsSaludRate),
                  'Sobre el sueldo bruto'),
              _InfoItem('EPS (alternativa)',
                  CurrencyFormatter.formatPercent(LegalParameters.kEpsRate),
                  'Cuando el empleador tiene EPS'),
            ],
          ),

          // ── Pensiones ─────────────────────────────────────────────
          _InfoSection(
            title: 'Sistema Pensionario',
            icon: Icons.account_balance_rounded,
            items: [
              _InfoItem('ONP',
                  CurrencyFormatter.formatPercent(LegalParameters.kOnpRate),
                  'Sobre el total remunerativo'),
              _InfoItem('AFP — Aporte al fondo',
                  CurrencyFormatter.formatPercent(LegalParameters.kAfpFondoRate),
                  'Igual para todas las AFP'),
              const _InfoItem('AFP Prima — Comisión flujo', '1.60%', 'Prima de seguro: 1.84%'),
              const _InfoItem('AFP Integra — Comisión flujo', '1.55%', 'Prima de seguro: 1.84%'),
              const _InfoItem('AFP Profuturo — Comisión flujo', '1.69%', 'Prima de seguro: 1.84%'),
              const _InfoItem('AFP Habitat — Comisión flujo', '1.38%', 'Prima de seguro: 1.84%'),
            ],
          ),

          // ── Quinta Categoría ──────────────────────────────────────
          _InfoSection(
            title: '5ta Categoría — Tramos IR',
            icon: Icons.percent_rounded,
            items: [
              const _InfoItem('Deducción estándar', '7 UIT', 'S/. 36,050 anuales'),
              for (final b in LegalParameters.kFifthCategoryBrackets)
                _InfoItem(
                  b.toUIT.isFinite
                      ? '${b.fromUIT.toInt()} a ${b.toUIT.toInt()} UIT'
                      : 'Más de ${b.fromUIT.toInt()} UIT',
                  CurrencyFormatter.formatPercent(b.rate),
                  'Sobre el exceso del tramo',
                ),
            ],
          ),

          // ── Horas Extra ───────────────────────────────────────────
          _InfoSection(
            title: 'Horas Extraordinarias',
            icon: Icons.access_time_rounded,
            items: [
              _InfoItem('Sobretasa primeras 2 horas',
                  CurrencyFormatter.formatPercent(LegalParameters.kOvertimeRate25),
                  'DL 854'),
              _InfoItem('Sobretasa horas adicionales',
                  CurrencyFormatter.formatPercent(LegalParameters.kOvertimeRate35),
                  'DL 854'),
            ],
          ),

          // ── Nota Disclaimer ───────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_rounded, size: 16,
                    color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Esta aplicación es una herramienta de referencia. Los valores '
                    'pueden variar según convenios colectivos, regímenes especiales '
                    'o modificaciones normativas posteriores a la última actualización.',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_InfoItem> items;

  const _InfoSection({
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: colorScheme.onPrimaryContainer),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          ...items.asMap().entries.map((entry) {
            final isLast = entry.key == items.length - 1;
            return _InfoItemTile(item: entry.value, isLast: isLast);
          }),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;
  final String source;
  const _InfoItem(this.label, this.value, this.source);
}

class _InfoItemTile extends StatelessWidget {
  final _InfoItem item;
  final bool isLast;

  const _InfoItemTile({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.label,
                        style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface)),
                    Text(item.source,
                        style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.7))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.value,
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
      ],
    );
  }
}
