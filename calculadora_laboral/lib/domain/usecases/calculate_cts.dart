import '../entities/employee_data.dart';
import '../entities/cts_result.dart';
import '../../core/constants/legal_parameters.dart';
import 'calculate_family_allowance.dart';

/// Calcula la CTS (Compensación por Tiempo de Servicios) semestral.
///
/// DS 001-97-TR (TUO de la Ley de CTS):
///
/// Remuneración computable =
///   Sueldo bruto + Asignación familiar + (1/6 de la gratificación semestral)
///
/// CTS semestral =
///   (Rem. computable / 12) × meses completos
///   + (Rem. computable / 360) × días adicionales
///
/// Nota: Las horas extra son computable solo si son habituales
/// (percibidas en al menos 3 meses del semestre). Para el MVP se
/// excluyen (caso conservador).
final class CalculateCtsUseCase {
  final CalculateFamilyAllowanceUseCase _familyAllowance;

  const CalculateCtsUseCase({
    CalculateFamilyAllowanceUseCase? familyAllowance,
  })  : _familyAllowance =
            familyAllowance ?? const CalculateFamilyAllowanceUseCase();

  CtsResult call(EmployeeData data) {
    final result = _calculateBaseCts(data);
    
    // Segmentación si cesó
    if (data.isCurrentlyWorking == false && data.endDate != null && data.startDate != null) {
      final end = data.endDate!;
      final isMayCese = end.month == 5 && end.day >= 1 && end.day <= 15;
      final isNovCese = end.month == 11 && end.day >= 1 && end.day <= 15;

      if (isMayCese || isNovCese) {
        final cutOffMonth = isMayCese ? 4 : 10;
        final cutOffDay = isMayCese ? 30 : 31;
        final cutOffDate = DateTime(end.year, cutOffMonth, cutOffDay);
        
        final m1 = _calculateMonths(data.startDate!, cutOffDate);
        final d1 = _calculateDays(data.startDate!, cutOffDate);
        
        // La CTS depositada debe incluir el 1/6 de grati si corresponde
        final depositadaData = data.copyWith(workedMonths: m1, workedDays: d1);
        final depositadaResult = _calculateBaseCts(depositadaData);
        final depositada = depositadaResult.totalCts;
        
        return CtsResult(
          grossSalary: result.grossSalary,
          familyAllowance: result.familyAllowance,
          sixthOfGratification: result.sixthOfGratification,
          computableSalary: result.computableSalary,
          completedMonths: result.completedMonths,
          additionalDays: result.additionalDays,
          ctsForMonths: result.ctsForMonths,
          ctsForDays: result.ctsForDays,
          totalCts: result.totalCts,
          ctsDepositadaBanco: depositada,
          ctsTruncaLiquidacion: result.totalCts - depositada,
        );
      }
    }
    
    return CtsResult(
      grossSalary: result.grossSalary,
      familyAllowance: result.familyAllowance,
      sixthOfGratification: result.sixthOfGratification,
      computableSalary: result.computableSalary,
      completedMonths: result.completedMonths,
      additionalDays: result.additionalDays,
      ctsForMonths: result.ctsForMonths,
      ctsForDays: result.ctsForDays,
      totalCts: result.totalCts,
      ctsDepositadaBanco: 0.0,
      ctsTruncaLiquidacion: result.totalCts,
    );
  }

  int _calculateMonths(DateTime start, DateTime end) {
    if (end.isBefore(start)) return 0;
    int months = 0;
    int days = 0;
    DateTime current = start;
    while (current.year < end.year || (current.year == end.year && current.month < end.month)) {
      if (current.day == 1) {
        months++;
        current = DateTime(current.year, current.month + 1, 1);
      } else {
        days += 30 - current.day + 1;
        current = DateTime(current.year, current.month + 1, 1);
      }
    }
    if (current.month == end.month && current.year == end.year) {
      if (current.day == 1 && end.day >= 30) {
        months++;
      } else if (current.day == 1) {
        days += end.day;
      } else {
        days += end.day - current.day + 1;
      }
    }
    months += days ~/ 30;
    return months.clamp(0, 6);
  }

  int _calculateDays(DateTime start, DateTime end) {
    if (end.isBefore(start)) return 0;
    int days = 0;
    DateTime current = start;
    while (current.year < end.year || (current.year == end.year && current.month < end.month)) {
      if (current.day != 1) {
        days += 30 - current.day + 1;
        current = DateTime(current.year, current.month + 1, 1);
      } else {
        current = DateTime(current.year, current.month + 1, 1);
      }
    }
    if (current.month == end.month && current.year == end.year) {
      if (current.day == 1 && end.day < 30) {
        days += end.day;
      } else if (current.day != 1) {
        days += end.day - current.day + 1;
      }
    }
    return (days % 30);
  }

  CtsResult _calculateBaseCts(EmployeeData data) {
    final familyAllowance = _familyAllowance(data);

    double regularVariablesAvg = 0;
    if (data.overtimeMeetRegularity == true) {
      regularVariablesAvg += data.semesterTotalOvertime / 6;
    }
    
    if (data.bonusesMeetRegularity == true) {
      regularVariablesAvg += data.semesterTotalBonuses / 6;
    }

    // El 1/6 de gratificación
    double sixthOfGratification = 0.0;
    if (data.hasLastGratification == true) {
      sixthOfGratification = data.lastGratificationAmount / 6;
    }
    
    final computableSalary = data.grossSalary + familyAllowance + regularVariablesAvg + sixthOfGratification;

    final regimeMultiplier = switch (data.regime) {
      CompanyRegime.general => 1.0,
      CompanyRegime.small => 0.5,
      CompanyRegime.micro => 0.0,
      CompanyRegime.intern => 0.0,
      null => 1.0,
    };

    final completedMonths = data.workedMonths;
    final additionalDays = data.workedDays;

    final bool trabajoSemestreCompleto = completedMonths >= 6;

    double totalCts = 0.0;
    double ctsForMonths = 0.0;
    double ctsForDays = 0.0;

    if (trabajoSemestreCompleto) {
      // Fórmula simplificada
      totalCts = (computableSalary / 2) * regimeMultiplier;
      ctsForMonths = totalCts;
    } else {
      // Fórmula proporcional
      final totalDays = (completedMonths * 30) + additionalDays;
      totalCts = (computableSalary / 360) * totalDays * regimeMultiplier;
      
      // Para mostrar el desglose (aunque el total se calcula proporcional)
      ctsForMonths = (computableSalary / 12) * completedMonths * regimeMultiplier;
      ctsForDays = (computableSalary / 360) * additionalDays * regimeMultiplier;
    }

    return CtsResult(
      grossSalary: data.grossSalary,
      familyAllowance: familyAllowance,
      sixthOfGratification: sixthOfGratification,
      computableSalary: computableSalary,
      completedMonths: completedMonths,
      additionalDays: additionalDays,
      ctsForMonths: ctsForMonths,
      ctsForDays: ctsForDays,
      totalCts: totalCts,
    );
  }
}
