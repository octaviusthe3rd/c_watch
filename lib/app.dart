import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/auth_gate.dart';

class CampusWatchApp extends StatelessWidget {
  const CampusWatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusWatch',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AuthGate(),
    );
  }
}