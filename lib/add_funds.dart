import 'package:flutter/material.dart';
import 'theme.dart';
import 'widgets.dart';

class AddFundsPage extends StatefulWidget {
  const AddFundsPage({super.key});

  @override
  State<AddFundsPage> createState() => _AddFundsPageState();
}

class _AddFundsPageState extends State<AddFundsPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController upiController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  bool isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final List<double> _quickAmounts = [100, 500, 1000, 2000, 5000];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    upiController.dispose();
    amountController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _addMoney() {
    final amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid amount',
              style: TextStyle(fontWeight: FontWeight.w600)),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }
    setState(() => isLoading = true);

    Future.delayed(const Duration(seconds: 2), () {
      setState(() => isLoading = false);
      Navigator.of(context).pop(amount);
    });
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
                padding:
                    const EdgeInsets.fromLTRB(8, 16, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppTheme.textPrimary, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Text(
                      'Add Funds',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Top-up amount display ──────────────────
                      GlassCard(
                        padding: const EdgeInsets.all(24),
                        border: Border.all(
                            color: AppTheme.primary.withOpacity(0.25)),
                        shadows: AppTheme.glowPurple,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('TOP UP AMOUNT',
                                style: AppTheme.label.copyWith(fontSize: 10)),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('₹',
                                    style: TextStyle(
                                      color: AppTheme.primary,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                    )),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: TextField(
                                    controller: amountController,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 40,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -1,
                                    ),
                                    cursorColor: AppTheme.primary,
                                    decoration: const InputDecoration(
                                      hintText: '0',
                                      hintStyle: TextStyle(
                                        color: AppTheme.textHint,
                                        fontSize: 40,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Quick amounts ──────────────────────────
                      Text('QUICK SELECT', style: AppTheme.label),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _quickAmounts.map((amt) {
                          return GestureDetector(
                            onTap: () => amountController.text =
                                amt.toStringAsFixed(0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppTheme.bgCard,
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusSm),
                                border: AppTheme.subtleBorder,
                              ),
                              child: Text(
                                '₹${amt.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 28),

                      // ── UPI ID ─────────────────────────────────
                      Text('UPI ID', style: AppTheme.label),
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
                          controller: upiController,
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                          cursorColor: AppTheme.primary,
                          decoration: InputDecoration(
                            hintText: 'yourname@upi',
                            hintStyle: const TextStyle(
                                color: AppTheme.textHint, fontSize: 15),
                            prefixIcon: const Icon(
                                Icons.alternate_email_rounded,
                                color: AppTheme.primary,
                                size: 20),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),

                      // ── Add Button ─────────────────────────────
                      PrimaryButton(
                        label: 'Add Money',
                        isLoading: isLoading,
                        icon: Icons.add_rounded,
                        onTap: _addMoney,
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
