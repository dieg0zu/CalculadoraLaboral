void main() {
  DateTime startDate = DateTime(2026, 2, 2);
  DateTime endDate = DateTime(2026, 5, 5);

  int mesesCompletosGrati = 0;
  DateTime gratPeriodStart = endDate.month <= 6 
      ? DateTime(endDate.year, 1, 1) 
      : DateTime(endDate.year, 7, 1);
  DateTime gratCompStart = startDate.isAfter(gratPeriodStart) ? startDate : gratPeriodStart;
  
  DateTime currentMonth = DateTime(gratCompStart.year, gratCompStart.month, 1);
  final endMonth = DateTime(endDate.year, endDate.month, 1);
  while (!currentMonth.isAfter(endMonth)) {
    final lastDayOfMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    final isStartValid = gratCompStart.isBefore(currentMonth) || 
                          (gratCompStart.year == currentMonth.year && gratCompStart.month == currentMonth.month && gratCompStart.day == 1);
    final isEndValid = endDate.isAfter(DateTime(currentMonth.year, currentMonth.month, lastDayOfMonth)) || 
                        (endDate.year == currentMonth.year && endDate.month == currentMonth.month && endDate.day == lastDayOfMonth);
    
    print('Month: ${currentMonth.month}, isStartValid: $isStartValid, isEndValid: $isEndValid');
    
    if (isStartValid && isEndValid) {
      mesesCompletosGrati++;
    }
    currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
  }
  print('Total meses: $mesesCompletosGrati');
}
