import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'theme.dart';

class FingerprintAuthPage extends StatefulWidget {
  final VoidCallback onAuthenticated;

  const FingerprintAuthPage({super.key, required this.onAuthenticated});

  @override
  State<FingerprintAuthPage> createState() => _FingerprintAuthPageState();
}

class _FingerprintAuthPageState extends State<FingerprintAuthPage>
    with SingleTickerProviderStateMixin {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticating = false;
  String _authStatus = 'Verify identity to unlock DharPay';

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _authenticate();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    try {
      bool supported = await auth.isDeviceSupported();
      bool canCheck = await auth.canCheckBiometrics;

      if (!supported || !canCheck) {
        setState(() => _authStatus = "Biometrics unavaliable");
        // For development, we skip if not available so we don't get stuck.
        // widget.onAuthenticated();
        return;
      }

      setState(() {
        _isAuthenticating = true;
        _authStatus = "Authenticating...";
      });

      bool authenticated = await auth.authenticate(
        localizedReason: "Please authenticate to unlock wallet",
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
          sensitiveTransaction: true,
        ),
      );

      setState(() => _isAuthenticating = false);

      if (authenticated) {
        setState(() => _authStatus = "Verified!");
        await Future.delayed(const Duration(milliseconds: 300));
        widget.onAuthenticated();
      } else {
        setState(() => _authStatus = "Authentication failed. Try again.");
      }
    } catch (e) {
      setState(() {
        _isAuthenticating = false;
        _authStatus = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── App Logo ───────────────────────────────
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppTheme.glowPurple,
                  ),
                  child: const Icon(Icons.currency_rupee,
                      color: Colors.white, size: 38),
                ),
                const SizedBox(height: 16),
                const Text('DharPay',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    )),
                const SizedBox(height: 60),

                // ── Biometric Icon ─────────────────────────
                ScaleTransition(
                  scale: _isAuthenticating
                      ? _pulseAnim
                      : const AlwaysStoppedAnimation(1.0),
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.bgCard,
                      border: Border.all(
                        color: _isAuthenticating
                            ? AppTheme.primary
                            : const Color(0xFF2A2A2E),
                        width: _isAuthenticating ? 2 : 1,
                      ),
                      boxShadow:
                          _isAuthenticating ? AppTheme.glowPurple : [],
                    ),
                    child: Icon(
                      Icons.fingerprint_rounded,
                      size: 80,
                      color: _isAuthenticating
                          ? AppTheme.primaryLight
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // ── Status Text ────────────────────────────
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _authStatus,
                    key: ValueKey(_authStatus),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: _authStatus.contains('failed') ||
                              _authStatus.contains('Error')
                          ? AppTheme.danger
                          : _authStatus.contains('Verified')
                              ? AppTheme.success
                              : AppTheme.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // ── Retry Button ───────────────────────────
                if (!_isAuthenticating)
                  GestureDetector(
                    onTap: _authenticate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.bgElevated,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMd),
                        border: AppTheme.subtleBorder,
                      ),
                      child: const Text(
                        'Unlock with Biometrics',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
