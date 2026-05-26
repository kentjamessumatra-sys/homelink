import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:prototype_project/utils/kulor_style.dart';


final buttonColors = WindowButtonColors(
  iconNormal: Colors.white,
  mouseOver: ColorStyle.topazyw4,
  mouseDown: ColorStyle.topazyw3,
  iconMouseOver: Colors.black,
  iconMouseDown: Colors.black,
);

final closeButtonColors = WindowButtonColors(
  mouseOver: const Color(0xFFD32F2F),
  mouseDown: const Color(0xFFB71C1C),
  iconNormal: Colors.white,
  iconMouseOver: Colors.black,
);

class TitleBar extends StatefulWidget {
  const TitleBar({super.key});

  @override
  State<TitleBar> createState() => _TitleBarState();
}

class _TitleBarState extends State<TitleBar> {
  void maximizeOrRestore() {
    setState(() {
      appWindow.maximizeOrRestore();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WindowTitleBarBox(
      child: Container(
        color: Colors.transparent,
        height: 100,
        child: Row(
          children: [
            Expanded(child: MoveWindow()),
            MinimizeWindowButton(colors: buttonColors),
            appWindow.isMaximized
                ? RestoreWindowButton(
                    colors: buttonColors,
                    onPressed: maximizeOrRestore,
                  )
                : MaximizeWindowButton(
                    colors: buttonColors,
                    onPressed: maximizeOrRestore,
                  ),
            CloseWindowButton(colors: closeButtonColors),
          ],
        ),
      ),
    );
  }
}
