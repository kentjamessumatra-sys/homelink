import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prototype_project/screen/home.dart';
import 'package:prototype_project/publicpages/public_dashboard_page.dart';
import 'package:prototype_project/publicpages/barangay_services_page.dart';
import 'package:prototype_project/publicpages/community_news_page.dart';
import 'package:prototype_project/publicpages/service_report_page.dart';
import 'package:prototype_project/publicpages/public_settings_page.dart';
import 'package:prototype_project/publicpages/profile_view_page.dart';
import 'package:prototype_project/utils/kulor_style.dart';

class PublicSidebar extends StatefulWidget {
  final ValueNotifier<Widget> currentPage;
  final ValueNotifier<int>? selectedIndexNotifier;
  final String userId;
  
  const PublicSidebar({
    super.key, 
    required this.currentPage, 
    this.selectedIndexNotifier,
    required this.userId,
  });

  @override
  State<PublicSidebar> createState() => _PublicSidebarState();
}

class _PublicSidebarState extends State<PublicSidebar> {
  int _selectedIndex = 0;
  String _userName = 'Resident';
  final _userRole = 'Resident';
  String _avatarImage = 'asset/man.png';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final supabase = Supabase.instance.client;
      
      final response = await supabase
          .from('resident_profiles')
          .select('first_name, last_name, gender')
          .eq('user_id', widget.userId)
          .maybeSingle();

      if (response == null) {
        setState(() => _isLoading = false);
        return;
      }

      final firstName = response['first_name'] ?? '';
      final lastName = response['last_name'] ?? '';
      final gender = response['gender']?.toString().toLowerCase() ?? 'male';
      
      setState(() {
        _userName = '$firstName $lastName'.trim();
        _avatarImage = gender == 'female' ? 'asset/woman.png' : 'asset/man.png';
        _isLoading = false;
      });
      
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [ColorStyle.topazyw2, ColorStyle.topazyw3],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Image.asset(
                  'asset/homelinklogo.png',
                  width: 90,
                  height: 90,
                ),
                const SizedBox(width: 5),
                const Text(
                  'HomeLink',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 0),
          const Divider(color: Colors.white54),
          ListTile(
            leading: const Icon(Icons.public, color: Colors.white),
            title: const Text('Public', style: TextStyle(color: Colors.white)),
            subtitle: const Text(
              'Barangay Ulbujan, Municipality of Calape, Province of Bohol',
              style: TextStyle(color: Colors.white70),
            ),
            onTap: () {},
          ),
          const SizedBox(height: 10.0),
          _buildSidebarItem(
            icon: Icons.dashboard,
            title: 'Dashboard',
            index: 0,
            onTap: () {
              setState(() => _selectedIndex = 0);
              widget.currentPage.value = const PublicDashboardPage();
            },
          ),
          _buildSidebarItem(
            icon: Icons.build_circle_outlined,
            title: 'Barangay Services',
            index: 1,
            onTap: () {
              setState(() => _selectedIndex = 1);
              widget.currentPage.value = const BarangayServicesPage();
              widget.selectedIndexNotifier?.value = 1;
            },
          ),
          _buildSidebarItem(
            icon: Icons.article_outlined,
            title: 'Community News',
            index: 2,
            onTap: () {
              setState(() => _selectedIndex = 2);
              widget.currentPage.value = const CommunityNewsPage();
              widget.selectedIndexNotifier?.value = 2;
            },
          ),
          _buildSidebarItem(
            icon: Icons.report_problem_outlined,
            title: 'Service Report',
            index: 3,
            onTap: () {
              setState(() => _selectedIndex = 3);
              widget.currentPage.value = const ServiceReportPage();
              widget.selectedIndexNotifier?.value = 3;
            },
          ),
          _buildSidebarItem(
            icon: Icons.settings,
            title: 'Settings',
            index: 4,
            onTap: () {
              setState(() => _selectedIndex = 4);
              widget.currentPage.value = const PublicSettingsPage();
              widget.selectedIndexNotifier?.value = 4;
            },
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(
                      width: 1.5,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 25,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  )
                                : Image.asset(
                                    _avatarImage,
                                    height: 45,
                                    width: 45,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        _avatarImage.contains('woman') 
                                            ? Icons.female 
                                            : Icons.male,
                                        size: 40,
                                        color: Colors.white,
                                      );
                                    },
                                  ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    title: Text(
                      _isLoading ? 'Loading...' : _userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      _userRole,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProfileViewPage(userId: widget.userId)
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const Divider(color: Colors.white54),
          _buildSidebarItem(
            icon: Icons.logout,
            title: 'Logout',
            index: 5,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: ColorStyle.topazyw1,
                  title: const Text('Logout Confirmation'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (context.mounted) {
                          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const Home()),
                            (route) => false,
                          );
                        }
                      },
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          color: ColorStyle.topazyw3,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String title,
    required int index,
    required VoidCallback onTap,
  }) {
    final isSelected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withValues(alpha: 0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onTap,
        hoverColor: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        child: ListTile(
          leading: Icon(icon, color: isSelected ? Colors.white : Colors.white70),
          title: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}