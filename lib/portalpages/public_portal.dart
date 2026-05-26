import 'package:flutter/material.dart';
import 'package:prototype_project/publicpages/public_dashboard_page.dart';
import 'package:prototype_project/navigation sidebar/public_sidebar.dart';
import 'package:prototype_project/titlebar/title_bar.dart';
import 'package:prototype_project/utils/kulor_style.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PublicPortal extends StatefulWidget {
  const PublicPortal({super.key});

  @override
  State<PublicPortal> createState() => _PublicPortalState();
}

class _PublicPortalState extends State<PublicPortal> {
  final ValueNotifier<Widget> _currentPage = ValueNotifier<Widget>(const SizedBox.shrink());
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);
  
  String _userId = '';
  bool _isLoading = true;
  bool _isInitialized = false; // ✅ ADD: Flag para hindi mag-double set

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    // Kuhanin ang user ID direkta sa Supabase sa halip na sa SharedPreferences
    final user = Supabase.instance.client.auth.currentUser;
    
    setState(() {
      _userId = user?.id ?? '';
      _isLoading = false;
    });

    if (!_isInitialized) {
      _isInitialized = true;
      _currentPage.value = const PublicDashboardPage();
    }
  }

  @override
  void dispose() {
    _currentPage.dispose();
    _selectedIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      backgroundColor: ColorStyle.cloudveil,
      body: Stack(
        children: [
          Row(
            children: [
              PublicSidebar(
                currentPage: _currentPage, 
                selectedIndexNotifier: _selectedIndex,
                userId: _userId,
              ),
              const VerticalDivider(thickness: 0, width: 0),
              Expanded(
                child: Container(
                  color: ColorStyle.topazyw4,
                  child: ValueListenableBuilder<Widget>(
                    valueListenable: _currentPage,
                    // ✅ FIX: Diretso return lang, walang if-check na gumagawa ng bagong instance
                    builder: (context, page, child) => page,
                  ),
                ),
              ),
            ],
          ),
          const TitleBar(),
        ],
      ),
    );
  }
}