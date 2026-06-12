/// Resultado del cálculo de liquidación por cese.
class LiquidationResult {
  final double netGratification;     // Bruto (Trunca + Bono Extraordinario — exonerada de pensión)
  final double ctsInBank;            // (Informativo, extraído del módulo CTS)
  final double netCtsInLiquidation;  // Bruto (tramo trunco — no sujeto a retención pensionaria)
  final double netVacations;         // Bruto (pozo histórico × baseSalary/30 × días ceil)
  final double netPendingSalary;     // Bruto (sueldo días del mes de cese)
  final double extraPayments;        // Bruto (passthrough de bonos pendientes y HH.EE. del mes)
  final double pensionDeduction;     // Retención AFP/ONP sobre conceptos gravados (sueldo+vac+extras)
  final double totalToPay;           // Neto a recibir = sumBrutos − pensionDeduction

  const LiquidationResult({
    required this.netGratification,
    required this.ctsInBank,
    required this.netCtsInLiquidation,
    required this.netVacations,
    required this.netPendingSalary,
    required this.extraPayments,
    required this.pensionDeduction,
    required this.totalToPay,
  });
}
