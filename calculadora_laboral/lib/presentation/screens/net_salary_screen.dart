import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/employee_data_provider.dart';
import '../../core/constants/legal_parameters.dart';
import '../widgets/inputs/net_salary_inputs_panel.dart';
import 'net_salary_result_screen.dart';

/// Tab 1 — Sueldo Neto Mensual.
///
/// Formulario de datos para el cálculo. Al darle a calcular, abre una nueva ventana
/// con el resultado final.
class NetSalaryScreen extends ConsumerWidget {
  const NetSalaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Calculadora de Sueldo Neto',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),

          const NetSalaryInputsPanel(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF005CEE),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.calculate_outlined, size: 20),
              label: const Text('Calcular Ahora', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              onPressed: () {
                final data = ref.read(netSalaryDataProvider);
                // Validación de campos obligatorios
                if (data.grossSalary <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, ingresa el sueldo bruto')),
                  );
                  return;
                }
                
                if (data.hasFamilyAllowance == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, selecciona si tienes hijos')),
                  );
                  return;
                }
                
                if (data.pensionSystem == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, selecciona un sistema pensionario')),
                  );
                  return;
                }
                
                if (data.pensionSystem == PensionSystem.afp && data.afpType == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, selecciona tu entidad AFP')),
                  );
                  return;
                }

                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NetSalaryResultScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
