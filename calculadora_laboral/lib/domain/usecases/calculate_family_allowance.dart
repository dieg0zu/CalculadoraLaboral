import '../entities/employee_data.dart';
import '../../core/constants/legal_parameters.dart';

/// Calcula el monto de asignación familiar mensual.
///
/// Ley 25129: Si el trabajador tiene carga familiar reconocida,
/// recibe el 10% de la RMV como asignación familiar, sin importar
/// el monto de su sueldo bruto.
///
/// Este caso de uso recibe los parámetros legales como argumento
/// (no los importa directamente) para garantizar portabilidad.
final class CalculateFamilyAllowanceUseCase {
  const CalculateFamilyAllowanceUseCase();

  /// Retorna el monto de asignación familiar en S/.
  /// Retorna 0.0 si el trabajador no tiene carga familiar.
  double call(EmployeeData data) {
    if (data.hasFamilyAllowance != true) return 0.0;
    return LegalParameters.kRMV * LegalParameters.kFamilyAllowanceRate;
  }
}
