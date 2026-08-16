class InsightMetrics {
  const InsightMetrics({
    required this.todayValue,
    required this.todayLabel,
    required this.dailyAverage,
    required this.previousDailyAverage,
    required this.averageChangePercent,
    required this.goalProgress,
    required this.dayLevels,
    required this.dayDurations,
    required this.peakWindow,
  });

  final Duration todayValue;
  final String todayLabel;
  final Duration dailyAverage;
  final Duration previousDailyAverage;
  final double? averageChangePercent;
  final double goalProgress;
  final List<double> dayLevels;
  final List<Duration> dayDurations;
  final String peakWindow;
}
