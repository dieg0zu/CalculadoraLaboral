import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/inputs/liquidation_inputs_panel.dart';
import '../../domain/usecases/calculate_liquidation.dart';
import '../providers/liquidation_data_provider.dart';
import 'liquidation_result_screen.dart';

class LiquidationScreen extends ConsumerStatefulWidget {
  const LiquidationScreen({super.key});

  @override
  ConsumerState<LiquidationScreen> createState() => _LiquidationScreenState();
}

class _LiquidationScreenState extends ConsumerState<LiquidationScreen> {

  void _onCalculate(DateTime startDate, DateTime endDate) {
    final data = ref.read(liquidationDataProvider).copyWith(
      startDate: startDate,
      endDate: endDate,
    );
    final calculateUseCase = CalculateLiquidationUseCase();
    
    final result = calculateUseCase(data);

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LiquidationResultScreen(result: result)),
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
            'Calculadora de Liquidación',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          LiquidationInputsPanel(onCalculate: _onCalculate),
        ],
      ),
    );
  }
}
