import 'dart:typed_data';

import 'package:prototype_project/services/service_report_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class ReportService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Generate unique report code
  String generateReportCode() {
    final now = DateTime.now();
    return 'RPT-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';
  }

  // Get current resident profile ID
  Future<String?> getCurrentResidentId() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final response = await _supabase
        .from('resident_profiles')
        .select('id')
        .eq('user_id', user.id)
        .single();

    return response['id'] as String?;
  }
  Future<Map<String, dynamic>?> getCurrentResidentProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final response = await _supabase
        .from('resident_profiles')
        .select('first_name, last_name, account_status')
        .eq('user_id', user.id)
        .maybeSingle();

    return response;
  }
  // Create new report
  Future<ServiceReportModel> createReport({
    required ReportType type,
    required String title,
    required String description,
    String? location,
    List<String> photoUrls = const [],
  }) async {
    final residentId = await getCurrentResidentId();
    if (residentId == null) throw Exception('Resident profile not found');

    final reportCode = generateReportCode();
    
    final response = await _supabase
        .from('service_reports')
        .insert({
          'report_code': reportCode,
          'resident_id': residentId,
          'report_type': type.name,
          'title': title,
          'description': description,
          'location': location,
          'photo_urls': photoUrls,
          'status': 'submitted',
          'submitted_at': DateTime.now().toIso8601String(),
          'is_public': false,
        })
        .select('*, resident_profiles(first_name, last_name, phone, address_purok, address_street)')
        .single();

    return ServiceReportModel.fromJson(response);
  }

  // Upload photo to storage
    // Upload photo to storage
  Future<String> uploadPhoto(String reportCode, String filePath, Uint8List bytes) async { // <-- List<int> → Uint8List
    final fileName = '$reportCode/${DateTime.now().millisecondsSinceEpoch}.jpg';
    
    await _supabase.storage
        .from('report-photos')
        .uploadBinary(fileName, bytes);

    return _supabase.storage
        .from('report-photos')
        .getPublicUrl(fileName);
  }

  // Get reports for current resident
  Future<List<ServiceReportModel>> getMyReports() async {
    final residentId = await getCurrentResidentId();
    if (residentId == null) throw Exception('Resident profile not found');

    final response = await _supabase
        .from('service_reports')
        .select('*, resident_profiles(first_name, last_name, phone, address_purok, address_street)')
        .eq('resident_id', residentId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ServiceReportModel.fromJson(json))
        .toList();
  }

  // Get all reports (Admin)
  Future<List<ServiceReportModel>> getAllReports({
    ReportStatus? statusFilter,
    ReportType? typeFilter,
    String? searchQuery,
  }) async {
    var query = _supabase
        .from('service_reports')
        .select('*, resident_profiles(first_name, last_name, phone, address_purok, address_street, address_barangay, address_municipality, address_province)');

    if (statusFilter != null) {
      query = query.eq('status', statusFilter.name);
    }

    if (typeFilter != null) {
      query = query.eq('report_type', typeFilter.name);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or('title.ilike.%$searchQuery%,description.ilike.%$searchQuery%,report_code.ilike.%$searchQuery%');
    }

    final response = await query.order('created_at', ascending: false);
    
    return (response as List)
        .map((json) => ServiceReportModel.fromJson(json))
        .toList();
  }

  // Update report status (Admin)
  Future<ServiceReportModel> updateStatus({
    required String reportId,
    required ReportStatus newStatus,
    String? adminFeedback,
  }) async {
    final updates = <String, dynamic>{
      'status': newStatus.name,
    };

    // Update timestamp based on status
    switch (newStatus) {
      case ReportStatus.received:
        updates['received_at'] = DateTime.now().toIso8601String();
        break;
      case ReportStatus.investigating:
        updates['investigating_at'] = DateTime.now().toIso8601String();
        break;
      case ReportStatus.resolved:
        updates['resolved_at'] = DateTime.now().toIso8601String();
        break;
      case ReportStatus.closed:
        updates['closed_at'] = DateTime.now().toIso8601String();
        break;
      default:
        break;
    }

    if (adminFeedback != null) {
      updates['admin_feedback'] = adminFeedback;
    }

    updates['admin_id'] = _supabase.auth.currentUser?.id;

    final response = await _supabase
        .from('service_reports')
        .update(updates)
        .eq('id', reportId)
        .select('*, resident_profiles(first_name, last_name, phone, address_purok, address_street)')
        .single();

    return ServiceReportModel.fromJson(response);
  }

  // Delete report (only if submitted/received)
  Future<void> deleteReport(String reportId) async {
    await _supabase
        .from('service_reports')
        .delete()
        .eq('id', reportId)
        .eq('status', 'submitted'); // Only allow deleting submitted reports
  }
}