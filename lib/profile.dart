import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'fingerprint_auth_page.dart';
import 'signup_page.dart';
import 'theme.dart';
import 'widgets.dart';

final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  String email = '';
  String username = '';

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
            CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
    _loadUserDetails();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadUserDetails() async {
    final storedEmail =
        await secureStorage.read(key: 'user_email') ?? '';
    final storedUsername =
        await secureStorage.read(key: 'user_username') ?? '';
    setState(() {
      email = storedEmail;
      username = storedUsername;
    });
  }

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => FingerprintAuthPage(
                onAuthenticated: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const SignupPage()),
                  );
                },
              )),
      (Route<dynamic> route) => false,
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: AppTheme.subtleBorder,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 18),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTheme.label.copyWith(fontSize: 10)),
              const SizedBox(height: 2),
              Text(
                value.isNotEmpty ? value : '—',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: AppTheme.textPrimary, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Profile',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
                    child: Column(
                      children: [
                        // ── Avatar ─────────────────────────────
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                shape: BoxShape.circle,
                                boxShadow: AppTheme.glowPurple,
                              ),
                              child: const Icon(Icons.person_rounded,
                                  color: Colors.white, size: 52),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppTheme.accent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: AppTheme.bg, width: 2),
                                ),
                                child: const Icon(Icons.check,
                                    color: Colors.white, size: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          username.isNotEmpty ? username : "Username",
                          style: AppTheme.heading2,
                        ),
                        const SizedBox(height: 4),
                        StatusBadge(
                          label: 'ACTIVE WALLET',
                          color: AppTheme.success,
                          icon: Icons.verified_rounded,
                        ),
                        const SizedBox(height: 36),

                        // ── Info ───────────────────────────────
                        _infoRow(Icons.person_outline_rounded,
                            'USERNAME', username),
                        const SizedBox(height: 12),
                        _infoRow(Icons.alternate_email_rounded,
                            'EMAIL ADDRESS', email),
                        const SizedBox(height: 12),
                        _infoRow(Icons.shield_outlined, 'SECURITY',
                            'Biometric Protected'),
                        const SizedBox(height: 40),

                        // ── Logout ─────────────────────────────
                        GestureDetector(
                          onTap: () => _logout(context),
                          child: Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.danger.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(
                                  AppTheme.radiusMd),
                              border: Border.all(
                                  color:
                                      AppTheme.danger.withOpacity(0.25)),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.logout_rounded,
                                    color: AppTheme.danger, size: 20),
                                SizedBox(width: 10),
                                Text(
                                  'Sign Out',
                                  style: TextStyle(
                                    color: AppTheme.danger,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
