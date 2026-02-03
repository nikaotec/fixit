import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:signature/signature.dart';

import '../models/execution_models.dart';
import '../providers/user_provider.dart';
import '../services/device_service.dart';
import '../services/execution_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class ExecutionFlowScreen extends StatefulWidget {
  final int? orderId;
  final String? qrPayload;
  final String? equipmentTitle;

  const ExecutionFlowScreen({
    super.key,
    this.orderId,
    this.qrPayload,
    this.equipmentTitle,
  });

  @override
  State<ExecutionFlowScreen> createState() => _ExecutionFlowScreenState();
}

class _ExecutionFlowScreenState extends State<ExecutionFlowScreen> {
  final _orderIdController = TextEditingController();
  final _signatureController = SignatureController(
    penStrokeWidth: 4,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  bool _isStarting = false;
  bool _isFinalizing = false;
  String? _qrPayload;
  ExecutionStartResponse? _execution;
  bool _autoStarted = false;

  final Map<int, bool> _itemStatus = {};
  final Map<int, int> _executionItemIds = {};
  final Map<int, TextEditingController> _observations = {};
  final Map<int, bool> _uploadingEvidence = {};

  @override
  void dispose() {
    _orderIdController.dispose();
    _signatureController.dispose();
    for (final controller in _observations.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_autoStarted && widget.orderId != null && widget.qrPayload != null) {
      _orderIdController.text = widget.orderId.toString();
      _qrPayload = widget.qrPayload;
      _autoStarted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _startExecution());
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Execution'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_execution == null) _buildStartCard(isDark),
            const SizedBox(height: 16),
            if (_execution != null) ...[
              _buildExecutionHeader(isDark),
              const SizedBox(height: 16),
              _buildChecklist(isDark),
              const SizedBox(height: 20),
              _buildSignatureSection(isDark),
              const SizedBox(height: 12),
              _buildFinalizeButton(),
              const SizedBox(height: 16),
              _buildReportButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStartCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkTheme : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDefaultDark : AppColors.borderLight,
        ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.qr_code_scanner, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Start Maintenance',
                  style: AppTypography.headline3.copyWith(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _orderIdController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Order ID',
              hintText: 'Ex: 123',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showScanner,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan QR'),
                ),
              ),
            ],
          ),
          if (_qrPayload != null) ...[
            const SizedBox(height: 8),
            Text(
              'QR captured',
              style: AppTypography.captionSmall.copyWith(
                color: isDark ? AppColors.slate300 : AppColors.slate600,
              ),
            ),
          ],
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _isStarting ? null : _startExecution,
            icon: _isStarting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow),
            label: Text(_isStarting ? 'Starting...' : 'Start'),
          ),
        ],
      ),
    );
  }

  Widget _buildExecutionHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkTheme : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDefaultDark : AppColors.borderLight,
        ),
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
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isDark ? AppColors.slate800 : AppColors.slate100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? AppColors.slate700 : AppColors.slate200,
              ),
            ),
            child: const Icon(Icons.build, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.equipmentTitle ?? 'Equipment',
                  style: AppTypography.bodyText.copyWith(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Execution #${_execution?.executionId ?? '-'}',
                  style: AppTypography.captionSmall.copyWith(
                    color: isDark ? AppColors.slate300 : AppColors.slate600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.statusInProgressBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'In Progress',
              style: AppTypography.captionSmall.copyWith(
                color: AppColors.statusInProgressText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklist(bool isDark) {
    final items = _execution!.checklistItems;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkTheme : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDefaultDark : AppColors.borderLight,
        ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Maintenance Checklist',
            style: AppTypography.headline3.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          for (final item in items) _buildChecklistItem(item, isDark),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(ExecutionChecklistItem item, bool isDark) {
    final observationController = _observations.putIfAbsent(
      item.id,
      () => TextEditingController(),
    );
    final uploading = _uploadingEvidence[item.id] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate800 : AppColors.slate50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.slate700 : AppColors.slate200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            item.descricao,
            style: AppTypography.bodyText.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _itemStatus[item.id] = true),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: (_itemStatus[item.id] ?? false)
                          ? AppColors.success
                          : (isDark ? AppColors.slate600 : AppColors.slate300),
                    ),
                    backgroundColor: (_itemStatus[item.id] ?? false)
                        ? AppColors.statusCompletedBg
                        : Colors.transparent,
                  ),
                  child: Text(
                    'Pass',
                    style: TextStyle(
                      color: (_itemStatus[item.id] ?? false)
                          ? AppColors.statusCompletedText
                          : (isDark ? AppColors.slate200 : AppColors.slate600),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _itemStatus[item.id] = false),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: (_itemStatus[item.id] ?? false)
                          ? (isDark ? AppColors.slate600 : AppColors.slate300)
                          : AppColors.danger,
                    ),
                    backgroundColor: (_itemStatus[item.id] ?? false)
                        ? Colors.transparent
                        : AppColors.statusFailedBg,
                  ),
                  child: Text(
                    'Fail',
                    style: TextStyle(
                      color: (_itemStatus[item.id] ?? false)
                          ? (isDark ? AppColors.slate200 : AppColors.slate600)
                          : AppColors.statusFailedText,
                    ),
                  ),
                ),
              ),
            ],
          ),
          TextField(
            controller: observationController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Observation (optional)',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _saveItem(item),
                  child: const Text('Save item'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: uploading ? null : () => _addEvidence(item),
                  icon: uploading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.camera_alt),
                  label: Text(item.obrigatorioFoto ? 'Evidence *' : 'Evidence'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String valLabel(ExecutionChecklistItem item, bool status) {
    if (status) {
      return item.critico ? 'Conforme (critico)' : 'Conforme';
    }
    return item.critico ? 'Nao conforme (critico)' : 'Nao conforme';
  }

  Widget _buildSignatureSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkTheme : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDefaultDark : AppColors.borderLight,
        ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Digital Signature',
            style: AppTypography.headline3.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.slate200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Signature(
              controller: _signatureController,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _signatureController.clear(),
              icon: const Icon(Icons.clear),
              label: const Text('Clear'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalizeButton() {
    return ElevatedButton.icon(
      onPressed: _isFinalizing ? null : _finalizeExecution,
      icon: _isFinalizing
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.check),
      label: Text(_isFinalizing ? 'Finalizing...' : 'Finalize'),
    );
  }

  Widget _buildReportButton() {
    return OutlinedButton.icon(
      onPressed: _downloadReport,
      icon: const Icon(Icons.picture_as_pdf),
      label: const Text('Download PDF Report'),
    );
  }

  Future<void> _showScanner() async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 420,
            child: Column(
              children: [
                Expanded(
                  child: MobileScanner(
                    onDetect: (capture) {
                      final barcode = capture.barcodes.firstOrNull;
                      final value = barcode?.rawValue;
                      if (value != null && value.isNotEmpty) {
                        setState(() => _qrPayload = value);
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _startExecution() async {
    final token = Provider.of<UserProvider>(context, listen: false).token;
    if (token == null) {
      _showSnack('User not authenticated');
      return;
    }

    final orderId = int.tryParse(_orderIdController.text);
    if (orderId == null || _qrPayload == null) {
      _showSnack('Provide order id and scan QR');
      return;
    }

    setState(() => _isStarting = true);
    try {
      final position = await _getPosition();
      final deviceId = await DeviceService.getDeviceId();
      final response = await ExecutionService.startExecution(
        token: token,
        maintenanceOrderId: orderId,
        qrCodePayload: _qrPayload!,
        deviceId: deviceId,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
      );

      setState(() {
        _execution = response;
      });
    } catch (e) {
      _showSnack(e.toString());
    } finally {
      setState(() => _isStarting = false);
    }
  }

  Future<void> _saveItem(ExecutionChecklistItem item) async {
    final token = Provider.of<UserProvider>(context, listen: false).token;
    if (token == null || _execution == null) return;

    final status = _itemStatus[item.id] ?? false;
    final observation = _observations[item.id]?.text;

    try {
      final response = await ExecutionService.recordItem(
        token: token,
        executionId: _execution!.executionId,
        checklistItemId: item.id,
        status: status,
        observation: observation,
      );
      setState(() {
        _executionItemIds[item.id] = response.id;
      });
      _showSnack('Item saved');
    } catch (e) {
      _showSnack(e.toString());
    }
  }

  Future<void> _addEvidence(ExecutionChecklistItem item) async {
    final token = Provider.of<UserProvider>(context, listen: false).token;
    if (token == null || _execution == null) return;

    final execItemId = _executionItemIds[item.id];
    if (execItemId == null) {
      _showSnack('Save the item before attaching evidence');
      return;
    }

    final picker = ImagePicker();
    final photo = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (photo == null) return;

    setState(() => _uploadingEvidence[item.id] = true);
    try {
      final bytes = await photo.readAsBytes();
      await ExecutionService.uploadEvidence(
        token: token,
        checklistExecutionItemId: execItemId,
        fileBytes: bytes,
        fileName: photo.name,
        mimeType: 'image/jpeg',
      );
      _showSnack('Evidence uploaded');
    } catch (e) {
      _showSnack(e.toString());
    } finally {
      setState(() => _uploadingEvidence[item.id] = false);
    }
  }

  Future<void> _finalizeExecution() async {
    if (_execution == null) return;
    if (_signatureController.isEmpty) {
      _showSnack('Signature required');
      return;
    }

    final token = Provider.of<UserProvider>(context, listen: false).token;
    if (token == null) return;

    setState(() => _isFinalizing = true);
    try {
      final signatureBytes = await _signatureController.toPngBytes();
      if (signatureBytes == null) {
        _showSnack('Failed to generate signature');
        return;
      }
      final base64Signature = base64Encode(signatureBytes);

      await ExecutionService.finalizeExecution(
        token: token,
        executionId: _execution!.executionId,
        signatureBase64: base64Signature,
      );
      _showSnack('Execution finalized');
    } catch (e) {
      _showSnack(e.toString());
    } finally {
      setState(() => _isFinalizing = false);
    }
  }

  Future<void> _downloadReport() async {
    final token = Provider.of<UserProvider>(context, listen: false).token;
    if (token == null || _execution == null) return;

    try {
      final bytes = await ExecutionService.downloadReport(
        token: token,
        executionId: _execution!.executionId,
      );

      await Share.shareXFiles([
        XFile.fromData(
          bytes,
          name: 'execucao-${_execution!.executionId}.pdf',
          mimeType: 'application/pdf',
        ),
      ]);
    } catch (e) {
      _showSnack(e.toString());
    }
  }

  Future<Position> _getPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location disabled');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied');
    }

    return Geolocator.getCurrentPosition();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
