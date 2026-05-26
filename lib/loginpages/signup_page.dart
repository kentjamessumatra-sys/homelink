import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prototype_project/utils/kulor_style.dart';
import 'package:prototype_project/widgets/text_widget.dart';
import 'package:prototype_project/utils/hide_scroll_behavior.dart';

class SignupPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const SignupPage({super.key, required this.showLoginPage});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  // FIXED: Gawing getter para lazy initialization
  SupabaseClient get supabase => Supabase.instance.client;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: ColorStyle.topazyw1,
          title: const Text('Terms Required'),
          content: const Text('You must agree to the Terms of Service and Privacy Policy.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Signup with Supabase Auth
      final response = await supabase.auth.signUp(
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      final user = response.user;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration failed. Please try again.')),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Insert into users table only (role = resident)
      await supabase.from('users').insert({
        'id': user.id,
        'email': user.email,
        'role': 'resident',
      });

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false, // User must click button
          builder: (context) => AlertDialog(
            backgroundColor: ColorStyle.topazyw1,
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 10),
                Text('Account Created'),
              ],
            ),
            content: const Text(
              'Your account has been created successfully!\n\n'
              'Please log in to complete your resident registration.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  widget.showLoginPage(); // Redirect to login page
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorStyle.topazyw3,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        );
      }

    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
        child: ScrollConfiguration(
          behavior: HideScrollBehavior(),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: SizedBox(
                        width: 600,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back, size: 30.0, color: Colors.white),
                                onPressed: widget.showLoginPage,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const TextWidget(
                              text: 'Create Account',
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            const TextWidget(
                              text: 'Join your local community today.',
                              fontSize: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 40),
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const TextWidget(text: 'EMAIL ADDRESS', fontSize: 14, color: Colors.white),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    controller: _emailController,
                                    focusNode: _emailFocusNode,
                                    textInputAction: TextInputAction.next,
                                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocusNode),
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.email_outlined, color: Colors.white),
                                      hintText: 'juan@example.com',
                                      hintStyle: const TextStyle(color: Colors.white70),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(5)),
                                        borderSide: const BorderSide(color: Colors.white),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(5)),
                                        borderSide: const BorderSide(color: Colors.white),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(5)),
                                        borderSide: const BorderSide(color: Colors.white),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) return 'Please enter your email';
                                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                      if (!emailRegex.hasMatch(value)) return 'Please enter a valid email address';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 15),
                                  const TextWidget(text: 'PASSWORD', fontSize: 14, color: Colors.white),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    controller: _passwordController,
                                    focusNode: _passwordFocusNode,
                                    textInputAction: TextInputAction.next,
                                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_confirmPasswordFocusNode),
                                    obscureText: _obscurePassword,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.white),
                                      hintText: '**********',
                                      hintStyle: const TextStyle(color: Colors.white70),
                                      border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(5)),
                                        borderSide: BorderSide(color: Colors.white),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(5)),
                                        borderSide: const BorderSide(color: Colors.white),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(5)),
                                        borderSide: const BorderSide(color: Colors.white),
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                          color: Colors.white,
                                        ),
                                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) return 'Please enter a password';
                                      if (value.length < 6) return 'Password must be at least 6 characters';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 15),
                                  const TextWidget(text: 'CONFIRM PASSWORD', fontSize: 14, color: Colors.white),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    controller: _confirmPasswordController,
                                    focusNode: _confirmPasswordFocusNode,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _signup(),
                                    obscureText: _obscureConfirmPassword,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.white),
                                      hintText: '**********',
                                      hintStyle: const TextStyle(color: Colors.white70),
                                      border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(5)),
                                        borderSide: BorderSide(color: Colors.white),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(5)),
                                        borderSide: const BorderSide(color: Colors.white),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(5)),
                                        borderSide: const BorderSide(color: Colors.white),
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                          color: Colors.white,
                                        ),
                                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) return 'Please confirm your password';
                                      if (value != _passwordController.text) return 'Passwords do not match';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Checkbox(
                                        value: _agreeToTerms,
                                        onChanged: (value) => setState(() => _agreeToTerms = value ?? false),
                                        checkColor: Colors.black,
                                        activeColor: Colors.white,
                                      ),
                                      Expanded(
                                        child: RichText(
                                          text: TextSpan(
                                            text: 'By creating an account, you agree to our ',
                                            style: DefaultTextStyle.of(context).style.copyWith(color: Colors.white),
                                            children: const [
                                              TextSpan(
                                                text: 'Terms of Service',
                                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                              ),
                                              TextSpan(text: ' and '),
                                              TextSpan(
                                                text: 'Privacy Policy.',
                                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _signup,
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                        foregroundColor: Colors.black,
                                      ),
                                      child: Ink(
                                        decoration: BoxDecoration(
                                          gradient: _isLoading ? null : const LinearGradient(
                                            colors: [ColorStyle.topazyw2, ColorStyle.topazyw3],
                                            stops: [0.1, 1.0],
                                          ),
                                          color: _isLoading ? Colors.grey : null,
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: Container(
                                          width: double.infinity,
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(vertical: 20),
                                          child: _isLoading
                                              ? const CircularProgressIndicator(color: Colors.white)
                                              : const Text('Create Account →', style: TextStyle(color: Colors.white)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Already have an account?", style: TextStyle(color: Colors.white)),
                                TextButton(
                                  onPressed: widget.showLoginPage,
                                  style: TextButton.styleFrom(foregroundColor: ColorStyle.topazyw3),
                                  child: const Text("Login"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
      ),
    );
  }
}