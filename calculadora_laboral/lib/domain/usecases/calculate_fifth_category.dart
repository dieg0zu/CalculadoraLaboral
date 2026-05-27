import '../../core/constants/legal_parameters.dart';

/// Resultado del cálculo de quinta categoría.
final class FifthCategoryResult {
  /// Renta neta imponible anual (después de deducción de 7 UIT)
  final double annualTaxableIncome;

  /// Impuesto anual calculado por tramos
  final double annualTax;

  /// Retención mensual proyectada (impuesto anual / 12)
  final double monthlyRetention;

  /// Desglose por tramos para visualización en la UI
  final List<BracketCalculation> bracketDetails;

  const FifthCategoryResult({
    required this.annualTaxableIncome,
    required this.annualTax,
    required this.monthlyRetention,
    required this.bracketDetails,
  });
}

/// Detalle de un tramo del impuesto.
final class BracketCalculation {
  final String label;
  final double taxableAmount;
  final double rate;
  final double tax;

  const BracketCalculation({
    required this.label,
    required this.taxableAmount,
    required this.rate,
    required this.tax,
  });
}

/// Calcula la retención del Impuesto a la Renta de Quinta Categoría.
///
/// Artículo 75° de la Ley del Impuesto a la Renta (DS 179-2004-EF):
///
/// 1. Se proyecta la remuneración anual del trabajador:
///    - Remuneración mensual × 12
///    - + Gratificaciones de julio y diciembre (2 sueldos adicionales)
///    - + Participación de utilidades (si aplica — no considerado en MVP)
///
/// 2. Se deduce 7 UIT como mínimo no imponible.
///
/// 3. Se aplica la tabla de tramos escalonados.
///
/// 4. El impuesto anual se divide entre 12 para obtener la retención mensual.
///
/// Para el MVP: se calcula la proyección estándar desde el mes 1,
/// sin acumulación de retenciones anteriores.
final class CalculateFifthCategoryUseCase {
  const CalculateFifthCategoryUseCase();

  /// [monthlyRemuneracion] = sueldo bruto + asig. familiar + horas extra
  FifthCategoryResult call(double monthlyRemuneracion) {
    if (monthlyRemuneracion <= 0) {
      return FifthCategoryResult(
        annualTaxableIncome: 0,
        annualTax: 0,
        monthlyRetention: 0,
        bracketDetails: [],
      );
    }

    // 1. Proyección anual: 12 remuneraciones + 2 gratificaciones ordinarias
    //    Las gratificaciones = 1 sueldo bruto cada una (simplificación estándar)
    final annualProjection = monthlyRemuneracion * 14;

    // 2. Deducción de 7 UIT
    final deduction = LegalParameters.kFifthCategoryDeductionUIT * LegalParameters.kUIT;
    final annualTaxableIncome = (annualProjection - deduction).clamp(0.0, double.infinity);

    if (annualTaxableIncome == 0) {
      return FifthCategoryResult(
        annualTaxableIncome: 0,
        annualTax: 0,
        monthlyRetention: 0,
        bracketDetails: [],
      );
    }

    // 3. Aplicar tramos escalonados
    final brackets = LegalParameters.kFifthCategoryBrackets;
    double remainingIncome = annualTaxableIncome;
    double totalTax = 0;
    final List<BracketCalculation> bracketDetails = [];

    for (final bracket in brackets) {
      if (remainingIncome <= 0) break;

      final fromSoles = bracket.fromUIT * LegalParameters.kUIT;
      final toSoles = bracket.toUIT.isFinite
          ? bracket.toUIT * LegalParameters.kUIT
          : double.infinity;

      final bracketWidth = toSoles.isFinite
          ? toSoles - fromSoles
          : remainingIncome;

      final taxableInBracket = remainingIncome.clamp(0.0, bracketWidth);
      final taxInBracket = taxableInBracket * bracket.rate;

      if (taxableInBracket > 0) {
        bracketDetails.add(BracketCalculation(
          label: bracket.toUIT.isFinite
              ? '${bracket.fromUIT.toInt()} – ${bracket.toUIT.toInt()} UIT'
              : 'Más de ${bracket.fromUIT.toInt()} UIT',
          taxableAmount: taxableInBracket,
          rate: bracket.rate,
          tax: taxInBracket,
        ));
      }

      totalTax += taxInBracket;
      remainingIncome -= taxableInBracket;
    }

    // 4. Retención mensual
    final monthlyRetention = totalTax / 12;

    return FifthCategoryResult(
      annualTaxableIncome: annualTaxableIncome,
      annualTax: totalTax,
      monthlyRetention: monthlyRetention,
      bracketDetails: bracketDetails,
    );
  }
}
