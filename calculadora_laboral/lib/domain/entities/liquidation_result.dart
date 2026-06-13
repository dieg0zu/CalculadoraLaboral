/// Resultado del cálculo de liquidación por cese.
///
/// Todos los montos de los conceptos individuales son BRUTOS.
/// La retención pensionaria se muestra por separado en [pensionDeduction].
/// [totalToPay] es la suma estricta de los conceptos menos la retención.
class LiquidationResult {
  /// Bruto: Gratificación trunca + Bono Extraordinario (exonerada de pensión — Ley 29351)
  final double netGratification;

  /// Informativo: CTS que ya cortó y debe depositarse en banco (no se paga en mano)
  final double ctsInBank;

  /// Bruto: tramo CTS trunco a pagar en la liquidación (no sujeto a retención pensionaria)
  final double netCtsInLiquidation;

  /// Bruto: vacaciones no gozadas × (baseSalary/30) × días ceil
  final double netVacations;

  /// Bruto: sueldo de los días trabajados en el mes de cese = (baseSalary/30) × diasMes
  final double netPendingSalary;

  /// Bruto: horas extra devengadas únicamente en el mes de cese.
  /// Ingreso directo — NO es el promedio semestral ni el historicalOvertimeSum.
  final double currentMonthOvertimeResult;

  /// Retención AFP/ONP sobre conceptos gravados (sueldo + vacaciones + HH.EE. del mes).
  /// Gratificación y CTS están exoneradas.
  final double pensionDeduction;

  /// Neto a recibir = netPendingSalary + currentMonthOvertimeResult
  ///               + netGratification + netCtsInLiquidation + netVacations
  ///               − pensionDeduction
  ///
  /// El sueldo básico completo y el historicalOvertimeSum (promedio semestral)
  /// son variables de referencia de las fórmulas y NUNCA se suman aquí directamente.
  final double totalToPay;

  const LiquidationResult({
    required this.netGratification,
    required this.ctsInBank,
    required this.netCtsInLiquidation,
    required this.netVacations,
    required this.netPendingSalary,
    required this.currentMonthOvertimeResult,
    required this.pensionDeduction,
    required this.totalToPay,
  });
}
