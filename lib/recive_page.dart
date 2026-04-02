import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'theme.dart';
import 'widgets.dart';

class ReceivePaymentPage extends StatefulWidget {
  final String ipAddress;
  final String username;

  const ReceivePaymentPage({
    super.key,
    required this.ipAddress,
    required this.username,
  });

  @override
  State<ReceivePaymentPage> createState() => _ReceivePaymentPageState();
}

class _ReceivePaymentPageState extends State<ReceivePaymentPage>
    with SingleTickerProviderStateMixin {
  late Future<Map<String, dynamic>> _paymentsFuture;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _paymentsFuture = fetchReceivedPayments();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> fetchReceivedPayments() async {
    final url =
        Uri.parse("http://${widget.ipAddress}:5000/untransact");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'payee': widget.username}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data != null && data['processed'] != null) {
        return data['processed'];
      }
    }

    return {"total": 0, "records": []};
  }

  String formatDate(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return "${dt.day.toString().padLeft(2, '0')}/"
        "${dt.month.toString().padLeft(2, '0')}/"
        "${dt.year.toString().substring(2)}";
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
                    const Expanded(
                      child: Text(
                        'Receive Payment',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    // Server pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCard,
                        borderRadius: BorderRadius.circular(20),
                        border: AppTheme.subtleBorder,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                                color: AppTheme.success,
                                shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            widget.ipAddress,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Body ───────────────────────────────────────────
              Expanded(
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _paymentsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primary,
                          strokeWidth: 2.5,
                        ),
                      );
                    }

                    final payments =
                        snapshot.data?['records'] as List? ?? [];
                    final total = snapshot.data?['total'] ?? 0;

                    // ── No records ──────────────────────────
                    if (payments.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: GlassCard(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 40),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: AppTheme.bgElevated,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                      Icons.inbox_rounded,
                                      size: 36,
                                      color: AppTheme.textMuted),
                                ),
                                const SizedBox(height: 20),
                                const Text('No Payments Yet',
                                    style: AppTheme.heading3),
                                const SizedBox(height: 8),
                                const Text(
                                  'Waiting for incoming\ntransactions...',
                                  textAlign: TextAlign.center,
                                  style: AppTheme.body,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    // ── Records list ────────────────────────
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                      children: [
                        // Total received card
                        GlassCard(
                          padding: const EdgeInsets.all(24),
                          border: Border.all(
                              color: AppTheme.success.withOpacity(0.25)),
                          shadows: AppTheme.glowGreen,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color:
                                      AppTheme.success.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                    Icons.south_west_rounded,
                                    color: AppTheme.success,
                                    size: 28),
                              ),
                              const SizedBox(height: 14),
                              const Text('Total Received',
                                  style: AppTheme.bodySmall),
                              const SizedBox(height: 6),
                              Text(
                                '₹$total',
                                style: const TextStyle(
                                  color: AppTheme.success,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'from ${payments.length} payer${payments.length == 1 ? '' : 's'}',
                                style: AppTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Table header
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: Text('DATE',
                                      style: AppTheme.label)),
                              Expanded(
                                  flex: 3,
                                  child: Text('FROM',
                                      style: AppTheme.label)),
                              Expanded(
                                  flex: 2,
                                  child: Text('AMOUNT',
                                      textAlign: TextAlign.right,
                                      style: AppTheme.label)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Records
                        ...payments.map((item) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppTheme.bgCard,
                              borderRadius: BorderRadius.circular(
                                  AppTheme.radiusMd),
                              border: AppTheme.subtleBorder,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    formatDate(item['transaction_time']),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textMuted),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    item['from'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "₹${item['amount']}",
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: AppTheme.success,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
