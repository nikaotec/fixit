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

  /// Reverse geocoding: coordinates -> address.
  static Future<GeocodingResult?> reverseGeocode(double lat, double lon) async {
    final uri = Uri.https(_baseUrl, '/reverse', {
      'lat': lat.toString(),
      'lon': lon.toString(),
      'format': 'json',
      'addressdetails': '1',
    });

    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      request.headers.set('User-Agent', 'FixitApp/1.0');
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      final data = json.decode(body) as Map<String, dynamic>;

      return GeocodingResult.fromJson(data);
    } catch (e) {
      return null;
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
  final String? street;
  final String? number;
  final String? neighborhood;
  final String? city;
  final String? zipCode;
  final String? state;

  const GeocodingResult({
    required this.displayName,
    required this.lat,
    required this.lon,
    required this.type,
    this.street,
    this.number,
    this.neighborhood,
    this.city,
    this.zipCode,
    this.state,
  });

  factory GeocodingResult.fromJson(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>? ?? {};

    return GeocodingResult(
      displayName: json['display_name'] ?? '',
      lat: double.tryParse(json['lat']?.toString() ?? '') ?? 0,
      lon: double.tryParse(json['lon']?.toString() ?? '') ?? 0,
      type: json['type'] ?? '',
      street: address['road'] ?? address['pedestrian'] ?? address['street'],
      number: address['house_number'],
      neighborhood:
          address['suburb'] ??
          address['neighbourhood'] ??
          address['neighborhood'],
      city:
          address['city'] ??
          address['town'] ??
          address['village'] ??
          address['municipality'],
      zipCode: address['postcode'],
      state: address['state'],
    );
  }
}
