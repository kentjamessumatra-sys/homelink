import 'package:flutter/material.dart';
import 'package:prototype_project/titlebar/title_bar.dart';
import 'package:prototype_project/utils/kulor_style.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileViewPage extends StatefulWidget {
  final String userId;

  const ProfileViewPage({super.key, required this.userId});

  @override
  State<ProfileViewPage> createState() => _ProfileViewPageState();
}

class _ProfileViewPageState extends State<ProfileViewPage> {
  bool _isEditing = false;
  bool _isLoading = true;
  bool _isSaving = false;

  Map<String, dynamic> _profileData = {};

  // Controllers
  final _firstNameCtrl = TextEditingController();
  final _middleNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _suffixCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _phoneSecondaryCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressPurokCtrl = TextEditingController();
  final _addressStreetCtrl = TextEditingController();
  final _occupationCtrl = TextEditingController();
  final _employmentStatusCtrl = TextEditingController();
  final _emergencyNameCtrl = TextEditingController();
  final _emergencyPhoneCtrl = TextEditingController();
  final _emergencyRelationCtrl = TextEditingController();

  // Dropdown values
  String? _gender;
  String? _civilStatus;
  DateTime? _birthdate;

  final List<String> _genderOptions = ['Male', 'Female'];
  final List<String> _civilStatusOptions = ['Single', 'Married', 'Widowed', 'Separated'];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _middleNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _suffixCtrl.dispose();
    _phoneCtrl.dispose();
    _phoneSecondaryCtrl.dispose();
    _emailCtrl.dispose();
    _addressPurokCtrl.dispose();
    _addressStreetCtrl.dispose();
    _occupationCtrl.dispose();
    _employmentStatusCtrl.dispose();
    _emergencyNameCtrl.dispose();
    _emergencyPhoneCtrl.dispose();
    _emergencyRelationCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('resident_profiles')
          .select('*, households(*)')
          .eq('user_id', widget.userId)
          .maybeSingle();

