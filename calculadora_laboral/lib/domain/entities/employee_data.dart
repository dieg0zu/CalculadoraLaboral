import '../../core/constants/legal_parameters.dart';

/// Input inmutable del motor de cálculo.
///
/// Representa todos los parámetros que el usuario ingresa en la UI.
/// Clase inmutable con copyWith manual — no requiere generación de código.
class EmployeeData {
  /// Sueldo bruto mensual pactado en contrato (S/.)
  final double grossSalary;

  /// ¿El trabajador tiene carga familiar reconocida?
  final bool? hasFamilyAllowance;

  /// Régimen de empresa (determina los multiplicadores)
  final CompanyRegime? regime;

  /// Bonos regulares y comisiones (promedio)
  final double bonuses;

  /// Sistema pensionario elegido
  final PensionSystem? pensionSystem;

  /// AFP seleccionada (solo aplica si pensionSystem == AFP)
  final AfpType? afpType;

  /// Tipo de comisión AFP
  final AfpCommissionType? commissionType;

  /// Horas extra con sobretasa del 25% en el mes
  final int overtimeHours25;

  /// Horas extra con sobretasa del 35% en el mes
  final int overtimeHours35;

  /// Suma total de bonos en el semestre (para CTS)
  final double semesterTotalBonuses;

  /// Suma total de horas extra percibidas en el semestre (para CTS)
  final double semesterTotalOvertime;

  /// Meses completos trabajados en el semestre/año (para truncos y CTS)
  final int workedMonths;

  /// Días adicionales del último mes incompleto (para CTS)
  final int workedDays;

  /// Tipo de seguro de salud seleccionado
  final HealthInsurance healthInsurance;

  /// Costo del plan EPS comercial (solo si aplica EPS)
  final double epsCost;

  /// ¿Las horas extras/bonos cumplen la regla de regularidad (>= 3 veces en semestre)?
  final bool variablesMeetRegularity;

  /// Mes de cálculo (1–12) para determinar semestre de gratificación
  final int currentMonth;

  const EmployeeData({
    this.grossSalary = 0.0,
    this.hasFamilyAllowance,
    this.regime,
    this.bonuses = 0.0,
    this.pensionSystem,
    this.afpType,
    this.commissionType,
    this.overtimeHours25 = 0,
    this.overtimeHours35 = 0,
    this.workedMonths = 0,
    this.workedDays = 0,
    this.healthInsurance = HealthInsurance.essalud,
    this.epsCost = 0.0,
    this.variablesMeetRegularity = false,
    this.currentMonth = 6,
    this.semesterTotalBonuses = 0.0,
    this.semesterTotalOvertime = 0.0,
  });

  EmployeeData copyWith({
    double? grossSalary,
    bool? hasFamilyAllowance,
    CompanyRegime? regime,
    double? bonuses,
    PensionSystem? pensionSystem,
    AfpType? afpType,
    AfpCommissionType? commissionType,
    int? overtimeHours25,
    int? overtimeHours35,
    int? workedMonths,
    int? workedDays,
    HealthInsurance? healthInsurance,
    double? epsCost,
    bool? variablesMeetRegularity,
    int? currentMonth,
    double? semesterTotalBonuses,
    double? semesterTotalOvertime,
    bool clearPensionSystem = false,
    bool clearAfpType = false,
    bool clearCommissionType = false,
  }) {
    return EmployeeData(
      grossSalary: grossSalary ?? this.grossSalary,
      hasFamilyAllowance: hasFamilyAllowance ?? this.hasFamilyAllowance,
      regime: regime ?? this.regime,
      bonuses: bonuses ?? this.bonuses,
      pensionSystem: clearPensionSystem ? null : (pensionSystem ?? this.pensionSystem),
      afpType: clearAfpType ? null : (afpType ?? this.afpType),
      commissionType: clearCommissionType ? null : (commissionType ?? this.commissionType),
      overtimeHours25: overtimeHours25 ?? this.overtimeHours25,
      overtimeHours35: overtimeHours35 ?? this.overtimeHours35,
      workedMonths: workedMonths ?? this.workedMonths,
      workedDays: workedDays ?? this.workedDays,
      healthInsurance: healthInsurance ?? this.healthInsurance,
      epsCost: epsCost ?? this.epsCost,
      variablesMeetRegularity: variablesMeetRegularity ?? this.variablesMeetRegularity,
      currentMonth: currentMonth ?? this.currentMonth,
      semesterTotalBonuses: semesterTotalBonuses ?? this.semesterTotalBonuses,
      semesterTotalOvertime: semesterTotalOvertime ?? this.semesterTotalOvertime,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmployeeData &&
          grossSalary == other.grossSalary &&
          hasFamilyAllowance == other.hasFamilyAllowance &&
          regime == other.regime &&
          bonuses == other.bonuses &&
          pensionSystem == other.pensionSystem &&
          afpType == other.afpType &&
          commissionType == other.commissionType &&
          overtimeHours25 == other.overtimeHours25 &&
          overtimeHours35 == other.overtimeHours35 &&
          workedMonths == other.workedMonths &&
          workedDays == other.workedDays &&
          healthInsurance == other.healthInsurance &&
          epsCost == other.epsCost &&
          variablesMeetRegularity == other.variablesMeetRegularity &&
          currentMonth == other.currentMonth &&
          semesterTotalBonuses == other.semesterTotalBonuses &&
          semesterTotalOvertime == other.semesterTotalOvertime;

  @override
  int get hashCode => Object.hash(
        grossSalary,
        hasFamilyAllowance,
        regime,
        bonuses,
        pensionSystem,
        afpType,
        commissionType,
        overtimeHours25,
        overtimeHours35,
        workedMonths,
        workedDays,
        healthInsurance,
        epsCost,
        variablesMeetRegularity,
        currentMonth,
        semesterTotalBonuses,
        semesterTotalOvertime,
      );
}
