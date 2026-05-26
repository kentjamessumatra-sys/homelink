import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:prototype_project/adminpages/add_resident_page.dart';
import 'package:prototype_project/adminpages/resident_design_page.dart'; 
import 'package:prototype_project/utils/kulor_style.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResidentManagementPage extends StatefulWidget {
  const ResidentManagementPage({super.key});

  @override
  State<ResidentManagementPage> createState() => _ResidentManagementPageState();
}

class _ResidentManagementPageState extends State<ResidentManagementPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> residents = [];
  List<Map<String, dynamic>> filteredResidents = [];
  bool isLoading = true;
  String searchQuery = '';
  
  // Purok counts
  Map<String, int> purokCounts = {};

  @override
  void initState() {
    super.initState();
    fetchResidents();
  }

  int _calculateAgeFromBirthdate(dynamic birthdate) {
    if (birthdate == null) return 0;
    try {
      final birth = DateTime.parse(birthdate.toString());
      final today = DateTime.now();
      int age = today.year - birth.year;
      if (today.month < birth.month || (today.month == birth.month && today.day < birth.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0;
    }
  }

  Future<void> fetchResidents() async {
    setState(() => isLoading = true);
    try {
      final response = await supabase
          .from('resident_profiles')
          .select('*, users:user_id(email, role)')
          .eq('account_status', 'approved')
          .order('last_name', ascending: true);

      final data = List<Map<String, dynamic>>.from(response);
      
      final purokMap = <String, int>{};
      for (var resident in data) {
        final purok = resident['address_purok']?.toString() ?? 'Unknown';
        purokMap[purok] = (purokMap[purok] ?? 0) + 1;
      }

      setState(() {
        residents = data;
        filteredResidents = data;
        purokCounts = purokMap;
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

  // 🔹 UPDATED: Filter that handles both search text and purok filter
  void filterResidents(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredResidents = residents;
      } else {
        // Check if query is a purok number (exact match for purok filter)
        final isPurokFilter = purokCounts.containsKey(query);
        
        if (isPurokFilter) {
          // Filter by purok only
          filteredResidents = residents.where((r) {
            return (r['address_purok']?.toString() ?? '') == query;
          }).toList();
        } else {
          // Filter by name/phone (search)
          filteredResidents = residents.where((r) {
            final name = '${r['last_name']}, ${r['first_name']}'.toLowerCase();
            final address = (r['address_purok'] ?? '').toLowerCase();
            final phone = (r['phone'] ?? '').toLowerCase();
            return name.contains(query.toLowerCase()) || 
                   address.contains(query.toLowerCase()) ||
                   phone.contains(query.toLowerCase());
          }).toList();
        }
      }
    });
  }

  String _formatFullName(Map<String, dynamic> r) {
    final first = r['first_name'] ?? '';
    final last = r['last_name'] ?? '';
    final middle = r['middle_name'];
    
    if (middle != null && middle.toString().isNotEmpty) {
      final middleInitial = middle.toString().trim()[0].toUpperCase();
      return '$last, $first $middleInitial.';
    }
    return '$last, $first';
  }

  String _formatFullAddress(Map<String, dynamic> r) {
    final purok = r['address_purok'] ?? '';
    final barangay = r['address_barangay'] ?? 'Ulbujan';
    final municipality = r['address_municipality'] ?? 'Calape';
    final province = r['address_province'] ?? 'Bohol';
    
    if (purok.isNotEmpty) {
      return 'Purok $purok, $barangay, $municipality, $province';
    }
    return '$barangay, $municipality, $province';
  }

  void showResidentDetails(Map<String, dynamic> resident) {
    final fullName = _formatFullName(resident);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 850),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
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
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Text(
                        '${resident['first_name']?[0] ?? ''}${resident['last_name']?[0] ?? ''}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: ColorStyle.topazyw3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            resident['users']?['email'] ?? 'No email',
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
                      icon: const Icon(Icons.close, color: Colors.white, size: 28),
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
                      _buildSectionTitle('Personal Information', Icons.person),
                      const SizedBox(height: 16),
                      _buildDetailRow('Full Name', fullName),
                      _buildDetailRow('Birthdate', _formatDate(resident['birthdate'])),
                      _buildDetailRow('Age', '${_calculateAgeFromBirthdate(resident['birthdate'])} years old'),
                      _buildDetailRow('Gender', (resident['gender'] ?? 'N/A').toString().toUpperCase()),
                      _buildDetailRow('Civil Status', (resident['civil_status'] ?? 'N/A').toString().toUpperCase()),
                      
                      const Divider(height: 32),
                      
                      _buildSectionTitle('Contact Information', Icons.contact_phone),
                      const SizedBox(height: 16),
                      _buildDetailRow('Phone', resident['phone'] ?? 'N/A'),
                      _buildDetailRow('Secondary Phone', resident['phone_secondary'] ?? 'N/A'),
                      _buildDetailRow('Email', resident['email'] ?? resident['users']?['email'] ?? 'N/A'),
                      
                      const Divider(height: 32),
                      
                      _buildSectionTitle('Address', Icons.location_on),
                      const SizedBox(height: 16),
                      _buildDetailRow('Complete Address', _formatFullAddress(resident)),
                      _buildDetailRow('Street', resident['address_street'] ?? 'N/A'),
                      
                      const Divider(height: 32),
                      
                      _buildSectionTitle('Work Information', Icons.work),
                      const SizedBox(height: 16),
                      _buildDetailRow('Occupation', resident['occupation'] ?? 'N/A'),
                      _buildDetailRow('Employment Status', (resident['employment_status'] ?? 'N/A').toString().toUpperCase()),
                      
                      const Divider(height: 32),
                      
                      _buildSectionTitle('Emergency Contact', Icons.emergency),
                      const SizedBox(height: 16),
                      _buildDetailRow('Name', resident['emergency_name'] ?? 'N/A'),
                      _buildDetailRow('Relationship', resident['emergency_relation'] ?? 'N/A'),
                      _buildDetailRow('Phone', resident['emergency_phone'] ?? 'N/A'),
                      
                      const Divider(height: 32),
                      
                      _buildSectionTitle('Identification', Icons.badge),
                      const SizedBox(height: 16),
                      _buildDetailRow('ID Type', resident['valid_id_type'] ?? 'N/A'),
                      _buildDetailRow('ID Number', resident['valid_id_number'] ?? 'N/A'),
                      
                      if (resident['valid_id_photo_url'] != null && 
                          resident['valid_id_photo_url'].toString().isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'ID Photo:',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            resident['valid_id_photo_url'],
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              height: 220,
                              color: Colors.grey.shade200,
                              child: const Center(child: Icon(Icons.error)),
                            ),
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 24),
                      
                      Text(
                        'Registered: ${_formatDateTime(resident['created_at'])}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
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
                          _showEditResidentDialog(resident); 
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorStyle.topazyw3,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showDeleteConfirm(resident);
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
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

  void _showEditResidentDialog(Map<String, dynamic> resident) {
    final firstNameController = TextEditingController(text: resident['first_name'] ?? '');
    final middleNameController = TextEditingController(text: resident['middle_name'] ?? '');
    final lastNameController = TextEditingController(text: resident['last_name'] ?? '');
    final purokController = TextEditingController(text: resident['address_purok'] ?? '');
    final streetController = TextEditingController(text: resident['address_street'] ?? '');
    final phoneController = TextEditingController(text: resident['phone'] ?? '');
    final phoneSecondaryController = TextEditingController(text: resident['phone_secondary'] ?? '');
    final emailController = TextEditingController(text: resident['email'] ?? '');
    final occupationController = TextEditingController(text: resident['occupation'] ?? '');
    final emergencyNameController = TextEditingController(text: resident['emergency_name'] ?? '');
    final emergencyPhoneController = TextEditingController(text: resident['emergency_phone'] ?? '');
    final emergencyRelationController = TextEditingController(text: resident['emergency_relation'] ?? '');
    final validIdNumberController = TextEditingController(text: resident['valid_id_number'] ?? '');
    
    final formKey = GlobalKey<FormState>();
    
    final List<String> idTypes = [
      'National ID', 'Passport', 'Driver\'s License', 'UMID', 'SSS ID',
      'PhilHealth ID', 'TIN ID', 'Postal ID', 'Voter\'s ID', 'PRC ID',
      'Senior Citizen ID', 'PWD ID', 'Barangay ID', 'Other'
    ];
    
    String? selectedIdType = resident['valid_id_type'];
    String? currentPhotoUrl = resident['valid_id_photo_url'];
    
    XFile? selectedPhoto;
    bool isUploading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          
          Future<void> pickImage() async {
            try {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(
                source: ImageSource.gallery,
                maxWidth: 1024,
                maxHeight: 1024,
                imageQuality: 85,
              );
              
              if (image != null) {
                setDialogState(() {
                  selectedPhoto = image;
                });
              }
            } catch (e) {
              debugPrint('Error picking image: $e');
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error selecting image: $e'), backgroundColor: Colors.red),
              );
            }
          }
          
          Future<String?> uploadImage(XFile file) async {
            try {
              setDialogState(() => isUploading = true);
              
              final bytes = await file.readAsBytes();
              final fileExt = file.name.split('.').last.toLowerCase();
              final timestamp = DateTime.now().millisecondsSinceEpoch;
              final fileName = '$timestamp.$fileExt';
              final filePath = 'id_photos/${resident['id']}/$fileName';
              
              await supabase.storage.from('resident-photos').uploadBinary(
                filePath,
                bytes,
                fileOptions: FileOptions(
                  contentType: 'image/${fileExt == 'jpg' ? 'jpeg' : fileExt}',
                  upsert: true,
                ),
              );
              
              final imageUrl = supabase.storage.from('resident-photos').getPublicUrl(filePath);
              return imageUrl;
            } catch (e) {
              debugPrint('Upload error: $e');
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.red),
              );
              return null;
            } finally {
              setDialogState(() => isUploading = false);
            }
          }

          return AlertDialog(
            backgroundColor: Colors.white,
            title: Row(
              children: [
                const Icon(Icons.edit, color: ColorStyle.topazyw3),
                const SizedBox(width: 12),
                const Expanded(child: Text('Edit Resident')),
                if (isUploading) ...[
                  const SizedBox(width: 12),
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(ColorStyle.topazyw3),
                    ),
                  ),
                ],
              ],
            ),
            content: Container(
              width: double.maxFinite,
              constraints: const BoxConstraints(maxWidth: 600, maxHeight: 750),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Personal Information',
                        style: TextStyle(fontWeight: FontWeight.bold, color: ColorStyle.topazyw3),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: lastNameController,
                        decoration: const InputDecoration(labelText: 'Last Name *', border: OutlineInputBorder()),
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: firstNameController,
                        decoration: const InputDecoration(labelText: 'First Name *', border: OutlineInputBorder()),
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: middleNameController,
                        decoration: const InputDecoration(labelText: 'Middle Name', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 24),
                      
                      const Text(
                        'Contact & Address',
                        style: TextStyle(fontWeight: FontWeight.bold, color: ColorStyle.topazyw3),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: phoneController,
                        decoration: const InputDecoration(labelText: 'Phone *', border: OutlineInputBorder()),
                        keyboardType: TextInputType.phone,
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: phoneSecondaryController,
                        decoration: const InputDecoration(
                          labelText: 'Secondary Phone (Optional)', 
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: purokController,
                        decoration: const InputDecoration(labelText: 'Purok *', border: OutlineInputBorder()),
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: streetController,
                        decoration: const InputDecoration(labelText: 'Street', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 24),
                      
                      const Text(
                        'Work & Emergency',
                        style: TextStyle(fontWeight: FontWeight.bold, color: ColorStyle.topazyw3),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: occupationController,
                        decoration: const InputDecoration(labelText: 'Occupation', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emergencyNameController,
                        decoration: const InputDecoration(labelText: 'Emergency Contact *', border: OutlineInputBorder()),
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emergencyPhoneController,
                        decoration: const InputDecoration(labelText: 'Emergency Phone *', border: OutlineInputBorder()),
                        keyboardType: TextInputType.phone,
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emergencyRelationController,
                        decoration: const InputDecoration(labelText: 'Relationship *', border: OutlineInputBorder()),
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 24),
                      
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ColorStyle.topazyw3.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ColorStyle.topazyw3.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.badge, color: ColorStyle.topazyw3),
                                const SizedBox(width: 8),
                                const Text(
                                  'Valid Identification',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold, 
                                    color: ColorStyle.topazyw3,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            DropdownButtonFormField<String>(
                              initialValue: selectedIdType,
                              decoration: const InputDecoration(
                                labelText: 'ID Type',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              ),
                              hint: const Text('Select ID Type'),
                              items: idTypes.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setDialogState(() {
                                  selectedIdType = value;
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            
                            TextFormField(
                              controller: validIdNumberController,
                              decoration: const InputDecoration(
                                labelText: 'ID Number',
                                border: OutlineInputBorder(),
                                hintText: 'Enter ID number',
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            const Text(
                              'ID Photo',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            
                            Container(
                              height: 180,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: selectedPhoto != null ? ColorStyle.topazyw3 : Colors.grey.shade300,
                                  width: selectedPhoto != null ? 2 : 1,
                                ),
                              ),
                              child: selectedPhoto != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(selectedPhoto!.path),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : currentPhotoUrl != null && currentPhotoUrl.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          currentPhotoUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) => Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.error_outline, color: Colors.grey.shade400, size: 40),
                                                const SizedBox(height: 8),
                                                Text('Failed to load image', style: TextStyle(color: Colors.grey.shade400)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    : Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.image_not_supported, color: Colors.grey.shade400, size: 40),
                                            const SizedBox(height: 8),
                                            Text(
                                              'No ID photo uploaded',
                                              style: TextStyle(color: Colors.grey.shade600),
                                            ),
                                          ],
                                        ),
                                      ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: isUploading ? null : pickImage,
                                icon: Icon(selectedPhoto != null ? Icons.refresh : Icons.camera_alt),
                                label: Text(selectedPhoto != null ? 'Change Photo' : 'Upload ID Photo'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: ColorStyle.topazyw3,
                                  side: BorderSide(color: ColorStyle.topazyw3),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            
                            if (selectedPhoto != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'New photo selected',
                                style: TextStyle(fontSize: 12, color: Colors.green.shade700, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isUploading ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isUploading ? null : () async {
                  if (!formKey.currentState!.validate()) return;
                  
                  try {
                    String? photoUrl = currentPhotoUrl;
                    
                    if (selectedPhoto != null) {
                      final uploadedUrl = await uploadImage(selectedPhoto!);
                      if (uploadedUrl != null) {
                        photoUrl = uploadedUrl;
                      }
                    }
                    
                    await supabase.from('resident_profiles').update({
                      'first_name': firstNameController.text.trim(),
                      'middle_name': middleNameController.text.trim(),
                      'last_name': lastNameController.text.trim(),
                      'phone': phoneController.text.trim(),
                      'phone_secondary': phoneSecondaryController.text.trim().isEmpty 
                          ? null 
                          : phoneSecondaryController.text.trim(),
                      'email': emailController.text.trim(),
                      'address_purok': purokController.text.trim(),
                      'address_street': streetController.text.trim(),
                      'occupation': occupationController.text.trim(),
                      'emergency_name': emergencyNameController.text.trim(),
                      'emergency_phone': emergencyPhoneController.text.trim(),
                      'emergency_relation': emergencyRelationController.text.trim(),
                      'valid_id_type': selectedIdType,
                      'valid_id_number': validIdNumberController.text.trim().isEmpty 
                          ? null 
                          : validIdNumberController.text.trim(),
                      'valid_id_photo_url': photoUrl,
                      'updated_at': DateTime.now().toIso8601String(),
                    }).eq('id', resident['id']);

                    if (context.mounted) {
                      Navigator.pop(context);
                      fetchResidents();
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Resident updated successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    debugPrint('Update error: $e');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating: $e'), backgroundColor: Colors.red),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: ColorStyle.topazyw3),
                child: isUploading 
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Save Changes',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: ColorStyle.topazyw3, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ColorStyle.topazyw3,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final d = DateTime.parse(date.toString());
      return DateFormat('MMMM dd, yyyy').format(d);
    } catch (e) {
      return 'N/A';
    }
  }

  String _formatDateTime(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final d = DateTime.parse(date.toString());
      return DateFormat('MMMM dd, yyyy - hh:mm a').format(d);
    } catch (e) {
      return 'N/A';
    }
  }

  void _showDeleteConfirm(Map<String, dynamic> resident) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Resident'),
        content: Text('Are you sure you want to delete ${resident['first_name']} ${resident['last_name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteResident(resident['id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteResident(String id) async {
    try {
      await supabase.from('resident_profiles').delete().eq('id', id);
      fetchResidents();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resident deleted'), backgroundColor: Colors.green),
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
          // 🔹 ENHANCED: Horizontal scrollable purok stats
          EnhancedPurokStats(
            purokCounts: purokCounts,
            currentFilter: searchQuery,
            onPurokSelected: (purok) {
              if (searchQuery == purok) {
                filterResidents(''); // Clear if already selected
              } else {
                filterResidents(purok);
              }
            },
          ),
          // 🔹 ENHANCED: Search with Filter dropdown (no counter overflow)
          SearchAndFilter(
            purokList: purokCounts.keys.toList()..sort(),
            currentFilter: searchQuery,
            onSearchChanged: (value) {
              // Only search if not currently filtering by purok dropdown
              if (!purokCounts.containsKey(searchQuery)) {
                filterResidents(value);
              } else {
                // If filtering by purok, search within that purok
                setState(() {
                  searchQuery = value;
                  filteredResidents = residents.where((r) {
                    final matchesPurok = (r['address_purok']?.toString() ?? '') == searchQuery;
                    final name = '${r['last_name']}, ${r['first_name']}'.toLowerCase();
                    final phone = (r['phone'] ?? '').toLowerCase();
                    final matchesSearch = name.contains(value.toLowerCase()) || 
                                         phone.contains(value.toLowerCase());
                    return matchesPurok && matchesSearch;
                  }).toList();
                });
              }
            },
            onFilterChanged: (value) {
              if (value != null) {
                filterResidents(value);
              }
            },
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredResidents.isEmpty
                    ? _buildEmptyState()
                    : _buildResidentsTable(),
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
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
          ),
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
                    'Resident Management',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Barangay Ulbujan Resident Database',
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
                      builder: (context) => const AddResidentPage(),
                    ),
                  );
                  fetchResidents();
                },
                icon: const Icon(Icons.person_add),
                label: const Text('Add Resident'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: ColorStyle.topazyw3,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
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
                  child: const Icon(
                    Icons.people_alt,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${residents.length}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Total Registered Residents',
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
        ],
      ),
    );
  }

  Widget _buildResidentsTable() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            decoration: BoxDecoration(
              color: ColorStyle.topazyw3.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'NAME',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'PHONE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    'ADDRESS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'ACTION',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: filteredResidents.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey.shade200,
                height: 1,
                indent: 24,
                endIndent: 24,
              ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: ColorStyle.topazyw3,
                  child: Text(
                    '${resident['last_name']?[0] ?? ''}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatFullName(resident),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${_calculateAgeFromBirthdate(resident['birthdate'])} yrs old',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Icon(Icons.phone, size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    resident['phone'] ?? 'N/A',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _formatFullAddress(resident),
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: IconButton(
                onPressed: () => showResidentDetails(resident),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorStyle.topazyw3.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.visibility,
                    color: ColorStyle.topazyw3,
                    size: 20,
                  ),
                ),
                tooltip: 'View Details',
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
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ColorStyle.topazyw3.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline,
              size: 80,
              color: ColorStyle.topazyw3.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No residents found',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isEmpty
                ? 'Start by adding a new resident'
                : 'Try adjusting your search',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          if (searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddResidentPage(),
                  ),
                );
                fetchResidents();
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Add Resident'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorStyle.topazyw3,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ],
      ),
    );
  }
}