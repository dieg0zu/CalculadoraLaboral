import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/inputs/gratification_inputs_panel.dart';
import '../providers/employee_data_provider.dart';
import '../../core/constants/legal_parameters.dart';
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
                if (data.hasInvalidDates || data.workedMonths == 0 && data.workedDays == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, ingresa fechas válidas y asegúrate que no haya errores.')),
                  );
                  return;
                }

                if (data.hasInvalidDates || data.workedMonths == 0 && data.workedDays == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, ingresa fechas válidas y asegúrate que no haya errores.')),
                  );
                  return;
                }

                if (data.regime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, selecciona un régimen laboral')),
                  );
                  return;
                }
                
                if (data.regime == CompanyRegime.micro || data.regime == CompanyRegime.intern) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Este régimen no aplica para Gratificación')),
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

                if (data.bonusesMeetRegularity == null && data.bonuses > 0) {
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

                if (data.healthInsurance == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, selecciona un seguro de salud')),
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
