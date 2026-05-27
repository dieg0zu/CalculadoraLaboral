import 'package:flutter/material.dart';

/// Card de sección con cabecera coloreada y contenido de lista.
///
/// Usada en todos los tabs de resultados para mostrar grupos
/// de conceptos (ej. "Ingresos", "Deducciones", "Total").
class SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? headerColor;
  final List<Widget> children;

  const SectionCard({
    super.key,
    required this.title,
    required this.icon,
    this.headerColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHeaderColor = headerColor ?? const Color(0xFFEEF2FB);
    // Texto siempre oscuro
    const onHeaderColor = Color(0xFF1A2A45);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera
          Container(
            decoration: BoxDecoration(
              color: effectiveHeaderColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 20, color: onHeaderColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: onHeaderColor,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                ),
              ],
            ),
          ),
          // Contenido
          Column(children: children),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
