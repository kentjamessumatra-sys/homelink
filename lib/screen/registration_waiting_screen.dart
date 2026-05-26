import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';  
import 'package:prototype_project/screen/home.dart';
import 'package:prototype_project/titlebar/title_bar.dart';
import 'package:prototype_project/utils/kulor_style.dart';

class RegistrationWaitingScreen extends StatefulWidget {
  const RegistrationWaitingScreen({super.key});

  @override
  State<RegistrationWaitingScreen> createState() =>
      _RegistrationWaitingScreenState();
}

class _RegistrationWaitingScreenState extends State<RegistrationWaitingScreen>
    with SingleTickerProviderStateMixin {
  
  final supabase = Supabase.instance.client;
  
  late final AnimationController _controller;
  late final Animation<double> _animation;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                          color: Colors.orange.withValues(alpha:  0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.hourglass_top_rounded,
                          size: 80,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Registration Pending',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Your barangay registration is currently being verified by the administrator.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha:  0.1),
                        borderRadius: BorderRadius.circular(8),
                        // ignore: deprecated_member_use
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: const Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.schedule, color: Colors.orange, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Estimated approval: 2-4 working days',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Your application has been successfully submitted and is currently under review. Please wait for admin approval.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 50),
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: ElevatedButton.icon(
                        onPressed: () => _showLogoutDialog(context),
                        icon: const Icon(Icons.logout),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorStyle.topazyw3,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40, 
                            vertical: 20,
                          ),
                        ),
                        label: const Text('Logout'),
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorStyle.topazyw1,
        title: const Text('Logout Confirmation'),
        content: const Text(
          'Are you sure you want to log out of your HomeLink account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () async {
              // ✅ NOW WORKING: May supabase instance na
              await supabase.auth.signOut();
              
              if (context.mounted) {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const Home()),
                );
              }
            },
            child: const Text(
              'Logout', 
              style: TextStyle(
                color: ColorStyle.topazyw3, 
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}