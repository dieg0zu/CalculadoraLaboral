import '../../core/constants/legal_parameters.dart';

/// Input inmutable del motor de cálculo.
///
/// Representa todos los parámetros que el usuario ingresa en la UI.
/// Clase inmutable con copyWith manual — no requiere generación de código.
class EmployeeData {
  /// Sueldo bruto mensual pactado en contrato (S/.)
  final double grossSalary;

  /// ¿El trabajador tiene carga familiar reconocida?
  final bool hasFamilyAllowance;

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

  /// Meses completos trabajados en el semestre/año (para truncos y CTS)
  final int workedMonths;

  /// Días adicionales del último mes incompleto (para CTS)
  final int workedDays;

  /// ¿El empleador tiene EPS en lugar de EsSalud?
  final bool hasEps;

  /// Mes de cálculo (1–12) para determinar semestre de gratificación
  final int currentMonth;

  const EmployeeData({
    this.grossSalary = 0.0,
    this.hasFamilyAllowance = false,
    this.pensionSystem,
    this.afpType,
    this.commissionType,
    this.overtimeHours25 = 0,
    this.overtimeHours35 = 0,
    this.workedMonths = 0,
    this.workedDays = 0,
    this.hasEps = false,
    this.currentMonth = 6,
  });

  EmployeeData copyWith({
    double? grossSalary,
    bool? hasFamilyAllowance,
    PensionSystem? pensionSystem,
    AfpType? afpType,
    AfpCommissionType? commissionType,
    int? overtimeHours25,
    int? overtimeHours35,
    int? workedMonths,
    int? workedDays,
    bool? hasEps,
    int? currentMonth,
    bool clearPensionSystem = false,
    bool clearAfpType = false,
    bool clearCommissionType = false,
  }) {
    return EmployeeData(
      grossSalary: grossSalary ?? this.grossSalary,
      hasFamilyAllowance: hasFamilyAllowance ?? this.hasFamilyAllowance,
      pensionSystem: clearPensionSystem ? null : (pensionSystem ?? this.pensionSystem),
      afpType: clearAfpType ? null : (afpType ?? this.afpType),
      commissionType: clearCommissionType ? null : (commissionType ?? this.commissionType),
      overtimeHours25: overtimeHours25 ?? this.overtimeHours25,
      overtimeHours35: overtimeHours35 ?? this.overtimeHours35,
      workedMonths: workedMonths ?? this.workedMonths,
      workedDays: workedDays ?? this.workedDays,
      hasEps: hasEps ?? this.hasEps,
      currentMonth: currentMonth ?? this.currentMonth,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmployeeData &&
          grossSalary == other.grossSalary &&
          hasFamilyAllowance == other.hasFamilyAllowance &&
          pensionSystem == other.pensionSystem &&
          afpType == other.afpType &&
          commissionType == other.commissionType &&
          overtimeHours25 == other.overtimeHours25 &&
          overtimeHours35 == other.overtimeHours35 &&
          workedMonths == other.workedMonths &&
          workedDays == other.workedDays &&
          hasEps == other.hasEps &&
          currentMonth == other.currentMonth;

  @override
  int get hashCode => Object.hash(
        grossSalary,
        hasFamilyAllowance,
        pensionSystem,
        afpType,
        commissionType,
        overtimeHours25,
        overtimeHours35,
        workedMonths,
        workedDays,
        hasEps,
        currentMonth,
      );
}
