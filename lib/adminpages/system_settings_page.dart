import 'package:flutter/material.dart';
import 'package:prototype_project/utils/kulor_style.dart';

class SystemSettingsPage extends StatefulWidget {
  const SystemSettingsPage({super.key});

  @override
  State<SystemSettingsPage> createState() => _SystemSettingsPageState();
}

class _SystemSettingsPageState extends State<SystemSettingsPage> {
  // Settings toggles
  bool _darkMode = false;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _pushNotifications = true;
  bool _autoBackup = true;
  bool _analyticsTracking = false;
  
  // Selected settings section
  String _selectedSection = 'general';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ColorStyle.topazyw2.withValues(alpha: 0.3),
            Colors.grey[100]!,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'System Settings',
                      style: TextStyle(
                        fontSize: 28,
                        color: ColorStyle.topazyw3,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.settings, size: 18, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          'Configure and manage your system preferences',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                _buildSaveButton(),
              ],
            ),
            const SizedBox(height: 24),
            
            // Settings Content
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Sidebar - Settings Categories
                  Container(
                    width: 260,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildSidebarItem(
                          icon: Icons.tune,
                          title: 'General',
                          subtitle: 'Basic preferences',
                          section: 'general',
                        ),
                        _buildSidebarItem(
                          icon: Icons.security,
                          title: 'Security & Privacy',
                          subtitle: 'Access control',
                          section: 'security',
                        ),
                        _buildSidebarItem(
                          icon: Icons.notifications,
                          title: 'Notifications',
                          subtitle: 'Alert settings',
                          section: 'notifications',
                        ),
                        _buildSidebarItem(
                          icon: Icons.storage,
                          title: 'Data Management',
                          subtitle: 'Storage & records',
                          section: 'data',
                        ),
                        _buildSidebarItem(
                          icon: Icons.backup,
                          title: 'Backup & Restore',
                          subtitle: 'Data recovery',
                          section: 'backup',
                        ),
                        _buildSidebarItem(
                          icon: Icons.info_outline,
                          title: 'System Info',
                          subtitle: 'Version & licenses',
                          section: 'system',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  
                  // Right Content Area
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _buildSettingsContent(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  const Text('Settings saved successfully!'),
                ],
              ),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ColorStyle.topazyw3,
                ColorStyle.topazyw3.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: ColorStyle.topazyw3.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.save, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Save Changes',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String section,
  }) {
    final isSelected = _selectedSection == section;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedSection = section;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isSelected
                  ? [ColorStyle.topazyw3.withValues(alpha: 0.1), ColorStyle.topazyw3.withValues(alpha: 0.05)]
                  : [Colors.transparent, Colors.transparent],
            ),
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: ColorStyle.topazyw3.withValues(alpha: 0.3))
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? ColorStyle.topazyw3.withValues(alpha: 0.15)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? ColorStyle.topazyw3 : Colors.grey[600],
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isSelected ? ColorStyle.topazyw3 : Colors.grey[800],
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isSelected ? ColorStyle.topazyw3 : Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsContent() {
    switch (_selectedSection) {
      case 'general':
        return _buildGeneralSettings();
      case 'security':
        return _buildSecuritySettings();
      case 'notifications':
        return _buildNotificationSettings();
      case 'data':
        return _buildDataManagementSettings();
      case 'backup':
        return _buildBackupSettings();
      case 'system':
        return _buildSystemInfoSettings();
      default:
        return _buildGeneralSettings();
    }
  }

  Widget _buildGeneralSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.tune,
            title: 'General Settings',
            subtitle: 'Configure basic application preferences',
          ),
          const SizedBox(height: 24),
          _buildSettingCard(
            title: 'Appearance',
            children: [
              _buildSwitchTile(
                icon: Icons.dark_mode,
                title: 'Dark Mode',
                subtitle: 'Switch between light and dark themes',
                value: _darkMode,
                onChanged: (value) => setState(() => _darkMode = value),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            title: 'Language & Region',
            children: [
              _buildDropdownTile(
                icon: Icons.language,
                title: 'Language',
                subtitle: 'Select your preferred language',
                value: 'English',
                items: ['English', 'Filipino', 'Spanish'],
              ),
              const Divider(height: 1),
              _buildDropdownTile(
                icon: Icons.location_on,
                title: 'Time Zone',
                subtitle: 'Set your local time zone',
                value: 'Asia/Manila (PHT)',
                items: ['Asia/Manila (PHT)', 'Asia/Tokyo (JST)', 'UTC'],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            title: 'Display',
            children: [
              _buildDropdownTile(
                icon: Icons.table_rows,
                title: 'Default View',
                subtitle: 'Choose the default page to show',
                value: 'Dashboard',
                items: ['Dashboard', 'Residents', 'Services', 'Announcements'],
              ),
              const Divider(height: 1),
              _buildDropdownTile(
                icon: Icons.format_list_numbered,
                title: 'Items Per Page',
                subtitle: 'Number of items to display in lists',
                value: '20',
                items: ['10', '20', '50', '100'],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.security,
            title: 'Security & Privacy',
            subtitle: 'Manage access control and security preferences',
          ),
          const SizedBox(height: 24),
          _buildSettingCard(
            title: 'Authentication',
            children: [
              _buildSwitchTile(
                icon: Icons.fingerprint,
                title: 'Biometric Login',
                subtitle: 'Use fingerprint or face recognition',
                value: true,
                onChanged: (value) {},
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                icon: Icons.timer,
                title: 'Auto Logout',
                subtitle: 'Automatically logout after inactivity',
                value: true,
                onChanged: (value) {},
              ),
              const Divider(height: 1),
              _buildActionTile(
                icon: Icons.lock_reset,
                title: 'Change Password',
                subtitle: 'Update your account password',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            title: 'Privacy',
            children: [
              _buildSwitchTile(
                icon: Icons.visibility_off,
                title: 'Hide Sensitive Data',
                subtitle: 'Mask private information in lists',
                value: true,
                onChanged: (value) {},
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                icon: Icons.history,
                title: 'Activity Logging',
                subtitle: 'Track user activities and changes',
                value: true,
                onChanged: (value) {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            title: 'Access Control',
            children: [
              _buildActionTile(
                icon: Icons.admin_panel_settings,
                title: 'Admin Roles',
                subtitle: 'Manage administrator permissions',
                onTap: () {},
              ),
              const Divider(height: 1),
              _buildActionTile(
                icon: Icons.group,
                title: 'User Permissions',
                subtitle: 'Configure user access levels',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.notifications,
            title: 'Notification Settings',
            subtitle: 'Configure how you receive alerts and updates',
          ),
          const SizedBox(height: 24),
          _buildSettingCard(
            title: 'Email Notifications',
            children: [
              _buildSwitchTile(
                icon: Icons.email,
                title: 'Email Alerts',
                subtitle: 'Receive notifications via email',
                value: _emailNotifications,
                onChanged: (value) => setState(() => _emailNotifications = value),
              ),
              const Divider(height: 1),
              _buildDropdownTile(
                icon: Icons.schedule,
                title: 'Frequency',
                subtitle: 'How often to receive email updates',
                value: 'Instant',
                items: ['Instant', 'Daily Digest', 'Weekly Digest', 'Never'],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            title: 'SMS Notifications',
            children: [
              _buildSwitchTile(
                icon: Icons.sms,
                title: 'SMS Alerts',
                subtitle: 'Receive important alerts via SMS',
                value: _smsNotifications,
                onChanged: (value) => setState(() => _smsNotifications = value),
              ),
              const Divider(height: 1),
              _buildActionTile(
                icon: Icons.contact_phone,
                title: 'Phone Numbers',
                subtitle: 'Manage notification phone numbers',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            title: 'Push Notifications',
            children: [
              _buildSwitchTile(
                icon: Icons.notifications_active,
                title: 'Push Notifications',
                subtitle: 'Receive in-app push notifications',
                value: _pushNotifications,
                onChanged: (value) => setState(() => _pushNotifications = value),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            title: 'Notification Types',
            children: [
              _buildSwitchTile(
                icon: Icons.announcement,
                title: 'Announcements',
                subtitle: 'New announcements and news',
                value: true,
                onChanged: (value) {},
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                icon: Icons.task_alt,
                title: 'Service Requests',
                subtitle: 'Updates on service requests',
                value: true,
                onChanged: (value) {},
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                icon: Icons.person_add,
                title: 'New Registrations',
                subtitle: 'New resident registration alerts',
                value: true,
                onChanged: (value) {},
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                icon: Icons.warning,
                title: 'System Alerts',
                subtitle: 'Critical system notifications',
                value: true,
                onChanged: (value) {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataManagementSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.storage,
            title: 'Data Management',
            subtitle: 'Manage storage, records, and data retention',
          ),
          const SizedBox(height: 24),
          _buildSettingCard(
            title: 'Storage',
            children: [
              _buildInfoTile(
                icon: Icons.folder,
                title: 'Storage Used',
                subtitle: '2.4 GB of 10 GB available',
                trailing: Container(
                  width: 120,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.24,
                    child: Container(
                      decoration: BoxDecoration(
                        color: ColorStyle.topazyw3,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              const Divider(height: 1),
              _buildActionTile(
                icon: Icons.cleaning_services,
                title: 'Clear Cache',
                subtitle: 'Free up storage space',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            title: 'Data Retention',
            children: [
              _buildDropdownTile(
                icon: Icons.history,
                title: 'Keep History',
                subtitle: 'How long to keep activity logs',
                value: '6 Months',
                items: ['1 Month', '3 Months', '6 Months', '1 Year', 'Forever'],
              ),
              const Divider(height: 1),
              _buildDropdownTile(
                icon: Icons.archive,
                title: 'Archive Records',
                subtitle: 'Auto-archive old records after',
                value: '1 Year',
                items: ['6 Months', '1 Year', '2 Years', '5 Years'],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            title: 'Data Export',
            children: [
              _buildActionTile(
                icon: Icons.file_download,
                title: 'Export All Data',
                subtitle: 'Download all system data',
                onTap: () {},
              ),
              const Divider(height: 1),
              _buildActionTile(
                icon: Icons.table_chart,
                title: 'Export Residents',
                subtitle: 'Download resident records (CSV)',
                onTap: () {},
              ),
              const Divider(height: 1),
              _buildActionTile(
                icon: Icons.description,
                title: 'Export Reports',
                subtitle: 'Download generated reports',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            title: 'Danger Zone',
            isDanger: true,
            children: [
              _buildActionTile(
                icon: Icons.delete_forever,
                title: 'Delete All Data',
                subtitle: 'Permanently remove all system data',
                isDanger: true,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackupSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.backup,
            title: 'Backup & Restore',
            subtitle: 'Manage data backups and recovery options',
          ),
          const SizedBox(height: 24),
          _buildSettingCard(
            title: 'Auto Backup',
            children: [
              _buildSwitchTile(
                icon: Icons.autorenew,
                title: 'Automatic Backups',
                subtitle: 'Automatically backup data daily',
                value: _autoBackup,
                onChanged: (value) => setState(() => _autoBackup = value),
              ),
              const Divider(height: 1),
              _buildDropdownTile(
                icon: Icons.schedule,
                title: 'Backup Time',
                subtitle: 'When to perform automatic backups',
                value: '2:00 AM',
                items: ['12:00 AM', '2:00 AM', '4:00 AM', '6:00 AM'],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            title: 'Backup History',
            children: [
              _buildBackupItem(
                date: 'Today, 2:00 AM',
                size: '245 MB',
                status: 'Success',
              ),
              const Divider(height: 1),
              _buildBackupItem(
                date: 'Yesterday, 2:00 AM',
                size: '242 MB',
                status: 'Success',
              ),
              const Divider(height: 1),
              _buildBackupItem(
                date: 'Jan 15, 2025',
                size: '238 MB',
                status: 'Success',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            title: 'Manual Actions',
            children: [
              _buildActionTile(
                icon: Icons.backup,
                title: 'Backup Now',
                subtitle: 'Create a manual backup',
                onTap: () {},
              ),
              const Divider(height: 1),
              _buildActionTile(
                icon: Icons.restore,
                title: 'Restore Backup',
                subtitle: 'Restore from a previous backup',
                onTap: () {},
              ),
              const Divider(height: 1),
              _buildActionTile(
                icon: Icons.cloud_upload,
                title: 'Cloud Sync',
                subtitle: 'Configure cloud backup storage',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSystemInfoSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.info,
            title: 'System Information',
            subtitle: 'View application details and system status',
          ),
          const SizedBox(height: 24),
          _buildSettingCard(
            title: 'Application Info',
            children: [
              _buildInfoTile(
                icon: Icons.apps,
                title: 'Application Name',
                subtitle: 'HomeLink - Barangay Management System',
              ),
              const Divider(height: 1),
              _buildInfoTile(
                icon: Icons.tag,
                title: 'Version',
                subtitle: '1.0.0 (Build 2025.01.15)',
              ),
              const Divider(height: 1),
              _buildInfoTile(
                icon: Icons.code,
                title: 'Framework',
                subtitle: 'Flutter 3.x',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            title: 'System Status',
            children: [
              _buildStatusTile(
                icon: Icons.check_circle,
                title: 'Database',
                status: 'Connected',
                statusColor: Colors.green,
              ),
              const Divider(height: 1),
              _buildStatusTile(
                icon: Icons.check_circle,
                title: 'API Server',
                status: 'Online',
                statusColor: Colors.green,
              ),
              const Divider(height: 1),
              _buildStatusTile(
                icon: Icons.check_circle,
                title: 'File Storage',
                status: 'Available',
                statusColor: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            title: 'Analytics',
            children: [
              _buildSwitchTile(
                icon: Icons.analytics,
                title: 'Usage Analytics',
                subtitle: 'Help improve the app with anonymous usage data',
                value: _analyticsTracking,
                onChanged: (value) => setState(() => _analyticsTracking = value),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            title: 'Legal & Support',
            children: [
              _buildActionTile(
                icon: Icons.description,
                title: 'Terms of Service',
                subtitle: 'View terms and conditions',
                onTap: () {},
              ),
              const Divider(height: 1),
              _buildActionTile(
                icon: Icons.privacy_tip,
                title: 'Privacy Policy',
                subtitle: 'View privacy policy',
                onTap: () {},
              ),
              const Divider(height: 1),
              _buildActionTile(
                icon: Icons.help,
                title: 'Help & Support',
                subtitle: 'Get help with the application',
                onTap: () {},
              ),
              const Divider(height: 1),
              _buildActionTile(
                icon: Icons.feedback,
                title: 'Send Feedback',
                subtitle: 'Report bugs or suggest features',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ColorStyle.topazyw3,
                ColorStyle.topazyw3.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingCard({
    required String title,
    required List<Widget> children,
    bool isDanger = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDanger
            ? Border.all(color: Colors.red[200]!)
            : Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: isDanger
                  ? Colors.red[50]
                  : ColorStyle.topazyw3.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isDanger ? Icons.warning : Icons.settings,
                  color: isDanger ? Colors.red[600] : ColorStyle.topazyw3,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDanger ? Colors.red[700] : ColorStyle.topazyw3,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ColorStyle.topazyw3.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: ColorStyle.topazyw3, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: ColorStyle.topazyw3,
            activeTrackColor: ColorStyle.topazyw3.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile({                                                                                                               
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ColorStyle.topazyw3.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: ColorStyle.topazyw3, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                icon: Icon(Icons.expand_more, color: Colors.grey[600]),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                ),
                items: items.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (newValue) {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDanger
                      ? Colors.red[50]
                      : ColorStyle.topazyw3.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isDanger ? Colors.red[600] : ColorStyle.topazyw3,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDanger ? Colors.red[700] : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDanger ? Colors.red[400] : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ColorStyle.topazyw3.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: ColorStyle.topazyw3, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // ignore: use_null_aware_elements
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildStatusTile({
    required IconData icon,
    required String title,
    required String status,
    required Color statusColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: statusColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, color: statusColor, size: 14),
                const SizedBox(width: 4),
                Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupItem({
    required String date,
    required String size,
    required String status,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.backup, color: Colors.green[600], size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Size: $size',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green[600], size: 14),
                const SizedBox(width: 4),
                Text(
                  status,
                  style: TextStyle(
                    color: Colors.green[600],
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.restore, color: ColorStyle.topazyw3),
            onPressed: () {},
            tooltip: 'Restore',
          ),
        ],
      ),
    );
  }
}
