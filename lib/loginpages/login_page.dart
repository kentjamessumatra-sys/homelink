import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prototype_project/screen/registration_reject.dart';
import 'package:prototype_project/utils/kulor_style.dart';
import 'package:prototype_project/screen/registration_form.dart';
import 'package:prototype_project/screen/registration_waiting_screen.dart';
import 'package:prototype_project/portalpages/admin_portal.dart';
import 'package:prototype_project/portalpages/public_portal.dart';
import 'package:prototype_project/widgets/text_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback showSignupPage;
  const LoginPage({super.key, required this.showSignupPage});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  bool _obscureText = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  SupabaseClient get supabase => Supabase.instance.client;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Expanded(child: Text(message)),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 20),
              onPressed: () {
                if (mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                }
              },
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red : null,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Please enter both email and password.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Supabase auth login
      final response = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      final user = response.user;
      if (user == null) {
        _showSnackBar('Login failed. Please check your credentials.', isError: true);
        setState(() => _isLoading = false);
        return;
      }

      // Fetch user role
      final userData = await supabase
          .from('users')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      final role = userData?['role']?.toString().toLowerCase() ?? 'resident';

      // Fetch resident profile status
      final profileData = await supabase
          .from('resident_profiles')
          .select('id, account_status, household_id')
          .eq('user_id', user.id)
          .maybeSingle();

      final profileId = profileData?['id'];
      final accountStatus = profileData?['account_status']?.toString().toLowerCase() ?? 'pending';
      final hasProfile = profileData != null;
      final profileCompleted = hasProfile;

      debugPrint('Role: $role, HasProfile: $hasProfile, Status: $accountStatus, Completed: $profileCompleted');

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', user.id);
      await prefs.setString('role', role);
      await prefs.setBool('profile_completed', profileCompleted);
      await prefs.setString('resident_status', accountStatus);
      await prefs.setString('email', user.email ?? '');
      if (profileId != null) {
        await prefs.setString('profile_id', profileId);
      }

      // Navigation logic
      if (role.contains('admin')) {
        _showSnackBar('Admin login successful!');
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AdminPortal()),
        );
      } else {
          if (!hasProfile) {
          _showSnackBar('Please complete your registration form.');
          // ignore: use_build_context_synchronously
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => RegistrationForm(userId: user.id)),
          );
        } else if (accountStatus == 'pending') {
          _showSnackBar('Registration pending approval.');
          // ignore: use_build_context_synchronously
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const RegistrationWaitingScreen()),
          );
        } else if (accountStatus == 'approved') {
          _showSnackBar('Welcome to HomeLink!');
          // ignore: use_build_context_synchronously
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const PublicPortal()),
          );
        } else if (accountStatus == 'rejected') {
          _showSnackBar('Registration rejected. Please update your information.');
          // ignore: use_build_context_synchronously
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const RegistrationRejectScreen()),
          );
        } else {
          _showSnackBar('Account status unclear. Contact administrator.', isError: true);
        }
      }

    } on AuthException catch (e) {
      _showSnackBar(e.message, isError: true);
    } catch (e) {
      _showSnackBar('Connection failed: $e', isError: true);
      debugPrint('Login error: $e');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [ColorStyle.topazyw2, ColorStyle.topazyw1],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Scrollbar(
                    thumbVisibility: false,
                    child: SingleChildScrollView(
                      child: SizedBox(
                        width: 550,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const TextWidget(
                              text: 'Welcome back,',
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            const TextWidget(
                              text: 'please enter your credentials to access your account.',
                              fontSize: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 40),
                            const TextWidget(text: 'Username or Email', fontSize: 14, color: Colors.white),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.person_outline, color: Colors.white),
                                hintText: 'Enter your email',
                                hintStyle: const TextStyle(color: Colors.white70),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(color: Colors.white),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(color: Colors.white),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            const TextWidget(text: 'Password', fontSize: 14, color: Colors.white),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              obscureText: _obscureText,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _login(),
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock_outline, color: Colors.white),
                                hintText: 'Enter your password',
                                hintStyle: const TextStyle(color: Colors.white70),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(color: Colors.white),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(color: Colors.white),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(color: Colors.white),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.white),
                                  onPressed: () => setState(() => _obscureText = !_obscureText),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _rememberMe,
                                      onChanged: (value) => setState(() => _rememberMe = value ?? false),
                                      checkColor: Colors.black,
                                      activeColor: Colors.white,
                                    ),
                                    const TextWidget(text: 'Remember me', color: Colors.white),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: const TextWidget(text: 'Forgot password?', color: Colors.white),
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                                  foregroundColor: Colors.black,
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: _isLoading ? null : const LinearGradient(colors: [ColorStyle.topazyw2, ColorStyle.topazyw3]),
                                    color: _isLoading ? Colors.grey : null,
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(vertical: 25),
                                    child: _isLoading
                                        ? const CircularProgressIndicator(color: Colors.white)
                                        : const Text('Login to Account', style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Don't have an account?", style: TextStyle(color: Colors.white)),
                                TextButton(
                                  onPressed: widget.showSignupPage,
                                  style: TextButton.styleFrom(foregroundColor: ColorStyle.topazyw3),
                                  child: const Text("Sign up"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  const Divider(color: Colors.black),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(foregroundColor: ColorStyle.topazyw3),
                        child: const Text('Privacy Policy'),
                      ),
                      const SizedBox(width: 20),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(foregroundColor: ColorStyle.topazyw3),
                        child: const Text('Terms of Service'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('CopyRight © 2026 HomeLink Philippines. All rights reserved.', style: TextStyle(color: ColorStyle.topazyw3)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}