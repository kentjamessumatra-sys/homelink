import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:prototype_project/screen/home.dart';
import 'package:prototype_project/screen/registration_waiting_screen.dart';
import 'package:prototype_project/titlebar/title_bar.dart';
import 'package:prototype_project/utils/kulor_style.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegistrationForm extends StatelessWidget {
  final String? userId;
  const RegistrationForm({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Row(
              children: [
                // Left Side - Gradient Panel
                // Left Side - Enhanced Gradient Panel
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [ColorStyle.topazyw2, ColorStyle.topazyw3],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        
                        // 🔹 MAIN LOGO - Centered with glow effect
                        Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.2),
                                blurRadius: 60,
                                spreadRadius: 10,
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'asset/homelink.png', // 🔹 Bago: homelink.png
                              height: 200,
                              width: 200,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 10),
                        
                        // 🔹 Tagline with better typography
                        const Text(
                          'Community Connectivity\nStarts Here',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.3,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // 🔹 Description
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Text(
                            'Securely register to access local government services, important announcements, and neighborhood updates in real-time.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white70,
                              height: 1.6,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // 🔹 Stats with icon
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_user_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Joined by 5,000+ residents',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // 🔹 GOVERNMENT LOGOS SECTION
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Official Partner of',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // 🔹 Logos row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Calape Logo
                                  Column(
                                    children: [
                                      Container(
                                        height: 120,
                                        width: 120,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.2),
                                              blurRadius: 15,
                                              offset: const Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        child: ClipOval(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Image.asset(
                                              'asset/logocalape.png',
                                              height: 104,
                                              width: 104,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Municipality\nof Calape',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          height: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(width: 30),
                                  
                                  // Divider
                                  Container(
                                    height: 80,
                                    width: 1,
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                  
                                  const SizedBox(width: 30),
                                  
                                  // Ulbujan Logo
                                  Column(
                                    children: [
                                      Container(
                                        height: 120,
                                        width: 120,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.2),
                                              blurRadius: 15,
                                              offset: const Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        child: ClipOval(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Image.asset(
                                              'asset/logoulbujan.png',
                                              height: 104,
                                              width: 104,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Barangay\nUlbujan',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          height: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // 🔹 Copyright
                        const Text(
                          '© 2026 HomeLink Philippines. All rights reserved.',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                // Right Side - Form
                Expanded(
                  flex: 4,
                  child: Container(
                    color: ColorStyle.topazyw4,
                    // 🔹 AYOS: Pass userId explicitly to ResidentForm
                    child: ResidentForm(userId: userId),
                  ),
                ),
              ],
            ),
          ),
          // Title Bar
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
}

class ResidentForm extends StatefulWidget {
  final String? userId;
  const ResidentForm({super.key, this.userId});

  @override
  State<ResidentForm> createState() => _ResidentFormState();
}

class _ResidentFormState extends State<ResidentForm> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  // Controllers with FocusNodes for Enter key navigation
  final _firstNameController = TextEditingController();
  final _firstNameFocusNode = FocusNode();
  
  final _middleNameController = TextEditingController();
  final _middleNameFocusNode = FocusNode();
  
  final _lastNameController = TextEditingController();
  final _lastNameFocusNode = FocusNode();
  
  final _suffixController = TextEditingController();
  final _suffixFocusNode = FocusNode();
  
  final _streetNameController = TextEditingController();
  final _streetNameFocusNode = FocusNode();
  
  final _purokController = TextEditingController();
  final _purokFocusNode = FocusNode();
  
  final _occupationController = TextEditingController();
  final _occupationFocusNode = FocusNode();
  
  final _idNumberController = TextEditingController();
  final _idNumberFocusNode = FocusNode();
  
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();
  
  final _phoneController = TextEditingController();
  final _phoneFocusNode = FocusNode();
  
  final _secondaryPhoneController = TextEditingController();
  final _secondaryPhoneFocusNode = FocusNode();
  
  final _emergencyNameController = TextEditingController();
  final _emergencyNameFocusNode = FocusNode();
  
  final _emergencyPhoneController = TextEditingController();
  final _emergencyPhoneFocusNode = FocusNode();
  
  final _ageController = TextEditingController();

  // State variables
  DateTime? _dateOfBirth;
  String? _gender;
  String? _civilStatus;
  String? _idType;
  String? _employmentStatus;
  String? _emergencyRelation;
  File? _validIdImage;
  int _age = 0;
  bool _isLoading = false;
  bool _isDataLoading = true;
  String? _errorMessage;

  // 🔹 FIX: Store the existing photo URL and signed URL
  String? _existingPhotoUrl;
  String? _existingPhotoSignedUrl;

  // Dropdown options
  final List<String> genderOptions = ['Male', 'Female'];
  final List<String> civilStatusOptions = ['Single', 'Married', 'Widowed', 'Separated'];
  final List<String> idTypeOptions = ['Philippine National ID', 'Driver\'s License', 'Passport', 'UMID', 'TIN ID', 'Voter\'s ID'];
  final List<String> employmentStatusOptions = ['Employed', 'Self-employed', 'Unemployed', 'Student', 'Retired'];
  final List<String> emergencyRelationOptions = [
    'Parent',
    'Spouse', 
    'Sibling',
    'Child',
    'Grandparent',
    'Aunt/Uncle',
    'Cousin',
    'Friend',
    'Neighbor',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    
    // 🔹 AYOS: Debug print para makita ang userId
    debugPrint('🔹🔹🔹 RegistrationForm initState 🔹🔹🔹');
    debugPrint('🔹 widget.userId: ${widget.userId}');
    debugPrint('🔹 widget.userId == null: ${widget.userId == null}');
    debugPrint('🔹 widget.userId?.isEmpty: ${widget.userId?.isEmpty}');
    debugPrint('🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹');
    
    // 🔹 AYOS: Mas malinaw na condition checking
    final String? currentUserId = widget.userId;
    
    if (currentUserId != null && currentUserId.isNotEmpty) {
      debugPrint('🔹 User ID is valid, loading existing data...');
      _loadExistingData();
    } else {
      debugPrint('❌ User ID is NULL or EMPTY!');
      setState(() {
        _isDataLoading = false;
        _errorMessage = 'Error: No User ID provided. Please logout and login again.';
      });
    }
  }

  // 🔹 AYOS: Better data loading with error handling
  Future<void> _loadExistingData() async {
    try {
      setState(() => _isDataLoading = true);
      
      final userId = widget.userId!;
      debugPrint('🔹 Loading data for user: $userId');
      
      final response = await supabase
          .from('resident_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      if (response != null) {
        debugPrint('🔹 Data found: ${response.toString()}');
        
        setState(() {
          // Load text data
          _firstNameController.text = response['first_name'] ?? '';
          _middleNameController.text = response['middle_name'] ?? '';
          _lastNameController.text = response['last_name'] ?? '';
          _suffixController.text = response['suffix'] ?? '';
          _phoneController.text = response['phone'] ?? '';
          _secondaryPhoneController.text = response['phone_secondary'] ?? '';
          _emailController.text = response['email'] ?? '';
          _purokController.text = response['address_purok'] ?? '';
          _streetNameController.text = response['address_street'] ?? '';
          _occupationController.text = response['occupation'] ?? '';
          _idNumberController.text = response['valid_id_number'] ?? '';
          _emergencyNameController.text = response['emergency_name'] ?? '';
          _emergencyPhoneController.text = response['emergency_phone'] ?? '';
          
          // Load dropdown values
          _emergencyRelation = response['emergency_relation'];
          
          // Capitalize stored values to match dropdown options
          _gender = response['gender'] != null 
              ? _capitalizeFirst(response['gender'].toString())
              : null;
              
          _civilStatus = response['civil_status'] != null
              ? _capitalizeFirst(response['civil_status'].toString())
              : null;
              
          _idType = response['valid_id_type'];
          
          _employmentStatus = response['employment_status'] != null
              ? _capitalizeFirst(response['employment_status'].toString())
              : null;
          
          // Load birthdate and calculate age
          if (response['birthdate'] != null) {
            _dateOfBirth = DateTime.parse(response['birthdate']);
            _age = _calculateAge(_dateOfBirth!);
            _ageController.text = _age.toString();
          }
          
          // 🔹 FIX: Check if there's an existing photo URL and generate signed URL
          if (response['valid_id_photo_url'] != null) {
            debugPrint('🔹 Existing photo URL: ${response['valid_id_photo_url']}');
            _existingPhotoUrl = response['valid_id_photo_url'];
            // Generate signed URL for private bucket
            _generateSignedUrlForExistingPhoto();
          }
        });
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Previous registration data loaded. Please review and update.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        debugPrint('🔹 No existing data found for user - new registration');
      }
    } catch (e) {
      debugPrint('❌ Error loading existing data: $e');
      setState(() {
        _errorMessage = 'Error loading data: $e';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isDataLoading = false);
    }
  }

  // 🔹 FIX: Generate signed URL for existing photo in private bucket
  Future<void> _generateSignedUrlForExistingPhoto() async {
    if (_existingPhotoUrl == null) return;
    
    try {
      // Extract filename from URL (the URL is like: https://.../storage/v1/object/public/valid-ids/filename.jpg)
      // or for private: https://.../storage/v1/object/authenticated/valid-ids/filename.jpg
      final uri = Uri.parse(_existingPhotoUrl!);
      final pathSegments = uri.pathSegments;
      
      // Find the bucket name and file path
      // URL structure: /storage/v1/object/(public|authenticated)/bucket-name/file-path
      int bucketIndex = -1;
      for (int i = 0; i < pathSegments.length; i++) {
        if (pathSegments[i] == 'valid-ids') {
          bucketIndex = i;
          break;
        }
      }
      
      if (bucketIndex != -1 && bucketIndex + 1 < pathSegments.length) {
        final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
        debugPrint('🔹 Extracted file path for signed URL: $filePath');
        
        // Create signed URL valid for 1 hour (3600 seconds)
        final signedUrl = await supabase
            .storage
            .from('valid-ids')
            .createSignedUrl(filePath, 3600);
        
        setState(() {
          _existingPhotoSignedUrl = signedUrl;
        });
        
        debugPrint('🔹 Signed URL generated successfully');
      }
    } catch (e) {
      debugPrint('❌ Error generating signed URL: $e');
      // Don't show error to user, just log it - the photo just won't display
    }
  }

  // Helper: Capitalize first letter only
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  @override
  void dispose() {
    // Dispose all controllers and focus nodes
    _firstNameController.dispose();
    _firstNameFocusNode.dispose();
    _middleNameController.dispose();
    _middleNameFocusNode.dispose();
    _lastNameController.dispose();
    _lastNameFocusNode.dispose();
    _suffixController.dispose();
    _suffixFocusNode.dispose();
    _streetNameController.dispose();
    _streetNameFocusNode.dispose();
    _purokController.dispose();
    _purokFocusNode.dispose();
    _occupationController.dispose();
    _occupationFocusNode.dispose();
    _idNumberController.dispose();
    _idNumberFocusNode.dispose();
    _emailController.dispose();
    _emailFocusNode.dispose();
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    _secondaryPhoneController.dispose();
    _secondaryPhoneFocusNode.dispose();
    _emergencyNameController.dispose();
    _emergencyNameFocusNode.dispose();
    _emergencyPhoneController.dispose();
    _emergencyPhoneFocusNode.dispose();
    _ageController.dispose();
    super.dispose();
  }

  int _calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    if (currentDate.month < birthDate.month ||
        (currentDate.month == birthDate.month && currentDate.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  String _capitalizeWords(String input) {
    if (input.isEmpty) return input;
    return input.trim().split(' ').where((w) => w.isNotEmpty).map((word) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Future<void> _pickValidIdImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          _validIdImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // 🔹 FIX: Upload and return the file path (not public URL) for private buckets
  Future<String?> _uploadValidIdImage() async {
    if (_validIdImage == null) return null;
    
    try {
      final fileName = '${widget.userId}_valid_id_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Upload file
      await supabase.storage.from('valid-ids').upload(fileName, _validIdImage!);
      
      // 🔹 FIX: For private bucket, store the file path and generate signed URL when needed
      // Return the format that can be used to generate signed URLs later
      // Store the full URL but we'll use signed URLs for display
      final publicUrl = supabase.storage.from('valid-ids').getPublicUrl(fileName);
      
      // Even though bucket is private, we store this URL format
      // The signed URL will be generated when displaying
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _saveToSupabase() async {
    // 🔹 AYOS: Double-check userId before saving
    final currentUserId = widget.userId;
    if (currentUserId == null || currentUserId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User ID not found. Please login again.'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? photoUrl;
      if (_validIdImage != null) {
        photoUrl = await _uploadValidIdImage();
      }

      final existingProfile = await supabase
          .from('resident_profiles')
          .select('id')
          .eq('user_id', currentUserId)
          .maybeSingle();

      final profileData = {
        'user_id': currentUserId,
        'first_name': _capitalizeWords(_firstNameController.text),
        'middle_name': _middleNameController.text.isNotEmpty ? _capitalizeWords(_middleNameController.text) : null,
        'last_name': _capitalizeWords(_lastNameController.text),
        'suffix': _suffixController.text.isNotEmpty ? _suffixController.text.trim() : null,
        'gender': _gender?.toLowerCase(),
        'birthdate': _dateOfBirth?.toIso8601String().split('T')[0],
        'civil_status': _civilStatus?.toLowerCase(),
        'phone': _phoneController.text.trim(),
        'phone_secondary': _secondaryPhoneController.text.isNotEmpty ? _secondaryPhoneController.text.trim() : null,
        'email': _emailController.text.isNotEmpty ? _emailController.text.trim() : null,
        'address_purok': _purokController.text.trim(),
        'address_street': _streetNameController.text.isNotEmpty ? _capitalizeWords(_streetNameController.text) : null,
        'address_barangay': 'Ulbujan',
        'address_municipality': 'Calape',
        'address_province': 'Bohol',
        'valid_id_type': _idType,
        'valid_id_number': _idNumberController.text.isNotEmpty ? _idNumberController.text.trim() : null,
        'valid_id_photo_url': photoUrl ?? _existingPhotoUrl,
        'occupation': _occupationController.text.isNotEmpty ? _capitalizeWords(_occupationController.text) : null,
        'employment_status': _employmentStatus?.toLowerCase(),
        'emergency_name': _capitalizeWords(_emergencyNameController.text),
        'emergency_phone': _emergencyPhoneController.text.trim(),
        'emergency_relation': _emergencyRelation,
        'account_status': 'pending',
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (existingProfile != null) {
        await supabase
            .from('resident_profiles')
            .update(profileData)
            .eq('user_id', currentUserId);
      } else {
        await supabase
            .from('resident_profiles')
            .insert(profileData);
      }

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: ColorStyle.topazyw1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 80),
                const SizedBox(height: 20),
                const Text('Registration Successful', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text('Your registration has been submitted for approval.', textAlign: TextAlign.center),
              ],
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const RegistrationWaitingScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorStyle.topazyw3,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving to Supabase: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildGlassCard({required String title, required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(255, 255, 255, 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🔹 $title',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ColorStyle.topazyw3),
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    FocusNode? nextFocusNode,
    TextInputType? keyboardType,
    bool required = false,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textInputAction: nextFocusNode != null ? TextInputAction.next : TextInputAction.done,
      onFieldSubmitted: (_) {
        if (nextFocusNode != null) {
          nextFocusNode.requestFocus();
        }
      },
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: const Color.fromRGBO(255, 255, 255, 0.1),
      ),
      validator: validator ?? (required ? (value) => (value == null || value.isEmpty) ? 'Please enter $label' : null : null),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Loading indicator habang naglo-load ng data
    if (_isDataLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading your information...'),
          ],
        ),
      );
    }

    // Error message kung walang userId
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  await supabase.auth.signOut();
                  if (mounted) {
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const Home()),
                    );
                  }
                },
                child: const Text('Logout and Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          // Show edit mode indicator
          Row(
            children: [
              const Text(
                'Resident Registration',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              if (widget.userId != null) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha:  0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: const Text(
                    'EDIT MODE',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Please complete the form below to register as a resident.',
            style: TextStyle(fontSize: 18, color: Colors.black),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PERSONAL INFORMATION
                    _buildGlassCard(
                      title: 'Personal Information',
                      children: [
                        _buildTextField(
                          controller: _firstNameController,
                          focusNode: _firstNameFocusNode,
                          nextFocusNode: _middleNameFocusNode,
                          label: 'First Name',
                          required: true,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _middleNameController,
                          focusNode: _middleNameFocusNode,
                          nextFocusNode: _lastNameFocusNode,
                          label: 'Middle Name',
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _lastNameController,
                          focusNode: _lastNameFocusNode,
                          nextFocusNode: _suffixFocusNode,
                          label: 'Last Name',
                          required: true,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _suffixController,
                          focusNode: _suffixFocusNode,
                          label: 'Suffix (Jr., Sr., III)',
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Gender *',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Color.fromRGBO(255, 255, 255, 0.1),
                          ),
                          dropdownColor: ColorStyle.topazyw1,
                          initialValue: _gender,
                          items: genderOptions.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                          onChanged: (v) => setState(() => _gender = v),
                          validator: (v) => v == null ? 'Please select gender' : null,
                        ),
                        const SizedBox(height: 20),
                        FormField<DateTime>(
                          validator: (value) => _dateOfBirth == null ? 'Please select date of birth' : null,
                          builder: (state) {
                            return InkWell(
                              onTap: () async {
                                final DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: _dateOfBirth ?? DateTime.now().subtract(const Duration(days: 6570)),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                );
                                if (pickedDate != null) {
                                  setState(() {
                                    _dateOfBirth = pickedDate;
                                    _age = _calculateAge(pickedDate);
                                    _ageController.text = _age.toString();
                                    state.didChange(pickedDate);
                                  });
                                }
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Date of Birth *',
                                  border: const OutlineInputBorder(),
                                  errorText: state.errorText,
                                  filled: true,
                                  fillColor: const Color.fromRGBO(255, 255, 255, 0.1),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(_dateOfBirth == null ? 'Select Date' : DateFormat('yyyy-MM-dd').format(_dateOfBirth!)),
                                    const Icon(Icons.calendar_today),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Age',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Color.fromRGBO(255, 255, 255, 0.1),
                          ),
                          controller: _ageController,
                          readOnly: true,
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Civil Status *',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Color.fromRGBO(255, 255, 255, 0.1),
                          ),
                          dropdownColor: ColorStyle.topazyw1,
                          initialValue: _civilStatus,
                          items: civilStatusOptions.map((cs) => DropdownMenuItem(value: cs, child: Text(cs))).toList(),
                          onChanged: (v) => setState(() => _civilStatus = v),
                          validator: (v) => v == null ? 'Please select civil status' : null,
                        ),
                      ],
                    ),

                    // ADDRESS INFORMATION
                    _buildGlassCard(
                      title: 'Address Information',
                      children: [
                        _buildTextField(
                          controller: _purokController,
                          focusNode: _purokFocusNode,
                          nextFocusNode: _streetNameFocusNode,
                          label: 'Purok / Zone',
                          required: true,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _streetNameController,
                          focusNode: _streetNameFocusNode,
                          label: 'Street',
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: 'Ulbujan',
                                readOnly: true,
                                decoration: const InputDecoration(
                                  labelText: 'Barangay',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Color.fromRGBO(255, 255, 255, 0.1),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: TextFormField(
                                initialValue: 'Calape',
                                readOnly: true,
                                decoration: const InputDecoration(
                                  labelText: 'Municipality',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Color.fromRGBO(255, 255, 255, 0.1),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: TextFormField(
                                initialValue: 'Bohol',
                                readOnly: true,
                                decoration: const InputDecoration(
                                  labelText: 'Province',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Color.fromRGBO(255, 255, 255, 0.1),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // CONTACT INFORMATION
                    _buildGlassCard(
                      title: 'Contact Information',
                      children: [
                        _buildTextField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          nextFocusNode: _phoneFocusNode,
                          label: 'Email Address',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _phoneController,
                          focusNode: _phoneFocusNode,
                          nextFocusNode: _secondaryPhoneFocusNode,
                          label: 'Phone Number',
                          keyboardType: TextInputType.phone,
                          required: true,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _secondaryPhoneController,
                          focusNode: _secondaryPhoneFocusNode,
                          label: 'Secondary Phone Number',
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),

                    // EMERGENCY CONTACT
                    _buildGlassCard(
                      title: 'Emergency Contact *',
                      children: [
                        _buildTextField(
                          controller: _emergencyNameController,
                          focusNode: _emergencyNameFocusNode,
                          nextFocusNode: _emergencyPhoneFocusNode,
                          label: 'Contact Name',
                          required: true,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _emergencyPhoneController,
                          focusNode: _emergencyPhoneFocusNode,
                          label: 'Contact Phone',
                          keyboardType: TextInputType.phone,
                          required: true,
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Relationship *',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Color.fromRGBO(255, 255, 255, 0.1),
                          ),
                          dropdownColor: ColorStyle.topazyw1,
                          initialValue: _emergencyRelation,
                          items: emergencyRelationOptions.map((relation) {
                            return DropdownMenuItem(
                              value: relation,
                              child: Text(relation),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => _emergencyRelation = v),
                          validator: (v) => v == null ? 'Please select relationship' : null,
                        ),
                      ],
                    ),

                    // IDENTIFICATION & OCCUPATION
                    _buildGlassCard(
                      title: 'Identification & Occupation',
                      children: [
                        _buildTextField(
                          controller: _occupationController,
                          focusNode: _occupationFocusNode,
                          nextFocusNode: _idNumberFocusNode,
                          label: 'Occupation',
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Employment Status',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Color.fromRGBO(255, 255, 255, 0.1),
                          ),
                          dropdownColor: ColorStyle.topazyw1,
                          initialValue: _employmentStatus,
                          items: employmentStatusOptions.map((es) => DropdownMenuItem(value: es, child: Text(es))).toList(),
                          onChanged: (v) => setState(() => _employmentStatus = v),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: 'Valid ID Type',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Color.fromRGBO(255, 255, 255, 0.1),
                                ),
                                dropdownColor: ColorStyle.topazyw1,
                                initialValue: _idType,
                                items: idTypeOptions.map((id) => DropdownMenuItem(value: id, child: Text(id))).toList(),
                                onChanged: (v) => setState(() {
                                  _idType = v;
                                  if (v == null) {
                                    _validIdImage = null;
                                  }
                                }),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 3,
                              child: _buildTextField(
                                controller: _idNumberController,
                                focusNode: _idNumberFocusNode,
                                label: 'ID Number',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        if (_idType != null) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _validIdImage == null && _existingPhotoSignedUrl == null ? Colors.orange : Colors.green,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: const Color.fromRGBO(255, 255, 255, 0.1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Valid ID Photo',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'REQUIRED',
                                        style: TextStyle(
                                          color: Colors.orange.shade800,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                
                                // 🔹 FIX: Display existing photo from signed URL if available
                                if (_existingPhotoSignedUrl != null && _validIdImage == null) ...[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      _existingPhotoSignedUrl!,
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        debugPrint('❌ Error loading image: $error');
                                        return Container(
                                          height: 150,
                                          width: double.infinity,
                                          color: Colors.grey.shade300,
                                          child: const Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.broken_image, color: Colors.grey),
                                                SizedBox(height: 8),
                                                Text('Failed to load image', style: TextStyle(color: Colors.grey)),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextButton.icon(
                                    onPressed: _pickValidIdImage,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Change Photo'),
                                  ),
                                ] else if (_validIdImage != null) ...[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      _validIdImage!,
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextButton.icon(
                                    onPressed: _pickValidIdImage,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Change Photo'),
                                  ),
                                ] else ...[
                                  OutlinedButton.icon(
                                    onPressed: _pickValidIdImage,
                                    icon: const Icon(Icons.upload_file),
                                    label: const Text('Upload Valid ID Photo'),
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(double.infinity, 50),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.shade50,
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.grey.shade600),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Please select a Valid ID Type first to upload your ID photo',
                                    style: TextStyle(color: Colors.grey.shade600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 30),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  // 🔹 FIX: Check for both new image and existing photo
                                  if (_idType != null && _validIdImage == null && _existingPhotoUrl == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please upload a valid ID photo'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  _saveToSupabase();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorStyle.topazyw3,
                          foregroundColor: Colors.white,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('SUBMIT REGISTRATION', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: ColorStyle.topazyw1,
                            title: const Text('Cancel Registration?'),
                            content: const Text('Your registration form is not yet submitted. If you log out now, your information will not be saved.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Continue Editing', style: TextStyle(color: Colors.red)),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await supabase.auth.signOut();
                                  if (mounted) {
                                    // ignore: use_build_context_synchronously
                                    Navigator.of(context).pop();
                                    // ignore: use_build_context_synchronously
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(builder: (context) => const Home()),
                                    );
                                  }
                                },
                                child: const Text('Logout', style: TextStyle(color: ColorStyle.topazyw3, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                        child: const Text('Logout', style: TextStyle(color: ColorStyle.topazyw3, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}