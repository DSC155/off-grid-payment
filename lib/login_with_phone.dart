import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pin_verification_page.dart';
import 'theme.dart';
import 'widgets.dart';

class LoginWithPhonePage extends StatefulWidget {
  const LoginWithPhonePage({super.key});

  @override
  State<LoginWithPhonePage> createState() => _LoginWithPhonePageState();
}

class _LoginWithPhonePageState extends State<LoginWithPhonePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController phoneController = TextEditingController();

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
  }

  @override
  void dispose() {
    phoneController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _showSnack(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: isError ? AppTheme.danger : AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _continueToPin() {
    String phoneNumber = phoneController.text.trim();
    if (phoneNumber.isEmpty) {
      _showSnack('Please enter your phone number');
      return;
    }
    if (phoneNumber.length < 10) {
      _showSnack('Please enter a valid 10-digit number');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PinVerificationPage(),
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
                    'Login with Phone',
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
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Icon ──────────────────────────────
                        Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: AppTheme.glowPurple,
                            ),
                            child: const Icon(Icons.phone_android_rounded,
                                color: Colors.white, size: 40),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Center(
                            child: Text('Login with Phone',
                                style: AppTheme.heading2)),
                        const SizedBox(height: 8),
                        const Center(
                          child: Text(
                            'Enter your phone number to continue',
                            style: AppTheme.body,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 48),

                        // ── Phone field ───────────────────────
                        Text('PHONE NUMBER', style: AppTheme.label),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.bgInput,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMd),
                            border: Border.all(
                                color: const Color(0xFF2A2A2E)),
                          ),
                          child: Row(
                            children: [
                              // Country code pill
                              Container(
                                margin: const EdgeInsets.only(left: 12),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.bgElevated,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  '+91',
                                  style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: phoneController,
                                  keyboardType: TextInputType.phone,
                                  maxLength: 10,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  cursorColor: AppTheme.primary,
                                  decoration: const InputDecoration(
                                    hintText: '9876543210',
                                    hintStyle: TextStyle(
                                        color: AppTheme.textHint,
                                        fontSize: 15),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 18),
                                    counterText: '',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Info notice ───────────────────────
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.08),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMd),
                            border: Border.all(
                                color: AppTheme.primary.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline_rounded,
                                  color: AppTheme.primaryLight, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'You will be asked for your 4-digit PIN on the next screen',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color:
                                        AppTheme.primaryLight.withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        // ── Continue button ───────────────────
                        PrimaryButton(
                          label: 'Continue',
                          icon: Icons.arrow_forward_rounded,
                          onTap: _continueToPin,
                        ),
                        const SizedBox(height: 20),

                        // ── Back link ─────────────────────────
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              'Back to Sign In',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
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
