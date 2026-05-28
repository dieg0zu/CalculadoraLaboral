import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/inputs/gratification_inputs_panel.dart';
import '../providers/employee_data_provider.dart';
import 'gratification_result_screen.dart';

/// Tab 2 — Gratificación semestral
class GratificationScreen extends ConsumerWidget {
  const GratificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Usa el nuevo panel independiente para Gratificación
          const GratificationInputsPanel(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.calculate_rounded, size: 20),
              label: const Text('Calcular ahora'),
              onPressed: () {
                final data = ref.read(gratificationDataProvider);
                if (data.grossSalary <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, ingresa el sueldo bruto')),
                  );
                  return;
                }
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const GratificationResultScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
