import 'package:flutter/material.dart';
import 'package:prototype_project/utils/kulor_style.dart';

class BarangayProfilePage extends StatefulWidget {
  final VoidCallback? onBack;

  const BarangayProfilePage({super.key, this.onBack});

  @override
  State<BarangayProfilePage> createState() => _BarangayProfilePageState();
}

class _BarangayProfilePageState extends State<BarangayProfilePage> {
  // Mock data for barangay - in a real app, this would come from a database/API
  final Map<String, dynamic> barangayData = {
    'name': 'Barangay Ulbujan',
    'municipality': 'Calape',
    'province': 'Bohol',
    'contactNumber': '0912-345-6789',
    'email': 'ulbujan.barangay@email.com',
    'totalPurok': 7,
    'totalResident': 1250,
    'description': 'Barangay Ulbujan is committed to providing efficient public services and maintaining peace, order, and development within the community. We strive to create a harmonious environment where every resident can thrive and enjoy quality living.',
  };

  final List<Map<String, String>> officials = [
    {'name': 'Hon. Juan P. Dela Cruz', 'position': 'Barangay Captain', 'image': 'man'},
    {'name': 'Hon. Maria L. Santos', 'position': 'Kagawad (Peace & Order)', 'image': 'woman'},
    {'name': 'Hon. Pedro R. Martinez', 'position': 'Kagawad (Infrastructure)', 'image': 'man'},
    {'name': 'Hon. Ana M. Reyes', 'position': 'Kagawad (Education)', 'image': 'woman'},
    {'name': 'Hon. Jose C. Torres', 'position': 'Kagawad (Health)', 'image': 'man'},
    {'name': 'Hon. Susan D. Lopez', 'position': 'Kagawad (Sports)', 'image': 'woman'},
    {'name': 'Hon. Roberto F. Garcia', 'position': 'Kagawad (Agriculture)', 'image': 'man'},
    {'name': 'Maria Clara S. Cruz', 'position': 'Barangay Secretary', 'image': 'woman'},
    {'name': 'Carlos J. Mendoza', 'position': 'Barangay Treasurer', 'image': 'man'},
    {'name': 'Pedro P. Dimaguila', 'position': 'SK Chairman', 'image': 'man'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorStyle.topazyw1,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [ColorStyle.topazyw1, ColorStyle.ivory],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // Hero Header with Logo and Name
            SliverAppBar(
              expandedHeight: 280,
              floating: false,
              pinned: true,
              backgroundColor: ColorStyle.topazyw2,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  if (widget.onBack != null) {
                    widget.onBack!();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [ColorStyle.topazyw2, ColorStyle.topazyw3],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        // Logo Section - Side by side without border, same size
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Municipal Logo (Left side)
                            Container(
                              width: 100,
                              height: 100,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'asset/logocalape.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                      ),
                                      child: const Icon(
                                        Icons.location_city,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 30),
                            // Barangay Seal/Logo (Right side)
                            Container(
                              width: 120,
                              height: 120,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'asset/logoulbujan.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                      ),
                                      child: const Icon(
                                        Icons.location_city,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Barangay Name
                        Text(
                          barangayData['name'],
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Municipality of ${barangayData['municipality']}, Province of ${barangayData['province']}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Content Sections
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Stats Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Purok',
                            '${barangayData['totalPurok']}',
                            Icons.location_on,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Total Resident',
                            '${barangayData['totalResident']}',
                            Icons.people,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Contact Information Card
                    _buildSectionCard(
                      'Contact Information',
                      Icons.contact_phone,
                      [
                        _buildContactRow(Icons.phone, 'Phone Number', barangayData['contactNumber']),
                        const SizedBox(height: 12),
                        _buildContactRow(Icons.email, 'Email', barangayData['email']),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Office Hours Card
                    _buildSectionCard(
                      'Office Hours',
                      Icons.access_time,
                      [
                        _buildOfficeHoursRow('Monday - Friday', '8:00 AM - 5:00 PM'),
                        const SizedBox(height: 8),
                        _buildOfficeHoursRow('Saturday', '9:00 AM - 12:00 PM (Half Day)'),
                        const SizedBox(height: 8),
                        _buildOfficeHoursRow('Sunday', 'Closed', isClosed: true),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Description Card
                    _buildSectionCard(
                      'About Us',
                      Icons.info_outline,
                      [
                        Text(
                          barangayData['description'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: ColorStyle.reddart,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Barangay Officials Section
                    const Text(
                      'Barangay Officials',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ColorStyle.reddart,
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    // Officials Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: officials.length,
                      itemBuilder: (context, index) => _buildOfficialCard(officials[index]),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
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
                  gradient: LinearGradient(
                    colors: [ColorStyle.topazyw1, ColorStyle.topazyw2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorStyle.reddart,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(height: 1),
          const SizedBox(height: 15),
          ...children,
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: ColorStyle.topazyw1.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: ColorStyle.topazyw3, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: ColorStyle.reddart,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOfficeHoursRow(String day, String time, {bool isClosed = false}) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            day,
            style: TextStyle(
              fontSize: 13,
              color: isClosed ? Colors.red : ColorStyle.reddart,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            time,
            style: TextStyle(
              fontSize: 13,
              color: isClosed ? Colors.red.shade300 : Colors.grey.shade700,
              fontWeight: isClosed ? FontWeight.w400 : FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildOfficialCard(Map<String, String> official) {
    final isMan = official['image'] == 'man';
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isMan 
                    ? [Colors.blue.shade400, Colors.blue.shade600]
                    : [Colors.pink.shade300, Colors.pink.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: (isMan ? Colors.blue : Colors.pink).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'asset/${official['image']}.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    isMan ? Icons.person : Icons.person_outline,
                    color: Colors.white,
                    size: 30,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            official['name']!,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: ColorStyle.reddart,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: ColorStyle.topazyw1.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              official['position']!,
              style: const TextStyle(
                fontSize: 9,
                color: ColorStyle.topazyw3,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
