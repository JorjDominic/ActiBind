import 'dart:convert';

import 'package:actibind/features/activities/models/public_holiday.dart';
import 'package:http/http.dart' as http;

class HolidayService {
  HolidayService._();

  static const _baseUrl = 'https://date.nager.at/api/v4/Holidays';
  static const defaultCountryCode = 'PH';
  static final Map<String, List<PublicHoliday>> _cache = {};

  static Future<List<PublicHoliday>> getHolidays({
    required int year,
    String countryCode = defaultCountryCode,
  }) async {
    final normalizedCountry = countryCode.toUpperCase();
    final cacheKey = '$normalizedCountry-$year';
    final cached = _cache[cacheKey];
    if (cached != null) return cached;

    final response = await http
        .get(Uri.parse('$_baseUrl/$normalizedCountry/$year'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Holiday API returned ${response.statusCode}.');
    }
    final holidays = (jsonDecode(response.body) as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(PublicHoliday.fromJson)
        .where((holiday) => holiday.types.contains('Public'))
        .toList(growable: false);
    _cache[cacheKey] = holidays;
    return holidays;
  }
}
