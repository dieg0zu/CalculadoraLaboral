import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/inputs/cts_inputs_panel.dart';
import '../providers/employee_data_provider.dart';
import '../../core/constants/legal_parameters.dart';
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
          const Text(
            'Calculadora de CTS',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          const CtsInputsPanel(),
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
                final data = ref.read(ctsDataProvider);
                if (data.regime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, selecciona un régimen laboral')),
                  );
                  return;
                }
                
                if (data.regime == CompanyRegime.micro || data.regime == CompanyRegime.intern) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Este régimen no aplica para CTS')),
                  );
                  return;
                }

                if (data.grossSalary <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, ingresa el sueldo bruto')),
                  );
                  return;
                }

                if (data.isCurrentlyWorking == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, indica si sigue trabajando')),
                  );
                  return;
                }

                if (data.hasFamilyAllowance == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, indica si tiene asignación familiar')),
                  );
                  return;
                }

                if (data.hasLastGratification == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, indica si recibiste gratificación')),
                  );
                  return;
                }

                if (data.hasLastGratification == true && data.lastGratificationAmount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, ingresa un monto válido de gratificación')),
                  );
                  return;
                }

                if (data.bonusesMeetRegularity == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, indica la regularidad de los bonos')),
                  );
                  return;
                }

                if (data.overtimeMeetRegularity == null && (data.overtimeHours25 > 0 || data.overtimeHours35 > 0)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, indica la regularidad de las horas extras')),
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
