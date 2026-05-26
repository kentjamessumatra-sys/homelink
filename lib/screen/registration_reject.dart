import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';  
import 'package:prototype_project/screen/home.dart';
import 'package:prototype_project/screen/registration_form.dart';
import 'package:prototype_project/titlebar/title_bar.dart';
import 'package:prototype_project/utils/kulor_style.dart';

class RegistrationRejectScreen extends StatefulWidget {
  final String? userId;
  
  const RegistrationRejectScreen({
    super.key, 
    this.userId,
  });

  @override
  State<RegistrationRejectScreen> createState() =>
      _RegistrationRejectScreenState();
}

class _RegistrationRejectScreenState extends State<RegistrationRejectScreen>
    with SingleTickerProviderStateMixin {
  
  final supabase = Supabase.instance.client;
  late final AnimationController _controller;
  late final Animation<double> _animation;
  late final Animation<double> _pulseAnimation;
  
  String? _adminNotes;
  bool _isLoading = true;
  bool _hasAdminNotes = false;
  
  // 🔹 BAGO: Store the actual userId to use (from widget or from auth)
  late final String? _effectiveUserId;

  @override
  void initState() {
    super.initState();
    
    // 🔹 CRITICAL FIX: Kunin ang userId mula sa widget OR sa current auth session
    _effectiveUserId = widget.userId ?? supabase.auth.currentUser?.id;
    
    debugPrint('🔹🔹🔹 RegistrationRejectScreen initState 🔹🔹🔹');
    debugPrint('🔹 widget.userId: ${widget.userId}');
    debugPrint('🔹 supabase.auth.currentUser?.id: ${supabase.auth.currentUser?.id}');
    debugPrint('🔹 _effectiveUserId: $_effectiveUserId');
    debugPrint('🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹');
    
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _loadAdminNotes();
  }
  
  Future<void> _loadAdminNotes() async {
    // 🔹 Use _effectiveUserId instead of widget.userId
    if (_effectiveUserId == null || _effectiveUserId.isEmpty) {
      debugPrint('❌ No effective userId available');
      setState(() => _isLoading = false);
      return;
    }
    
    try {
      debugPrint('🔹 Loading admin notes for user: $_effectiveUserId');
      
      final response = await supabase
          .from('resident_profiles')
          .select('admin_notes')
          .eq('user_id', _effectiveUserId)
          .maybeSingle();
      
      debugPrint('🔹 Database response: $response');
      
      if (mounted) {
        setState(() {
          if (response != null && response['admin_notes'] != null) {
            _adminNotes = response['admin_notes'].toString();
            _hasAdminNotes = _adminNotes!.trim().isNotEmpty;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading admin notes: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showAdminReasonDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.admin_panel_settings, color: Colors.red),
              SizedBox(width: 12),
              Text(
                'Reason for Rejection',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _hasAdminNotes && _adminNotes != null
                        ? _adminNotes!
                        : 'No specific reason provided by admin.\n\nPlease ensure all your information is accurate and complete.',
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Please address the issues mentioned and resubmit your registration.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            // 🔹 AYOS: Close lang, walang Edit button
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorStyle.topazyw3,
                foregroundColor: Colors.white,
              ),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _goToEditForm() {
    // 🔹 CRITICAL FIX: Use _effectiveUserId
    debugPrint('🔹 Navigating to RegistrationForm with userId: $_effectiveUserId');
    
    if (_effectiveUserId == null || _effectiveUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: User ID not found. Please login again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RegistrationForm(
          userId: _effectiveUserId, // 🔹 Use the effective userId
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: ColorStyle.topazyw1,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RotationTransition(
                      turns: _animation,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 80,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Registration Rejected',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 25),
                    
                    // 🔹 AYOS: Laging may button
                    if (!_isLoading) ...[
                      ElevatedButton.icon(
                        onPressed: _showAdminReasonDialog,
                        icon: Icon(
                          _hasAdminNotes ? Icons.message : Icons.info_outline,
                          color: Colors.white,
                        ),
                        label: Text(
                          _hasAdminNotes 
                              ? 'View Admin Message' 
                              : 'View Rejection Details',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _hasAdminNotes
                            ? 'Tap to see why your registration was rejected'
                            : 'Tap to see general guidelines for correction',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 25),
                    ] else ...[
                      const CircularProgressIndicator(),
                      const SizedBox(height: 25),
                    ],
                    
                    const Text(
                      'Your registration request has been reviewed and rejected by the administrator. Please revise your information and submit again.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Tips para sa correction
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 500),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '💡 Tips for correction:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '• Make sure all information is accurate\n• Upload a clear valid ID\n• Provide a working contact number',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    TextButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Contact Barangay Office'),
                            content: const Text(
                              'Barangay Ulbujan, Calape, Bohol\n\n'
                              'Phone: (038) 123-4567\n'
                              'Email: barangay.ulbujan@email.com',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.help_outline),
                      label: const Text('Need Help? Contact Us'),
                    ),
                    
                    const SizedBox(height: 20),
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: ElevatedButton.icon(
                        onPressed: _goToEditForm,
                        icon: const Icon(Icons.edit),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorStyle.topazyw3,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40, 
                            vertical: 20,
                          ),
                        ),
                        label: const Text(
                          'Edit Registration',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    TextButton(
                      onPressed: () async {
                        await supabase.auth.signOut();  
                        if (mounted) {
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const Home()),
                          );
                        }
                      },
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.brown),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
}