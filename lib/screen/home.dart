import 'package:flutter/material.dart';
import 'package:prototype_project/loginpages/login_page.dart';
import 'package:prototype_project/loginpages/signup_page.dart';
import 'package:prototype_project/titlebar/title_bar.dart';
import 'package:prototype_project/utils/kulor_style.dart';
import 'package:prototype_project/widgets/homelink_widget.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _showLoginPage = true;

  void _toggleView() {
    setState(() {
      _showLoginPage = !_showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              // Left Side - Gradient Panel
              Expanded(
                flex: 3,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [ColorStyle.topazyw2, ColorStyle.topazyw3],
                      stops: [0.1, 0.7],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const HomeLinkWidget(),
                ),
              ),
              
              // Right Side - Login or Signup
              Expanded(
                flex: 4,
                child: _showLoginPage
                    ? LoginPage(showSignupPage: _toggleView)
                    : SignupPage(showLoginPage: _toggleView),
              ),
            ],
          ),
          const TitleBar(),
        ],
      ),
    );
  }
}