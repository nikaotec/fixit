import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/technician.dart';
import 'firestore_helper.dart';

class FirestoreTechnicianService {
  static Future<List<Technician>> getAll() async {
    // Assuming technicians are stored in the global 'users' collection
    // and have a 'companyId' field matching the current company.
    // OR they are in 'technicians' subcollection of company.
    // Based on previous context, users are global.
    // But let's check if we have a 'technicians' collection in company?
    // If not, we query global users.

    // For now, let's assume we query global users by companyId.
    // However, FirestoreHelper.companyId is dynamic.

    // Alternative: The old backend had /technicians.
    // In Firebase, we might want to replicate this.
    // Let's assume we query 'users' collection where companyId matches and role is technician.

    // But wait, UserProvider reads from 'users/{uid}'.

    final companyId = await FirestoreHelper.getCompanyId();
    if (companyId.isEmpty) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('companyId', isEqualTo: companyId)
        // .where('role', isEqualTo: 'TECHNICIAN') // specific roles?
        .get();

    return snapshot.docs.map((doc) {
      return Technician.fromMap(doc.data(), doc.id);
    }).toList();
  }

  // Helper to match existing signature
  static Future<List<Technician>> search({required String query}) async {
    final all = await getAll();
    final q = query.toLowerCase();
    return all.where((t) {
      return t.name.toLowerCase().contains(q) ||
          (t.email?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  static Future<Set<String>> getFavorites() async {
    // For now, using local storage as source of truth for favorites
    // In a real app, we should sync this with a user's subcollection
    return loadFavoriteIds();
  }

  static Future<List<Technician>> getFavoriteDetails() async {
    final ids = await getFavorites();
    if (ids.isEmpty) return [];
    final all = await getAll();
    return all.where((t) => ids.contains(t.id)).toList();
  }

  static Future<Set<String>> setFavorite({
    required String technicianId,
    required bool isFavorite,
  }) async {
    final ids = await loadFavoriteIds();
    if (isFavorite) {
      ids.add(technicianId);
    } else {
      ids.remove(technicianId);
    }
    await saveFavoriteIds(ids);

    // Optionally sync with Firestore user profile here
    // final userId = FirebaseAuth.instance.currentUser?.uid;
    // if (userId != null) { ... }

    return ids;
  }

  // --- Local Cache Helpers (copied/adapted from legacy Service to keep behavior) ---

  static const _favoritesKey = 'favorite_technician_ids';
  static const _favoritesCacheKey = 'favorite_technicians_cache';

  static Future<List<Technician>> loadCachedFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_favoritesCacheKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> data = jsonDecode(raw);
      return data
          .whereType<Map<String, dynamic>>() // Ensure correct type
          .map((e) => Technician.fromMap(e, e['id'] ?? ''))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveCachedFavorites(List<Technician> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = favorites.map((t) => t.toMap()).toList();
    await prefs.setString(_favoritesCacheKey, jsonEncode(payload));
  }

  static Future<Set<String>> loadFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_favoritesKey) ?? [];
    return list.toSet();
  }

  static Future<void> saveFavoriteIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, ids.toList());
  }

  static Future<void> submitReview({
    required String technicianId,
    required double rating,
    String? comment,
  }) async {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(technicianId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final doc = await transaction.get(userRef);
      if (!doc.exists) throw Exception('Technician not found');

      final data = doc.data() as Map<String, dynamic>;
      final currentRating = (data['rating'] as num?)?.toDouble() ?? 0.0;
      final currentCount = (data['reviewCount'] as num?)?.toInt() ?? 0;

      final newCount = currentCount + 1;
      final newRating = ((currentRating * currentCount) + rating) / newCount;

      transaction.update(userRef, {
        'rating': newRating,
        'reviewCount': newCount,
      });

      // Add review to subcollection
      final reviewRef = userRef.collection('reviews').doc();
      transaction.set(reviewRef, {
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
