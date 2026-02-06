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
  });

  factory Technician.fromJson(Map<String, dynamic> json) {
    return Technician(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['nome'] ?? 'Técnico',
      role: _parseRole(json['role'] ?? json['cargo']),
      email: json['email'],
      status: _parseStatus(json['status'] ?? json['situacao']),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      completed: (json['completed'] as num?)?.toInt() ?? 0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      avatarUrl: json['avatarUrl'] ?? json['avatar'],
    );
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
