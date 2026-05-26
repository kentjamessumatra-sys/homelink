import 'package:flutter/material.dart';

class ServiceRequest {
  final String id;
  final String requestCode;
  final String residentId;
  final String serviceId;
  final String purpose;
  final String status;
  final String? adminNotes;
  final DateTime requestedAt;
  final DateTime? processedAt;
  final DateTime? pickupDate;
  final String? serviceName;
  final String? residentName;
  final String? residentPhone;        
  final String? residentAddress;      
  final double? fee;

  ServiceRequest({
    required this.id,
    required this.requestCode,
    required this.residentId,
    required this.serviceId,
    required this.purpose,
    required this.status,
    this.adminNotes,
    required this.requestedAt,
    this.processedAt,
    this.pickupDate,
    this.serviceName,
    this.residentName,
    this.residentPhone,       
    this.residentAddress,      
    this.fee,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'] as String,
      requestCode: json['request_code'] as String,
      residentId: json['resident_id'] as String,
      serviceId: json['service_id'] as String,
      purpose: json['purpose'] as String,
      status: json['status'] as String,
      adminNotes: json['admin_notes'] as String?,
      requestedAt: DateTime.parse(json['requested_at'] as String),
      processedAt: json['processed_at'] != null 
          ? DateTime.parse(json['processed_at'] as String) 
          : null,
      pickupDate: json['pickup_date'] != null 
          ? DateTime.parse(json['pickup_date'] as String) 
          : null,
      serviceName: json['barangay_services']?['service_name'] as String?,
      residentName: json['resident_profiles']?['first_name'] != null 
          ? '${json['resident_profiles']['first_name']} ${json['resident_profiles']['last_name']}'
          : null,
      residentPhone: json['resident_profiles']?['phone'] as String?,
      residentAddress: json['resident_profiles']?['address_purok'] as String?,
      fee: json['barangay_services']?['fee'] != null 
          ? (json['barangay_services']['fee'] as num).toDouble() 
          : null,
    );
  }

  // DAPAT NASA LOOB NG CLASS ITO
  String get statusLabel {
    switch (status) {
      case 'pending': return 'Pending';
      case 'approved': return 'Approved';
      case 'ready_to_pickup': return 'Ready to Pickup';
      case 'completed': return 'Completed';
      case 'rejected': return 'Rejected/Cancelled';
      default: return status;
    }
  }

  // DAPAT NASA LOOB DIN NG CLASS ITO
  Color get statusColor {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'approved': return Colors.blue;
      case 'ready_to_pickup': return Colors.purple;
      case 'completed': return Colors.green;
      case 'rejected': return Colors.red;
      default: return Colors.black;
    }
  }
  bool get isCancelledByResident => 
  status == 'rejected' && adminNotes == 'Cancelled by resident';
}  // END NG CLASS