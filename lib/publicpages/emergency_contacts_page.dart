import 'package:flutter/material.dart';
import 'package:prototype_project/utils/kulor_style.dart';

class EmergencyContactsPage extends StatefulWidget {
  final VoidCallback? onBack;

  const EmergencyContactsPage({super.key, this.onBack});

  @override
  State<EmergencyContactsPage> createState() => _EmergencyContactsPageState();
}

class _EmergencyContactsPageState extends State<EmergencyContactsPage> {
  final List<Map<String, dynamic>> emergencyContacts = [
    {
      'name': 'Police Station',
      'description': 'Local police emergency number',
      'phone': '911',
      'icon': Icons.local_police,
      'color': Colors.blue.shade700,
    },
    {
      'name': 'Fire Station / BFP',
      'description': 'Fire emergency hotline',
      'phone': '911',
      'icon': Icons.local_fire_department,
      'color': Colors.red.shade600,
    },
    {
      'name': 'Barangay Office',
      'description': 'Barangay Ulbujan Office',
      'phone': '0912-345-6789',
      'icon': Icons.location_city,
      'color': ColorStyle.topazyw3,
    },
    {
      'name': 'Ambulance / Health Center',
      'description': 'Medical emergency number',
      'phone': '911',
      'icon': Icons.medical_services,
      'color': Colors.green.shade600,
    },
    {
      'name': 'Disaster Response Team',
      'description': 'DRRM Office Calape',
      'phone': '0912-345-6780',
      'icon': Icons.warning_amber,
      'color': Colors.orange.shade600,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorStyle.topazyw1,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ColorStyle.topazyw3),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: const Text(
          'Emergency Contacts',
          style: TextStyle(
            color: ColorStyle.topazyw3,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [ColorStyle.topazyw1, ColorStyle.ivory],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade600, Colors.red.shade800],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.emergency,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Emergency Hotline',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'In case of emergency, dial the appropriate hotline number',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              
              // Emergency Contacts List
              const Text(
                'Available Emergency Contacts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorStyle.reddart,
                ),
              ),
              const SizedBox(height: 15),
              
              ...emergencyContacts.map((contact) => _buildContactCard(contact)),
              
              const SizedBox(height: 20),
              
              // Note
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber.shade700, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Please note that some numbers may require area code prefix. For best results, save these contacts to your phone.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard(Map<String, dynamic> contact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: (contact['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              contact['icon'] as IconData,
              color: contact['color'] as Color,
              size: 28,
            ),
          ),
          const SizedBox(width: 15),
          // Contact Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact['name'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColorStyle.reddart,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  contact['description'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // Phone Number
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [(contact['color'] as Color), (contact['color'] as Color).withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.phone, color: Colors.white, size: 18),
                const SizedBox(width: 5),
                Text(
                  contact['phone'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
