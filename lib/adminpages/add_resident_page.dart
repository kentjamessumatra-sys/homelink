import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:prototype_project/utils/kulor_style.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class AddResidentPage extends StatefulWidget {
  const AddResidentPage({super.key});

  @override
  State<AddResidentPage> createState() => _AddResidentPageState();
}

class _AddResidentPageState extends State<AddResidentPage> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  
  // Controllers
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _purokController = TextEditingController();
  final _streetController = TextEditingController();
  final _phoneController = TextEditingController();
  final _phoneSecondaryController = TextEditingController();
  final _emailController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _occupationController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  
  // FocusNodes for Next/Enter navigation
  final _firstNameFocus = FocusNode();
  final _middleNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _purokFocus = FocusNode();
  final _streetFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _phoneSecondaryFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _occupationFocus = FocusNode();
  final _emergencyNameFocus = FocusNode();
  final _emergencyPhoneFocus = FocusNode();
  
  // State
  DateTime? _birthdate;
  String? _gender;
  String? _civilStatus;
  String? _idType;
  String? _employmentStatus;
  String? _emergencyRelation;
  File? _idPhoto;
  bool _isLoading = false;

  final List<String> _genderOptions = ['Male', 'Female'];
  final List<String> _civilStatusOptions = ['Single', 'Married', 'Widowed', 'Separated'];
  final List<String> _idTypeOptions = [
    'National ID',
    'Passport',
    'Driver\'s License',
    'UMID',
    'SSS ID',
    'PhilHealth ID',
    'TIN ID',
    'Postal ID',
    'Voter\'s ID',
    'PRC ID',
    'Senior Citizen ID',
    'PWD ID',
    'Barangay ID',
    'Other'
  ];
  final List<String> _employmentOptions = ['Employed', 'Self-employed', 'Unemployed', 'Student', 'Retired'];
  final List<String> _relationOptions = ['Parent', 'Spouse', 'Sibling', 'Child', 'Grandparent', 'Aunt/Uncle', 'Cousin', 'Friend', 'Neighbor', 'Other'];

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery, 
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() => _idPhoto = File(picked.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<String?> _uploadImage() async {
    if (_idPhoto == null) return null;
    try {
      final fileName = 'resident_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await supabase.storage.from('resident-photos').upload(fileName, _idPhoto!);
      return supabase.storage.from('resident-photos').getPublicUrl(fileName);
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  Future<bool> _checkDuplicate() async {
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    
    if (phone.isEmpty) return false;
    
    try {
      final phoneCheck = await supabase
          .from('resident_profiles')
          .select('id, first_name, last_name')
          .eq('phone', phone)
          .maybeSingle();
      
      if (phoneCheck != null) {
        if (mounted) {
          _showDuplicateDialog(
            'Phone Number Already Exists',
            'A resident named ${phoneCheck['first_name']} ${phoneCheck['last_name']} is already using this phone number.',
          );
        }
        return true;
      }

      if (email.isNotEmpty) {
        final emailCheck = await supabase
            .from('resident_profiles')
            .select('id, first_name, last_name')
            .eq('email', email)
            .maybeSingle();
        
        if (emailCheck != null) {
          if (mounted) {
            _showDuplicateDialog(
              'Email Already Exists',
              'A resident named ${emailCheck['first_name']} ${emailCheck['last_name']} is already using this email.',
            );
          }
          return true;
        }
      }
      
      return false;
    } catch (e) {
      debugPrint('Error checking duplicate: $e');
      return false;
    }
  }

  void _showDuplicateDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.orange),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveResident() async {
    if (!_formKey.currentState!.validate()) return;

    if (_birthdate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select birthdate'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Check for duplicates
      final isDuplicate = await _checkDuplicate();
      if (isDuplicate) {
        setState(() => _isLoading = false);
        return;
      }

      // Show confirmation dialog
      final confirm = await showDialog<bool>(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Registration'),
          content: Text('Add ${_capitalize(_firstNameController.text)} ${_capitalize(_lastNameController.text)} to the barangay database?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: ColorStyle.topazyw3),
              child: const Text('Confirm', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirm != true) {
        setState(() => _isLoading = false);
        return;
      }

      // Upload image if exists
      String? photoUrl;
      if (_idPhoto != null) {
        photoUrl = await _uploadImage();
      }

      // Prepare data
      final residentData = {
        'first_name': _capitalize(_firstNameController.text.trim()),
        'middle_name': _capitalize(_middleNameController.text.trim()),
        'last_name': _capitalize(_lastNameController.text.trim()),
        'gender': _gender?.toLowerCase(),
        'birthdate': _birthdate?.toIso8601String().split('T')[0],
        'civil_status': _civilStatus?.toLowerCase(),
        'phone': _phoneController.text.trim(),
        'phone_secondary': _phoneSecondaryController.text.trim().isEmpty 
            ? null 
            : _phoneSecondaryController.text.trim(),
        'email': _emailController.text.trim().isEmpty 
            ? null 
            : _emailController.text.trim(),
        'address_purok': _purokController.text.trim(),
        'address_street': _streetController.text.trim().isEmpty 
            ? null 
            : _streetController.text.trim(),
        'address_barangay': 'Ulbujan',
        'address_municipality': 'Calape',
        'address_province': 'Bohol',
        'valid_id_type': _idType,
        'valid_id_number': _idNumberController.text.trim().isEmpty 
            ? null 
            : _idNumberController.text.trim(),
        'valid_id_photo_url': photoUrl,
        'occupation': _occupationController.text.trim().isEmpty 
            ? null 
            : _capitalize(_occupationController.text.trim()),
        'employment_status': _employmentStatus?.toLowerCase(),
        'emergency_name': _capitalize(_emergencyNameController.text.trim()),
        'emergency_phone': _emergencyPhoneController.text.trim(),
        'emergency_relation': _emergencyRelation,
        'account_status': 'approved',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      debugPrint('Inserting data: $residentData');

      // Insert to database
      final response = await supabase.from('resident_profiles').insert(residentData).select();
      
      debugPrint('Insert response: $response');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Resident added successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        await Future.delayed(const Duration(milliseconds: 500));
        // ignore: use_build_context_synchronously
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('Error saving resident: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving resident: $e'), 
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  void _clearForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Form'),
        content: const Text('Are you sure you want to clear all entered data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _formKey.currentState?.reset();
              setState(() {
                _firstNameController.clear();
                _middleNameController.clear();
                _lastNameController.clear();
                _purokController.clear();
                _streetController.clear();
                _phoneController.clear();
                _phoneSecondaryController.clear();
                _emailController.clear();
                _idNumberController.clear();
                _occupationController.clear();
                _emergencyNameController.clear();
                _emergencyPhoneController.clear();
                _birthdate = null;
                _gender = null;
                _civilStatus = null;
                _idType = null;
                _employmentStatus = null;
                _emergencyRelation = null;
                _idPhoto = null;
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Dispose controllers
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _purokController.dispose();
    _streetController.dispose();
    _phoneController.dispose();
    _phoneSecondaryController.dispose();
    _emailController.dispose();
    _idNumberController.dispose();
    _occupationController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    
    // Dispose focus nodes
    _firstNameFocus.dispose();
    _middleNameFocus.dispose();
    _lastNameFocus.dispose();
    _purokFocus.dispose();
    _streetFocus.dispose();
    _phoneFocus.dispose();
    _phoneSecondaryFocus.dispose();
    _emailFocus.dispose();
    _occupationFocus.dispose();
    _emergencyNameFocus.dispose();
    _emergencyPhoneFocus.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorStyle.topazyw1,
      appBar: AppBar(
        backgroundColor: ColorStyle.topazyw3,
        elevation: 0,
        title: const Text(
          'Add New Resident',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            onPressed: _clearForm,
            icon: const Icon(Icons.clear_all, color: Colors.white),
            label: const Text('Clear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildSectionTitle('Personal Information'),
              const SizedBox(height: 16),
              
              // 🔹 FIXED: With FocusNode and Next action
              _buildTextField(
                controller: _firstNameController,
                focusNode: _firstNameFocus,
                nextFocus: _middleNameFocus,
                label: 'First Name *',
                required: true,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _middleNameController,
                focusNode: _middleNameFocus,
                nextFocus: _lastNameFocus,
                label: 'Middle Name',
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _lastNameController,
                focusNode: _lastNameFocus,
                label: 'Last Name *',
                required: true,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: 'Gender *',
                      value: _gender,
                      items: _genderOptions,
                      onChanged: (val) => setState(() => _gender = val),
                      required: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdown(
                      label: 'Civil Status *',
                      value: _civilStatus,
                      items: _civilStatusOptions,
                      onChanged: (val) => setState(() => _civilStatus = val),
                      required: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDatePicker(),
              const SizedBox(height: 32),
              _buildSectionTitle('Address'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _purokController,
                focusNode: _purokFocus,
                nextFocus: _streetFocus,
                label: 'Purok/Zone *',
                required: true,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _streetController,
                focusNode: _streetFocus,
                label: 'Street',
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildReadOnlyField('Barangay', 'Ulbujan')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildReadOnlyField('Municipality', 'Calape')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildReadOnlyField('Province', 'Bohol')),
                ],
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Contact Information'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                focusNode: _phoneFocus,
                nextFocus: _phoneSecondaryFocus,
                label: 'Phone Number *',
                required: true,
                keyboard: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _phoneSecondaryController,
                focusNode: _phoneSecondaryFocus,
                nextFocus: _emailFocus,
                label: 'Secondary Phone (Optional)',
                keyboard: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _emailController,
                focusNode: _emailFocus,
                label: 'Email',
                keyboard: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Work Information'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _occupationController,
                focusNode: _occupationFocus,
                label: 'Occupation',
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                label: 'Employment Status',
                value: _employmentStatus,
                items: _employmentOptions,
                onChanged: (val) => setState(() => _employmentStatus = val),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Emergency Contact'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emergencyNameController,
                focusNode: _emergencyNameFocus,
                nextFocus: _emergencyPhoneFocus,
                label: 'Contact Name *',
                required: true,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _emergencyPhoneController,
                focusNode: _emergencyPhoneFocus,
                label: 'Contact Phone *',
                required: true,
                keyboard: TextInputType.phone,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                label: 'Relationship *',
                value: _emergencyRelation,
                items: _relationOptions,
                onChanged: (val) => setState(() => _emergencyRelation = val),
                required: true,
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Identification'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildDropdown(
                      label: 'ID Type',
                      value: _idType,
                      items: _idTypeOptions,
                      onChanged: (val) => setState(() => _idType = val),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: _buildTextField(
                      controller: _idNumberController,
                      label: 'ID Number',
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildImageUploader(),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveResident,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorStyle.topazyw3,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Saving...', style: TextStyle(fontSize: 18)),
                          ],
                        )
                      : const Text(
                          'ADD RESIDENT',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColorStyle.topazyw3.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_add, color: ColorStyle.topazyw3, size: 32),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manual Registration',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Add resident information manually. This will bypass the approval process.',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ColorStyle.topazyw3,
          ),
        ),
      ],
    );
  }

  // 🔹 FIXED: Added FocusNode support for Enter/Next navigation
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool required = false,
    TextInputType? keyboard,
    FocusNode? focusNode,
    FocusNode? nextFocus,
    TextInputAction? textInputAction,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboard,
      textInputAction: textInputAction ?? (nextFocus != null ? TextInputAction.next : TextInputAction.done),
      onFieldSubmitted: (_) {
        if (nextFocus != null) {
          FocusScope.of(context).requestFocus(nextFocus);
        } else {
          FocusScope.of(context).unfocus();
        }
      },
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: required
          ? (val) => val == null || val.isEmpty ? 'Please enter $label' : null
          : null,
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now().subtract(const Duration(days: 6570)),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          setState(() => _birthdate = date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Birthdate *',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _birthdate == null 
                  ? 'Select Date' 
                  : DateFormat('MMMM dd, yyyy').format(_birthdate!),
              style: TextStyle(
                color: _birthdate == null ? Colors.grey.shade600 : Colors.black,
              ),
            ),
            const Icon(Icons.calendar_today, color: ColorStyle.topazyw3),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    bool required = false,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      validator: required ? (val) => val == null ? 'Please select $label' : null : null,
    );
  }

  Widget _buildImageUploader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _idPhoto != null ? Colors.green : Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _idPhoto != null ? Icons.check_circle : Icons.camera_alt,
                color: _idPhoto != null ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                'Valid ID Photo',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _idPhoto != null ? Colors.green : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_idPhoto != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                _idPhoto!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Change Photo'),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _idPhoto = null),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Remove', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ] else
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload ID Photo'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
        ],
      ),
    );
  }
}