import 'dart:convert';

import 'package:actibind/features/weather/models/current_weather.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  WeatherService._();

  static const _endpoint = 'https://api.open-meteo.com/v1/forecast';
  static CurrentWeather? _cached;
  static DateTime? _cachedAt;
  static double? _cachedLatitude;
  static double? _cachedLongitude;

  static Future<CurrentWeather> getCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    final cached = _cached;
    final cachedAt = _cachedAt;
    if (cached != null &&
        cachedAt != null &&
        _cachedLatitude != null &&
        _cachedLongitude != null &&
        (latitude - _cachedLatitude!).abs() < .01 &&
        (longitude - _cachedLongitude!).abs() < .01 &&
        DateTime.now().difference(cachedAt) < const Duration(minutes: 15)) {
      return cached;
    }

    final uri = Uri.parse(_endpoint).replace(
      queryParameters: {
        'latitude': latitude.toStringAsFixed(5),
        'longitude': longitude.toStringAsFixed(5),
        'current':
            'temperature_2m,relative_humidity_2m,apparent_temperature,is_day,weather_code,wind_speed_10m',
        'timezone': 'Asia/Manila',
      },
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Weather API returned ${response.statusCode}.');
    }
    final weather = CurrentWeather.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
    _cached = weather;
    _cachedAt = DateTime.now();
    _cachedLatitude = latitude;
    _cachedLongitude = longitude;
    return weather;
  }
}
