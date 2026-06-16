import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/employee_data_provider.dart';
import '../../core/constants/legal_parameters.dart';
import '../widgets/inputs/net_salary_inputs_panel.dart';
import 'net_salary_result_screen.dart';

/// Tab 1 — Sueldo Neto Mensual.
class NetSalaryScreen extends ConsumerStatefulWidget {
  const NetSalaryScreen({super.key});

  @override
  ConsumerState<NetSalaryScreen> createState() => _NetSalaryScreenState();
}

class _NetSalaryScreenState extends ConsumerState<NetSalaryScreen> {
  void _onCalculate() {
    final data = ref.read(netSalaryDataProvider);

    if (data.grossSalary <= 0 ||
        data.hasFamilyAllowance == null ||
        data.pensionSystem == null ||
        (data.pensionSystem == PensionSystem.afp && data.afpType == null) ||
        data.healthInsurance == null ||
        (data.healthInsurance == HealthInsurance.eps && data.epsCost <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, complete todos los campos')),
      );
      return;
    }

    // ── Todo OK → navegar ────────────────────────────────────────────
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NetSalaryResultScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              onPressed: _onCalculate,
            ),
          ),
        ],
      ),
    );
  }
}
