import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'theme.dart';
import 'widgets.dart';

class PayToShopPage extends StatefulWidget {
  final String ipAddress;
  final String senderUsername;

  const PayToShopPage({
    super.key,
    required this.ipAddress,
    required this.senderUsername,
  });

  @override
  State<PayToShopPage> createState() => _PayToShopPageState();
}

class _PayToShopPageState extends State<PayToShopPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController amountController = TextEditingController();

  String merchantName = "";
  bool fetchingMerchant = true;
  bool isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    _fetchMerchant();
  }

  @override
  void dispose() {
    amountController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _fetchMerchant() async {
    final url =
        Uri.parse("http://${widget.ipAddress}:5000/merchantname");
    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);
      merchantName = data["merchant"] ?? "Unknown Shop";
    } catch (e) {
      merchantName = "Unknown Shop";
    }
    setState(() => fetchingMerchant = false);
  }

  Future<void> _sendPayment() async {
    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      _showSnack("Enter a valid amount", isError: true);
      return;
    }

    final url =
        Uri.parse("http://${widget.ipAddress}:5000/pay");
    final data = {
      "username": widget.senderUsername,
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
        _showSnack("Payment successful!", isError: false);
        Navigator.pop(context, amount);
      } else {
        _showSnack("Payment failed: ${response.body}", isError: true);
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
        child: FadeTransition(
          opacity: _fadeAnim,
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
                      'Pay to Shop',
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: Column(
                    children: [
                      // ── Merchant Card ─────────────────────────
                      GlassCard(
                        padding: const EdgeInsets.all(24),
                        border: Border.all(
                            color: AppTheme.accentCool.withOpacity(0.25)),
                        child: fetchingMerchant
                            ? const Center(
                                child: SizedBox(
                                  height: 48,
                                  width: 48,
                                  child: CircularProgressIndicator(
                                    color: AppTheme.primary,
                                    strokeWidth: 2.5,
                                  ),
                                ),
                              )
                            : Column(
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentCool
                                          .withOpacity(0.12),
                                      borderRadius:
                                          BorderRadius.circular(18),
                                    ),
                                    child: const Icon(
                                        Icons.storefront_rounded,
                                        color: AppTheme.accentCool,
                                        size: 32),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    merchantName,
                                    style: AppTheme.heading3,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.bgElevated,
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
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      const SizedBox(height: 28),

                      // ── Amount Field ──────────────────────────
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text('AMOUNT', style: AppTheme.label)),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.bgInput,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMd),
                          border:
                              Border.all(color: const Color(0xFF2A2A2E)),
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
                            hintText: 'Enter amount to pay',
                            hintStyle: const TextStyle(
                                color: AppTheme.textHint, fontSize: 15),
                            prefixIcon: const Icon(Icons.currency_rupee,
                                color: AppTheme.accent, size: 20),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // ── Pay Button ────────────────────────────
                      PrimaryButton(
                        label: 'Pay Now',
                        isLoading: isLoading,
                        icon: Icons.storefront_rounded,
                        gradient: AppTheme.sendGradient,
                        onTap: _sendPayment,
                      ),
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
