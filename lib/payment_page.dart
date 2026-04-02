import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'theme.dart';
import 'widgets.dart';

class PaymentPage extends StatefulWidget {
  final String ipAddress;
  const PaymentPage({super.key, required this.ipAddress});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController ip1 = TextEditingController();
  final TextEditingController ip2 = TextEditingController();
  final TextEditingController ip3 = TextEditingController();
  final TextEditingController ip4 = TextEditingController();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _voiceInput = "";

  bool isLoading = false;
  String result = '';

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    final parts = widget.ipAddress.split('.');
    if (parts.length == 4) {
      ip1.text = parts[0];
      ip2.text = parts[1];
      ip3.text = parts[2];
      ip4.text = parts[3];
    }
    _speech = stt.SpeechToText();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    ip1.dispose();
    ip2.dispose();
    ip3.dispose();
    ip4.dispose();
    usernameController.dispose();
    amountController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _listen() async {
    if (!_isListening) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Say: "send 500 to username"',
              style: TextStyle(fontWeight: FontWeight.w600)),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
      await Future.delayed(const Duration(seconds: 1));

      bool available = await _speech.initialize(
        onStatus: (val) => debugPrint('Speech status: $val'),
        onError: (val) => debugPrint('Speech error: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _voiceInput = val.recognizedWords;
              _processVoiceCommand(_voiceInput);
            });
          },
          localeId: 'en_IN',
          cancelOnError: true,
          listenMode: stt.ListenMode.confirmation,
        );
      }
    } else {
      _speech.stop();
      setState(() => _isListening = false);
    }
  }

  void _processVoiceCommand(String command) {
    final regex = RegExp(
        r'(pay|send|transfer)\s+(\d+)\s+(?:to|for)?\s+(\w+)',
        caseSensitive: false);
    final match = regex.firstMatch(command);
    if (match != null) {
      final amount = match.group(2);
      final uname = match.group(3);
      if (amount != null) amountController.text = amount;
      if (uname != null) usernameController.text = uname;
    }
  }

  String get ipAddress =>
      "${ip1.text.trim()}.${ip2.text.trim()}.${ip3.text.trim()}.${ip4.text.trim()}";

  bool validateIp() {
    final parts = [ip1.text, ip2.text, ip3.text, ip4.text];
    for (var part in parts) {
      if (part.isEmpty) return false;
      final numVal = int.tryParse(part);
      if (numVal == null || numVal < 0 || numVal > 255) return false;
    }
    return true;
  }

  Future<void> submitPayment() async {
    final uname = usernameController.text.trim();
    final amountText = amountController.text.trim();

    if (!validateIp()) {
      _showSnack('Invalid IP address', isError: true);
      return;
    }
    if (uname.isEmpty || amountText.isEmpty) {
      _showSnack('Please fill all fields', isError: true);
      return;
    }
    final amount = double.tryParse(amountText);
    if (amount == null) {
      _showSnack('Invalid amount', isError: true);
      return;
    }

    final url = Uri.parse("http://$ipAddress:5000/pay");
    final data = {'username': uname, 'amount': amount};

    setState(() {
      isLoading = true;
      result = '';
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      setState(() {
        result =
            "Status: ${response.statusCode}\nResponse: ${response.body}";
      });
      if (response.statusCode == 200) {
        _showSnack('Payment Successful! ✓', isError: false);
      }
    } catch (e) {
      setState(() => result = "Error: $e");
      _showSnack('Error: $e', isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnack(String msg, {required bool isError}) {
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

  Widget _buildIpBox(TextEditingController controller) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.bgInput,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2A2A2E)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        maxLength: 3,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        cursorColor: AppTheme.primary,
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 12, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppTheme.textPrimary, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Payment',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    // Voice mic button
                    GestureDetector(
                      onTap: _listen,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: _isListening
                              ? AppTheme.danger
                              : AppTheme.bgCard,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _isListening
                                ? AppTheme.danger.withOpacity(0.4)
                                : const Color(0xFF2A2A2E),
                          ),
                          boxShadow: _isListening
                              ? [
                                  BoxShadow(
                                    color:
                                        AppTheme.danger.withOpacity(0.4),
                                    blurRadius: 12,
                                    spreadRadius: -2,
                                  )
                                ]
                              : null,
                        ),
                        child: Icon(
                          _isListening ? Icons.mic : Icons.mic_none_rounded,
                          color: _isListening
                              ? Colors.white
                              : AppTheme.textSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── IP Address ────────────────────────────
                      Text('SERVER IP ADDRESS', style: AppTheme.label),
                      const SizedBox(height: 12),
                      GlassCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Expanded(child: _buildIpBox(ip1)),
                            const Text(' . ',
                                style: TextStyle(
                                    color: AppTheme.primary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            Expanded(child: _buildIpBox(ip2)),
                            const Text(' . ',
                                style: TextStyle(
                                    color: AppTheme.primary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            Expanded(child: _buildIpBox(ip3)),
                            const Text(' . ',
                                style: TextStyle(
                                    color: AppTheme.primary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            Expanded(child: _buildIpBox(ip4)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Username ──────────────────────────────
                      Text('USERNAME', style: AppTheme.label),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.bgInput,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(
                              color: const Color(0xFF2A2A2E)),
                        ),
                        child: TextField(
                          controller: usernameController,
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                          cursorColor: AppTheme.primary,
                          decoration: InputDecoration(
                            hintText: 'Recipient username',
                            hintStyle: const TextStyle(
                                color: AppTheme.textHint, fontSize: 15),
                            prefixIcon: const Icon(
                                Icons.person_outline_rounded,
                                color: AppTheme.primary,
                                size: 20),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Amount ────────────────────────────────
                      Text('AMOUNT', style: AppTheme.label),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.bgInput,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(
                              color: const Color(0xFF2A2A2E)),
                        ),
                        child: TextField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                          cursorColor: AppTheme.primary,
                          decoration: InputDecoration(
                            hintText: 'Enter amount',
                            hintStyle: const TextStyle(
                                color: AppTheme.textHint, fontSize: 15),
                            prefixIcon: const Icon(
                                Icons.currency_rupee,
                                color: AppTheme.accent,
                                size: 20),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),

                      // ── Submit ────────────────────────────────
                      PrimaryButton(
                        label: 'Submit Payment',
                        isLoading: isLoading,
                        icon: Icons.send_rounded,
                        onTap: submitPayment,
                      ),

                      // ── Result ────────────────────────────────
                      if (result.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: result.contains('Error')
                                ? AppTheme.danger.withOpacity(0.08)
                                : AppTheme.success.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(
                                AppTheme.radiusMd),
                            border: Border.all(
                              color: result.contains('Error')
                                  ? AppTheme.danger.withOpacity(0.25)
                                  : AppTheme.success.withOpacity(0.25),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Icon(
                                result.contains('Error')
                                    ? Icons.error_outline_rounded
                                    : Icons.check_circle_outline_rounded,
                                color: result.contains('Error')
                                    ? AppTheme.danger
                                    : AppTheme.success,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  result,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: result.contains('Error')
                                        ? AppTheme.danger
                                        : AppTheme.success,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
