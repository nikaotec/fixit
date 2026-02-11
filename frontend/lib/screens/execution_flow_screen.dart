import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'dashboard_screen.dart';

import 'package:image_picker/image_picker.dart';

import '../models/execution_models.dart';
import '../models/local_photo.dart';
import '../l10n/app_localizations.dart';

import '../services/device_service.dart';
import '../services/firestore_execution_service.dart';
import '../services/firestore_helper.dart';
import '../services/speech_service.dart';
import '../services/voice_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'execution_review_screen.dart';
import 'execution_report_preview_screen.dart';

class ExecutionFlowScreen extends StatefulWidget {
  final String? orderId;
  final String? qrPayload;
  final String? equipmentTitle;
  final String? orderType;

  const ExecutionFlowScreen({
    super.key,
    this.orderId,
    this.qrPayload,
    this.equipmentTitle,
    this.orderType,
  });

  @override
  State<ExecutionFlowScreen> createState() => _ExecutionFlowScreenState();
}

class _ExecutionFlowScreenState extends State<ExecutionFlowScreen> {
  final _orderIdController = TextEditingController();
  final _serviceDescriptionController = TextEditingController();
  final SpeechService _speechService = SpeechService();
  bool _listeningService = false;
  bool _speechAvailable = true;
  bool _checkedSpeech = false;
  String _serviceBaseText = '';
  String _serviceLocale = 'pt_BR';
  String _servicePartial = '';

  bool _isStarting = false;
  String? _qrPayload;
  ExecutionStartResponse? _execution;
  bool _autoStarted = false;
  bool _isFinalized = false;
  StreamSubscription? _ordersSub;

  final Map<String, bool> _itemStatus = {};
  final Map<String, TextEditingController> _observations = {};
  final Map<String, List<LocalPhoto>> _pendingEvidence = {};
  bool _loadedLocale = false;

  @override
  void dispose() {
    _orderIdController.dispose();
    _serviceDescriptionController.dispose();
    for (final controller in _observations.values) {
      controller.dispose();
    }
    _ordersSub?.cancel();
    super.dispose();
  }

  Future<void> _toggleServiceDictation() async {
    final l10n = AppLocalizations.of(context);
    final available = await _speechService.ensureInitialized();
    if (!available) {
      _showSnack(l10n?.voiceNotAvailable ?? 'Entrada de voz indisponível');
      return;
    }
    if (_speechService.isListening) {
      await _speechService.stop();
      if (mounted) setState(() => _listeningService = false);
      return;
    }
    _serviceBaseText = _serviceDescriptionController.text.trim();
    if (mounted) setState(() => _listeningService = true);
    await _speechService.start(
      localeId: _serviceLocale,
      onResult: (words, isFinal) {
        final prefix = _serviceBaseText.isEmpty ? '' : '$_serviceBaseText ';
        _serviceDescriptionController.text = '$prefix$words';
        _serviceDescriptionController.selection = TextSelection.fromPosition(
          TextPosition(offset: _serviceDescriptionController.text.length),
        );
        if (mounted) {
          setState(() => _servicePartial = words);
        }
        if (isFinal && mounted) {
          setState(() {
            _listeningService = false;
            _servicePartial = '';
          });
        }
      },
    );
  }

