import 'package:prototype_project/services/announcement_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AnnouncementService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user ID
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  // Check if admin
  Future<bool> isAdmin() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;
    final response = await _supabase
        .from('users')
        .select('role')
        .eq('id', user.id)
        .single();
    return response['role'] == 'admin';
  }

  // Create announcement (Admin only)
  Future<AnnouncementModel> createAnnouncement({
    required String title,
    required String content,
    String? category,
    AnnouncementPriority priority = AnnouncementPriority.normal,
    DateTime? expiresAt,
    bool isPublished = true,
  }) async {
    final response = await _supabase
        .from('announcements')
        .insert({
          'title': title,
          'content': content,
          'category': category,
          'priority': priority.name,
          'published_by': _currentUserId,
          'is_published': isPublished,
          'expires_at': expiresAt?.toIso8601String(),
        })
        .select('*, users(email)')
        .single();

    return AnnouncementModel.fromJson(response);
  }

  // Update announcement
  Future<AnnouncementModel> updateAnnouncement({
    required String id,
    required String title,
    required String content,
    String? category,
    AnnouncementPriority priority = AnnouncementPriority.normal,
    DateTime? expiresAt,
    bool? isPublished,
  }) async {
    final updates = <String, dynamic>{
      'title': title,
      'content': content,
      'category': category,
      'priority': priority.name,
      'expires_at': expiresAt?.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (isPublished != null) {
      updates['is_published'] = isPublished;
    }

    final response = await _supabase
        .from('announcements')
        .update(updates)
        .eq('id', id)
        .select('*, users(email)')
        .single();

    return AnnouncementModel.fromJson(response);
  }

  // Delete announcement
  Future<void> deleteAnnouncement(String id) async {
    await _supabase.from('announcements').delete().eq('id', id);
  }

  // Get all announcements (Admin - includes drafts)
  Future<List<AnnouncementModel>> getAllAnnouncements() async {
    final response = await _supabase
        .from('announcements')
        .select('*, users(email)')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => AnnouncementModel.fromJson(json))
        .toList();
  }

  // Get published announcements (Resident - active only)
  Future<List<AnnouncementModel>> getPublishedAnnouncements() async {
    final now = DateTime.now().toIso8601String();
    
    final response = await _supabase
        .from('announcements')
        .select('*, users(email)')
        .eq('is_published', true)
        .or('expires_at.is.null,expires_at.gte.$now')
        .order('priority', ascending: false) // Urgent first
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => AnnouncementModel.fromJson(json))
        .toList();
  }

  // Toggle publish status
  Future<void> togglePublishStatus(String id, bool currentStatus) async {
    await _supabase
        .from('announcements')
        .update({'is_published': !currentStatus})
        .eq('id', id);
  }
}