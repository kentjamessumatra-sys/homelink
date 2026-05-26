import 'package:flutter/material.dart';

enum AnnouncementPriority {
  low,
  normal,
  high,
  urgent;

  String get label {
    switch (this) {
      case AnnouncementPriority.low: return 'Low';
      case AnnouncementPriority.normal: return 'Normal';
      case AnnouncementPriority.high: return 'High';
      case AnnouncementPriority.urgent: return 'Urgent';
    }
  }

  Color get color {
    switch (this) {
      case AnnouncementPriority.low: return Colors.grey;
      case AnnouncementPriority.normal: return Colors.blue;
      case AnnouncementPriority.high: return Colors.orange;
      case AnnouncementPriority.urgent: return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case AnnouncementPriority.low: return Icons.arrow_downward;
      case AnnouncementPriority.normal: return Icons.remove;
      case AnnouncementPriority.high: return Icons.arrow_upward;
      case AnnouncementPriority.urgent: return Icons.warning_amber_rounded;
    }
  }
}

class AnnouncementModel {
  final String? id;
  final String title;
  final String content;
  final String? category;
  final AnnouncementPriority priority;
  final String? publishedBy;
  final String? adminName;
  final bool isPublished;
  final DateTime? expiresAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AnnouncementModel({
    this.id,
    required this.title,
    required this.content,
    this.category,
    this.priority = AnnouncementPriority.normal,
    this.publishedBy,
    this.adminName,
    this.isPublished = true,
    this.expiresAt,
    this.createdAt,
    this.updatedAt,
  });

  /// Safe parser para sa DateTime — handles String, DateTime, at null
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    // Safe priority parser
    AnnouncementPriority parsePriority(dynamic val) {
      if (val == null) return AnnouncementPriority.normal;
      final str = val.toString().toLowerCase().trim();
      return AnnouncementPriority.values.firstWhere(
        (e) => e.name == str,
        orElse: () => AnnouncementPriority.normal,
      );
    }

    // CRITICAL FIX: Safe admin name extraction
    String? parseAdminName(dynamic json) {
      final users = json['users'];
      if (users is! Map) return null;
      final email = users['email']?.toString();
      if (email == null || email.isEmpty) return null;
      return email.split('@').first;
    }

    return AnnouncementModel(
      id: json['id']?.toString(),
      // CRITICAL FIX: Null-safe fallback para sa title/content
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      category: json['category']?.toString(),
      priority: parsePriority(json['priority']),
      publishedBy: json['published_by']?.toString(),
      adminName: parseAdminName(json) ?? 'Admin',
      isPublished: json['is_published'] as bool? ?? true,
      // CRITICAL FIX: Handles both String at DateTime galing sa Supabase
      expiresAt: _parseDateTime(json['expires_at']),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'category': category,
      'priority': priority.name,
      'is_published': isPublished,
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isUrgent => priority == AnnouncementPriority.urgent;
}