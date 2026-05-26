import 'package:flutter/material.dart';
import 'package:prototype_project/adminpages/add_household_page.dart';
import 'package:prototype_project/utils/kulor_style.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HouseholdPage extends StatefulWidget {
  const HouseholdPage({super.key});

  @override
  State<HouseholdPage> createState() => _HouseholdPageState();
}

class _HouseholdPageState extends State<HouseholdPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> households = [];
  List<Map<String, dynamic>> filteredHouseholds = [];
  bool isLoading = true;
  String searchQuery = '';
  Map<String, int> purokCounts = {};
  int totalHouseholds = 0;

  @override
  void initState() {
    super.initState();
    fetchHouseholds();
  }

  Future<void> fetchHouseholds() async {
    setState(() => isLoading = true);
    try {
      final response = await supabase
          .from('households')
          .select('''
            *,
            household_members (
              id,
              first_name,
              last_name,
              middle_name,
              relationship_to_head,
              contact_number,
              gender,
              is_head
            )
          ''')
          .order('created_at', ascending: false);

      final data = List<Map<String, dynamic>>.from(response);
      
      final processedHouseholds = data.map((household) {
        final members = List<Map<String, dynamic>>.from(household['household_members'] ?? []);
        final head = members.firstWhere(
          (m) => m['is_head'] == true,
          orElse: () => members.isNotEmpty ? members.first : {},
        );
        
        return {
          ...household,
          'members': members,
          'member_count': members.length,
          'head_name': head.isNotEmpty 
              ? '${head['first_name']} ${head['last_name']}'
              : 'No Members Yet',
          'head_phone': head['contact_number'],
          'head_id': head['id'],
        };
      }).toList();

      final purokMap = <String, int>{};
      for (var h in processedHouseholds) {
        final purok = h['purok']?.toString() ?? 'Unknown';
        purokMap[purok] = (purokMap[purok] ?? 0) + 1;
      }

      setState(() {
        households = processedHouseholds;
        filteredHouseholds = processedHouseholds;
        purokCounts = purokMap;
        totalHouseholds = processedHouseholds.length;
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

  void filterHouseholds(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredHouseholds = households;
      } else {
        filteredHouseholds = households.where((h) {
          final houseNum = (h['house_number'] ?? '').toLowerCase();
          final purok = (h['purok'] ?? '').toLowerCase();
          final street = (h['street'] ?? '').toLowerCase();
          final headName = (h['head_name'] ?? '').toLowerCase();
          return houseNum.contains(query.toLowerCase()) ||
                 purok.contains(query.toLowerCase()) ||
                 street.contains(query.toLowerCase()) ||
                 headName.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void showHouseholdDetails(Map<String, dynamic> household) {
    final members = List<Map<String, dynamic>>.from(household['members'] ?? []);
    final head = members.firstWhere(
      (m) => m['is_head'] == true,
      orElse: () => {},
    );
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700, maxHeight: 800),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [ColorStyle.topazyw2, ColorStyle.topazyw3],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.home, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            household['house_number'] ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${household['member_count']} Members',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
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
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Purok', 'Purok ${household['purok'] ?? 'N/A'}'),
                      _buildDetailRow('Street', household['street'] ?? 'N/A'),
                      _buildDetailRow('Barangay', household['barangay'] ?? 'Ulbujan'),
                      _buildDetailRow('Municipality', household['municipality'] ?? 'Calape'),
                      _buildDetailRow('Province', household['province'] ?? 'Bohol'),
                      const Divider(height: 32),
                      
                      if (head.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber.shade700),
                            const SizedBox(width: 8),
                            const Text(
                              'HEAD OF HOUSEHOLD',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: ColorStyle.topazyw3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${head['first_name']} ${head['last_name']}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.phone, size: 16, color: Colors.green),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Contact: ${head['contact_number'] ?? 'N/A'}',
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 32),
                      ],
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'All Members',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ColorStyle.topazyw3,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: ColorStyle.topazyw3.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${members.length} total',
                              style: const TextStyle(
                                color: ColorStyle.topazyw3,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      if (members.isEmpty)
                        const Center(child: Text('No members'))
                      else
                        ...members.map((member) => _buildMemberTileWithContact(member)),
                    ],
                  ),
                ),
              ),
              
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showAddMemberDialog(household['id'], household);
                        },
                        icon: const Icon(Icons.person_add),
                        label: const Text('Add Member'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorStyle.topazyw3,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showFullEditHouseholdDialog(household);
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit All'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: ColorStyle.topazyw3,
                          side: const BorderSide(color: ColorStyle.topazyw3),
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

  Widget _buildMemberTileWithContact(Map<String, dynamic> member) {
    final isHead = member['is_head'] == true;
    final name = '${member['first_name']} ${member['last_name']}';
    final relation = member['relationship_to_head'] ?? 'Member';
    final phone = member['contact_number'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHead ? Colors.amber.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHead ? Colors.amber.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isHead ? Colors.amber : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isHead ? Icons.star : Icons.person,
              color: isHead ? Colors.white : Colors.grey.shade700,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (isHead) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'HEAD',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  relation,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                if (phone != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.phone, size: 12, color: Colors.green.shade700),
                      const SizedBox(width: 4),
                      Text(
                        phone,
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (phone != null)
            IconButton(
              icon: const Icon(Icons.call, color: Colors.green),
              onPressed: () {},
              tooltip: 'Call $phone',
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
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
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullEditHouseholdDialog(Map<String, dynamic> household) {
    // Location controllers
    final purokController = TextEditingController(text: household['purok'] ?? '');
    final streetController = TextEditingController(text: household['street'] ?? '');
    
    // Get head data
    final members = List<Map<String, dynamic>>.from(household['members'] ?? []);
    final head = members.firstWhere(
      (m) => m['is_head'] == true,
      orElse: () => {},
    );
    
    // Head controllers
    final headFirstNameController = TextEditingController(text: head['first_name'] ?? '');
    final headLastNameController = TextEditingController(text: head['last_name'] ?? '');
    final headMiddleNameController = TextEditingController(text: head['middle_name'] ?? '');
    final headPhoneController = TextEditingController(text: head['contact_number'] ?? '');
    
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [ColorStyle.topazyw2, ColorStyle.topazyw3],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Edit Household',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                household['house_number'] ?? 'N/A',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: isSaving ? null : () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  
                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── LOCATION SECTION ──
                          _buildEditSectionTitle(Icons.location_on, 'Location'),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: purokController,
                                  decoration: _editInputDecoration('Purok *'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: streetController,
                                  decoration: _editInputDecoration('Street'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _buildReadOnlyEditField('Barangay', 'Ulbujan')),
                              const SizedBox(width: 8),
                              Expanded(child: _buildReadOnlyEditField('Municipality', 'Calape')),
                              const SizedBox(width: 8),
                              Expanded(child: _buildReadOnlyEditField('Province', 'Bohol')),
                            ],
                          ),
                          
                          const Divider(height: 40),
                          
                          // ── HEAD OF HOUSEHOLD SECTION ──
                          _buildEditSectionTitle(Icons.star, 'Head of Household'),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: headFirstNameController,
                                  decoration: _editInputDecoration('First Name *'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: headLastNameController,
                                  decoration: _editInputDecoration('Last Name *'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: headMiddleNameController,
                            decoration: _editInputDecoration('Middle Name'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: headPhoneController,
                            decoration: _editInputDecoration('Contact Number', prefixIcon: Icons.phone),
                            keyboardType: TextInputType.phone,
                          ),
                          
                          const Divider(height: 40),
                          
                          // ── MEMBERS SECTION ──
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildEditSectionTitle(Icons.people, 'Members'),
                              Text(
                                '${members.length} total',
                                style: TextStyle(
                                  color: ColorStyle.topazyw3,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          if (members.isEmpty)
                            const Center(child: Text('No members'))
                          else
                            ...members.map((member) => _buildEditableMemberTile(
                              member: member,
                              householdId: household['id'],
                              onUpdated: () {
                                Navigator.pop(context);
                                fetchHouseholds();
                              },
                              onDeleted: () {
                                Navigator.pop(context);
                                fetchHouseholds();
                              },
                            )),
                        ],
                      ),
                    ),
                  ),
                  
                  // Footer Buttons
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isSaving ? null : () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                            label: const Text('Cancel'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade300,
                              foregroundColor: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: isSaving
                                ? null
                                : () async {
                                    if (purokController.text.trim().isEmpty ||
                                        headFirstNameController.text.trim().isEmpty ||
                                        headLastNameController.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Purok, Head First Name, and Last Name are required'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                      return;
                                    }

                                    setDialogState(() => isSaving = true);

                                    try {
                                      // 1. Update household location
                                      await supabase.from('households').update({
                                        'purok': purokController.text.trim(),
                                        'street': streetController.text.trim().isEmpty ? null : streetController.text.trim(),
                                      }).eq('id', household['id']);

                                      // 2. Update head member
                                      if (head.isNotEmpty && head['id'] != null) {
                                        await supabase.from('household_members').update({
                                          'first_name': headFirstNameController.text.trim(),
                                          'last_name': headLastNameController.text.trim(),
                                          'middle_name': headMiddleNameController.text.trim().isEmpty
                                              ? null
                                              : headMiddleNameController.text.trim(),
                                          'contact_number': headPhoneController.text.trim().isEmpty
                                              ? null
                                              : headPhoneController.text.trim(),
                                        }).eq('id', head['id']);
                                      }

                                      if (mounted) {
                                        // ignore: use_build_context_synchronously
                                        Navigator.pop(context);
                                        fetchHouseholds();
                                        // ignore: use_build_context_synchronously
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('✅ Household updated successfully!'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      setDialogState(() => isSaving = false);
                                      if (mounted) {
                                        // ignore: use_build_context_synchronously
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                                        );
                                      }
                                    }
                                  },
                            icon: isSaving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Icon(Icons.save),
                            label: Text(isSaving ? 'Saving...' : 'Save Changes'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorStyle.topazyw3,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 🆕 EDITABLE MEMBER TILE — with Edit & Delete buttons
  Widget _buildEditableMemberTile({
    required Map<String, dynamic> member,
    required String householdId,
    required VoidCallback onUpdated,
    required VoidCallback onDeleted,
  }) {
    final isHead = member['is_head'] == true;
    final name = '${member['first_name']} ${member['last_name']}';
    final relation = member['relationship_to_head'] ?? 'Member';
    final phone = member['contact_number'];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isHead ? Colors.amber.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHead ? Colors.amber.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isHead ? Colors.amber : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isHead ? Icons.star : Icons.person,
              color: isHead ? Colors.white : Colors.grey.shade700,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  '$relation${phone != null ? ' • $phone' : ''}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
          if (!isHead) ...[
            // Edit button for non-head members
            IconButton(
              icon: const Icon(Icons.edit, color: ColorStyle.topazyw3, size: 20),
              onPressed: () {
                Navigator.pop(context);
                _showEditMemberDialog(member: member, onUpdated: onUpdated);
              },
              tooltip: 'Edit Member',
            ),
            // Delete button for non-head members
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () => _confirmDeleteMember(member, onDeleted),
              tooltip: 'Delete Member',
            ),
          ] else ...[
            // Head can only be edited through the main form above
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'HEAD',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 🆕 EDIT MEMBER DIALOG
  void _showEditMemberDialog({
    required Map<String, dynamic> member,
    required VoidCallback onUpdated,
  }) {
    final firstNameController = TextEditingController(text: member['first_name'] ?? '');
    final lastNameController = TextEditingController(text: member['last_name'] ?? '');
    final middleNameController = TextEditingController(text: member['middle_name'] ?? '');
    final contactController = TextEditingController(text: member['contact_number'] ?? '');
    final otherRelationController = TextEditingController();
    
    String? selectedRelationship = member['relationship_to_head'];
    bool isOther = selectedRelationship == 'Other';
    bool isSaving = false;

    final List<String> relationships = ['Wife', 'Husband', 'Son', 'Daughter', 'Baby', 'Parent', 'Renter', 'Other'];

    // If current relationship is not in standard list, set to Other
    if (!relationships.contains(selectedRelationship)) {
      selectedRelationship = 'Other';
      isOther = true;
      otherRelationController.text = member['relationship_to_head'] ?? '';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.edit, color: ColorStyle.topazyw3),
                const SizedBox(width: 12),
                const Text('Edit Member'),
              ],
            ),
            content: SizedBox(
              width: 450,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: firstNameController,
                            decoration: const InputDecoration(
                              labelText: 'First Name *',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: lastNameController,
                            decoration: const InputDecoration(
                              labelText: 'Last Name *',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: middleNameController,
                      decoration: const InputDecoration(
                        labelText: 'Middle Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedRelationship,
                      decoration: const InputDecoration(
                        labelText: 'Relationship *',
                        border: OutlineInputBorder(),
                      ),
                      items: relationships.map((r) => 
                        DropdownMenuItem(value: r, child: Text(r))
                      ).toList(),
                      onChanged: (v) {
                        setDialogState(() {
                          selectedRelationship = v;
                          isOther = v == 'Other';
                        });
                      },
                    ),
                    if (isOther) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: otherRelationController,
                        decoration: const InputDecoration(
                          labelText: 'Specify Relationship *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: contactController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Number',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                onPressed: isSaving
                    ? null
                    : () async {
                        if (firstNameController.text.trim().isEmpty ||
                            lastNameController.text.trim().isEmpty ||
                            selectedRelationship == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('First Name, Last Name, and Relationship are required'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        setDialogState(() => isSaving = true);

                        try {
                          final relationship = isOther
                              ? otherRelationController.text.trim()
                              : selectedRelationship!;

                          await supabase.from('household_members').update({
                            'first_name': firstNameController.text.trim(),
                            'last_name': lastNameController.text.trim(),
                            'middle_name': middleNameController.text.trim().isEmpty
                                ? null
                                : middleNameController.text.trim(),
                            'relationship_to_head': relationship,
                            'contact_number': contactController.text.trim().isEmpty
                                ? null
                                : contactController.text.trim(),
                          }).eq('id', member['id']);

                          if (mounted) {
                            // ignore: use_build_context_synchronously
                            Navigator.pop(context);
                            onUpdated();
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✅ Member updated!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          setDialogState(() => isSaving = false);
                          if (mounted) {
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                icon: isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(isSaving ? 'Saving...' : 'Save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorStyle.topazyw3,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // 🆕 CONFIRM DELETE MEMBER
  void _confirmDeleteMember(Map<String, dynamic> member, VoidCallback onDeleted) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Member?'),
        content: Text(
          'Are you sure you want to remove ${member['first_name']} ${member['last_name']} from this household?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              try {
                await supabase
                    .from('household_members')
                    .delete()
                    .eq('id', member['id']);

                if (mounted) {
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                  onDeleted();
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🗑️ Member removed'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            icon: const Icon(Icons.delete),
            label: const Text('Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Helper widgets for edit dialog
  Widget _buildEditSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: ColorStyle.topazyw3, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: ColorStyle.topazyw3,
          ),
        ),
      ],
    );
  }

  InputDecoration _editInputDecoration(String label, {IconData? prefixIcon}) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: Colors.grey.shade50,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: ColorStyle.topazyw3, size: 20) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  Widget _buildReadOnlyEditField(String label, String value) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  // Add Member Dialog (existing, unchanged)
  void _showAddMemberDialog(String householdId, Map<String, dynamic> householdData) {
    final formKey = GlobalKey<FormState>();
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final middleNameController = TextEditingController();
    final contactController = TextEditingController();
    final otherRelationController = TextEditingController();
    
    String? selectedRelationship;
    String? selectedGender;
    bool isLoading = false;
    bool isOther = false;

    final List<String> relationships = ['Head', 'Wife', 'Husband', 'Son', 'Daughter', 'Baby', 'Parent', 'Renter', 'Other'];
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.person_add, color: ColorStyle.topazyw3),
                const SizedBox(width: 12),
                const Text('Add Household Member'),
              ],
            ),
            content: SizedBox(
              width: 500,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: firstNameController,
                              decoration: const InputDecoration(
                                labelText: 'First Name *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => v?.isEmpty == true ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: lastNameController,
                              decoration: const InputDecoration(
                                labelText: 'Last Name *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => v?.isEmpty == true ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: middleNameController,
                        decoration: const InputDecoration(
                          labelText: 'Middle Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      DropdownButtonFormField<String>(
                        initialValue: selectedRelationship,
                        decoration: const InputDecoration(
                          labelText: 'Relationship to Head *',
                          border: OutlineInputBorder(),
                        ),
                        items: relationships.map((r) => 
                          DropdownMenuItem(value: r, child: Text(r))
                        ).toList(),
                        onChanged: (v) {
                          setDialogState(() {
                            selectedRelationship = v;
                            isOther = v == 'Other';
                          });
                        },
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                      
                      if (isOther) ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: otherRelationController,
                          decoration: const InputDecoration(
                            labelText: 'Specify Relationship *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v?.isEmpty == true ? 'Required' : null,
                        ),
                      ],
                      
                      const SizedBox(height: 12),
                      
                      DropdownButtonFormField<String>(
                        initialValue: selectedGender,
                        decoration: const InputDecoration(
                          labelText: 'Gender',
                          border: OutlineInputBorder(),
                        ),
                        items: ['male', 'female'].map((g) => 
                          DropdownMenuItem(value: g, child: Text(g.toUpperCase()))
                        ).toList(),
                        onChanged: (v) => selectedGender = v,
                      ),
                      const SizedBox(height: 12),
                      
                      TextFormField(
                        controller: contactController,
                        decoration: const InputDecoration(
                          labelText: 'Contact Number (Optional)',
                          hintText: 'For members with own phone',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                onPressed: isLoading ? null : () async {
                  if (!formKey.currentState!.validate()) return;
                  
                  setDialogState(() => isLoading = true);
                  
                  try {
                    final relationship = isOther 
                        ? otherRelationController.text.trim()
                        : selectedRelationship!;
                        
                    await supabase.from('household_members').insert({
                      'household_id': householdId,
                      'first_name': firstNameController.text.trim(),
                      'last_name': lastNameController.text.trim(),
                      'middle_name': middleNameController.text.trim().isEmpty 
                          ? null 
                          : middleNameController.text.trim(),
                      'relationship_to_head': relationship,
                      'contact_number': contactController.text.trim().isEmpty 
                          ? null 
                          : contactController.text.trim(),
                      'gender': selectedGender,
                      'is_head': false,
                    });
                    
                    if (mounted) {
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                      fetchHouseholds();
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Member added successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    setDialogState(() => isLoading = false);
                    if (mounted) {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorStyle.topazyw3,
                  foregroundColor: Colors.white,
                ),
                icon: isLoading 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.save),
                label: Text(isLoading ? 'Saving...' : 'Add Member'),
              ),
            ],
          );
        },
      ),
    );
  }

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
          _buildPurokStats(),
          _buildSearchBar(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredHouseholds.isEmpty
                    ? _buildEmptyState()
                    : _buildHouseholdsTable(),
          ),
        ],
      ),
    );
  }

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
                    'Household Management',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage Barangay Ulbujan Households',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddHouseholdPage(),
                    ),
                  );
                  fetchHouseholds();
                },
                icon: const Icon(Icons.add_home),
                label: const Text('Add Household'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: ColorStyle.topazyw3,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.home, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$totalHouseholds',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Total Registered Households',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.people, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                           '${households.fold<int>(0, (sum, h) => sum + ((h['member_count'] as int?) ?? 0))}',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Total Residents (All Households)',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPurokStats() {
    if (purokCounts.isEmpty) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_city, color: ColorStyle.topazyw3, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Households per Purok',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ColorStyle.topazyw3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: purokCounts.entries.map((entry) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: ColorStyle.topazyw3.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.home, size: 16, color: ColorStyle.topazyw3),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Purok ${entry.key}',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: ColorStyle.topazyw3,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${entry.value}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
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

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: filterHouseholds,
              decoration: InputDecoration(
                hintText: 'Search house number, purok, or head name...',
                prefixIcon: const Icon(Icons.search, color: ColorStyle.topazyw3),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.95),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${filteredHouseholds.length}',
              style: const TextStyle(
                color: ColorStyle.topazyw3,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHouseholdsTable() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            decoration: BoxDecoration(
              color: ColorStyle.topazyw3.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text('HOUSE NO.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                ),
                const Expanded(
                  flex: 1,
                  child: Text('PUROK', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                ),
                const Expanded(
                  flex: 2,
                  child: Text('HEAD OF HOUSEHOLD', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                ),
                const Expanded(
                  flex: 1,
                  child: Text('MEMBERS', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                ),
                const Expanded(
                  flex: 1,
                  child: Text('ACTION', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: filteredHouseholds.length,
              separatorBuilder: (_, _) => Divider(color: Colors.grey.shade200, height: 1),
              itemBuilder: (context, index) {
                final h = filteredHouseholds[index];
                return _buildTableRow(h);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(Map<String, dynamic> h) {
    final memberCount = h['member_count'] as int;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorStyle.topazyw3.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.home, color: ColorStyle.topazyw3, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  h['house_number'] ?? 'N/A',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ColorStyle.topazyw3.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Purok ${h['purok'] ?? 'N/A'}',
                style: const TextStyle(
                  color: ColorStyle.topazyw3,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                if (h['head_name']?.toString().startsWith('No') == true) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 14, color: Colors.red.shade700),
                        const SizedBox(width: 4),
                        Text(
                          'NO HEAD',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Text(
                    h['head_name'] ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: memberCount > 0 ? ColorStyle.topazyw3 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$memberCount',
                  style: TextStyle(
                    color: memberCount > 0 ? Colors.white : Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: IconButton(
                onPressed: () => showHouseholdDetails(h),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorStyle.topazyw3.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.visibility, color: ColorStyle.topazyw3, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_outlined, size: 80, color: ColorStyle.topazyw3.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text('No households found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Start by adding a new household'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddHouseholdPage()),
              );
              fetchHouseholds();
            },
            icon: const Icon(Icons.add_home),
            label: const Text('Add Household'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorStyle.topazyw3,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}