import 'package:flutter/material.dart';
import 'package:prototype_project/utils/kulor_style.dart';

class PublicSettingsPage extends StatefulWidget {
  const PublicSettingsPage({super.key});

  @override
  State<PublicSettingsPage> createState() => _PublicSettingsPageState();
}

class _PublicSettingsPageState extends State<PublicSettingsPage> {
  // Mock data para sa prototype
  final Map<String, dynamic> _barangayInfo = {
    'barangayName': 'Barangay Ulbujan',
    'municipality': 'Municipality of Calape',
    'province': 'Province of Bohol',
    'contactNumber': '(038) 123-4567',
    'email': 'barangay.ulbujan@calape.gov.ph',
    'officeHours': 'Monday - Friday, 8:00 AM - 5:00 PM',
  };

  final List<Map<String, String>> _developerCredits = [
    {
      'label': 'Developed by',
      'name': 'Kent James Sumatra',
      'role': 'Solo Developer',
    },
    {
      'label': 'Powered by',
      'name': 'Flutter + Supabase',
      'role': 'Technology Stack',
    },
  ];

  bool _darkModeEnabled = false;
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorStyle.topazyw4,
      // REMOVE: SingleChildScrollView → palitan natin ng CustomScrollView
      body: CustomScrollView(
        slivers: [
          // ===== STICKY HEADER: Hindi mawawala sa taas =====
          SliverAppBar(
            expandedHeight: 280, // Height kapag fully expanded
            pinned: true,        // ⭐ KEY: Mag-stay sa taas kapag nag-scroll
            floating: false,
            snap: false,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildOfficialHeader(),
            ),
          ),

          // ===== MAIN CONTENT =====
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // Barangay Information Section
                    _buildSectionTitle('Barangay Information'),
                    const SizedBox(height: 16),
                    _buildBarangayInfoCard(),

                    const SizedBox(height: 32),

                    // System Preferences Section
                    _buildSectionTitle('System Preferences'),
                    const SizedBox(height: 16),
                    _buildPreferencesCard(),

                    const SizedBox(height: 32),

                    // About & Credits Section
                    _buildSectionTitle('About HomeLink'),
                    const SizedBox(height: 16),
                    _buildAboutCard(),

                    const SizedBox(height: 32),

                    // Developer Credits
                    _buildSectionTitle('Credits'),
                    const SizedBox(height: 16),
                    _buildCreditsCard(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),

          // ===== FOOTER: Partner Logos =====
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildPartnerFooter(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  // ===== HEADER WIDGET =====
  Widget _buildOfficialHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorStyle.topazyw3,
            ColorStyle.topazyw2,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: ColorStyle.topazyw3.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Official Logos Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Barangay Logo
                _buildLogoContainer(
                  imagePath: 'asset/logoulbujan.png',
                  label: 'Barangay Ulbujan',
                  size: 80,
                ),
                const SizedBox(width: 24),
                // Municipality Logo
                _buildLogoContainer(
                  imagePath: 'asset/logocalape.png',
                  label: 'Municipality of Calape',
                  size: 80,
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Title
            const Text(
              'HomeLink',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Barangay Management System',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.8),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Barangay Ulbujan, Calape, Bohol',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoContainer({
    required String imagePath,
    required String label,
    required double size,
  }) {
    return Tooltip(
      message: label,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback kung wala pa ang image
              return Container(
                color: Colors.white.withValues(alpha: 0.1),
                child: Icon(
                  Icons.account_balance,
                  size: size * 0.5,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ===== SECTION TITLE =====
  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: ColorStyle.topazyw3,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ColorStyle.topazyw3,
          ),
        ),
      ],
    );
  }

  // ===== BARANGAY INFO CARD =====
  Widget _buildBarangayInfoCard() {
    final infoItems = [
      {'icon': Icons.location_city, 'label': 'Barangay', 'value': _barangayInfo['barangayName']},
      {'icon': Icons.map, 'label': 'Municipality', 'value': _barangayInfo['municipality']},
      {'icon': Icons.landscape, 'label': 'Province', 'value': _barangayInfo['province']},
      {'icon': Icons.phone, 'label': 'Contact', 'value': _barangayInfo['contactNumber']},
      {'icon': Icons.email, 'label': 'Email', 'value': _barangayInfo['email']},
      {'icon': Icons.access_time, 'label': 'Office Hours', 'value': _barangayInfo['officeHours']},
    ];

    return _buildCard(
      child: Column(
        children: infoItems.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorStyle.topazyw3.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: ColorStyle.topazyw3,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['label'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: ColorStyle.paleslate,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['value'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ===== PREFERENCES CARD =====
  Widget _buildPreferencesCard() {
    return _buildCard(
      child: Column(
        children: [
          // Dark Mode Toggle
          _buildToggleTile(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            subtitle: 'Switch to dark theme',
            value: _darkModeEnabled,
            onChanged: (value) {
              setState(() => _darkModeEnabled = value);
            },
          ),
          const Divider(height: 1),
          // Notifications Toggle
          _buildToggleTile(
            icon: Icons.notifications_active,
            title: 'Push Notifications',
            subtitle: 'Receive updates and alerts',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: ColorStyle.topazyw3.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: ColorStyle.topazyw3, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: ColorStyle.paleslate,
          ),
        ),
        trailing: Switch.adaptive(
          value: value,
          onChanged: onChanged,
          // ignore: deprecated_member_use
          activeColor: ColorStyle.topazyw3,
        ),
      ),
    );
  }

  // ===== ABOUT CARD =====
  Widget _buildAboutCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColorStyle.topazyw3.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.home_work,
                  color: ColorStyle.topazyw3,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'HomeLink v1.0.0',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'A digital barangay management solution\nfor efficient public service delivery.',
                      style: TextStyle(
                        fontSize: 13,
                        color: ColorStyle.slategrey,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          // Feature highlights
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFeatureChip('Resident Management'),
              _buildFeatureChip('Online Requests'),
              _buildFeatureChip('Reports & Tracking'),
              _buildFeatureChip('Announcements'),
              _buildFeatureChip('Digital Records'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ColorStyle.topazyw3.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ColorStyle.topazyw3.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: ColorStyle.topazyw3,
        ),
      ),
    );
  }

  // ===== CREDITS CARD =====
  Widget _buildCreditsCard() {
    return _buildCard(
      child: Column(
        children: _developerCredits.map((credit) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ColorStyle.topazyw3,
                        ColorStyle.topazyw2,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.code,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        credit['label']!,
                        style: TextStyle(
                          fontSize: 12,
                          color: ColorStyle.paleslate,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        credit['name']!,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        credit['role']!,
                        style: TextStyle(
                          fontSize: 12,
                          color: ColorStyle.slategrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ===== PARTNER FOOTER =====
  Widget _buildPartnerFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        children: [
          Text(
            'In partnership with',
            style: TextStyle(
              fontSize: 12,
              color: ColorStyle.paleslate,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Bagong Pilipinas Logo
              _buildPartnerLogo(
                imagePath: 'asset/bagoph.png',
                label: 'Bagong Pilipinas',
                height: 50,
              ),
              const SizedBox(width: 32),
              // BISU Logo
              _buildPartnerLogo(
                imagePath: 'asset/bisu.png',
                label: 'Bohol Island State University',
                height: 50,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '© 2026  Barangay Ulbujan. All rights reserved.',
            style: TextStyle(
              fontSize: 11,
              color: ColorStyle.paleslate,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerLogo({
    required String imagePath,
    required String label,
    required double height,
  }) {
    return Tooltip(
      message: label,
      child: Image.asset(
        imagePath,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            width: height * 1.5,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                label.split(' ').map((w) => w[0]).take(3).join(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ColorStyle.topazyw3,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ===== REUSABLE CARD WIDGET =====
  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: child,
    );
  }
}