import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'theme.dart';
import 'widgets.dart';

class PayToFriendPage extends StatefulWidget {
  final String ipAddress;
  final String senderUsername;
  const PayToFriendPage({
    super.key,
    required this.ipAddress,
    required this.senderUsername,
  });

  @override
  State<PayToFriendPage> createState() => _PayToFriendPageState();
}

class _PayToFriendPageState extends State<PayToFriendPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController friendController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  bool isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
            CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    friendController.dispose();
    amountController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _sendPayment() async {
    final String friend = friendController.text.trim();
    final amount = double.tryParse(amountController.text.trim());

    if (friend.isEmpty) {
      _showSnack("Enter friend's username", isError: true);
      return;
    }
    if (amount == null || amount <= 0) {
      _showSnack("Enter a valid amount", isError: true);
      return;
    }

    final url = Uri.parse("http://${widget.ipAddress}:5000/transact");
    final data = {
      "from": widget.senderUsername,
      "to": friend,
      "amount": amount,
    };

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        _showSnack("Sent ₹$amount to $friend", isError: false);
        Navigator.pop(context, amount);
      } else {
        _showSnack("Failed: ${response.body}", isError: true);
      }
    } catch (e) {
      _showSnack("Error: $e", isError: true);
    }

    setState(() => isLoading = false);
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
                    'Pay to Friend',
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
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Recipient avatar ──────────────────
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: AppTheme.sendGradient,
                                  shape: BoxShape.circle,
                                  boxShadow: AppTheme.glowPurple,
                                ),
                                child: const Icon(Icons.person_rounded,
                                    color: Colors.white, size: 40),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Hotspot Transfer',
                                style: AppTheme.bodySmall.copyWith(
                                    color: AppTheme.textMuted),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.bgCard,
                                  borderRadius:
                                      BorderRadius.circular(20),
                                  border: AppTheme.subtleBorder,
                                ),
                                child: Text(
                                  widget.ipAddress,
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ── Friend username ───────────────────
                        Text('RECIPIENT USERNAME', style: AppTheme.label),
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
                            controller: friendController,
                            style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                            cursorColor: AppTheme.primary,
                            decoration: InputDecoration(
                              hintText: "Friend's username",
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

                        // ── Amount ────────────────────────────
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
                        const SizedBox(height: 40),

                        // ── Send Button ───────────────────────
                        PrimaryButton(
                          label: 'Send Money',
                          isLoading: isLoading,
                          icon: Icons.arrow_upward_rounded,
                          onTap: _sendPayment,
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
