import '../entities/employee_data.dart';
import '../entities/liquidation_result.dart';
import '../../core/constants/legal_parameters.dart';
import 'calculate_cts.dart';
import 'calculate_vacation.dart';
import 'calculate_gratification.dart';
import 'calculate_pension_retention.dart';

/// Calcula la liquidación básica por cese del trabajador.
///
/// Incluye los beneficios truncos al momento del cese:
/// - CTS del semestre en curso (proporcional)
/// - Vacaciones truncas no gozadas
/// - Gratificación trunca proporcional al semestre
/// - Bonificación extraordinaria de la gratificación trunca (Ley 29351)
///
/// No incluye: indemnización por despido arbitrario, participación de
/// utilidades ni otros conceptos variables.
final class CalculateLiquidationUseCase {
  final CalculateCtsUseCase _cts;
  final CalculateVacationUseCase _vacation;
  final CalculateGratificationUseCase _gratification;
  final CalculatePensionRetentionUseCase _pension;

  const CalculateLiquidationUseCase({
    CalculateCtsUseCase? cts,
    CalculateVacationUseCase? vacation,
    CalculateGratificationUseCase? gratification,
    CalculatePensionRetentionUseCase? pension,
  })  : _cts = cts ?? const CalculateCtsUseCase(),
        _vacation = vacation ?? const CalculateVacationUseCase(),
        _gratification = gratification ?? const CalculateGratificationUseCase(),
        _pension = pension ?? const CalculatePensionRetentionUseCase();

  LiquidationResult call(EmployeeData data) {
    // CTS trunca del semestre en curso
    final ctsResult = _cts(data);
    final truncatedCts = ctsResult.totalCts;

    // Vacaciones truncas
    final vacResult = _vacation(data);
    final truncatedVacationsGross = vacResult.truncatedVacation;

    // Retenciones de Ley sobre las vacaciones truncas (AFP/ONP)
    final pensionDetail = _pension(data, truncatedVacationsGross);
    final vacationsRetention = pensionDetail.totalRetention;
    final truncatedVacationsNet = truncatedVacationsGross - vacationsRetention;

    // Gratificación trunca
    final gratResult = _gratification(data.copyWith(isCurrentlyWorking: false));
    final truncatedGratification = gratResult.baseGratification;
    final truncatedExtraBonus = gratResult.extraordinaryBonus;

    final totalLiquidation = truncatedCts +
        truncatedVacationsNet +
        truncatedGratification +
        truncatedExtraBonus;

    return LiquidationResult(
      truncatedCts: truncatedCts,
      truncatedVacations: truncatedVacationsNet,
      truncatedGratification: truncatedGratification,
      truncatedExtraBonus: truncatedExtraBonus,
      totalLiquidation: totalLiquidation,
      workedMonths: data.workedMonths,
      workedDays: data.workedDays,
    );
  }
}
