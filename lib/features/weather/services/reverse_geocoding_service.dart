import 'dart:convert';

import 'package:http/http.dart' as http;

class ReverseGeocodingService {
  ReverseGeocodingService._();

  static final Map<String, String> _cache = {};

  static Future<String?> getCity({
    required double latitude,
    required double longitude,
  }) async {
    final key =
        'locality-v2:${latitude.toStringAsFixed(3)},${longitude.toStringAsFixed(3)}';
    final cached = _cache[key];
    if (cached != null) return cached;

    final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
      'format': 'jsonv2',
      'lat': latitude.toStringAsFixed(6),
      'lon': longitude.toStringAsFixed(6),
      'zoom': '13',
      'addressdetails': '1',
      'accept-language': 'en',
    });
    final response = await http
        .get(
          uri,
          headers: const {
            'User-Agent': 'ActiBind/1.0 (weather location lookup)',
          },
        )
        .timeout(const Duration(seconds: 6));
    if (response.statusCode != 200) return null;

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final address = body['address'] as Map<String, dynamic>?;
    if (address == null) return null;
    for (final field in const [
      'municipality',
      'town',
      'village',
      'city',
      'city_district',
      'suburb',
      'county',
      'state',
    ]) {
      final value = address[field] as String?;
      if (value != null && value.trim().isNotEmpty) {
        _cache[key] = value.trim();
        return value.trim();
      }
    }
    return null;
  }
}
