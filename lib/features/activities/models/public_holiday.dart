class PublicHoliday {
  const PublicHoliday({
    required this.date,
    required this.name,
    required this.countryCode,
    required this.nationalHoliday,
    required this.types,
  });

  final DateTime date;
  final String name;
  final String countryCode;
  final bool nationalHoliday;
  final List<String> types;

  factory PublicHoliday.fromJson(Map<String, dynamic> json) => PublicHoliday(
    date: DateTime.parse(json['date'] as String),
    name: json['name'] as String,
    countryCode: json['countryCode'] as String,
    nationalHoliday: json['nationalHoliday'] as bool? ?? true,
    types: (json['holidayTypes'] as List<dynamic>? ?? const []).cast<String>(),
  );
}
