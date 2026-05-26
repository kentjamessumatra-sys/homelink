import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:prototype_project/screen/home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://kdmnsmljkzmhfabtmriq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtkbW5zbWxqa3ptaGZhYnRtcmlxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU0NDEyMjksImV4cCI6MjA5MTAxNzIyOX0.xlbvVWOODM9tHo8LB1wvKErURDTSScjLIqr5lFa07LM',
  );

  runApp(const MyApp());

  appWindow.show();
  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(1300, 850);
    win.minSize = initialSize;
    win.size = initialSize;
    win.alignment = Alignment.center;
    win.title = "HomeLink Barangay Management System";
    win.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}