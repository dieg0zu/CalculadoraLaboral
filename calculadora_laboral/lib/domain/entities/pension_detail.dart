/// Desglose de la retención pensionaria mensual del trabajador.
class PensionDetail {
  /// Nombre del sistema (ej. "AFP Prima - Flujo" o "ONP")
  final String systemName;

  /// Aporte al fondo de pensiones (10% del total remunerativo, solo AFP)
  final double fondoAporte;

  /// Comisión de la AFP sobre el flujo / mixta
  final double afpCommission;

  /// Prima de seguro de invalidez y sobrevivencia (solo AFP)
  final double insurancePremium;

  /// Retención ONP (13% del total remunerativo, solo ONP)
  final double onpRetention;

  /// Total retenido al trabajador
  final double totalRetention;

  const PensionDetail({
    required this.systemName,
    this.fondoAporte = 0.0,
    this.afpCommission = 0.0,
    this.insurancePremium = 0.0,
    this.onpRetention = 0.0,
    required this.totalRetention,
  });
}
