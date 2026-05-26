import 'package:flutter/material.dart';

enum ReportType {
  infrastructure,
  noise,
  theft,
  dispute,
  health,
  safety,
  cleanliness,
  other;

  String get label {
    switch (this) {
      case ReportType.infrastructure: return 'Infrastructure';
      case ReportType.noise: return 'Noise Complaint';
      case ReportType.theft: return 'Theft/Crime';
      case ReportType.dispute: return 'Dispute';
      case ReportType.health: return 'Health Concern';
      case ReportType.safety: return 'Safety Issue';
      case ReportType.cleanliness: return 'Cleanliness';
      case ReportType.other: return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case ReportType.infrastructure: return Icons.construction;
      case ReportType.noise: return Icons.volume_up;
      case ReportType.theft: return Icons.local_police;
      case ReportType.dispute: return Icons.people;
      case ReportType.health: return Icons.health_and_safety;
      case ReportType.safety: return Icons.warning;
      case ReportType.cleanliness: return Icons.delete;
      case ReportType.other: return Icons.more_horiz;
    }
  }
}

enum ReportStatus {
  submitted,
  received,
  investigating,
  // ignore: constant_identifier_names
  in_progress,
  resolved,
  closed,
  rejected;

  String get label {
    switch (this) {
      case ReportStatus.submitted: return 'Submitted';
      case ReportStatus.received: return 'Received';
      case ReportStatus.investigating: return 'Investigating';
      case ReportStatus.in_progress: return 'In Progress';
      case ReportStatus.resolved: return 'Resolved';
      case ReportStatus.closed: return 'Closed';
      case ReportStatus.rejected: return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case ReportStatus.submitted: return Colors.grey;
      case ReportStatus.received: return Colors.blue;
      case ReportStatus.investigating: return Colors.orange;
      case ReportStatus.in_progress: return Colors.deepOrange;
      case ReportStatus.resolved: return Colors.green;
      case ReportStatus.closed: return Colors.purple;
      case ReportStatus.rejected: return Colors.red;
    }
  }
}

class ServiceReportModel {
  final String? id;
  final String reportCode;
  final String? residentId;
  final String? residentName;
  final String? residentPhone;
  final String? residentAddress;
  final ReportType reportType;
  final String title;
  final String description;
  final String? location;
  final List<String> photoUrls;
  final ReportStatus status;
  final String? adminFeedback;
  final String? adminId;
  final DateTime? submittedAt;
  final DateTime? receivedAt;
  final DateTime? investigatingAt;
  final DateTime? resolvedAt;
  final DateTime? closedAt;
  final bool isPublic;
  final DateTime? createdAt;

  ServiceReportModel({
    this.id,
    required this.reportCode,
    this.residentId,
    this.residentName,
    this.residentPhone,
    this.residentAddress,
    required this.reportType,
    required this.title,
    required this.description,
    this.location,
    this.photoUrls = const [],
    this.status = ReportStatus.submitted,
    this.adminFeedback,
    this.adminId,
    this.submittedAt,
    this.receivedAt,
    this.investigatingAt,
    this.resolvedAt,
    this.closedAt,
    this.isPublic = false,
    this.createdAt,
  });

  factory ServiceReportModel.fromJson(Map<String, dynamic> json) {
    return ServiceReportModel(
      id: json['id'],
      reportCode: json['report_code'],
      residentId: json['resident_id'],
      residentName: json['resident_profiles']?['first_name'] != null
          ? '${json['resident_profiles']['first_name']} ${json['resident_profiles']['last_name']}'
          : null,
      residentPhone: json['resident_profiles']?['phone'],
      residentAddress: json['resident_profiles'] != null
          ? 'Purok ${json['resident_profiles']['address_purok'] ?? ''}, ${json['resident_profiles']['address_street'] ?? ''}'
          : null,
      reportType: ReportType.values.firstWhere(
        (e) => e.name == json['report_type'],
        orElse: () => ReportType.other,
      ),
      title: json['title'],
      description: json['description'],
      location: json['location'],
      photoUrls: List<String>.from(json['photo_urls'] ?? []),
      status: ReportStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReportStatus.submitted,
      ),
      adminFeedback: json['admin_feedback'],
      adminId: json['admin_id'],
      submittedAt: json['submitted_at'] != null 
          ? DateTime.parse(json['submitted_at']) 
          : null,
      receivedAt: json['received_at'] != null 
          ? DateTime.parse(json['received_at']) 
          : null,
      investigatingAt: json['investigating_at'] != null 
          ? DateTime.parse(json['investigating_at']) 
          : null,
      resolvedAt: json['resolved_at'] != null 
          ? DateTime.parse(json['resolved_at']) 
          : null,
      closedAt: json['closed_at'] != null 
          ? DateTime.parse(json['closed_at']) 
          : null,
      isPublic: json['is_public'] ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'report_code': reportCode,
      'resident_id': residentId,
      'report_type': reportType.name,
      'title': title,
      'description': description,
      'location': location,
      'photo_urls': photoUrls,
      'status': status.name,
      'admin_feedback': adminFeedback,
      'admin_id': adminId,
      'is_public': isPublic,
    };
  }
}