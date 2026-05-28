/// Parámetros legales peruanos vigentes — 2025
///
/// Esta clase es el ÚNICO lugar donde residen los valores numéricos de la
/// legislación laboral peruana. Ningún caso de uso puede tener magic numbers.
///
/// Fuentes:
/// - DS 003-2025-TR  → RMV S/. 1,130
/// - RS 000-2025-EF  → UIT S/. 5,150
/// - SBS Circular G-217 → Comisiones AFP 2024/2025
abstract final class LegalParameters {
  // ─────────────────────────────────────────────────────────────────
  // Remuneraciones de referencia
  // ─────────────────────────────────────────────────────────────────

  /// Remuneración Mínima Vital mensual (S/.)
  static const double kRMV = 1130.0;

  /// Unidad Impositiva Tributaria anual (S/.)
  static const double kUIT = 5150.0;

  // ─────────────────────────────────────────────────────────────────
  // Aportes del empleador
  // ─────────────────────────────────────────────────────────────────

  /// Tasa de aporte EsSalud (empleador) — 9%
  static const double kEsSaludRate = 0.09;

  /// Tasa de aporte EPS (empleador) — 6.75% (cuando aplique) a EsSalud + 2.25% a EPS
  /// Para el MVP, el costo general sigue siendo 9%.
  static const double kEpsRate = 0.0675; // Porcentaje que va a EsSalud

  /// Costo fijo empleador SIS Microempresa
  static const double kSisFixedCost = 15.0;

  // ─────────────────────────────────────────────────────────────────
  // Sistema Privado de Pensiones (AFP) — retención del trabajador
  //
  // Aporte obligatorio al fondo: 10% (igual para todas las AFP)
  // ─────────────────────────────────────────────────────────────────

  /// Aporte al fondo de pensiones (igual para todas las AFP)
  static const double kAfpFondoRate = 0.10;

  /// Comisiones AFP por tipo de comisión
  /// Formato: { 'flujo': tasa, 'mixta_flujo': tasa, 'mixta_fija': monto_soles }
  /// La comisión mixta tiene un componente porcentual sobre el flujo
  /// y un componente fijo mensual sobre el saldo del fondo.
  /// Para MVP se usa la comisión sobre el flujo (remuneración mensual).
  static const Map<AfpType, AfpCommission> kAfpCommissions = {
    AfpType.prima: AfpCommission(
      name: 'AFP Prima',
      flujoRate: 0.0160,      // 1.60% sobre remuneración
      mixtaFlujoRate: 0.0077, // 0.77% sobre remuneración (mixta)
      primaSeguoRate: 0.0184, // 1.84% prima de seguro (igual en ambas)
    ),
    AfpType.integra: AfpCommission(
      name: 'AFP Integra',
      flujoRate: 0.0155,
      mixtaFlujoRate: 0.0067,
      primaSeguoRate: 0.0184,
    ),
    AfpType.profuturo: AfpCommission(
      name: 'AFP Profuturo',
      flujoRate: 0.0169,
      mixtaFlujoRate: 0.0082,
      primaSeguoRate: 0.0184,
    ),
    AfpType.habitat: AfpCommission(
      name: 'AFP Habitat',
      flujoRate: 0.0138,
      mixtaFlujoRate: 0.0057,
      primaSeguoRate: 0.0184,
    ),
  };

  // ─────────────────────────────────────────────────────────────────
  // Sistema Nacional de Pensiones (ONP)
  // ─────────────────────────────────────────────────────────────────

  /// Tasa ONP — 13% sobre la remuneración asegurable
  static const double kOnpRate = 0.13;

  // ─────────────────────────────────────────────────────────────────
  // Asignación Familiar
  // ─────────────────────────────────────────────────────────────────

  /// Porcentaje de la RMV para la asignación familiar — 10%
  static const double kFamilyAllowanceRate = 0.10;

  /// Monto fijo de asignación familiar = 10% de la RMV
  static double get kFamilyAllowance => kRMV * kFamilyAllowanceRate;

  // ─────────────────────────────────────────────────────────────────
  // Horas Extras — Decreto Legislativo 854
  // ─────────────────────────────────────────────────────────────────

  /// Sobretasa de las primeras 2 horas extra — 25%
  static const double kOvertimeRate25 = 0.25;

  /// Sobretasa de las horas extra adicionales (>2h en día) — 35%
  static const double kOvertimeRate35 = 0.35;

  /// Días laborales estándar al mes
  static const double kWorkDaysPerMonth = 30.0;

  /// Horas laborales estándar al día
  static const double kWorkHoursPerDay = 8.0;

  // ─────────────────────────────────────────────────────────────────
  // Quinta Categoría — Tabla de tramos SUNAT
  // ─────────────────────────────────────────────────────────────────

  /// Deducción estándar de 7 UIT para quinta categoría
  static const double kFifthCategoryDeductionUIT = 7.0;

