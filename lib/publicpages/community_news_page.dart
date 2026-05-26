import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prototype_project/services/announcement_model.dart';
import 'package:prototype_project/services/announcement_service.dart';
import 'package:prototype_project/utils/kulor_style.dart';

class CommunityNewsPage extends StatefulWidget {
  const CommunityNewsPage({super.key});

  @override
  State<CommunityNewsPage> createState() => _CommunityNewsPageState();
}

class _CommunityNewsPageState extends State<CommunityNewsPage> {
  final AnnouncementService _service = AnnouncementService();
  List<AnnouncementModel> _announcements = [];
  bool _isLoading = true;
  String _searchQuery = '';
  AnnouncementPriority? _priorityFilter;

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getPublishedAnnouncements();
      setState(() {
        _announcements = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load news: $e');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  List<AnnouncementModel> get _filtered {
    return _announcements.where((a) {
      final matchesSearch = _searchQuery.isEmpty ||
          a.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          a.content.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesPriority = _priorityFilter == null || a.priority == _priorityFilter;
      return matchesSearch && matchesPriority;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final urgentList = _filtered.where((a) => a.priority == AnnouncementPriority.urgent).toList();
    final normalList = _filtered.where((a) => a.priority != AnnouncementPriority.urgent).toList();

    return Scaffold(
      backgroundColor: ColorStyle.ivory,
      appBar: AppBar(
        title: const Text(
          'Barangay Announcements',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [ColorStyle.topazyw2, ColorStyle.topazyw3],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAnnouncements,
              color: ColorStyle.topazyw3,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Search & Filter
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextField(
                            onChanged: (v) => setState(() => _searchQuery = v),
                            decoration: InputDecoration(
                              hintText: 'Search announcements...',
                              hintStyle: const TextStyle(color: ColorStyle.paleslate),
                              prefixIcon: const Icon(Icons.search, color: ColorStyle.topazyw3),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 40,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                _buildFilterChip('All', null, ColorStyle.topazyw3),
                                _buildFilterChip('Urgent', AnnouncementPriority.urgent, Colors.red),
                                _buildFilterChip('High', AnnouncementPriority.high, Colors.orange),
                                _buildFilterChip('Normal', AnnouncementPriority.normal, Colors.blue),
                                _buildFilterChip('Low', AnnouncementPriority.low, Colors.grey),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Urgent Section (Pinned)
                  if (urgentList.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: Row(
                          children: [
                            Icon(Icons.push_pin, color: Colors.red, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'URGENT',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildAnnouncementCard(urgentList[index], isUrgent: true),
                        childCount: urgentList.length,
                      ),
                    ),
                    const SliverToBoxAdapter(child: Divider(height: 32, indent: 16, endIndent: 16)),
                  ],

                  // Regular Announcements
                  if (normalList.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: Text(
                          'LATEST NEWS',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: ColorStyle.topazyw3,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),

                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildAnnouncementCard(normalList[index]),
                      childCount: normalList.length,
                    ),
                  ),

                  // Empty State
                  if (_filtered.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.campaign_outlined, size: 80, color: ColorStyle.platinum),
                            const SizedBox(height: 16),
                            Text(
                              'No announcements yet',
                              style: TextStyle(color: ColorStyle.slategrey, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildFilterChip(String label, AnnouncementPriority? priority, Color color) {
    final isSelected = _priorityFilter == priority;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: color.withValues(alpha: 0.2),
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? color : ColorStyle.slategrey,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (_) => setState(() => _priorityFilter = priority),
      ),
    );
  }

  Widget _buildAnnouncementCard(AnnouncementModel item, {bool isUrgent = false}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isUrgent 
                ? Colors.red.withValues(alpha: 0.15) 
                : ColorStyle.topazyw3.withValues(alpha: 0.08),
            blurRadius: isUrgent ? 16 : 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: isUrgent 
            ? Border.all(color: Colors.red.withValues(alpha: 0.3), width: 1.5)
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showDetailBottomSheet(item),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: item.priority.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(item.priority.icon, size: 14, color: item.priority.color),
                            const SizedBox(width: 4),
                            Text(
                              item.priority.label,
                              style: TextStyle(
                                color: item.priority.color,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (item.category != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: ColorStyle.ivory,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item.category!,
                            style: TextStyle(
                              color: ColorStyle.slategrey,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: ColorStyle.topazyw3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.content,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: ColorStyle.slategrey,
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 14, color: ColorStyle.paleslate),
                      const SizedBox(width: 4),
                      Text(
                        item.adminName ?? 'Barangay Admin',
                        style: TextStyle(fontSize: 12, color: ColorStyle.paleslate),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.schedule, size: 14, color: ColorStyle.paleslate),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM dd, yyyy').format(item.createdAt ?? DateTime.now()),
                        style: TextStyle(fontSize: 12, color: ColorStyle.paleslate),
                      ),
                      if (item.expiresAt != null) ...[
                        const Spacer(),
                        Icon(Icons.timer, size: 14, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          'Until ${DateFormat('MMM dd').format(item.expiresAt!)}',
                          style: const TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDetailBottomSheet(AnnouncementModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(color: ColorStyle.platinum, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: item.priority.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(item.priority.icon, size: 16, color: item.priority.color),
                      const SizedBox(width: 6),
                      Text(
                        item.priority.label,
                        style: TextStyle(
                          color: item.priority.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('MMM dd, yyyy').format(item.createdAt ?? DateTime.now()),
                  style: TextStyle(color: ColorStyle.paleslate, fontSize: 13),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: ColorStyle.topazyw3,
              ),
            ),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorStyle.ivory,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.content,
                style: TextStyle(
                  fontSize: 15,
                  color: ColorStyle.slategrey,
                  height: 1.6,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: ColorStyle.paleslate),
                const SizedBox(width: 6),
                Text(
                  'Posted by: ${item.adminName ?? 'Barangay Admin'}',
                  style: TextStyle(color: ColorStyle.slategrey, fontSize: 13),
                ),
              ],
            ),
            if (item.expiresAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(Icons.timer, size: 16, color: Colors.orange),
                    const SizedBox(width: 6),
                    Text(
                      'Valid until: ${DateFormat('MMMM dd, yyyy').format(item.expiresAt!)}',
                      style: const TextStyle(color: Colors.orange, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorStyle.topazyw3,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