      if (response != null) {
        setState(() {
          _profileData = response;
          _syncControllers();
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _syncControllers() {
    _firstNameCtrl.text = _profileData['first_name'] ?? '';
    _middleNameCtrl.text = _profileData['middle_name'] ?? '';
    _lastNameCtrl.text = _profileData['last_name'] ?? '';
    _suffixCtrl.text = _profileData['suffix'] ?? '';
    _phoneCtrl.text = _profileData['phone'] ?? '';
    _phoneSecondaryCtrl.text = _profileData['phone_secondary'] ?? '';
    _emailCtrl.text = _profileData['email'] ?? '';
    _addressPurokCtrl.text = _profileData['address_purok'] ?? '';
    _addressStreetCtrl.text = _profileData['address_street'] ?? '';
    _occupationCtrl.text = _profileData['occupation'] ?? '';
    _employmentStatusCtrl.text = _profileData['employment_status'] ?? '';
    _emergencyNameCtrl.text = _profileData['emergency_name'] ?? '';
    _emergencyPhoneCtrl.text = _profileData['emergency_phone'] ?? '';
    _emergencyRelationCtrl.text = _profileData['emergency_relation'] ?? '';

    _gender = _capitalizeFirst(_profileData['gender']);
    _civilStatus = _capitalizeFirst(_profileData['civil_status']);

    if (_profileData['birthdate'] != null) {
      _birthdate = DateTime.tryParse(_profileData['birthdate']);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('resident_profiles').update({
        'first_name': _firstNameCtrl.text.trim(),
        'middle_name': _middleNameCtrl.text.trim().isEmpty ? null : _middleNameCtrl.text.trim(),
        'last_name': _lastNameCtrl.text.trim(),
        'suffix': _suffixCtrl.text.trim().isEmpty ? null : _suffixCtrl.text.trim(),
        'gender': _gender?.toLowerCase(),
        'civil_status': _civilStatus?.toLowerCase(),
        'birthdate': _birthdate?.toIso8601String().split('T')[0],
        'phone': _phoneCtrl.text.trim(),
        'phone_secondary': _phoneSecondaryCtrl.text.trim().isEmpty ? null : _phoneSecondaryCtrl.text.trim(),
        'email': _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        'address_purok': _addressPurokCtrl.text.trim(),
        'address_street': _addressStreetCtrl.text.trim().isEmpty ? null : _addressStreetCtrl.text.trim(),
        'occupation': _occupationCtrl.text.trim().isEmpty ? null : _occupationCtrl.text.trim(),
        'employment_status': _employmentStatusCtrl.text.trim().isEmpty ? null : _employmentStatusCtrl.text.trim().toLowerCase(),
        'emergency_name': _emergencyNameCtrl.text.trim(),
        'emergency_phone': _emergencyPhoneCtrl.text.trim(),
        'emergency_relation': _emergencyRelationCtrl.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', widget.userId);

      await _loadProfile();
      setState(() => _isEditing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  String _capitalizeFirst(String? text) {
    if (text == null || text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.month}/${date.day}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String _getInitials(String firstName, String lastName) {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return '$f$l'.toUpperCase();
  }

  String _getFullName() {
    final first = _profileData['first_name'] ?? '';
    final middle = _profileData['middle_name'] ?? '';
    final last = _profileData['last_name'] ?? '';
    final suffix = _profileData['suffix'] ?? '';
    return '$first ${middle.isNotEmpty ? '$middle ' : ''}$last${suffix.isNotEmpty ? ' $suffix' : ''}'.trim();
  }

  int? _calculateAge() {
    if (_birthdate == null) return null;
    final now = DateTime.now();
    int age = now.year - _birthdate!.year;
    if (now.month < _birthdate!.month || (now.month == _birthdate!.month && now.day < _birthdate!.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorStyle.topazyw1,
      body: Stack(
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_profileData.isEmpty)
            _buildEmptyState()
          else
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 240,
                  pinned: true,
                  floating: false,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildProfileHeader(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          _buildStatusBanner(),
                          const SizedBox(height: 24),

                          // Personal Information
                          _buildSection(
                            title: 'Personal Information',
                            icon: Icons.person_outline,
                            children: [
                              _buildField('First Name', _firstNameCtrl, Icons.person, required: true),
                              _buildField('Middle Name', _middleNameCtrl, Icons.person_outline),
                              _buildField('Last Name', _lastNameCtrl, Icons.person, required: true),
                              _buildField('Suffix', _suffixCtrl, Icons.short_text),
                              _buildDropdown('Gender', _gender, _genderOptions, Icons.wc_outlined, (v) => setState(() => _gender = v)),
                              _buildDatePicker('Date of Birth', Icons.cake_outlined),
                              _buildInfoRow('Age', '${_calculateAge() ?? 'N/A'} years old', Icons.calendar_today),
                              _buildDropdown('Civil Status', _civilStatus, _civilStatusOptions, Icons.favorite_border, (v) => setState(() => _civilStatus = v)),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Contact Information
                          _buildSection(
                            title: 'Contact Information',
                            icon: Icons.contact_phone_outlined,
                            children: [
                              _buildField('Primary Phone', _phoneCtrl, Icons.phone, required: true, keyboardType: TextInputType.phone),
                              _buildField('Secondary Phone', _phoneSecondaryCtrl, Icons.phone_iphone, keyboardType: TextInputType.phone),
                              _buildField('Email Address', _emailCtrl, Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Address
                          _buildSection(
                            title: 'Address',
                            icon: Icons.location_on_outlined,
                            children: [
                              _buildField('Purok', _addressPurokCtrl, Icons.signpost_outlined, required: true),
                              _buildField('Street', _addressStreetCtrl, Icons.add_road),
                              _buildInfoRow('Barangay', _profileData['address_barangay'] ?? 'Ulbujan', Icons.location_city),
                              _buildInfoRow('Municipality', _profileData['address_municipality'] ?? 'Calape', Icons.map_outlined),
                              _buildInfoRow('Province', _profileData['address_province'] ?? 'Bohol', Icons.landscape_outlined),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Employment
                          _buildSection(
                            title: 'Employment',
                            icon: Icons.work_outline,
                            children: [
                              _buildField('Occupation', _occupationCtrl, Icons.business_center_outlined),
                              _buildField('Employment Status', _employmentStatusCtrl, Icons.assignment_ind_outlined),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Emergency Contact
                          _buildSection(
                            title: 'Emergency Contact',
                            icon: Icons.emergency_outlined,
                            children: [
                              _buildField('Contact Name', _emergencyNameCtrl, Icons.person_pin, required: true),
                              _buildField('Contact Phone', _emergencyPhoneCtrl, Icons.phone_in_talk, required: true, keyboardType: TextInputType.phone),
                              _buildField('Relationship', _emergencyRelationCtrl, Icons.people_outline, required: true),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Household Info
                          

                          // Account Info
                          _buildSection(
                            title: 'Account Information',
                            icon: Icons.admin_panel_settings_outlined,
                            children: [
                              _buildInfoRow('Member Since', _formatDate(_profileData['created_at']), Icons.calendar_today),
                              _buildInfoRow('Last Updated', _formatDate(_profileData['updated_at']), Icons.update),
                            ],
                          ),

                          const SizedBox(height: 32),
                          _buildActionButtons(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: TitleBar(),
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
          const Icon(Icons.person_off, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No Profile Found', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Please complete your registration first.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadProfile,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final fullName = _getFullName();
    final firstName = _profileData['first_name'] ?? '';
    final lastName = _profileData['last_name'] ?? '';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ColorStyle.topazyw3, ColorStyle.topazyw2],
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 3),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Center(
                child: Text(
                  _getInitials(firstName, lastName),
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              fullName.isEmpty ? 'Loading...' : fullName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              _profileData['email'] ?? '',
              style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8)),
            ),
            const SizedBox(height: 4),
            Text(
              'Resident • Barangay Ulbujan',
              style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6), letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    final status = _profileData['account_status'] ?? 'pending';
    final color = switch (status) {
      'approved' => Colors.green,
      'rejected' => Colors.red,
      'pending' => Colors.orange,
      _ => Colors.grey,
    };
    final icon = switch (status) {
      'approved' => Icons.verified,
      'rejected' => Icons.cancel,
      'pending' => Icons.pending,
      _ => Icons.help,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Text(
            'Account Status: ${_capitalizeFirst(status)}',
            style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required IconData icon, required List<Widget> children}) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ColorStyle.topazyw3.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: ColorStyle.topazyw3, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ColorStyle.topazyw3)),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    if (!_isEditing) {
      return _buildInfoRow(label, controller.text.isEmpty ? 'N/A' : controller.text, icon);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: required ? (v) => v == null || v.isEmpty ? 'Please enter $label' : null : null,
        style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          prefixIcon: Icon(icon, color: ColorStyle.topazyw3, size: 20),
          filled: true,
          fillColor: ColorStyle.topazyw1.withValues(alpha: 0.5),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: ColorStyle.topazyw3, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          labelStyle: TextStyle(color: ColorStyle.paleslate, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> options,
    IconData icon,
    ValueChanged<String?> onChanged, {
    bool required = false,
  }) {
    if (!_isEditing) {
      return _buildInfoRow(label, value ?? 'N/A', icon);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          prefixIcon: Icon(icon, color: ColorStyle.topazyw3, size: 20),
          filled: true,
          fillColor: ColorStyle.topazyw1.withValues(alpha: 0.5),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: ColorStyle.topazyw3, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          labelStyle: TextStyle(color: ColorStyle.paleslate, fontSize: 13),
        ),
        dropdownColor: Colors.white,
        items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
        onChanged: onChanged,
        validator: required ? (v) => v == null ? 'Please select $label' : null : null,
      ),
    );
  }

  Widget _buildDatePicker(String label, IconData icon) {
    if (!_isEditing) {
      return _buildInfoRow(label, _formatDate(_profileData['birthdate']), icon);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: _birthdate ?? DateTime(2000),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (picked != null) setState(() => _birthdate = picked);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: ColorStyle.topazyw3, size: 20),
            filled: true,
            fillColor: ColorStyle.topazyw1.withValues(alpha: 0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            labelStyle: TextStyle(color: ColorStyle.paleslate, fontSize: 13),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _birthdate == null ? 'Select Date' : _formatDate(_birthdate!.toIso8601String()),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _birthdate == null ? ColorStyle.paleslate : Colors.black87,
                ),
              ),
              const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ColorStyle.topazyw3.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: ColorStyle.topazyw3, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: ColorStyle.paleslate, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isSaving
                ? null
                : () {
                    if (_isEditing) {
                      _saveProfile();
                    } else {
                      setState(() => _isEditing = true);
                    }
                  },
            icon: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Icon(_isEditing ? Icons.save : Icons.edit),
            label: Text(_isEditing ? 'Save Changes' : 'Edit Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorStyle.topazyw3,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 2,
            ),
          ),
        ),
        if (_isEditing) ...[
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _syncControllers();
                });
              },
              icon: const Icon(Icons.cancel),
              label: const Text('Cancel'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ],
    );
  }
}    