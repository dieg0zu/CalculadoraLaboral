import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/inputs/inputs_panel.dart';
import '../providers/employee_data_provider.dart';
import 'vacation_liquidation_result_screen.dart';

/// Tab 4 — Liquidación y Vacaciones Truncas
class VacationLiquidationScreen extends ConsumerStatefulWidget {
  const VacationLiquidationScreen({super.key});

  @override
  ConsumerState<VacationLiquidationScreen> createState() => _VacationLiquidationScreenState();
}

class _VacationLiquidationScreenState extends ConsumerState<VacationLiquidationScreen> {
  void _onCalculate() {
    final data = ref.read(employeeDataProvider);

    if (data.grossSalary <= 0 ||
        (data.workedMonths == 0 && data.workedDays == 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, complete todos los campos')),
      );
      return;
    }

    // ── Todo OK → navegar ────────────────────────────────────────────
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const VacationLiquidationResultScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const InputsPanel(
            showBonuses: true,
            showPensionSystem: true,
            showEps: true,
            showWorkedTimeFields: true,
            showWorkedDays: true,
          ),
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
              icon: const Icon(Icons.calculate_rounded, size: 20),
              label: const Text('Calcular ahora', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              onPressed: _onCalculate,
            ),
          ),
        ],
      ),
    );
  }
}
