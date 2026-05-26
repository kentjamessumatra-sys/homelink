import 'package:flutter/material.dart';
import 'package:prototype_project/adminpages/announcements_page.dart';
import 'package:prototype_project/adminpages/household_page.dart';
import 'package:prototype_project/adminpages/registration_approvals_page.dart';
import 'package:prototype_project/adminpages/dashboard_page.dart';
import 'package:prototype_project/adminpages/resident_management_page.dart';
import 'package:prototype_project/adminpages/service_report_page.dart';
import 'package:prototype_project/adminpages/service_request_page.dart';
import 'package:prototype_project/adminpages/system_settings_page.dart';
import 'package:prototype_project/screen/home.dart';
import 'package:prototype_project/utils/kulor_style.dart';

class AdminSidebar extends StatefulWidget {
  final ValueNotifier<Widget> currentPage;
  const AdminSidebar({super.key, required this.currentPage});

  @override
  State<AdminSidebar> createState() => _AdminSidebarState();
}

class _AdminSidebarState extends State<AdminSidebar> {
  int _selectedIndex = 0; // Default to Dashboard selected

  @override
  void initState() {
    super.initState();
    widget.currentPage.value = const DashboardPage(); // Set initial page
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
          const ListTile(
            leading: Icon(Icons.admin_panel_settings, color: Colors.white),
            title: Text('Admin', style: TextStyle(color: Colors.white)),
            subtitle: Text(
              'Barangay Ulbujan, Municipality of Calape, Province of Bohol',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          const SizedBox(height: 10.0),
          _buildSidebarItem(
            icon: Icons.dashboard,
            title: 'Dashboard',
            index: 0,
            onTap: () {
              widget.currentPage.value = const DashboardPage();
            },
          ),
          _buildSidebarItem(
            icon: Icons.people,
            title: 'Resident Management',
            index: 1,
            onTap: () {
              widget.currentPage.value = const ResidentManagementPage();
            },
          ),
          _buildSidebarItem(
            icon: Icons.how_to_reg_outlined,
            title: 'Registration Approvals',
            index: 2,
            onTap: () {
              widget.currentPage.value = const RegistrationApprovalsPage();
            },
          ),
          _buildSidebarItem(
            icon: Icons.home,
            title: 'Households',
            index: 3, // O kung anong index ang available
            onTap: () {
              widget.currentPage.value = const HouseholdPage();
            },
          ),
          _buildSidebarItem(
            icon: Icons.build_circle_outlined,
            title: 'Service Request',
            index: 4,
            onTap: () {
              widget.currentPage.value = const ServiceRequestPage();
            },
          ),
          _buildSidebarItem(
            icon: Icons.campaign_outlined,
            title: 'Announcements',
            index: 5,
            onTap: () {
              widget.currentPage.value = const AnnouncementsPage();
            },
          ),
          _buildSidebarItem(
            icon: Icons.description_outlined,
            title: 'Service Report',
            index: 6,
            onTap: () {
              widget.currentPage.value = const ServiceReportPage();
            },
          ),
          const Spacer(),
          _buildSidebarItem(
            icon: Icons.settings,
            title: 'System Settings',
            index: 7,
            onTap: () {
              widget.currentPage.value = const SystemSettingsPage();
            },
          ),
          const Divider(color: Colors.white54),
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: _buildSidebarItem(
              icon: Icons.logout,
              title: 'Logout',
              index: 8,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: ColorStyle.topazyw1,
                    title: const Text('Confirmation'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const Home()),
                          );
                        },
                        child: const Text('Logout', style: TextStyle(color: ColorStyle.topazyw3, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              },
            ),
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
    Widget? trailing,
  }) {
    final isSelected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withValues(alpha:  0.3) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
          onTap();
        },
        hoverColor: Colors.white.withValues(alpha:  0.2),
        borderRadius: BorderRadius.circular(10),
        child: ListTile(
          leading: Icon(icon, color: Colors.white),
          title: Text(title, style: const TextStyle(color: Colors.white)),
          trailing: trailing,
        ),
      ),
    );
  }
}
