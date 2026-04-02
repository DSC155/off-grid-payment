import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'theme.dart';

const MethodChannel _networkChannel = MethodChannel('network/bind');

Future<void> bindToWifi() async {
  try {
    await _networkChannel.invokeMethod('bindToWifi');
    debugPrint("Network bind successful");
  } catch (e) {
    debugPrint("Bind Error: $e");
  }
}

class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  final MobileScannerController controller = MobileScannerController();

  bool _scanned = false;
  String status = "Point camera at a hotspot QR code";
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.location.request();
  }

  Map<String, String> _parseWifiQr(String qr) {
    final ssid = RegExp(r'S:([^;]+)').firstMatch(qr)?.group(1) ?? '';
    final password = RegExp(r'P:([^;]+)').firstMatch(qr)?.group(1) ?? '';
    final type = RegExp(r'T:([^;]+)').firstMatch(qr)?.group(1) ?? 'WPA';
    final ip = RegExp(r'IP:([^;]+)').firstMatch(qr)?.group(1) ?? '';
    return {"ssid": ssid, "password": password, "type": type, "server_ip": ip};
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_scanned) return;
    final code = capture.barcodes.first.rawValue;
    if (code == null) return;

    setState(() {
      _scanned = true;
      _isConnecting = true;
      status = "QR detected — connecting...";
    });

    final wifi = _parseWifiQr(code);

    try {
      await WiFiForIoTPlugin.connect(
        wifi["ssid"]!,
        password: wifi["password"],
        security:
            wifi["type"] == "WEP" ? NetworkSecurity.WEP : NetworkSecurity.WPA,
        joinOnce: true,
      );

      bool connected = false;
      String? deviceIp;

      for (int i = 0; i < 12; i++) {
        deviceIp = await WiFiForIoTPlugin.getIP();
        if (deviceIp != null &&
            deviceIp.isNotEmpty &&
            deviceIp != "0.0.0.0") {
          connected = true;
          break;
        }
        await Future.delayed(const Duration(seconds: 1));
      }

      if (!connected) {
        setState(() {
          status = "Could not connect. Try again.";
          _scanned = false;
          _isConnecting = false;
        });
        return;
      }

      setState(() => status = "Binding network...");
      await bindToWifi();
      setState(() {
        status = "Connected & Ready!";
        _isConnecting = false;
      });

      String returnIp =
          wifi["server_ip"]!.isNotEmpty ? wifi["server_ip"]! : deviceIp!;

      Navigator.of(context).pop(returnIp);
    } catch (e) {
      setState(() {
        status = "Error: $e";
        _scanned = false;
        _isConnecting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────
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
                    'Scan QR Code',
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

            // ── Scanner ──────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      MobileScanner(onDetect: _onDetect),
                      // Overlay frame
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppTheme.primary,
                            width: 2.5,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Status ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.bgCard,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(
                    color: _isConnecting
                        ? AppTheme.primary.withOpacity(0.3)
                        : status.contains('Ready')
                            ? AppTheme.success.withOpacity(0.3)
                            : status.contains('Error') ||
                                    status.contains('not connect')
                                ? AppTheme.danger.withOpacity(0.3)
                                : const Color(0xFF2A2A2E),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isConnecting)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: AppTheme.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    if (_isConnecting) const SizedBox(width: 12),
                    Icon(
                      status.contains('Ready')
                          ? Icons.check_circle_rounded
                          : status.contains('Error') ||
                                  status.contains('not connect')
                              ? Icons.error_rounded
                              : Icons.qr_code_scanner_rounded,
                      size: 18,
                      color: status.contains('Ready')
                          ? AppTheme.success
                          : status.contains('Error') ||
                                  status.contains('not connect')
                              ? AppTheme.danger
                              : AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        status,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: status.contains('Ready')
                              ? AppTheme.success
                              : status.contains('Error') ||
                                      status.contains('not connect')
                                  ? AppTheme.danger
                                  : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
