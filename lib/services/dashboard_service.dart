import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardStats {
  final int totalResidents;
  final int pendingReports;
  final int pendingRegistrations;
  final int activeAnnouncements;
  final int totalHouseholds;
  final int pendingServiceRequests;
  final int resolvedReportsThisMonth;

  DashboardStats({
    required this.totalResidents,
    required this.pendingReports,
    required this.pendingRegistrations,
    required this.activeAnnouncements,
    required this.totalHouseholds,
    required this.pendingServiceRequests,
    required this.resolvedReportsThisMonth,
  });
}

class DashboardService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Sabay-sabay na fetch ang lahat ng stats para mabilis
  Future<DashboardStats> getAdminStats() async {
    try {
      final now = DateTime.now().toIso8601String();
      final firstDayOfMonth = DateTime(DateTime.now().year, DateTime.now().month, 1).toIso8601String();

      // PARALLEL: Lahat ng count queries sabay-sabay
      final results = await Future.wait([
        _supabase.from('resident_profiles').select('id'),
        _supabase.from('service_reports').select('id').or('status.eq.submitted,status.eq.received,status.eq.investigating'),
        _supabase.from('resident_profiles').select('id').eq('account_status', 'pending'),
        _supabase.from('announcements').select('id').eq('is_published', true).or('expires_at.is.null,expires_at.gte.$now'),
        _supabase.from('households').select('id'),
        _supabase.from('service_requests').select('id').or('status.eq.pending,status.eq.approved,status.eq.ready_to_pickup'),
        _supabase.from('service_reports').select('id').eq('status', 'resolved').gte('resolved_at', firstDayOfMonth),
      ]);

      return DashboardStats(
        totalResidents: results[0].length,
        pendingReports: results[1].length,
        pendingRegistrations: results[2].length,
        activeAnnouncements: results[3].length,
        totalHouseholds: results[4].length,
        pendingServiceRequests: results[5].length,
        resolvedReportsThisMonth: results[6].length,
      );
    } catch (e, st) {
      debugPrint('getAdminStats error: $e\n$st');
      throw Exception('Failed to load dashboard stats: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getRecentActivity({int limit = 6}) async {
    try {
      // PARALLEL: Sabay ang reports, registrations, at requests
      final futures = await Future.wait([
        _supabase
            .from('service_reports')
            .select('id, report_code, title, status, submitted_at, created_at, resident_id, resident_profiles(first_name, last_name)')
            .order('created_at', ascending: false)
            .limit(limit),
        _supabase
            .from('resident_profiles')
            .select('id, first_name, last_name, account_status, created_at')
            .order('created_at', ascending: false)
            .limit(limit),
        _supabase
            .from('service_requests')
            .select('id, request_code, purpose, status, requested_at, created_at, resident_id, resident_profiles(first_name, last_name)')
            .order('created_at', ascending: false)
            .limit(limit),
      ]);

      final reports = futures[0];
      final registrations = futures[1];
      final requests = futures[2];

      final activities = <Map<String, dynamic>>[];

      for (final r in reports) {
        final profile = r['resident_profiles'];
        final submittedAt = r['submitted_at'] as String?;
        final createdAt = r['created_at'] as String?;

        DateTime? parsedTime;
        if (submittedAt != null) parsedTime = DateTime.tryParse(submittedAt);
        if (parsedTime == null && createdAt != null) parsedTime = DateTime.tryParse(createdAt);
        parsedTime ??= DateTime.now();

        activities.add({
          'type': 'report',
          'title': '${profile?['first_name'] ?? 'Unknown'} submitted a report',
          'subtitle': r['title'] as String? ?? 'No title',
          'status': r['status'] as String? ?? 'unknown',
          'time': parsedTime,
          'icon': Icons.report_outlined,
          'color': Colors.orange,
        });
      }

      for (final r in registrations) {
        final createdAt = r['created_at'] as String?;
        final parsedTime = createdAt != null ? DateTime.tryParse(createdAt) ?? DateTime.now() : DateTime.now();

        activities.add({
          'type': 'registration',
          'title': '${r['first_name'] as String? ?? 'Unknown'} ${r['last_name'] as String? ?? ''} registered',
          'subtitle': 'Account status: ${r['account_status'] as String? ?? 'unknown'}',
          'status': r['account_status'] as String? ?? 'unknown',
          'time': parsedTime,
          'icon': Icons.person_add_outlined,
          'color': Colors.blue,
        });
      }

      for (final r in requests) {
        final profile = r['resident_profiles'];
        final requestedAt = r['requested_at'] as String?;
        final createdAt = r['created_at'] as String?;

        DateTime? parsedTime;
        if (requestedAt != null) parsedTime = DateTime.tryParse(requestedAt);
        if (parsedTime == null && createdAt != null) parsedTime = DateTime.tryParse(createdAt);
        parsedTime ??= DateTime.now();

        activities.add({
          'type': 'request',
          'title': '${profile?['first_name'] ?? 'Unknown'} requested a service',
          'subtitle': r['purpose'] as String? ?? 'No details',
          'status': r['status'] as String? ?? 'unknown',
          'time': parsedTime,
          'icon': Icons.description_outlined,
          'color': Colors.purple,
        });
      }

      activities.sort((a, b) => (b['time'] as DateTime).compareTo(a['time'] as DateTime));
      return activities.take(limit).toList();
    } catch (e, st) {
      debugPrint('getRecentActivity error: $e\n$st');
      throw Exception('Failed to load recent activity: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getReportsByStatus() async {
    try {
      final statuses = ['submitted', 'received', 'investigating', 'in_progress', 'resolved', 'closed', 'rejected'];
      
      // PARALLEL: Lahat ng status counts sabay-sabay
      final futures = statuses.map((status) => 
        _supabase.from('service_reports').select('id').eq('status', status)
      ).toList();
      
      final results = await Future.wait(futures);

      return List.generate(statuses.length, (i) => {
        'status': statuses[i],
        'count': results[i].length,
      });
    } catch (e, st) {
      debugPrint('getReportsByStatus error: $e\n$st');
      throw Exception('Failed to load report stats: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getLatestAnnouncements({int limit = 3}) async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await _supabase
          .from('announcements')
          .select('id, title, content, category, priority, published_by, is_published, expires_at, created_at, updated_at')
          .eq('is_published', true)
          .or('expires_at.is.null,expires_at.gte.$now')
          .order('created_at', ascending: false)
          .limit(limit);

      return response.map<Map<String, dynamic>>((item) {
        return {
          'id': item['id'] ?? '',
          'title': item['title'] ?? '',
          'content': item['content'] ?? '',
          'category': item['category'],
          'priority': item['priority'] ?? 'normal',
          'published_by': item['published_by'],
          'is_published': item['is_published'] ?? true,
          'expires_at': item['expires_at'],
          'created_at': item['created_at'],
          'updated_at': item['updated_at'],
        };
      }).toList();
    } catch (e, st) {
      debugPrint('getLatestAnnouncements error: $e\n$st');
      throw Exception('Failed to load announcements: $e');
    }
  }
}