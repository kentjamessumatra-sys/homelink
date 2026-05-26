import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prototype_project/services/announcement_model.dart';
import 'package:prototype_project/services/announcement_service.dart';
import 'package:prototype_project/utils/kulor_style.dart';

class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key});

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage>
    with TickerProviderStateMixin {
  final AnnouncementService _service = AnnouncementService();
  List<AnnouncementModel> _announcements = [];
  List<AnnouncementModel> _filteredAnnouncements = [];
  bool _isLoading = true;

  // Filter & Search State
  AnnouncementPriority? _selectedPriority;
  final TextEditingController _searchController = TextEditingController();
  // ignore: unused_field
  bool _isSearching = false;

  // Animation controllers
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );
    _loadAnnouncements();

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadAnnouncements() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await _service.getAllAnnouncements();
      if (!mounted) return;
      setState(() {
        _announcements = data;
        _applyFilters();
        _isLoading = false;
      });
      _fabAnimationController.forward();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Failed to load: $e');
    }
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = _announcements;

    // Apply priority filter
    if (_selectedPriority != null) {
      filtered = filtered.where((a) => a.priority == _selectedPriority).toList();
    }

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((a) =>
        a.title.toLowerCase().contains(query) ||
        a.content.toLowerCase().contains(query) ||
        (a.category?.toLowerCase().contains(query) ?? false)
      ).toList();
    }

    if (!mounted) return;
    setState(() => _filteredAnnouncements = filtered);
  }

  void _setPriorityFilter(AnnouncementPriority? priority) {
    setState(() {
      _selectedPriority = _selectedPriority == priority ? null : priority;
      _applyFilters();
    });
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: ColorStyle.redtraf,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showForm({AnnouncementModel? announcement}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      transitionAnimationController: AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      ),
      builder: (context) => AnnouncementFormSheet(
        announcement: announcement,
        onSave: (model) async {
          try {
            if (announcement == null) {
              await _service.createAnnouncement(
                title: model.title,
                content: model.content,
                category: model.category,
                priority: model.priority,
                expiresAt: model.expiresAt,
                isPublished: model.isPublished,
              );
              if (mounted) _showSuccess('Announcement published!');
            } else {
              await _service.updateAnnouncement(
                id: announcement.id!,
                title: model.title,
                content: model.content,
                category: model.category,
                priority: model.priority,
                expiresAt: model.expiresAt,
                isPublished: model.isPublished,
              );
              if (mounted) _showSuccess('Announcement updated!');
            }
            if (context.mounted) Navigator.pop(context);
            _loadAnnouncements();
          } catch (e) {
            if (mounted) _showError('Error: $e');
          }
        },
      ),
    );
  }

  void _showDetail(AnnouncementModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AnnouncementDetailSheet(
        announcement: item,
        onEdit: () {
          Navigator.pop(context);
          _showForm(announcement: item);
        },
        onDelete: () => _delete(item.id!),
        onTogglePublish: () => _togglePublish(item),
      ),
    );
  }

  Future<void> _delete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: ColorStyle.redtraf),
            const SizedBox(width: 8),
            const Text('Delete Announcement'),
          ],
        ),
        content: const Text('Are you sure? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: ColorStyle.slategrey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorStyle.redtraf,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _service.deleteAnnouncement(id);
        if (mounted) _showSuccess('Deleted successfully');
        _loadAnnouncements();
      } catch (e) {
        if (mounted) _showError('Delete failed: $e');
      }
    }
  }

  Future<void> _togglePublish(AnnouncementModel item) async {
    try {
      await _service.togglePublishStatus(item.id!, item.isPublished);
      _loadAnnouncements();
      if (mounted) _showSuccess(item.isPublished ? 'Unpublished' : 'Published');
    } catch (e) {
      if (mounted) _showError('Error: $e');
    }
  }

  Map<String, int> get _priorityCounts {
    return {
      'all': _announcements.length,
      for (var p in AnnouncementPriority.values)
        p.name: _announcements.where((a) => a.priority == p).length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorStyle.ivory,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // App Bar - Clean, no search icon
          SliverAppBar(
            expandedHeight: 60,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [ColorStyle.topazyw2, ColorStyle.topazyw3],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const FlexibleSpaceBar(
                titlePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                title: Text(
                  'Manage Announcements',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),

          // Search Bar + Priority Filter Chips Combined
          SliverToBoxAdapter(
            child: Container(
              color: ColorStyle.ivory,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar - Sa ilalim ng title, malayo sa close button
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: TextField(
                      controller: _searchController,
                      onTap: () => setState(() => _isSearching = true),
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search announcements...',
                        hintStyle: TextStyle(color: ColorStyle.paleslate),
                        prefixIcon: const Icon(Icons.search, color: ColorStyle.topazyw3, size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close, color: ColorStyle.paleslate, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _isSearching = false);
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: ColorStyle.topazyw3.withValues(alpha: 0.2)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: ColorStyle.topazyw3.withValues(alpha: 0.2)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: ColorStyle.topazyw3, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ),

                  // Priority Filter Chips - Below search bar
                  SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildPriorityChip('All', _priorityCounts['all'] ?? 0, null, ColorStyle.topazyw2),
                        ...AnnouncementPriority.values.map((p) {
                          return _buildPriorityChip(
                            p.label,
                            _priorityCounts[p.name] ?? 0,
                            p,
                            p.color,
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: ColorStyle.topazyw3))
            : RefreshIndicator(
                onRefresh: _loadAnnouncements,
                color: ColorStyle.topazyw3,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _filteredAnnouncements.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _filteredAnnouncements.length,
                          itemBuilder: (context, index) {
                            final item = _filteredAnnouncements[index];
                            return _buildAnnouncementCard(item, index);
                          },
                        ),
                ),
              ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          onPressed: () => _showForm(),
          backgroundColor: ColorStyle.topazyw3,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'New',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String label, int count, AnnouncementPriority? priority, Color color) {
    final isSelected = _selectedPriority == priority;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _setPriorityFilter(priority),
          borderRadius: BorderRadius.circular(25),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha: 0.2) : color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected ? color : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  priority?.icon ?? Icons.all_inclusive,
                  size: 16,
                  color: isSelected ? color : color.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? color : color.withValues(alpha: 0.8),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? color : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: isSelected ? Colors.white : color.withValues(alpha: 0.7),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchController.text.isNotEmpty || _selectedPriority != null
                ? Icons.search_off
                : Icons.campaign_outlined,
            size: 100,
            color: ColorStyle.platinum,
          ),
          const SizedBox(height: 20),
          Text(
            _searchController.text.isNotEmpty || _selectedPriority != null
                ? 'No announcements found'
                : 'No announcements yet',
            style: TextStyle(
              color: ColorStyle.slategrey,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty || _selectedPriority != null
                ? 'Try adjusting your filters'
                : 'Tap the + button to create one',
            style: TextStyle(
              color: ColorStyle.paleslate,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(AnnouncementModel item, int index) {
    return Hero(
      tag: 'announcement_${item.id}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDetail(item),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: ColorStyle.topazyw3.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Priority bar
                Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: item.priority.color,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: item.priority.color.withValues(alpha: 0.12),
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
                          if (!item.isPublished)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'DRAFT',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          if (item.isExpired)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: ColorStyle.redtraf.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'EXPIRED',
                                style: TextStyle(
                                  color: ColorStyle.redtraf,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
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
                      const SizedBox(height: 6),
                      Text(
                        item.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: ColorStyle.slategrey,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.person_outline, size: 14, color: ColorStyle.paleslate),
                          const SizedBox(width: 4),
                          Text(
                            item.adminName ?? 'Admin',
                            style: TextStyle(fontSize: 12, color: ColorStyle.paleslate),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.access_time, size: 14, color: ColorStyle.paleslate),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat("MMM dd, yyyy").format(item.createdAt ?? DateTime.now()),
                            style: TextStyle(fontSize: 12, color: ColorStyle.paleslate),
                          ),
                          if (item.category != null) ...[
                            const SizedBox(width: 16),
                            Icon(Icons.label_outline, size: 14, color: ColorStyle.paleslate),
                            const SizedBox(width: 4),
                            Text(
                              item.category!,
                              style: TextStyle(fontSize: 12, color: ColorStyle.paleslate),
                            ),
                          ],
                        ],
                      ),

                      const Divider(height: 24),

                      // Quick Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildQuickAction(
                            icon: item.isPublished ? Icons.visibility_off : Icons.visibility,
                            label: item.isPublished ? 'Unpublish' : 'Publish',
                            color: ColorStyle.slategrey,
                            onTap: () => _togglePublish(item),
                          ),
                          _buildQuickAction(
                            icon: Icons.edit_outlined,
                            label: 'Edit',
                            color: ColorStyle.topazyw3,
                            onTap: () => _showForm(announcement: item),
                          ),
                          _buildQuickAction(
                            icon: Icons.delete_outline,
                            label: 'Delete',
                            color: ColorStyle.redtraf,
                            onTap: () => _delete(item.id!),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== DETAIL BOTTOM SHEET ====================

class AnnouncementDetailSheet extends StatelessWidget {
  final AnnouncementModel announcement;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTogglePublish;

  const AnnouncementDetailSheet({
    super.key,
    required this.announcement,
    required this.onEdit,
    required this.onDelete,
    required this.onTogglePublish,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: ColorStyle.platinum,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              Expanded(
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    // Header with priority bar
                    SliverToBoxAdapter(
                      child: Hero(
                        tag: 'announcement_${announcement.id}',
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: announcement.priority.color.withValues(alpha: 0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Priority bar
                              Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: announcement.priority.color,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: announcement.priority.color.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(announcement.priority.icon, size: 16, color: announcement.priority.color),
                                              const SizedBox(width: 6),
                                              Text(
                                                announcement.priority.label,
                                                style: TextStyle(
                                                  color: announcement.priority.color,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        if (!announcement.isPublished)
                                          _buildStatusBadge('DRAFT', Colors.grey),
                                        if (announcement.isExpired)
                                          _buildStatusBadge('EXPIRED', ColorStyle.redtraf),
                                      ],
                                    ),

                                    const SizedBox(height: 20),
                                    Text(
                                      announcement.title,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: ColorStyle.topazyw3,
                                        height: 1.3,
                                      ),
                                    ),

                                    const SizedBox(height: 20),
                                    // Meta info row
                                    Wrap(
                                      spacing: 16,
                                      runSpacing: 8,
                                      children: [
                                        _buildMetaItem(Icons.person_outline, announcement.adminName ?? 'Admin'),
                                        _buildMetaItem(Icons.access_time, DateFormat("MMM dd, yyyy - hh:mm a").format(announcement.createdAt ?? DateTime.now())),
                                        if (announcement.category != null)
                                          _buildMetaItem(Icons.label_outline, announcement.category!),
                                        if (announcement.expiresAt != null)
                                          _buildMetaItem(Icons.timer_outlined, 'Expires: ${DateFormat("MMM dd, yyyy").format(announcement.expiresAt!)}'),
                                      ],
                                    ),

                                    const Divider(height: 32),

                                    // Full Content
                                    Text(
                                      'Content',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: ColorStyle.topazyw3.withValues(alpha: 0.7),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      announcement.content,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: ColorStyle.slategrey,
                                        height: 1.6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Bottom spacing
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100),
                    ),
                  ],
                ),
              ),

              // Bottom Action Bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            onTogglePublish();
                          },
                          icon: Icon(
                            announcement.isPublished ? Icons.visibility_off : Icons.visibility,
                            size: 20,
                          ),
                          label: Text(announcement.isPublished ? 'Unpublish' : 'Publish'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: announcement.isPublished ? Colors.grey.shade200 : ColorStyle.topazyw3,
                            foregroundColor: announcement.isPublished ? ColorStyle.slategrey : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: ColorStyle.topazyw3.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onEdit();
                          },
                          icon: const Icon(Icons.edit, color: ColorStyle.topazyw3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: ColorStyle.redtraf.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onDelete();
                          },
                          icon: const Icon(Icons.delete_outline, color: ColorStyle.redtraf),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: ColorStyle.paleslate),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(fontSize: 13, color: ColorStyle.paleslate),
        ),
      ],
    );
  }
}

// ==================== FORM BOTTOM SHEET (ENHANCED) ====================

class AnnouncementFormSheet extends StatefulWidget {
  final AnnouncementModel? announcement;
  final Function(AnnouncementModel) onSave;

  const AnnouncementFormSheet({super.key, this.announcement, required this.onSave});

  @override
  State<AnnouncementFormSheet> createState() => _AnnouncementFormSheetState();
}

class _AnnouncementFormSheetState extends State<AnnouncementFormSheet> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _categoryController = TextEditingController();

  AnnouncementPriority _priority = AnnouncementPriority.normal;
  bool _isPublished = true;
  DateTime? _expiresAt;
  bool _isSaving = false;

  // Character counters
  final int _maxTitleLength = 100;
  final int _maxContentLength = 2000;

  @override
  void initState() {
    super.initState();
    if (widget.announcement != null) {
      final a = widget.announcement!;
      _titleController.text = a.title;
      _contentController.text = a.content;
      _categoryController.text = a.category ?? '';
      _priority = a.priority;
      _isPublished = a.isPublished;
      _expiresAt = a.expiresAt;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickExpiryDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expiresAt ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ColorStyle.topazyw3,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: ColorStyle.topazyw3,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _expiresAt = date);
    }
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and content are required')),
      );
      return;
    }

    setState(() => _isSaving = true);

    widget.onSave(AnnouncementModel(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      category: _categoryController.text.trim().isNotEmpty ? _categoryController.text.trim() : null,
      priority: _priority,
      isPublished: _isPublished,
      expiresAt: _expiresAt,
    ));

    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: ColorStyle.platinum,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              widget.announcement == null ? 'New Announcement' : 'Edit Announcement',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ColorStyle.topazyw3,
              ),
            ),
            const SizedBox(height: 24),

            // Title with counter
            TextField(
              controller: _titleController,
              maxLength: _maxTitleLength,
              buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
                return Text(
                  '$currentLength/$maxLength',
                  style: TextStyle(
                    fontSize: 11,
                    color: currentLength >= maxLength! ? ColorStyle.redtraf : ColorStyle.paleslate,
                  ),
                );
              },
              decoration: InputDecoration(
                labelText: 'Title',
                hintText: 'Enter announcement title',
                prefixIcon: const Icon(Icons.title, color: ColorStyle.topazyw3),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: ColorStyle.topazyw3, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Content with counter
            TextField(
              controller: _contentController,
              maxLines: 5,
              maxLength: _maxContentLength,
              buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
                return Text(
                  '$currentLength/$maxLength',
                  style: TextStyle(
                    fontSize: 11,
                    color: currentLength >= maxLength! ? ColorStyle.redtraf : ColorStyle.paleslate,
                  ),
                );
              },
              decoration: InputDecoration(
                labelText: 'Content',
                hintText: 'Write the announcement details...',
                prefixIcon: const Icon(Icons.article, color: ColorStyle.topazyw3),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: ColorStyle.topazyw3, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Category
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: 'Category (Optional)',
                hintText: 'e.g., Health, Safety, Events',
                prefixIcon: const Icon(Icons.label_outline, color: ColorStyle.topazyw3),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: ColorStyle.topazyw3, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Priority
            Text(
              'Priority Level',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: ColorStyle.topazyw3,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: AnnouncementPriority.values.map((p) {
                final isSelected = _priority == p;
                return ChoiceChip(
                  label: Text(p.label),
                  selected: isSelected,
                  selectedColor: p.color.withValues(alpha: 0.2),
                  backgroundColor: Colors.grey.shade100,
                  labelStyle: TextStyle(
                    color: isSelected ? p.color : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  avatar: Icon(p.icon, size: 18, color: isSelected ? p.color : Colors.grey),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isSelected ? p.color : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  onSelected: (_) => setState(() => _priority = p),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Expiry & Publish
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickExpiryDate,
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(
                      _expiresAt == null ? 'Set Expiry' : 'Expires: ${DateFormat("MMM dd, yyyy").format(_expiresAt!)}',
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ColorStyle.topazyw3,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: ColorStyle.topazyw3.withValues(alpha: 0.3)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ColorStyle.topazyw3.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _isPublished,
                          onChanged: (v) => setState(() => _isPublished = v!),
                          activeColor: ColorStyle.topazyw3,
                        ),
                        const Expanded(
                          child: Text(
                            'Publish Now',
                            style: TextStyle(fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorStyle.topazyw3,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                  shadowColor: ColorStyle.topazyw3.withValues(alpha: 0.4),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        widget.announcement == null ? 'Post Announcement' : 'Update Announcement',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
