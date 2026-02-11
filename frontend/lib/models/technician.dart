import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class Technician {
  final String id;
  final String name;
  final String role;
  final String? email;
  final TechnicianStatus status;
  final double rating;
  final int completed;
  final int reviewCount;
  final String? avatarUrl;
  bool isFavorite;

  Technician({
    required this.id,
    required this.name,
    required this.role,
    this.email,
    required this.status,
    required this.rating,
    required this.completed,
    required this.reviewCount,
    this.avatarUrl,
    this.isFavorite = false,
  });

  factory Technician.fromMap(Map<String, dynamic> map, String docId) {
    return Technician(
      id: docId.isNotEmpty ? docId : (map['id']?.toString() ?? ''),
      name: map['name'] ?? map['nome'] ?? 'Técnico',
      role: _parseRole(map['role'] ?? map['cargo']),
      email: map['email'],
      status: _parseStatus(map['status'] ?? map['situacao']),
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      completed: (map['completed'] as num?)?.toInt() ?? 0,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      avatarUrl: map['avatarUrl'] ?? map['avatar'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'role': role,
      if (email != null) 'email': email,
      'status': status.value,
      'rating': rating,
      'completed': completed,
      'reviewCount': reviewCount,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    };
  }

  static String _parseRole(dynamic value) {
    final raw = value?.toString().trim();
    if (raw == null || raw.isEmpty) return 'Técnico';
    final normalized = raw.toLowerCase();
    if (normalized.contains('tecnico') || normalized.contains('technician')) {
      return 'Técnico';
    }
    if (normalized.contains('gestor') || normalized.contains('manager')) {
      return 'Gestor';
    }
    if (normalized.contains('admin')) return 'Admin';
    if (normalized.contains('cliente') || normalized.contains('client')) {
      return 'Cliente';
    }
    return raw[0].toUpperCase() + raw.substring(1).toLowerCase();
  }

  static TechnicianStatus _parseStatus(dynamic value) {
    final raw = value?.toString().toLowerCase() ?? '';
    if (raw.contains('available') || raw.contains('disponivel')) {
      return TechnicianStatus.available;
    }
    if (raw.contains('busy') || raw.contains('ocupado')) {
      return TechnicianStatus.busy;
    }
    return TechnicianStatus.offline;
  }
}

enum TechnicianStatus { available, busy, offline }

extension TechnicianStatusX on TechnicianStatus {
  String get label {
    switch (this) {
      case TechnicianStatus.available:
        return 'Disponível';
      case TechnicianStatus.busy:
        return 'Ocupado';
      case TechnicianStatus.offline:
        return 'Offline';
    }
  }

  String get value {
    switch (this) {
      case TechnicianStatus.available:
        return 'available';
      case TechnicianStatus.busy:
        return 'busy';
      case TechnicianStatus.offline:
        return 'offline';
    }
  }

  Color get color {
    switch (this) {
      case TechnicianStatus.available:
        return AppColors.success;
      case TechnicianStatus.busy:
        return AppColors.warning;
      case TechnicianStatus.offline:
        return AppColors.slate500;
    }
  }
}
