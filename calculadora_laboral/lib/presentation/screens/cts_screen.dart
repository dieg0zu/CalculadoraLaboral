import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/inputs/cts_inputs_panel.dart';
import '../providers/employee_data_provider.dart';
import 'cts_result_screen.dart';

/// Tab 3 — Cálculo de CTS (Compensación por Tiempo de Servicios)
class CtsScreen extends ConsumerWidget {
  const CtsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CtsInputsPanel(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.calculate_rounded, size: 20),
              label: const Text('Calcular ahora'),
              onPressed: () {
                final data = ref.read(ctsDataProvider);
                if (data.grossSalary <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, ingresa el sueldo bruto')),
                  );
                  return;
                }
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CtsResultScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
