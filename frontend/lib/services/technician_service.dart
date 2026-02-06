import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/technician.dart';
import 'api_service.dart';

class TechnicianService {
  static const _favoritesKey = 'favorite_technician_ids';
  static const _favoritesCacheKey = 'favorite_technicians_cache';

  static Future<List<Technician>> getAll({required String token}) async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/technicians'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Technician.fromJson(e)).toList();
    }
    throw Exception('Erro ao carregar técnicos (${response.statusCode})');
  }

  static Future<List<Technician>> search({
    required String token,
    required String query,
  }) async {
    final uri = Uri.parse('${ApiService.baseUrl}/technicians/search')
        .replace(queryParameters: {'q': query});
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Technician.fromJson(e)).toList();
    }
    throw Exception('Erro ao pesquisar técnicos (${response.statusCode})');
  }

  static Future<Set<String>> getFavorites({required String token}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/technicians/favorites'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final ids = _parseFavoriteIds(data);
        await _saveFavoriteIds(ids);
        return ids;
      }
    } catch (_) {
      // Fallback to local storage below.
    }
    return _loadFavoriteIds();
  }

  static Future<List<Technician>> getFavoriteDetails({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/technicians/favorites/details'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final favorites = data.map((e) => Technician.fromJson(e)).toList();
        await saveCachedFavorites(favorites);
        return favorites;
      }
    } catch (_) {
      // Fallback to local cache below.
    }
    return loadCachedFavorites();
  }

  static Future<Set<String>> setFavorite({
    required String token,
    required String technicianId,
    required bool isFavorite,
  }) async {
    final method = isFavorite ? 'POST' : 'DELETE';
    try {
      final response = await http.Request(
        method,
        Uri.parse('${ApiService.baseUrl}/technicians/$technicianId/favorite'),
      )
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        });
      final streamed = await response.send();
      if (streamed.statusCode >= 200 && streamed.statusCode < 300) {
        final updated = await _loadFavoriteIds();
        if (isFavorite) {
          updated.add(technicianId);
        } else {
          updated.remove(technicianId);
        }
        await _saveFavoriteIds(updated);
        return updated;
      }
    } catch (_) {
      // Fallback to local storage below.
    }
    final local = await _loadFavoriteIds();
    if (isFavorite) {
      local.add(technicianId);
    } else {
      local.remove(technicianId);
    }
    await _saveFavoriteIds(local);
    return local;
  }

  static Future<void> submitReview({
    required String token,
    required String technicianId,
    required double rating,
    String? comment,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/technicians/$technicianId/reviews'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Erro ao enviar avaliação (${response.statusCode})');
    }
  }

  static Set<String> _parseFavoriteIds(dynamic data) {
    final ids = <String>{};
    if (data is List) {
      for (final item in data) {
        if (item is Map<String, dynamic>) {
          final id = item['id']?.toString();
          if (id != null && id.isNotEmpty) ids.add(id);
        } else {
          final id = item?.toString();
          if (id != null && id.isNotEmpty) ids.add(id);
        }
      }
    }
    return ids;
  }

  static Future<List<Technician>> loadCachedFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_favoritesCacheKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> data = jsonDecode(raw);
      return data
          .whereType<Map<String, dynamic>>()
          .map((e) => Technician.fromJson(e))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveCachedFavorites(List<Technician> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = favorites
        .map((t) => {
              'id': t.id,
              'name': t.name,
              'role': t.role,
              'email': t.email,
              'status': t.status.value,
              'rating': t.rating,
              'completed': t.completed,
              'reviewCount': t.reviewCount,
              'avatarUrl': t.avatarUrl,
            })
        .toList();
    await prefs.setString(_favoritesCacheKey, jsonEncode(payload));
  }

  static Future<Set<String>> _loadFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_favoritesKey) ?? [];
    return list.toSet();
  }

  static Future<void> _saveFavoriteIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, ids.toList());
  }
}
