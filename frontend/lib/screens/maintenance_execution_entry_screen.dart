import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/execution_models.dart';

import '../services/firestore_execution_service.dart';
import '../services/firestore_order_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../l10n/app_localizations.dart';
import 'execution_flow_screen.dart';

class MaintenanceExecutionEntryScreen extends StatefulWidget {
  final String? initialEquipmentCode;
  final String? initialQrPayload;

  const MaintenanceExecutionEntryScreen({
    super.key,
    this.initialEquipmentCode,
    this.initialQrPayload,
  });

  @override
  State<MaintenanceExecutionEntryScreen> createState() =>
      _MaintenanceExecutionEntryScreenState();
}

class _MaintenanceExecutionEntryScreenState
    extends State<MaintenanceExecutionEntryScreen> {
  final _codeController = TextEditingController();
  int _step = 0;
  bool _isLoading = false;
  String? _error;
  ExecutionLookupResponse? _lookup;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialEquipmentCode != null &&
        widget.initialEquipmentCode!.isNotEmpty) {
      _codeController.text = widget.initialEquipmentCode!;
      WidgetsBinding.instance.addPostFrameCallback((_) => _lookupByCode());
    } else if (widget.initialQrPayload != null &&
        widget.initialQrPayload!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _lookupByQr(widget.initialQrPayload!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDarkTheme
          : AppColors.backgroundLight,
      appBar: AppBar(title: Text(l10n.maintenanceExecutionTitle)),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _buildStep(context, isDark, l10n),
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, bool isDark, AppLocalizations l10n) {
    switch (_step) {
      case 0:
        return _entryStep(isDark, l10n);
      case 1:
        return _scanStep(isDark, l10n);
      case 2:
        return _successStep(isDark, l10n);
      default:
        return _errorStep(isDark, l10n);
    }
  }

  Widget _entryStep(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.maintenanceExecutionStartTitle,
            style: AppTypography.headline3.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.maintenanceExecutionEntrySubtitle,
            style: AppTypography.bodyText.copyWith(
              color: isDark ? AppColors.slate300 : AppColors.slate600,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _codeController,
            decoration: InputDecoration(
              labelText: l10n.equipmentCodeLabel,
              hintText: l10n.equipmentCodeHint,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _isLoading ? null : _lookupByCode,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.lookupOrderButton),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Divider(color: AppColors.slate300.withOpacity(0.4)),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.orDivider,
                style: AppTypography.caption.copyWith(
                  color: isDark ? AppColors.slate400 : AppColors.slate500,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Divider(color: AppColors.slate300.withOpacity(0.4)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _isLoading ? null : () => setState(() => _step = 1),
            icon: const Icon(Icons.qr_code_scanner),
            label: Text(l10n.scanQrCodeButton),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              _error!,
              style: AppTypography.caption.copyWith(color: AppColors.danger),
            ),
          ],
        ],
      ),
    );
  }

  Widget _scanStep(bool isDark, AppLocalizations l10n) {
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
                  if (value != null && value.isNotEmpty && !_isLoading) {
                    _lookupByQr(value);
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
                l10n.alignQrInstruction,
                style: AppTypography.bodyTextSmall.copyWith(
                  color: isDark ? AppColors.slate300 : AppColors.slate600,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => setState(() => _step = 0),
                child: Text(l10n.typeCodeButton),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _successStep(bool isDark, AppLocalizations l10n) {
    final equipmentName = _lookup?.equipmentName ?? l10n.equipmentLabel;
    final equipmentCode = _lookup?.equipmentCode ?? '-';
    final orderId = _lookup?.maintenanceOrderId;
    final orderStatus = _formatStatus(_lookup?.maintenanceOrderStatus, l10n);
    final clientName = _lookup?.clientName ?? '-';
    final scheduledFor = _formatScheduledFor(_lookup?.scheduledFor, l10n);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
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
            l10n.orderFoundTitle,
            style: AppTypography.headline3.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$equipmentName • $equipmentCode',
            style: AppTypography.bodyText.copyWith(
              color: isDark ? AppColors.slate300 : AppColors.slate600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.slate800 : AppColors.slate100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  l10n.orderNumberLabel(orderId?.toString() ?? '-'),
                  style: AppTypography.bodyText.copyWith(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  orderStatus,
                  style: AppTypography.caption.copyWith(
                    color: isDark ? AppColors.slate300 : AppColors.slate600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.clientLabel(clientName),
                  style: AppTypography.caption.copyWith(
                    color: isDark ? AppColors.slate300 : AppColors.slate600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.scheduledForLabel(scheduledFor),
                  style: AppTypography.caption.copyWith(
                    color: isDark ? AppColors.slate300 : AppColors.slate600,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _startExecutionFlow,
            child: Text(l10n.goToChecklistButton),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => setState(() {
              _lookup = null;
              _step = 0;
            }),
            child: Text(l10n.searchAnotherEquipmentButton),
          ),
        ],
      ),
    );
  }

  Widget _errorStep(bool isDark, AppLocalizations l10n) {
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
            l10n.orderNotFoundTitle,
            style: AppTypography.headline3.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? l10n.tryAnotherCode,
            textAlign: TextAlign.center,
            style: AppTypography.bodyText.copyWith(
              color: isDark ? AppColors.slate300 : AppColors.slate600,
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () => setState(() => _step = 0),
            child: Text(l10n.tryAgainButton),
          ),
        ],
      ),
    );
  }

  Future<void> _lookupByCode() async {
    final l10n = AppLocalizations.of(context)!;
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _error = l10n.equipmentCodeRequiredError);
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final orderId = _parseOrderId(code);
      if (orderId != null) {
        final resolved = await _lookupByOrderId(orderId);
        if (resolved) return;
      }
      final response = await FirestoreExecutionService.lookupExecution(
        equipmentCode: code.toUpperCase(),
      );
      if (!mounted) return;
      setState(() {
        _lookup = response;
        _step = 2;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = l10n.orderNotFoundError;
        _step = 3;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _lookupByQr(String payload) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await FirestoreExecutionService.lookupExecution(
        qrCodePayload: payload,
      );
      if (!mounted) return;
      setState(() {
        _lookup = response;
        _step = 2;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = l10n.qrNotRecognizedError;
        _step = 3;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _parseOrderId(String input) {
    final normalized = input.trim();
    if (normalized.toUpperCase().startsWith('SO-')) {
      return normalized.substring(3);
    }
    // Allow any non-empty string as ID if it doesn't have spaces?
    // Firestore IDs are usually 20 chars alphanumeric.
    if (normalized.isNotEmpty && !normalized.contains(' ')) {
      return normalized;
    }
    return null;
  }

  Future<bool> _lookupByOrderId(String orderId) async {
    try {
      final order = await FirestoreOrderService.getById(id: orderId);
      final qrPayload = order.equipamento.qrCode.trim();
      if (qrPayload.isNotEmpty) {
        final response = await FirestoreExecutionService.lookupExecution(
          qrCodePayload: qrPayload,
        );
        if (!mounted) return false;
        setState(() {
          _lookup = response;
          _step = 2;
        });
        return true;
      }
      final equipmentCode = order.equipamento.codigo.trim();
      if (equipmentCode.isNotEmpty) {
        final response = await FirestoreExecutionService.lookupExecution(
          equipmentCode: equipmentCode,
        );
        if (!mounted) return false;
        setState(() {
          _lookup = response;
          _step = 2;
        });
        return true;
      }
    } catch (_) {}
    return false;
  }

  void _startExecutionFlow() {
    final data = _lookup;
    if (data == null) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ExecutionFlowScreen(
          orderId: data.maintenanceOrderId,
          qrPayload: data.qrCodePayload,
          equipmentTitle: data.equipmentName,
          orderType: 'MANUTENCAO',
        ),
      ),
    );
  }

  String _formatStatus(String? raw, AppLocalizations l10n) {
    switch (raw) {
      case 'EM_ANDAMENTO':
        return l10n.statusInProgress;
      case 'FINALIZADA':
        return l10n.statusFinished;
      case 'ATRASADA':
        return l10n.statusOverdue;
      case 'CANCELADA':
        return l10n.statusCancelled;
      case 'ABERTA':
        return l10n.statusOpen;
      default:
        return l10n.statusUnavailable;
    }
  }

  String _formatScheduledFor(String? raw, AppLocalizations l10n) {
    if (raw == null || raw.isEmpty) return l10n.scheduledNotDefined;
    try {
      final date = DateTime.parse(raw);
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$day/$month/$year $hour:$minute';
    } catch (_) {
      return raw;
    }
  }
}

extension IterableExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
