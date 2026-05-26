import 'package:flutter/material.dart';
import 'package:prototype_project/navigation%20sidebar/admin_sidebar.dart';
import 'package:prototype_project/titlebar/title_bar.dart';
import 'package:prototype_project/utils/kulor_style.dart';

class AdminPortal extends StatefulWidget {
  const AdminPortal({super.key});

  @override
  State<AdminPortal> createState() => _AdminPortalState();
}

class _AdminPortalState extends State<AdminPortal> {
  final ValueNotifier<Widget> _currentPage = ValueNotifier<Widget>(Container());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorStyle.cloudveil,
      body: Stack(
        children: [
          Row(
            children: [
              AdminSidebar(currentPage: _currentPage),
              const VerticalDivider(thickness: 0, width: 0),
              Expanded(
                child: Container(
                  color: ColorStyle.topazyw4,
                  child: ValueListenableBuilder<Widget>(
                    valueListenable: _currentPage,
                    builder: (context, page, child) {
                      return page;
                    },
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