  /// Tramos del Impuesto a la Renta de Quinta Categoría
  /// Cada tramo: { uitDesde, uitHasta, tasa }
  /// El último tramo no tiene límite superior (infinity)
  static const List<FifthCategoryBracket> kFifthCategoryBrackets = [
    FifthCategoryBracket(fromUIT: 0,   toUIT: 5,   rate: 0.08),
    FifthCategoryBracket(fromUIT: 5,   toUIT: 20,  rate: 0.14),
    FifthCategoryBracket(fromUIT: 20,  toUIT: 35,  rate: 0.17),
    FifthCategoryBracket(fromUIT: 35,  toUIT: 45,  rate: 0.20),
    FifthCategoryBracket(fromUIT: 45,  toUIT: double.infinity, rate: 0.30),
  ];

  // ─────────────────────────────────────────────────────────────────
  // Gratificación — Ley 27735 y Ley 29351
  // ─────────────────────────────────────────────────────────────────

  /// Meses de referencia para gratificación de julio (enero–junio)
  static const int kGratJulioDesde = 1;
  static const int kGratJulioHasta = 6;

  /// Meses de referencia para gratificación de diciembre (julio–diciembre)
  static const int kGratDicDesde = 7;
  static const int kGratDicHasta = 12;

  /// Meses totales del semestre
  static const int kGratMonthsPerSemester = 6;

  /// Bonificación extraordinaria Ley 29351 — EsSalud (empleador paga al trabajador)
  static const double kGratBonifEsSaludRate = 0.09;

  /// Bonificación extraordinaria Ley 29351 — EPS
  static const double kGratBonifEpsRate = 0.0675;

  // ─────────────────────────────────────────────────────────────────
  // CTS — Decreto Supremo 001-97-TR
  // ─────────────────────────────────────────────────────────────────

  /// Meses del semestre CTS
  static const int kCtsMonthsPerSemester = 6;

  /// Días del año para CTS
  static const int kCtsDaysPerYear = 360;
}

// ─────────────────────────────────────────────────────────────────────────────
// Value objects auxiliares (inmutables, sin lógica)
// ─────────────────────────────────────────────────────────────────────────────

/// Tipos de AFP disponibles
enum AfpType {
  prima,
  integra,
  profuturo,
  habitat;

  String get displayName => switch (this) {
        AfpType.prima => 'AFP Prima',
        AfpType.integra => 'AFP Integra',
        AfpType.profuturo => 'AFP Profuturo',
        AfpType.habitat => 'AFP Habitat',
      };
}

/// Tipo de sistema pensionario
enum PensionSystem {
  afp,
  onp;

  String get displayName => switch (this) {
        PensionSystem.afp => 'AFP (Privado)',
        PensionSystem.onp => 'ONP (Estatal)',
      };
}

/// Tipo de comisión AFP
enum AfpCommissionType {
  flujo,
  mixta,
  noSabe;

  String get displayName => switch (this) {
        AfpCommissionType.flujo => 'Comisión sobre el flujo',
        AfpCommissionType.mixta => 'Comisión mixta',
        AfpCommissionType.noSabe => 'No estoy seguro',
      };
}

/// Tipos de régimen laboral de empresa
enum CompanyRegime {
  general,
  small,
  micro,
  intern;

  String get displayName => switch (this) {
        CompanyRegime.general => 'Régimen General',
        CompanyRegime.small => 'Pequeña Empresa',
        CompanyRegime.micro => 'Microempresa',
        CompanyRegime.intern => 'Practicante',
      };
}

/// Tipo de Seguro de Salud
enum HealthInsurance {
  sis,
  essalud,
  eps,
  both;

  String get displayName => switch (this) {
        HealthInsurance.sis => 'SIS Microempresa',
        HealthInsurance.essalud => 'EsSalud Regular',
        HealthInsurance.eps => 'EPS',
        HealthInsurance.both => 'Ambos',
      };
}

/// Estructura de comisiones de una AFP
final class AfpCommission {
  final String name;

  /// Comisión sobre el flujo (% de la remuneración)
  final double flujoRate;

  /// Componente flujo de la comisión mixta (% de la remuneración)
  final double mixtaFlujoRate;

  /// Prima de seguro de invalidez, sobrevivencia y gastos de sepelio
  final double primaSeguoRate;

  const AfpCommission({
    required this.name,
    required this.flujoRate,
    required this.mixtaFlujoRate,
    required this.primaSeguoRate,
  });
}

/// Tramo del impuesto a la renta de quinta categoría
final class FifthCategoryBracket {
  /// Límite inferior en UIT (incluido)
  final double fromUIT;

  /// Límite superior en UIT (excluido)
  final double toUIT;

  /// Tasa impositiva del tramo
  final double rate;

  const FifthCategoryBracket({
    required this.fromUIT,
    required this.toUIT,
    required this.rate,
  });
}
