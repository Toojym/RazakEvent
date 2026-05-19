class DateFilter {
  final DateTime? from;
  final DateTime? to;
  final bool upcomingOnly;

  const DateFilter.upcoming()
      : from = null,
        to = null,
        upcomingOnly = true;

  const DateFilter.range({required this.from, required this.to})
      : upcomingOnly = false;

  const DateFilter.none()
      : from = null,
        to = null,
        upcomingOnly = false;
}