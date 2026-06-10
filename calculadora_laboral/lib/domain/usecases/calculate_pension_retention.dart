import '../entities/employee_data.dart';
import '../entities/pension_detail.dart';
import '../../core/constants/legal_parameters.dart';

/// Calcula la retención pensionaria mensual del trabajador.
///
/// Soporta:
/// - **ONP**: 13% fijo sobre la remuneración asegurable.
/// - **AFP (comisión flujo)**: aporte al fondo (10%) + comisión AFP + prima seguro,
///   todos sobre la remuneración mensual.
/// - **AFP (comisión mixta)**: aporte al fondo (10%) + comisión mixta sobre flujo
///   + prima seguro. El componente fijo sobre el saldo del fondo NO se incluye
///   aquí (se muestra como referencia en la UI).
///
/// La remuneración asegurable es la suma de todos los ingresos computables
/// del mes (sueldo bruto + asig. familiar + horas extra).
final class CalculatePensionRetentionUseCase {
  const CalculatePensionRetentionUseCase();

  /// [totalRemuneracion] = grossSalary + familyAllowance + overtimePay
  PensionDetail call(EmployeeData data, double totalRemuneracion) {
    if (totalRemuneracion <= 0) {
      return PensionDetail(
        systemName: _systemName(data),
        totalRetention: 0,
      );
    }

    if (data.pensionSystem == null) {
      return const PensionDetail(
        systemName: 'No seleccionado',
        totalRetention: 0,
      );
    }

    if (data.pensionSystem == PensionSystem.onp) {
      return _calculateOnp(totalRemuneracion);
    } else {
      if (data.afpType == null || data.commissionType == null) {
        return const PensionDetail(
          systemName: 'Faltan datos de AFP',
          totalRetention: 0,
        );
      }
      return _calculateAfp(data, totalRemuneracion);
    }
  }

  PensionDetail _calculateOnp(double totalRem) {
    final retention = totalRem * LegalParameters.kOnpRate;
    return PensionDetail(
      systemName: 'ONP — Sistema Nacional de Pensiones',
      onpRetention: retention,
      totalRetention: retention,
    );
  }

  PensionDetail _calculateAfp(EmployeeData data, double totalRem) {
    final commission = LegalParameters.kAfpCommissions[data.afpType!]!;

    // Aporte obligatorio al fondo de pensiones: 10%
    final fondoAporte = totalRem * LegalParameters.kAfpFondoRate;

    // Prima de seguro (igual para flujo y mixta)
    final insurancePremium = totalRem * commission.primaSeguoRate;

    // Comisión AFP
    // noSabe se trata como mixta (corresponde al ~80% del mercado)
    final double afpCommission = totalRem * commission.mixtaFlujoRate;
    final String commLabel = 'mixta';

    final totalRetention = fondoAporte + afpCommission + insurancePremium;

    return PensionDetail(
      systemName: '${commission.name} — Comisión $commLabel',
      fondoAporte: fondoAporte,
      afpCommission: afpCommission,
      insurancePremium: insurancePremium,
      totalRetention: totalRetention,
    );
  }

  String _systemName(EmployeeData data) {
    if (data.pensionSystem == null) return 'No seleccionado';
    if (data.pensionSystem == PensionSystem.onp) return 'ONP';
    if (data.afpType == null) return 'AFP (Falta tipo)';
    final commission = LegalParameters.kAfpCommissions[data.afpType];
    return commission?.name ?? 'AFP';
  }
}
