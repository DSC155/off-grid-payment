import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'pay_to_friend_page.dart';
import 'scan.dart';
import 'profile.dart';
import 'pay_to_shop_page.dart';
import 'recive_page.dart';
import 'add_funds.dart';
import 'theme.dart';
import 'widgets.dart';

final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  String? connectedIp;
  String username = '';
  double balance = 0.0;

  final List<Map<String, dynamic>> transactions = [];
  final currencyFormatter =
      NumberFormat.currency(locale: "en_IN", symbol: "₹");

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final storedUsername = await secureStorage.read(key: 'user_username');
    if (storedUsername != null && storedUsername.isNotEmpty) {
      setState(() => username = storedUsername);
    }
  }

  bool _validateIp(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) return false;
    for (var p in parts) {
      final n = int.tryParse(p);
      if (n == null || n < 0 || n > 255) return false;
    }
    return true;
  }

  // ──────────────────────────────────────────────────────────
  // FUNDS & TRANSFER LOGIC
  // ──────────────────────────────────────────────────────────
  Future<void> _navigateToAddFunds() async {
    final added = await Navigator.push<double>(
      context,
      MaterialPageRoute(builder: (context) => const AddFundsPage()),
    );

    if (added != null && added > 0) {
      setState(() {
        balance += added;
        transactions.insert(0, {
          'name': 'Added Funds',
          'method': 'Top-up',
          'amount': added,
          'type': 'receive',
        });
      });

      _showSnack("₹${added.toStringAsFixed(2)} added to wallet", isSuccess: true);
    }
  }

  void _showSnack(String msg, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: isSuccess ? AppTheme.success : AppTheme.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // SEND BOTTOM SHEET
  // ──────────────────────────────────────────────────────────
  void _showSendOptions() {
    if (connectedIp == null) {
      _showSnack("Please connect to a device first.");
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text("Send Money", style: AppTheme.heading2),
              const SizedBox(height: 6),
              const Text('Select recipient type',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
              const SizedBox(height: 24),

              // Option 1
              _paymentOptionCard(
                icon: Icons.person_rounded,
                iconColor: AppTheme.primary,
                title: "To Friend",
                subtitle: "Direct hotspot transfer",
                onTap: () async {
                  Navigator.pop(context);
                  final sentAmount = await Navigator.push<double>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PayToFriendPage(
                          ipAddress: connectedIp!, senderUsername: username),
                    ),
                  );
                  if (sentAmount != null && sentAmount > 0) {
                    setState(() {
                      balance -= sentAmount;
                      transactions.insert(0, {
                        'name': 'Sent to Friend',
                        'method': 'Offline transfer',
                        'amount': sentAmount,
                        'type': 'send',
                      });
                    });
                    _showSnack("₹$sentAmount sent successfully", isSuccess: true);
                  }
                },
              ),
              const SizedBox(height: 12),

              // Option 2
              _paymentOptionCard(
                icon: Icons.storefront_rounded,
                iconColor: AppTheme.accentCool,
                title: "To Shop",
                subtitle: "Merchant payment via hotspot",
                onTap: () async {
                  Navigator.pop(context);
                  final sentAmount = await Navigator.push<double>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PayToShopPage(
                        ipAddress: connectedIp!,
                        senderUsername: username,
                      ),
                    ),
                  );
                  if (sentAmount != null && sentAmount > 0) {
                    setState(() {
                      balance -= sentAmount;
                      transactions.insert(0, {
                        'name': 'Paid at Shop',
                        'method': 'Offline merchant',
                        'amount': sentAmount,
                        'type': 'send',
                      });
                    });
                    _showSnack("₹$sentAmount paid!", isSuccess: true);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper inside Portfolio to get fallback colors since AppTheme doesn't have primaryListColor
  Color get _primaryColor => AppTheme.primary;

  Widget _paymentOptionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: AppTheme.subtleBorder,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppTheme.textMuted.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // IP CONNECTION DIALOG
  // ──────────────────────────────────────────────────────────
  void _showEditIpDialog() {
    final a = TextEditingController();
    final b = TextEditingController();
    final c = TextEditingController();
    final d = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.bgSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Connect Hotspot IP", style: AppTheme.heading3),
              const SizedBox(height: 6),
              const Text("Enter the manual IP address to connect",
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ipBox(a),
                  const Text('.', style: TextStyle(color: AppTheme.textMuted, fontSize: 20)),
                  _ipBox(b),
                  const Text('.', style: TextStyle(color: AppTheme.textMuted, fontSize: 20)),
                  _ipBox(c),
                  const Text('.', style: TextStyle(color: AppTheme.textMuted, fontSize: 20)),
                  _ipBox(d),
                ],
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                label: 'Connect',
                height: 48,
                onTap: () {
                  final ip = "${a.text}.${b.text}.${c.text}.${d.text}";
                  if (_validateIp(ip)) {
                    setState(() => connectedIp = ip);
                    Navigator.of(context).pop();
                  } else {
                    _showSnack("Invalid IP format");
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ipBox(TextEditingController c) {
    return Container(
      width: 48,
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppTheme.bgInput,
        borderRadius: BorderRadius.circular(8),
        border: AppTheme.subtleBorder,
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: c,
        maxLength: 3,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold),
        cursorColor: AppTheme.primary,
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // BUILD
  // ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isConnected = connectedIp != null;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── APP BAR & PROFILE ─────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    // Avatar
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfilePage()),
                      ),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.bgElevated,
                          border: AppTheme.subtleBorder,
                        ),
                        child: const Icon(Icons.person_rounded,
                            color: AppTheme.primaryLight, size: 24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Greeting text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Good day,',
                              style: TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 13)),
                          Text(username.isEmpty ? 'My Wallet' : username,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.3,
                              )),
                        ],
                      ),
                    ),
                    // Connection Pill
                    GestureDetector(
                      onTap: _showEditIpDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isConnected
                              ? AppTheme.success.withOpacity(0.12)
                              : AppTheme.bgElevated,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isConnected
                                ? AppTheme.success.withOpacity(0.25)
                                : const Color(0xFF2A2A2E),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    isConnected ? AppTheme.success : AppTheme.danger,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isConnected ? "Connected" : "Offline",
                              style: TextStyle(
                                color: isConnected
                                    ? AppTheme.success
                                    : AppTheme.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // QR Scan Icon
                    GestureDetector(
                      onTap: () async {
                        final ip = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const QrScanPage()),
                        );
                        if (ip != null && ip is String && _validateIp(ip)) {
                          setState(() => connectedIp = ip);
                        }
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.bgElevated,
                          shape: BoxShape.circle,
                          border: AppTheme.subtleBorder,
                        ),
                        child: const Icon(Icons.qr_code_scanner_rounded,
                            color: AppTheme.textSecondary, size: 18),
                      ),
                    )
                  ],
                ),
              ),
            ),

            // ── BALANCE CARD ──────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: GlassCard(
                  padding: const EdgeInsets.all(24),
                  color: const Color(0xFF161618), // Slightly tinted card
                  border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                  shadows: AppTheme.glowPurple,
                  child: Stack(
                    children: [
                      // bg blob
                      Positioned(
                        right: -40,
                        top: -40,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppTheme.primary.withOpacity(0.15),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Balance', style: AppTheme.bodySmall),
                              // Visa-like logo
                              Text('DHARPAY',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.3),
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2,
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  )),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            currencyFormatter.format(balance),
                            style: AppTheme.displayLarge,
                          ),
                          const SizedBox(height: 24),
                          // Card details line
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '• • • •   • • • •   8149',
                                style: TextStyle(
                                  color: AppTheme.textSecondary.withOpacity(0.8),
                                  fontSize: 15,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const StatusBadge(
                                  label: 'ACTIVE', color: AppTheme.success),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── ACTION GRID ───────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    QuickActionButton(
                      icon: Icons.add_rounded,
                      label: 'Top Up',
                      iconColor: AppTheme.accentCool,
                      onTap: _navigateToAddFunds,
                    ),
                    QuickActionButton(
                      icon: Icons.arrow_upward_rounded,
                      label: 'Send',
                      iconColor: AppTheme.primaryLight,
                      onTap: _showSendOptions,
                    ),
                    QuickActionButton(
                      icon: Icons.arrow_downward_rounded,
                      label: 'Request',
                      iconColor: AppTheme.success,
                      onTap: () async {
                        if (connectedIp != null && username.isNotEmpty) {
                          final receivedAmount = await Navigator.push<double>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReceivePaymentPage(
                                  ipAddress: connectedIp!, username: username),
                            ),
                          );

                          if (receivedAmount != null && receivedAmount > 0) {
                            setState(() {
                              balance += receivedAmount;
                              transactions.insert(0, {
                                'name': 'Received inline',
                                'method': 'Hotspot connection',
                                'amount': receivedAmount,
                                'type': 'receive'
                              });
                            });
                            _showSnack("₹$receivedAmount received!", isSuccess: true);
                          }
                        } else {
                          _showSnack("Connect to a device first!");
                        }
                      },
                    ),
                    QuickActionButton(
                      icon: Icons.more_horiz_rounded,
                      label: 'More',
                      iconColor: AppTheme.textSecondary,
                      onTap: () {
                        // Empty for now
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ── TRANSACTIONS HEADER ───────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 32, 20, 16),
                child: Text('Recent Transactions', style: AppTheme.heading3),
              ),
            ),

            // ── TRANSACTIONS LIST ─────────────────────────────
            transactions.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        height: 160,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white.withOpacity(0.05),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.receipt_long_rounded,
                                size: 40, color: AppTheme.textMuted),
                            const SizedBox(height: 12),
                            Text('No transactions yet',
                                style:
                                    TextStyle(color: AppTheme.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final txn = transactions[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 6),
                          child: _txnItem(txn['name'], txn['method'],
                              txn['amount'], txn['type']),
                        );
                      },
                      childCount: transactions.length,
                    ),
                  ),

            // ── BOTTOM PADDING ─────────────────────────────────
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // TRANSACTION WIDGET
  // ──────────────────────────────────────────────────────────
  Widget _txnItem(String name, String method, double amount, String type) {
    final bool isSend = type == 'send';
    final Color color = isSend ? AppTheme.textPrimary : AppTheme.success;
    final IconData icon =
        isSend ? Icons.arrow_outward_rounded : Icons.south_west_rounded;
    final Color iconColor = isSend ? AppTheme.textPrimary : AppTheme.success;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.bgElevated,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
                const SizedBox(height: 4),
                Text(method,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          Text(
            '${isSend ? '-' : '+'}${currencyFormatter.format(amount)}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
