import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prototype_project/services/announcement_model.dart';
import 'package:prototype_project/services/dashboard_service.dart';
import 'package:prototype_project/utils/kulor_style.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DashboardService _dashboardService = DashboardService();
  
  DashboardStats? _stats;
  List<Map<String, dynamic>> _recentActivity = [];
  List<Map<String, dynamic>> _reportsByStatus = [];
  List<AnnouncementModel> _latestAnnouncements = [];
  
  bool _isLoading = true;
  bool _isLoadingActivity = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

 Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      // PARALLEL: Stats, Reports Chart, at Announcements sabay-sabay
      final results = await Future.wait([
        _dashboardService.getAdminStats(),
        _dashboardService.getReportsByStatus(),
        _dashboardService.getLatestAnnouncements(limit: 3),
      ]);

      setState(() {
        _stats = results[0] as DashboardStats;
        _reportsByStatus = results[1] as List<Map<String, dynamic>>;
        _latestAnnouncements = (results[2] as List<Map<String, dynamic>>)
            .map((a) => AnnouncementModel.fromJson(Map<String, dynamic>.from(a)))
            .toList();
        _isLoading = false;
      });

      // Load activity separately (pwede na ito kasi mas mababa ang priority)
      _loadActivity();
    } catch (e, stackTrace) {
      setState(() => _isLoading = false);
      debugPrint('🔥 DASHBOARD ERROR: $e');
      debugPrint('📍 STACK: $stackTrace');
      _showError('Failed to load dashboard: $e');
    }
  }

  Future<void> _loadActivity() async {
    try {
      final activity = await _dashboardService.getRecentActivity(limit: 6);
      setState(() {
        _recentActivity = activity;
        _isLoadingActivity = false;
      });
    } catch (e) {
      setState(() => _isLoadingActivity = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorStyle.topazyw4,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              color: ColorStyle.topazyw3,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    _buildWelcomeSection(),
                    const SizedBox(height: 28),
                    
                    // Stats Grid
                    _buildStatsGrid(),
                    const SizedBox(height: 28),
                    
                    // Middle Row: Charts + Recent Activity
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildReportsChart(),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 3,
                          child: _buildRecentActivity(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    
                    // Bottom Row: Quick Actions + Latest Announcements
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildQuickActions(),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 3,
                          child: _buildLatestAnnouncements(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWelcomeSection() {
    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(now);
    final greeting = _getGreeting();

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorStyle.topazyw3,
            ColorStyle.topazyw2,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ColorStyle.topazyw3.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Welcome to HomeLink Admin Portal',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white60, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              size: 64,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = [
      {
        'title': 'Total Residents',
        'value': _stats?.totalResidents.toString() ?? '0',
        'icon': Icons.people,
        'color': Colors.blue,
        'subtitle': '${_stats?.totalHouseholds ?? 0} households',
      },
      {
        'title': 'Pending Reports',
        'value': _stats?.pendingReports.toString() ?? '0',
        'icon': Icons.report_outlined,
        'color': Colors.orange,
        'subtitle': 'Needs attention',
      },
      {
        'title': 'Pending Registrations',
        'value': _stats?.pendingRegistrations.toString() ?? '0',
        'icon': Icons.person_add,
        'color': Colors.purple,
        'subtitle': 'Awaiting approval',
      },
      {
        'title': 'Active Announcements',
        'value': _stats?.activeAnnouncements.toString() ?? '0',
        'icon': Icons.campaign,
        'color': Colors.green,
        'subtitle': 'Currently published',
      },
      {
        'title': 'Pending Requests',
        'value': _stats?.pendingServiceRequests.toString() ?? '0',
        'icon': Icons.assignment_turned_in,
        'color': Colors.teal,
        'subtitle': 'Service requests',
      },
      {
        'title': 'Resolved (This Month)',
        'value': _stats?.resolvedReportsThisMonth.toString() ?? '0',
        'icon': Icons.check_circle,
        'color': Colors.indigo,
        'subtitle': 'Reports completed',
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Determine columns based on width
        int crossAxisCount;
        double aspectRatio;

        if (width > 1400) {
          crossAxisCount = 6;
          aspectRatio = 1.3;
        } else if (width > 1100) {
          crossAxisCount = 3;
          aspectRatio = 1.6;
        } else if (width > 700) {
          crossAxisCount = 3;
          aspectRatio = 1.4;
        } else {
          crossAxisCount = 2;
          aspectRatio = 1.2;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: aspectRatio,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            return _StatCard(
              title: stat['title'] as String,
              value: stat['value'] as String,
              icon: stat['icon'] as IconData,
              color: stat['color'] as Color,
              subtitle: stat['subtitle'] as String,
            );
          },
        );
      },
    );
  }

  Widget _buildReportsChart() {
    final colors = {
      'submitted': Colors.grey,
      'received': Colors.blue,
      'investigating': Colors.orange,
      'in_progress': Colors.deepOrange,
      'resolved': Colors.green,
      'closed': Colors.purple,
      'rejected': Colors.red,
    };

    final labels = {
      'submitted': 'Submitted',
      'received': 'Received',
      'investigating': 'Investigating',
      'in_progress': 'In Progress',
      'resolved': 'Resolved',
      'closed': 'Closed',
      'rejected': 'Rejected',
    };

    final total = _reportsByStatus.fold<int>(0, (sum, item) => sum + (item['count'] as int));

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ColorStyle.topazyw3.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ColorStyle.topazyw3.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.pie_chart, color: ColorStyle.topazyw3, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Reports Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorStyle.topazyw3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (total == 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.inbox, size: 48, color: ColorStyle.platinum),
                    const SizedBox(height: 8),
                    Text('No reports yet', style: TextStyle(color: ColorStyle.slategrey)),
                  ],
                ),
              ),
            )
          else
            Column(
              children: _reportsByStatus.map((item) {
                final status = item['status'] as String;
                final count = item['count'] as int;
                final percentage = total > 0 ? (count / total * 100) : 0.0;
                final color = colors[status] ?? Colors.grey;
                final label = labels[status] ?? status;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 6,
                                backgroundColor: color,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                label,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: ColorStyle.slategrey,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '$count (${percentage.toStringAsFixed(1)}%)',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: ColorStyle.topazyw3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Total Reports: $total',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: ColorStyle.slategrey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ColorStyle.topazyw3.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.notifications_active, color: Colors.blue, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ColorStyle.topazyw3,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: ColorStyle.ivory,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Live',
                  style: TextStyle(
                    color: ColorStyle.topazyw3,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_isLoadingActivity)
            const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
          else if (_recentActivity.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.inbox, size: 48, color: ColorStyle.platinum),
                    const SizedBox(height: 8),
                    Text('No recent activity', style: TextStyle(color: ColorStyle.slategrey)),
                  ],
                ),
              ),
            )
          else
            Column(
              children: _recentActivity.asMap().entries.map((entry) {
                final activity = entry.value;
                final isLast = entry.key == _recentActivity.length - 1;
                final timeAgo = _getTimeAgo(activity['time'] as DateTime);

                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (activity['color'] as Color).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            activity['icon'] as IconData,
                            color: activity['color'] as Color,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity['title'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                activity['subtitle'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: ColorStyle.slategrey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                timeAgo,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: ColorStyle.paleslate,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (!isLast) const Divider(height: 24),
                  ],
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'icon': Icons.person_add, 'title': 'Review Registrations', 'color': Colors.purple, 'route': '/admin/registrations'},
      {'icon': Icons.campaign, 'title': 'Post Announcement', 'color': Colors.green, 'route': '/admin/announcements'},
      {'icon': Icons.report, 'title': 'View Reports', 'color': Colors.orange, 'route': '/admin/reports'},
      {'icon': Icons.assignment, 'title': 'Service Requests', 'color': Colors.teal, 'route': '/admin/requests'},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ColorStyle.topazyw3.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ColorStyle.topazyw3.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.flash_on, color: ColorStyle.topazyw3, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorStyle.topazyw3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...actions.map((action) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () {
                  // Navigate to route
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (action['color'] as Color).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          action['icon'] as IconData,
                          color: action['color'] as Color,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          action['title'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
                    ],
                  ),
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildLatestAnnouncements() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ColorStyle.topazyw3.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.campaign, color: Colors.green, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Latest Announcements',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ColorStyle.topazyw3,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_latestAnnouncements.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No active announcements',
                  style: TextStyle(color: ColorStyle.slategrey),
                ),
              ),
            )
          else
            Column(
              children: _latestAnnouncements.map((announcement) {
                final priorityColors = {
                  'low': Colors.grey,
                  'normal': Colors.blue,
                  'high': Colors.orange,
                  'urgent': Colors.red,
                };

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: ColorStyle.ivory,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (priorityColors[announcement.priority.name] ?? Colors.grey).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (priorityColors[announcement.priority.name] ?? Colors.grey).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.campaign,
                          color: priorityColors[announcement.priority.name] ?? Colors.grey,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              announcement.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('MMM dd, yyyy').format(announcement.createdAt ?? DateTime.now()),
                              style: TextStyle(
                                fontSize: 12,
                                color: ColorStyle.paleslate,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (priorityColors[announcement.priority.name] ?? Colors.grey).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          announcement.priority.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: priorityColors[announcement.priority.name] ?? Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
        mainAxisSize: MainAxisSize.min, 
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20), 
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: ColorStyle.topazyw3,
              ),
            ),
          ),
          const SizedBox(height: 4),

          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ColorStyle.slategrey,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),

          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: ColorStyle.paleslate,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}