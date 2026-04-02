import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'fingerprint_auth_page.dart';
import 'signup_page.dart';
import 'login_page.dart';
import 'portfolio_page.dart';
import 'theme.dart';

final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

void main() {
  runApp(const DharPayApp());
}

class DharPayApp extends StatelessWidget {
  const DharPayApp({super.key});

  Future<bool> _hasAccount() async {
    final username = await secureStorage.read(key: 'user_username');
    return username != null && username.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DharPay',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppTheme.bg,
        colorSchemeSeed: AppTheme.primary,
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppTheme.bg,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: FutureBuilder<bool>(
        future: _hasAccount(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primary,
                  strokeWidth: 2.5,
                ),
              ),
            );
          }
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            );
          }
          if (snapshot.data == false) {
            return const SignupPage();
          }
          return FingerprintAuthPage(
            onAuthenticated: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const PortfolioPage()),
              );
            },
          );
        },
      ),
      routes: {
        '/signup': (context) => const SignupPage(),
        '/login': (context) => const LoginPage(),
        '/portfolio': (context) => const PortfolioPage(),
      },
    );
  }
}
