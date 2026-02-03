import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'execution_flow_screen.dart';

class QRFlowScreen extends StatefulWidget {
  final int? orderId;
  final String? equipmentTitle;

  const QRFlowScreen({super.key, this.orderId, this.equipmentTitle});

  @override
  State<QRFlowScreen> createState() => _QRFlowScreenState();
}

class _QRFlowScreenState extends State<QRFlowScreen> {
  int _step = 0;
  String? _payload;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDarkTheme : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('QR Code'),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _buildStep(context, isDark),
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, bool isDark) {
    switch (_step) {
      case 0:
        return _permissionStep(isDark);
      case 1:
        return _scanStep(isDark);
      case 2:
        return _successStep(isDark);
      default:
        return _errorStep(isDark);
    }
  }

  Widget _permissionStep(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: isDark ? AppColors.slate800 : AppColors.slate100,
              borderRadius: BorderRadius.circular(24),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: AppColors.shadow.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: const Icon(Icons.qr_code_scanner,
                size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text(
            'Camera access required',
            style: AppTypography.headline3.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Enable camera to scan equipment QR codes and start maintenance.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyText.copyWith(
              color: isDark ? AppColors.slate300 : AppColors.slate600,
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () => setState(() => _step = 1),
            child: const Text('Allow Camera'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Not now'),
          ),
        ],
      ),
    );
  }

  Widget _scanStep(bool isDark) {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: AppColors.shadow.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: MobileScanner(
                onDetect: (capture) {
                  final barcode = capture.barcodes.firstOrNull;
                  final value = barcode?.rawValue;
                  if (value != null && value.isNotEmpty) {
                    setState(() {
                      _payload = value;
                      _step = 2;
                    });
                  }
                },
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            children: [
              Text(
                'Align the QR code within the frame',
                style: AppTypography.bodyTextSmall.copyWith(
                  color: isDark ? AppColors.slate300 : AppColors.slate600,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => setState(() => _step = 3),
                child: const Text('Simulate unrecognized'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _successStep(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.statusCompletedBg,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.check_circle,
              size: 56,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Equipment identified',
            style: AppTypography.headline3.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.equipmentTitle ?? 'Industrial HVAC Unit',
            style: AppTypography.bodyText.copyWith(
              color: isDark ? AppColors.slate300 : AppColors.slate600,
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              if (widget.orderId == null) {
                _askForOrderId();
                return;
              }
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ExecutionFlowScreen(
                    orderId: widget.orderId,
                    qrPayload: _payload,
                    equipmentTitle: widget.equipmentTitle,
                  ),
                ),
              );
            },
            child: const Text('Start Maintenance'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => setState(() => _step = 1),
            child: const Text('Scan another'),
          ),
        ],
      ),
    );
  }

  Widget _errorStep(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.statusFailedBg,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 56,
              color: AppColors.danger,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Unrecognized code',
            style: AppTypography.headline3.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try scanning again or search for the equipment manually.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyText.copyWith(
              color: isDark ? AppColors.slate300 : AppColors.slate600,
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () => setState(() => _step = 1),
            child: const Text('Try scanning again'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to orders'),
          ),
        ],
      ),
    );
  }

  Future<void> _askForOrderId() async {
    final controller = TextEditingController();
    final orderId = await showDialog<int?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Order ID'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Order ID'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final id = int.tryParse(controller.text);
                Navigator.pop(context, id);
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );

    if (orderId == null) return;
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ExecutionFlowScreen(
          orderId: orderId,
          qrPayload: _payload,
          equipmentTitle: widget.equipmentTitle,
        ),
      ),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
