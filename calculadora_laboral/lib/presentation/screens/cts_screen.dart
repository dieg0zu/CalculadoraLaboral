import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/inputs/cts_inputs_panel.dart';
import '../providers/employee_data_provider.dart';
import 'cts_result_screen.dart';

/// Tab 3 — Cálculo de CTS (Compensación por Tiempo de Servicios)
class CtsScreen extends ConsumerStatefulWidget {
  const CtsScreen({super.key});

  @override
  ConsumerState<CtsScreen> createState() => _CtsScreenState();
}

class _CtsScreenState extends ConsumerState<CtsScreen> {
  void _onCalculate() {
    final data = ref.read(ctsDataProvider);

    if (data.startDate == null ||
        (data.isCurrentlyWorking == false && data.endDate == null) ||
        data.regime == null ||
        data.grossSalary <= 0 ||
        data.isCurrentlyWorking == null ||
        data.hasFamilyAllowance == null ||
        data.hasLastGratification == null ||
        (data.hasLastGratification == true && data.lastGratificationAmount <= 0) ||
        data.bonusesMeetRegularity == null ||
        (data.bonusesMeetRegularity == true && data.semesterTotalBonuses <= 0) ||
        data.overtimeMeetRegularity == null ||
        (data.overtimeMeetRegularity == true && data.semesterTotalOvertime <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, complete todos los campos')),
      );
      return;
    }

    // ── Todo OK → navegar ────────────────────────────────────────────
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CtsResultScreen()),
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
              onPressed: _onCalculate,
            ),
          ),
        ],
      ),
    );
  }
}
