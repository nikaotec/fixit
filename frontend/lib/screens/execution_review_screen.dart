import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';
import '../models/execution_models.dart';
import '../models/local_photo.dart';
import '../l10n/app_localizations.dart';
import '../providers/user_provider.dart';
import '../services/execution_service.dart';
import '../services/speech_service.dart';
import '../services/voice_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class ExecutionReviewScreen extends StatefulWidget {
  final int executionId;
  final List<ExecutionChecklistItem> items;
  final Map<int, bool> itemStatus;
  final Map<int, TextEditingController> observations;
  final Map<int, List<LocalPhoto>> pendingEvidence;
  final String orderType;
  final TextEditingController? serviceDescriptionController;

  const ExecutionReviewScreen({
    super.key,
    required this.executionId,
    required this.items,
    required this.itemStatus,
    required this.observations,
    required this.pendingEvidence,
    required this.orderType,
    this.serviceDescriptionController,
  });

  @override
  State<ExecutionReviewScreen> createState() => _ExecutionReviewScreenState();
}

class _ExecutionReviewScreenState extends State<ExecutionReviewScreen> {
  late final TextEditingController _finalObservationController;
  late final bool _ownsFinalObservationController;
  final SpeechService _speechService = SpeechService();
  bool _listeningObservation = false;
  bool _speechAvailable = true;
  String _observationBaseText = '';
  String _observationLocale = 'pt_BR';
  String _observationPartial = '';
  bool _loadedLocale = false;
  final _signatureController = SignatureController(
    penStrokeWidth: 4,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  final List<LocalPhoto> _executionPhotos = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _ownsFinalObservationController = widget.serviceDescriptionController == null;
    _finalObservationController =
        widget.serviceDescriptionController ?? TextEditingController();
    _loadVoiceLocale();
    _checkSpeechAvailability();
  }

  Future<void> _loadVoiceLocale() async {
    if (_loadedLocale) return;
    _loadedLocale = true;
    final saved = await VoicePreferences.getLocale();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final fallback = (l10n?.localeName ?? 'pt_BR').startsWith('en')
        ? 'en_US'
        : 'pt_BR';
    setState(() => _observationLocale = saved ?? fallback);
  }

  Future<void> _checkSpeechAvailability() async {
    final available = await _speechService.ensureInitialized();
    if (!mounted) return;
    setState(() => _speechAvailable = available);
  }

