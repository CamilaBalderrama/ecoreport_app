import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/report_screen.dart';

void main() {
  runApp(const EcoReportApp());
}

class EcoReportApp extends StatelessWidget {
  const EcoReportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoReport GPS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20),
          primary: const Color(0xFF2E7D32),
          secondary: const Color(0xFF4CAF50),
          surface: const Color(0xFFF4F6F4),
        ),
        scaffoldBackgroundColor: const Color(0xFFF9FBF9),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/report': (context) => const ReportScreen(),
        '/list': (context) => const ReportListScreen(),
      },
    );
  }
}