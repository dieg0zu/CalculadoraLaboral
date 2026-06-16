import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/inputs/gratification_inputs_panel.dart';
import '../providers/employee_data_provider.dart';
import 'gratification_result_screen.dart';

/// Tab 2 — Gratificación semestral
class GratificationScreen extends ConsumerStatefulWidget {
  const GratificationScreen({super.key});

  @override
  ConsumerState<GratificationScreen> createState() => _GratificationScreenState();
}

class _GratificationScreenState extends ConsumerState<GratificationScreen> {
  void _onCalculate() {
    final data = ref.read(gratificationDataProvider);

    if (data.startDate == null ||
        (data.isCurrentlyWorking == false && data.endDate == null) ||
        data.regime == null ||
        data.grossSalary <= 0 ||
        data.isCurrentlyWorking == null ||
        data.hasFamilyAllowance == null ||
        data.bonusesMeetRegularity == null ||
        (data.bonusesMeetRegularity == true && data.semesterTotalBonuses <= 0) ||
        data.overtimeMeetRegularity == null ||
        (data.overtimeMeetRegularity == true && data.semesterTotalOvertime <= 0) ||
        data.healthInsurance == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, complete todos los campos')),
      );
      return;
    }

    // ── Todo OK → navegar ────────────────────────────────────────────
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GratificationResultScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const GratificationInputsPanel(),
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