  @override
  void dispose() {
    if (_ownsFinalObservationController) {
      _finalObservationController.dispose();
    }
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _toggleObservationDictation() async {
    final l10n = AppLocalizations.of(context);
    final available = await _speechService.ensureInitialized();
    if (!available) {
      _showSnack(l10n?.voiceNotAvailable ?? 'Entrada de voz indisponível');
      return;
    }
    if (_speechService.isListening) {
      await _speechService.stop();
      if (mounted) setState(() => _listeningObservation = false);
      return;
    }
    _observationBaseText = _finalObservationController.text.trim();
    if (mounted) setState(() => _listeningObservation = true);
    await _speechService.start(
      localeId: _observationLocale,
      onResult: (words, isFinal) {
        final prefix = _observationBaseText.isEmpty ? '' : '$_observationBaseText ';
        _finalObservationController.text = '$prefix$words';
        _finalObservationController.selection = TextSelection.fromPosition(
          TextPosition(offset: _finalObservationController.text.length),
        );
        if (mounted) {
          setState(() => _observationPartial = words);
        }
        if (isFinal && mounted) {
          setState(() {
            _listeningObservation = false;
            _observationPartial = '';
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
        return Opacity(
          opacity: _listeningObservation ? value : 0,
          child: child,
        );
      },
      onEnd: () {
        if (mounted && _listeningObservation) {
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
    final label = _observationLocale == 'en_US'
        ? (l10n?.englishUS ?? 'English (US)')
        : (l10n?.portugueseBrazil ?? 'Português (BR)');
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (mounted) {
          setState(() => _observationLocale = value);
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDarkTheme : AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Revisar execução')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isMaintenance()) ...[
              _buildSummaryCard(isDark),
              const SizedBox(height: 16),
            ],
            _buildFinalObservation(isDark),
            const SizedBox(height: 16),
            _buildExecutionPhotos(isDark),
            const SizedBox(height: 16),
            _buildSignatureSection(isDark),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _finalizeExecution,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(_isSaving ? 'Salvando...' : 'Confirmar e finalizar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(bool isDark) {
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
            'Resumo do checklist',
            style: AppTypography.headline3.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          for (final item in widget.items) _buildSummaryItem(item, isDark),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(ExecutionChecklistItem item, bool isDark) {
    final done = widget.itemStatus[item.id] ?? false;
    final observation = widget.observations[item.id]?.text ?? '';
    final evidenceCount = widget.pendingEvidence[item.id]?.length ?? 0;
    final subtitle = isDark ? AppColors.slate300 : AppColors.slate600;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate800 : AppColors.slate50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.slate700 : AppColors.slate200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.descricao,
            style: AppTypography.bodyText.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            done ? 'Marcado como feito' : 'Não marcado',
            style: AppTypography.caption.copyWith(
              color: done ? AppColors.success : AppColors.danger,
            ),
          ),
          if (observation.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Obs: $observation',
              style: AppTypography.caption.copyWith(color: subtitle),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            'Evidências: $evidenceCount',
            style: AppTypography.caption.copyWith(color: subtitle),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalObservation(bool isDark) {
    final isMaintenance = _isMaintenance();
    final l10n = AppLocalizations.of(context);
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
            isMaintenance ? 'Observação final' : 'Descrição do serviço executado',
            style: AppTypography.headline3.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _finalObservationController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: isMaintenance
                  ? 'Descreva o que foi feito...'
                  : 'Detalhe o serviço realizado...',
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: _speechAvailable ? _toggleObservationDictation : null,
                icon: Icon(
                  _listeningObservation ? Icons.mic : Icons.mic_none,
                ),
                label: Text(
                  _listeningObservation
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
                            _listeningObservation = false;
                            _observationPartial = '';
                          });
                        }
                      }
                    : null,
                icon: const Icon(Icons.stop_circle_outlined),
                label: Text(l10n?.stopListening ?? 'Parar'),
              ),
              _buildLocaleSelector(l10n),
              if (_listeningObservation)
                _buildListeningBadge(
                  isDark,
                  l10n?.listening ?? 'Ouvindo...',
                ),
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
          if (_observationPartial.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${l10n?.transcribing ?? 'Transcrevendo'}: $_observationPartial',
              style: AppTypography.caption.copyWith(
                color: isDark ? AppColors.slate300 : AppColors.slate600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExecutionPhotos(bool isDark) {
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
            'Fotos e vídeos da execução',
            style: AppTypography.headline3.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final photo in _executionPhotos)
                _mediaPreview(photo, isDark),
              _addPhotoTile(isDark),
              _addVideoTile(isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mediaPreview(LocalPhoto photo, bool isDark) {
    final isVideo = photo.mimeType.startsWith('video');
    if (!isVideo) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          Uint8List.fromList(photo.bytes),
          width: 72,
          height: 72,
          fit: BoxFit.cover,
        ),
      );
    }
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate800 : AppColors.slate100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.slate700 : AppColors.slate200,
        ),
      ),
      child: const Icon(Icons.videocam, size: 22),
    );
  }

  Widget _addPhotoTile(bool isDark) {
    return InkWell(
      onTap: _pickExecutionPhoto,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: isDark ? AppColors.slate800 : AppColors.slate100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? AppColors.slate700 : AppColors.slate200,
          ),
        ),
        child: const Icon(Icons.add_a_photo, size: 20),
      ),
    );
  }

  Widget _addVideoTile(bool isDark) {
    return InkWell(
      onTap: _pickExecutionVideo,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: isDark ? AppColors.slate800 : AppColors.slate100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? AppColors.slate700 : AppColors.slate200,
          ),
        ),
        child: const Icon(Icons.videocam, size: 20),
      ),
    );
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Assinatura',
            style: AppTypography.headline3.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 160,
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
              label: const Text('Limpar'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickExecutionPhoto() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (photo == null) return;
    final bytes = await photo.readAsBytes();
    setState(() {
      _executionPhotos.add(
        LocalPhoto(bytes: bytes, name: photo.name, mimeType: 'image/jpeg'),
      );
    });
  }

  Future<void> _pickExecutionVideo() async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(source: ImageSource.camera, maxDuration: const Duration(seconds: 20));
    if (video == null) return;
    final bytes = await video.readAsBytes();
    setState(() {
      _executionPhotos.add(
        LocalPhoto(bytes: bytes, name: video.name, mimeType: 'video/mp4'),
      );
    });
  }

  Future<void> _finalizeExecution() async {
    if (_signatureController.isEmpty) {
      _showSnack('Assinatura obrigatória');
      return;
    }

    if (_isMaintenance()) {
      if (!_allItemsMarked()) {
        _showSnack('Marque todos os itens antes de finalizar');
        return;
      }

      if (!_evidenceRequirementsMet()) {
        _showSnack('Adicione evidências obrigatórias');
        return;
      }
    } else {
      if (_finalObservationController.text.trim().isEmpty) {
        _showSnack('Descreva o serviço executado');
        return;
      }
    }

    final token = Provider.of<UserProvider>(context, listen: false).token;
    if (token == null) {
      _showSnack('Usuário não autenticado');
      return;
    }

    setState(() => _isSaving = true);
    try {
      if (_isMaintenance()) {
        final execItemIds = <int, int>{};
        for (final item in widget.items) {
          final status = widget.itemStatus[item.id] ?? false;
          final observation = widget.observations[item.id]?.text;
          final response = await ExecutionService.recordItem(
            token: token,
            executionId: widget.executionId,
            checklistItemId: item.id,
            status: status,
            observation: observation,
          );
          execItemIds[item.id] = response.id;
        }

        for (final entry in widget.pendingEvidence.entries) {
          final execItemId = execItemIds[entry.key];
          if (execItemId == null) continue;
          for (final photo in entry.value) {
            await ExecutionService.uploadEvidence(
              token: token,
              checklistExecutionItemId: execItemId,
              fileBytes: Uint8List.fromList(photo.bytes),
              fileName: photo.name,
              mimeType: photo.mimeType,
            );
          }
        }
      }

      for (final photo in _executionPhotos) {
        await ExecutionService.uploadExecutionPhoto(
          token: token,
          executionId: widget.executionId,
          fileBytes: Uint8List.fromList(photo.bytes),
          fileName: photo.name,
          mimeType: photo.mimeType,
        );
      }

      final signatureBytes = await _signatureController.toPngBytes();
      if (signatureBytes == null) {
        _showSnack('Falha ao gerar assinatura');
        return;
      }
      final base64Signature = base64Encode(signatureBytes);
      await ExecutionService.finalizeExecution(
        token: token,
        executionId: widget.executionId,
        signatureBase64: base64Signature,
        finalObservation: _finalObservationController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      _showSnack('Erro ao finalizar: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  bool _allItemsMarked() {
    for (final item in widget.items) {
      if (widget.itemStatus[item.id] != true) return false;
    }
    return true;
  }

  bool _evidenceRequirementsMet() {
    for (final item in widget.items) {
      if (!item.obrigatorioFoto) continue;
      final count = widget.pendingEvidence[item.id]?.length ?? 0;
      if (count == 0) return false;
    }
    return true;
  }

  bool _isMaintenance() {
    return widget.orderType == 'MANUTENCAO';
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
