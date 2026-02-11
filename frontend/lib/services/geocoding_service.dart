import 'dart:convert';
import 'dart:io';

/// Service for geocoding addresses to coordinates using OpenStreetMap Nominatim.
class GeocodingService {
  static const _baseUrl = 'nominatim.openstreetmap.org';

  /// Searches for an address and returns a list of results with lat/lng.
  static Future<List<GeocodingResult>> searchAddress(String query) async {
    if (query.trim().length < 3) return [];

    final uri = Uri.https(_baseUrl, '/search', {
      'q': query,
      'format': 'json',
      'limit': '5',
      'addressdetails': '1',
    });

    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      request.headers.set('User-Agent', 'FixitApp/1.0');
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      final data = json.decode(body) as List;

      return data.map((item) => GeocodingResult.fromJson(item)).toList();
    } finally {
      client.close();
    }
  }
}

class GeocodingResult {
  final String displayName;
  final double lat;
  final double lon;
  final String type;

  const GeocodingResult({
    required this.displayName,
    required this.lat,
    required this.lon,
    required this.type,
  });

  factory GeocodingResult.fromJson(Map<String, dynamic> json) {
    return GeocodingResult(
      displayName: json['display_name'] ?? '',
      lat: double.tryParse(json['lat']?.toString() ?? '') ?? 0,
      lon: double.tryParse(json['lon']?.toString() ?? '') ?? 0,
      type: json['type'] ?? '',
    );
  }
}
