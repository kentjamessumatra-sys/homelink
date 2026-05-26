import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prototype_project/utils/kulor_style.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegistrationApprovalsPage extends StatefulWidget {
  const RegistrationApprovalsPage({super.key});

  @override
  State<RegistrationApprovalsPage> createState() => _RegistrationApprovalsPageState();
}

class _RegistrationApprovalsPageState extends State<RegistrationApprovalsPage> {
  final supabase = Supabase.instance.client;
  
  // Tab management
  int _selectedTab = 0; // 0 = Pending, 1 = Approved Today, 2 = Rejected Today
  
  // Data lists
  List<Map<String, dynamic>> pendingResidents = [];
  List<Map<String, dynamic>> approvedTodayList = [];
  List<Map<String, dynamic>> rejectedTodayList = [];
  List<Map<String, dynamic>> filteredResidents = [];
  
  bool isLoading = true;
  String searchQuery = '';
  int totalPending = 0;
  int approvedToday = 0;
  int rejectedToday = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day).toIso8601String();
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

      final pendingResponse = await supabase
          .from('resident_profiles')
          .select('''
            id,
            user_id,
            first_name,
            middle_name,
            last_name,
            suffix,
            gender,
            civil_status,
            birthdate,
            phone,
            phone_secondary,
            email,
            address_purok,
            address_street,
            address_barangay,
            address_municipality,
            address_province,
            valid_id_type,
            valid_id_number,
            valid_id_photo_url,
            occupation,
            employment_status,
            emergency_name,
            emergency_phone,
            emergency_relation,
            is_head_of_household,
            relationship_to_head,
            account_status,
            created_at,
            updated_at,
            admin_notes,
            users:user_id(email)
          ''')
          .eq('account_status', 'pending')
          .order('created_at', ascending: true);

      final approvedResponse = await supabase
          .from('resident_profiles')
          .select('''
            id,
            user_id,
            first_name,
            middle_name,
            last_name,
            suffix,
            gender,
            civil_status,
            birthdate,
            phone,
            phone_secondary,
            email,
            address_purok,
            address_street,
            address_barangay,
            address_municipality,
            address_province,
            valid_id_type,
            valid_id_number,
            valid_id_photo_url,
            occupation,
            employment_status,
            emergency_name,
            emergency_phone,
            emergency_relation,
            is_head_of_household,
            relationship_to_head,
            account_status,
            created_at,
            updated_at,
            admin_notes,
            users:user_id(email)
          ''')
          .eq('account_status', 'approved')
          .gte('updated_at', todayStart)
          .lte('updated_at', todayEnd)
          .lt('created_at', todayStart)
          .order('updated_at', ascending: false);

      final rejectedResponse = await supabase
          .from('resident_profiles')
          .select('''
            id,
            user_id,
            first_name,
            middle_name,
            last_name,
            suffix,
            gender,
            civil_status,
            birthdate,
            phone,
            phone_secondary,
            email,
            address_purok,
            address_street,
            address_barangay,
            address_municipality,
            address_province,
            valid_id_type,
            valid_id_number,
            valid_id_photo_url,
            occupation,
            employment_status,
            emergency_name,
            emergency_phone,
            emergency_relation,
            is_head_of_household,
            relationship_to_head,
            account_status,
            created_at,
            updated_at,
            admin_notes,
            users:user_id(email)
          ''')
          .eq('account_status', 'rejected')
          .gte('updated_at', todayStart)
          .lte('updated_at', todayEnd)
          .order('updated_at', ascending: false);

      setState(() {
        pendingResidents = List<Map<String, dynamic>>.from(pendingResponse);
        approvedTodayList = List<Map<String, dynamic>>.from(approvedResponse);
        rejectedTodayList = List<Map<String, dynamic>>.from(rejectedResponse);
        
        _updateFilteredList();
        
        totalPending = pendingResidents.length;
        approvedToday = approvedTodayList.length;
        rejectedToday = rejectedTodayList.length;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _updateFilteredList() {
    List<Map<String, dynamic>> sourceList;
    switch (_selectedTab) {
      case 0:
        sourceList = pendingResidents;
        break;
      case 1:
        sourceList = approvedTodayList;
        break;
      case 2:
        sourceList = rejectedTodayList;
        break;
      default:
        sourceList = pendingResidents;
    }

    if (searchQuery.isEmpty) {
      filteredResidents = sourceList;
    } else {
      filteredResidents = sourceList.where((r) {
        final name = '${r['first_name']} ${r['last_name']}'.toLowerCase();
        final phone = (r['phone'] ?? '').toLowerCase();
        return name.contains(searchQuery.toLowerCase()) || phone.contains(searchQuery.toLowerCase());
      }).toList();
    }
  }

  void _onTabChanged(int tab) {
    setState(() {
      _selectedTab = tab;
      searchQuery = '';
      _updateFilteredList();
    });
  }

  void filterResidents(String query) {
    setState(() {
      searchQuery = query;
      _updateFilteredList();
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // APPROVE RESIDENT
  // ═══════════════════════════════════════════════════════════════
  Future<void> approveResident(String profileId) async {
    try {
      final now = DateTime.now().toIso8601String();
      
      await supabase.from('resident_profiles').update({
        'account_status': 'approved',
        'updated_at': now,
      }).eq('id', profileId);
      
      await fetchData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Resident approved!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // REJECT RESIDENT
  // ═══════════════════════════════════════════════════════════════
  Future<void> rejectResident(String profileId, String reason) async {
    try {
      final now = DateTime.now().toIso8601String();
      
      await supabase.from('resident_profiles').update({
        'account_status': 'rejected',
        'admin_notes': reason,
        'updated_at': now,
      }).eq('id', profileId);
      
      await fetchData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Resident rejected'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════
  
  // 🆕 Calculate age from birthdate string
  int? _calculateAge(String? birthdateStr) {
    if (birthdateStr == null || birthdateStr.isEmpty) return null;
    try {
      final birthdate = DateTime.parse(birthdateStr);
      final now = DateTime.now();
      int age = now.year - birthdate.year;
      if (now.month < birthdate.month || 
          (now.month == birthdate.month && now.day < birthdate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      debugPrint('Error calculating age: $e');
      return null;
    }
  }

  // 🆕 Format birthdate to readable string
  String _formatBirthdate(String? birthdateStr) {
    if (birthdateStr == null || birthdateStr.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(birthdateStr);
      return DateFormat('MMMM dd, yyyy').format(date); // e.g. "January 15, 1990"
    } catch (e) {
      return 'N/A';
    }
  }

  String _formatFullName(Map<String, dynamic> resident) {
    final first = resident['first_name'] ?? '';
    final last = resident['last_name'] ?? '';
    final middle = resident['middle_name'];
    
    if (middle != null && middle.toString().isNotEmpty) {
      final middleInitial = middle.toString().trim()[0].toUpperCase();
      return '$first $middleInitial. $last';
    }
    return '$first $last';
  }

  String _formatAddress(Map<String, dynamic> resident) {
    final purok = resident['address_purok'] ?? '';
    final barangay = resident['address_barangay'] ?? 'Ulbujan';
    final municipality = resident['address_municipality'] ?? 'Calape';
    final province = resident['address_province'] ?? 'Bohol';
    return 'Purok $purok, $barangay $municipality $province';
  }

  String _formatPhone(Map<String, dynamic> resident) {
    final primary = resident['phone'] ?? '';
    final secondary = resident['phone_secondary'];
    if (secondary != null && secondary.toString().isNotEmpty) {
      return '$primary / $secondary';
    }
    return primary;
  }

  Future<String?> _getSignedUrl(String? photoUrl) async {
    if (photoUrl == null || photoUrl.isEmpty) return null;
    try {
      final uri = Uri.parse(photoUrl);
      final pathSegments = uri.pathSegments;
      int bucketIndex = -1;
      for (int i = 0; i < pathSegments.length; i++) {
        if (pathSegments[i] == 'valid-ids') {
          bucketIndex = i;
          break;
        }
      }
      if (bucketIndex != -1 && bucketIndex + 1 < pathSegments.length) {
        final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
        return await supabase.storage.from('valid-ids').createSignedUrl(filePath, 3600);
      }
    } catch (e) {
      debugPrint('❌ Error generating signed URL: $e');
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════════
  // DIALOGS
  // ═══════════════════════════════════════════════════════════════
  Future<void> showDetailsDialog(Map<String, dynamic> resident) async {
    final fullName = _formatFullName(resident);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    String? signedPhotoUrl;
    if (resident['valid_id_photo_url'] != null && resident['valid_id_photo_url'].toString().isNotEmpty) {
      signedPhotoUrl = await _getSignedUrl(resident['valid_id_photo_url']);
    }
    
    if (mounted) Navigator.pop(context);
    if (!mounted) return;
    
    final bool isReadOnly = _selectedTab != 0;
    final String status = resident['account_status'] ?? 'pending';
    final Color statusColor = status == 'approved' ? Colors.green : (status == 'rejected' ? Colors.red : Colors.orange);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700, maxHeight: 800),
          decoration: BoxDecoration(
            color: ColorStyle.topazyw1,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with status badge
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [ColorStyle.topazyw2, ColorStyle.topazyw3],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Resident Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailItem('Full Name', fullName),
                      _buildDetailItem('Birthdate', _formatBirthdate(resident['birthdate'])), // 🆕 DAGDAG
                      _buildDetailItem('Age', '${_calculateAge(resident['birthdate']) ?? 'N/A'} years old'), // ✅ FIXED
                      _buildDetailItem('Gender', (resident['gender'] ?? 'N/A').toString().toUpperCase()),
                      _buildDetailItem('Civil Status', (resident['civil_status'] ?? 'N/A').toString().toUpperCase()),
                      _buildDetailItem('Phone', _formatPhone(resident)),
                      _buildDetailItem('Email', resident['users']?['email'] ?? resident['email'] ?? 'N/A'),
                      _buildDetailItem('Address', _formatAddress(resident)),
                      _buildDetailItem('Occupation', resident['occupation'] ?? 'N/A'),
                      _buildDetailItem('Employment Status', (resident['employment_status'] ?? 'N/A').toString().toUpperCase()),
                      _buildDetailItem('ID Type', resident['valid_id_type'] ?? 'N/A'),
                      _buildDetailItem('ID Number', resident['valid_id_number'] ?? 'N/A'),
                      _buildDetailItem('Emergency Contact', '${resident['emergency_name']} (${resident['emergency_relation']}) - ${resident['emergency_phone']}'),
                      
                      // Show admin notes if rejected
                      if (status == 'rejected' && resident['admin_notes'] != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.warning, color: Colors.red.shade700, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Rejection Reason',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                resident['admin_notes'],
                                style: TextStyle(color: Colors.red.shade900),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      // Show approval/rejection timestamp
                      if (status == 'approved') ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green.shade700, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Approved on: ${DateFormat('MMM dd, yyyy - hh:mm a').format(DateTime.parse(resident['updated_at']))}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      if (status == 'rejected') ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.schedule, color: Colors.orange.shade700, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Rejected on: ${DateFormat('MMM dd, yyyy - hh:mm a').format(DateTime.parse(resident['updated_at']))}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      if (signedPhotoUrl != null) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Valid ID Photo:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            signedPhotoUrl,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                height: 200,
                                color: Colors.grey.shade200,
                                child: const Center(child: CircularProgressIndicator()),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.error, color: Colors.red),
                                      SizedBox(height: 8),
                                      Text('Failed to load ID photo', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ] else if (resident['valid_id_photo_url'] != null && resident['valid_id_photo_url'].toString().isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Valid ID Photo:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 200,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.no_photography, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Unable to load ID photo (Access Denied)', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              // Actions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade300)),
                ),
                child: isReadOnly
                    ? Center(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          label: const Text('Close'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            foregroundColor: Colors.black87,
                            minimumSize: const Size(200, 48),
                          ),
                        ),
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _showRejectReasonDialog(resident['id'], fullName);
                              },
                              icon: const Icon(Icons.cancel, color: Colors.white),
                              label: const Text('REJECT'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                approveResident(resident['id']);
                              },
                              icon: const Icon(Icons.check_circle, color: Colors.white),
                              label: const Text('APPROVE'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRejectReasonDialog(String profileId, String name) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorStyle.topazyw1,
        title: Text('Reject $name'),
        content: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            maxLines: 5,
            minLines: 3,
            decoration: const InputDecoration(
              hintText: 'Enter reason for rejection...',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.all(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context);
                rejectResident(profileId, controller.text);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // BUILD METHOD
  // ═══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [ColorStyle.topazyw4, ColorStyle.topazyw1],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          _buildSearchBar(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredResidents.isEmpty
                    ? _buildEmptyState()
                    : _buildDataTable(),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HEADER with clickable stat cards
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ColorStyle.topazyw2, ColorStyle.topazyw3],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Registration Approvals',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Review and manage resident registrations',
                    style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8)),
                  ),
                ],
              ),
              IconButton(
                onPressed: fetchData,
                icon: const Icon(Icons.refresh, color: Colors.white),
                style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.2)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatCard('Pending', totalPending.toString(), Icons.pending, Colors.orange, 0),
              const SizedBox(width: 16),
              _buildStatCard('Approved Today', approvedToday.toString(), Icons.check_circle, Colors.green, 1),
              const SizedBox(width: 16),
              _buildStatCard('Rejected Today', rejectedToday.toString(), Icons.cancel, Colors.red, 2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, int tabIndex) {
    final bool isSelected = _selectedTab == tabIndex;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabChanged(tabIndex),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected 
                ? Colors.white.withValues(alpha: 0.3) 
                : Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? Colors.white.withValues(alpha: 0.6) 
                  : Colors.white.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8)]
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(title, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB BAR
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTabBar() {
    final List<String> tabLabels = ['Pending', 'Approved Today', 'Rejected Today'];
    final List<Color> tabColors = [Colors.orange, Colors.green, Colors.red];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: List.generate(3, (index) {
          final bool isSelected = _selectedTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => _onTabChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? tabColors[index].withValues(alpha: 0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? tabColors[index] : Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      index == 0 ? Icons.pending : (index == 1 ? Icons.check_circle : Icons.cancel),
                      color: isSelected ? tabColors[index] : Colors.grey.shade500,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tabLabels[index],
                      style: TextStyle(
                        color: isSelected ? tabColors[index] : Colors.grey.shade600,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: Colors.transparent,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: filterResidents,
              decoration: InputDecoration(
                hintText: _selectedTab == 0 
                    ? 'Search pending resident name or phone...'
                    : (_selectedTab == 1 
                        ? 'Search approved resident name or phone...'
                        : 'Search rejected resident name or phone...'),
                prefixIcon: Icon(Icons.search, color: ColorStyle.topazyw3),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('${filteredResidents.length} Results', style: TextStyle(color: ColorStyle.topazyw3, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: ColorStyle.topazyw3.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Expanded(flex: 2, child: Text('NAME', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54))),
                const Expanded(flex: 1, child: Text('PHONE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54))),
                const Expanded(flex: 1, child: Text('AGE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54))),
                const Expanded(flex: 2, child: Text('ADDRESS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54))),
                const Expanded(flex: 1, child: Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54), textAlign: TextAlign.center)),
              ],
            ),
          ),
          // Table Body
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: filteredResidents.length,
              separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200, height: 1),
              itemBuilder: (context, index) {
                final resident = filteredResidents[index];
                return _buildTableRow(resident);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(Map<String, dynamic> resident) {
    final fullName = _formatFullName(resident);
    final age = _calculateAge(resident['birthdate'])?.toString() ?? 'N/A'; // ✅ FIXED
    final address = _formatAddress(resident);
    final status = resident['account_status'] ?? 'pending';
    
    final bool isPending = _selectedTab == 0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: status == 'approved' 
                      ? Colors.green 
                      : (status == 'rejected' ? Colors.red : ColorStyle.topazyw3),
                  child: Text(
                    '${resident['first_name']?[0] ?? ''}${resident['last_name']?[0] ?? ''}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        isPending 
                            ? 'Submitted: ${DateFormat('MMM dd').format(DateTime.parse(resident['created_at']))}'
                            : (status == 'approved'
                                ? 'Approved: ${DateFormat('MMM dd, hh:mm a').format(DateTime.parse(resident['updated_at']))}'
                                : (status == 'rejected'
                                    ? 'Rejected: ${DateFormat('MMM dd, hh:mm a').format(DateTime.parse(resident['updated_at']))}'
                                    : '')),
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 1, child: Text(resident['phone'] ?? 'N/A')),
          Expanded(flex: 1, child: Text('$age yrs')),
          Expanded(flex: 2, child: Text(address)),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => showDetailsDialog(resident),
                  icon: Icon(Icons.visibility, color: ColorStyle.topazyw3),
                  tooltip: 'View Details',
                ),
                if (isPending) ...[
                  IconButton(
                    onPressed: () => approveResident(resident['id']),
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    tooltip: 'Approve',
                  ),
                  IconButton(
                    onPressed: () => _showRejectReasonDialog(resident['id'], fullName),
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    tooltip: 'Reject',
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final List<String> messages = [
      'No pending approvals',
      'No approved registrations today',
      'No rejected registrations today',
    ];
    final List<String> subMessages = [
      'All registrations have been processed',
      'No residents were approved today',
      'No residents were rejected today',
    ];
    final List<IconData> icons = [
      Icons.check_circle_outline,
      Icons.thumb_up_off_alt,
      Icons.block_outlined,
    ];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icons[_selectedTab], size: 100, color: ColorStyle.topazyw3.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(messages[_selectedTab], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(subMessages[_selectedTab], style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}