  Widget _buildListeningBadge(bool isDark, String label) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.4, end: 1),
      duration: const Duration(milliseconds: 900),
      builder: (context, value, child) {
        return Opacity(opacity: _listeningService ? value : 0, child: child);
      },
      onEnd: () {
        if (mounted && _listeningService) {
          setState(() {});
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? AppColors.slate800 : AppColors.slate100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTypography.captionSmall.copyWith(
            color: isDark ? AppColors.slate200 : AppColors.slate700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLocaleSelector(AppLocalizations? l10n) {
    final label = _serviceLocale == 'en_US'
        ? (l10n?.englishUS ?? 'English (US)')
        : (l10n?.portugueseBrazil ?? 'Português (BR)');
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (mounted) {
          setState(() => _serviceLocale = value);
        }
        VoicePreferences.setLocale(value);
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'pt_BR',
          child: Text(l10n?.portugueseBrazil ?? 'Português (BR)'),
        ),
        PopupMenuItem(
          value: 'en_US',
          child: Text(l10n?.englishUS ?? 'English (US)'),
        ),
      ],
      child: OutlinedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.language),
        label: Text(label),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_execution != null) {
      _connectRealtime(_execution!.maintenanceOrderId);
    }
    if (!_loadedLocale) {
      _loadedLocale = true;
      _loadVoiceLocale();
    }
    if (!_checkedSpeech) {
      _checkedSpeech = true;
      _checkSpeechAvailability();
    }
  }

  Future<void> _loadVoiceLocale() async {
    final saved = await VoicePreferences.getLocale();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final fallback = (l10n?.localeName ?? 'pt_BR').startsWith('en')
        ? 'en_US'
        : 'pt_BR';
    setState(() => _serviceLocale = saved ?? fallback);
  }

  Future<void> _checkSpeechAvailability() async {
    final available = await _speechService.ensureInitialized();
    if (!mounted) return;
    setState(() => _speechAvailable = available);
  }

  void _connectRealtime(String orderId) async {
    _ordersSub?.cancel();
    final companyRef = await FirestoreHelper.companyRef();
    _ordersSub = companyRef
        .collection('serviceOrders')
        .doc(orderId)
        .snapshots()
        .listen((split) {
          if (!split.exists) return;
          final data = split.data() as Map<String, dynamic>;
          final status = data['status'] as String?;
          if (status == 'FINALIZADA' && mounted && !_isFinalized) {
            setState(() => _isFinalized = true);
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final isMaintenance = _isMaintenanceOrder();
    if (!_autoStarted &&
        widget.orderId != null &&
        (widget.qrPayload != null || !isMaintenance)) {
      _orderIdController.text = widget.orderId.toString();
      _qrPayload = widget.qrPayload;
      _autoStarted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _startExecution());
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = _executionTitle();

    return Scaffold(
      appBar: AppBar(title: Text(title)),
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
              if (_isFinalized)
                _buildFinalizedActions(isDark)
              else ...[
                _buildChecklist(isDark),
                const SizedBox(height: 20),
                _buildReviewButton(),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStartCard(bool isDark) {
    final isMaintenance = _isMaintenanceOrder();
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
                child: const Icon(
                  Icons.qr_code_scanner,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _startCardTitle(),
                  style: AppTypography.headline3.copyWith(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isMaintenance) ...[
            Text(
              'Leia o QR code para validar o equipamento',
              style: AppTypography.bodyTextSmall.copyWith(
                color: isDark ? AppColors.slate300 : AppColors.slate600,
              ),
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _orderIdController,
            decoration: const InputDecoration(
              labelText: 'Order ID',
              hintText: 'Ex: 123',
            ),
          ),
          const SizedBox(height: 12),
          if (isMaintenance) ...[
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
          ],
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
    final isMaintenance = _execution!.orderType == 'MANUTENCAO';
    final l10n = AppLocalizations.of(context);

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
            isMaintenance ? 'Maintenance Checklist' : 'Descrição do serviço',
            style: AppTypography.headline3.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (isMaintenance) ...[
            for (final item in items) _buildChecklistItem(item, isDark),
          ] else ...[
            if (_execution!.problemDescription != null &&
                _execution!.problemDescription!.isNotEmpty) ...[
              Text(
                'Problema informado: ${_execution!.problemDescription}',
                style: AppTypography.caption.copyWith(
                  color: isDark ? AppColors.slate300 : AppColors.slate600,
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _serviceDescriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Descreva o que foi feito',
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _speechAvailable ? _toggleServiceDictation : null,
                  icon: Icon(_listeningService ? Icons.mic : Icons.mic_none),
                  label: Text(
                    _listeningService
                        ? (l10n?.listening ?? 'Ouvindo...')
                        : (l10n?.voiceInput ?? 'Entrada por voz'),
                  ),
                ),
                TextButton.icon(
                  onPressed: _speechService.isListening
                      ? () async {
                          await _speechService.stop();
                          if (mounted) {
                            setState(() {
                              _listeningService = false;
                              _servicePartial = '';
                            });
                          }
                        }
                      : null,
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: Text(l10n?.stopListening ?? 'Parar'),
                ),
                _buildLocaleSelector(l10n),
                if (_listeningService)
                  _buildListeningBadge(isDark, l10n?.listening ?? 'Ouvindo...'),
              ],
            ),
            if (!_speechAvailable) ...[
              const SizedBox(height: 6),
              Text(
                l10n?.voiceNotAvailable ?? 'Entrada de voz indisponível',
                style: AppTypography.caption.copyWith(
                  color: isDark ? AppColors.slate400 : AppColors.slate600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            if (_servicePartial.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '${l10n?.transcribing ?? 'Transcrevendo'}: $_servicePartial',
                style: AppTypography.caption.copyWith(
                  color: isDark ? AppColors.slate300 : AppColors.slate600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildChecklistItem(ExecutionChecklistItem item, bool isDark) {
    final observationController = _observations.putIfAbsent(
      item.id,
      () => TextEditingController(),
    );
    final uploading = false;

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
          CheckboxListTile(
            value: _itemStatus[item.id] ?? false,
            onChanged: (value) =>
                setState(() => _itemStatus[item.id] = value ?? false),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              'Marcar como feito',
              style: AppTypography.caption.copyWith(
                color: isDark ? AppColors.slate300 : AppColors.slate600,
              ),
            ),
            activeColor: AppColors.success,
          ),
          TextField(
            controller: observationController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Observação (opcional)',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _queueEvidence(item),
                  icon: uploading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.camera_alt),
                  label: Text(
                    item.obrigatorioFoto
                        ? 'Evidência * (${_pendingEvidence[item.id]?.length ?? 0})'
                        : 'Evidência (${_pendingEvidence[item.id]?.length ?? 0})',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewButton() {
    return ElevatedButton.icon(
      onPressed: _execution == null ? null : _openReview,
      icon: const Icon(Icons.check_circle_outline),
      label: const Text('Revisar e finalizar'),
    );
  }

  Widget _buildFinalizedActions(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkTheme : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDefaultDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Execução finalizada',
            style: AppTypography.headline3.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _viewReport,
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Visualizar PDF'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _downloadReport,
            icon: const Icon(Icons.share_outlined),
            label: const Text('Compartilhar PDF'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _goToDashboard,
            icon: const Icon(Icons.dashboard_outlined),
            label: const Text('Voltar ao dashboard'),
          ),
        ],
      ),
    );
  }

  void _goToDashboard() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
      (route) => false,
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
    final orderId = _orderIdController.text.trim();
    if (orderId.isEmpty) {
      _showSnack('Provide order id');
      return;
    }
    if (_isMaintenanceOrder() && (_qrPayload == null || _qrPayload!.isEmpty)) {
      _showSnack('Leia o QR code');
      return;
    }

    setState(() => _isStarting = true);
    try {
      final position = await _getPosition();
      final deviceId = await DeviceService.getDeviceId();
      final response = await FirestoreExecutionService.startExecution(
        maintenanceOrderId: orderId,
        qrCodePayload: _qrPayload,
        deviceId: deviceId,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
      );

      _connectRealtime(response.maintenanceOrderId);

      setState(() {
        _execution = response;
        _serviceDescriptionController.text = '';
        for (final item in response.checklistItems) {
          _itemStatus.putIfAbsent(item.id, () => false);
        }
      });
    } catch (e) {
      _showSnack(e.toString());
    } finally {
      setState(() => _isStarting = false);
    }
  }

  Future<void> _queueEvidence(ExecutionChecklistItem item) async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (photo == null) return;
    final bytes = await photo.readAsBytes();
    setState(() {
      final list = _pendingEvidence.putIfAbsent(item.id, () => []);
      list.add(
        LocalPhoto(bytes: bytes, name: photo.name, mimeType: 'image/jpeg'),
      );
    });
  }

  Future<void> _openReview() async {
    if (_execution == null) return;
    final items = _execution!.checklistItems;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ExecutionReviewScreen(
          orderId: _execution!.maintenanceOrderId,
          executionId: _execution!.executionId,
          items: items,
          itemStatus: _itemStatus,
          observations: _observations,
          pendingEvidence: _pendingEvidence,
          orderType: _execution!.orderType,
          serviceDescriptionController: _serviceDescriptionController,
        ),
      ),
    );
    if (result == true && mounted) {
      setState(() => _isFinalized = true);
      _showSnack('Execução finalizada');
    }
  }

  void _viewReport() {
    if (_execution == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExecutionReportPreviewScreen(
          executionId: _execution!.executionId,
          orderId: _execution!.maintenanceOrderId,
        ),
      ),
    );
  }

  Future<void> _downloadReport() async {
    // Client-side PDF generation is handled in the preview screen
    _viewReport();
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _executionTitle() {
    final type = _execution?.orderType;
    if (type == 'CONSERTO') return 'Repair Execution';
    if (type == 'OUTROS') return 'Service Execution';
    if (type == 'MANUTENCAO') return 'Maintenance Execution';
    return _isMaintenanceOrder()
        ? 'Maintenance Execution'
        : 'Service Execution';
  }

  String _startCardTitle() {
    final type = _execution?.orderType ?? widget.orderType;
    if (type == 'CONSERTO') return 'Start Repair';
    if (type == 'OUTROS') return 'Start Service';
    if (type == 'MANUTENCAO') return 'Start Maintenance';
    return 'Start Execution';
  }

  bool _isMaintenanceOrder() {
    final type = _execution?.orderType ?? widget.orderType;
    return type == null || type == 'MANUTENCAO';
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
