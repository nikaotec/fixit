import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../providers/user_provider.dart';
import '../services/equipment_service.dart';
import '../services/checklist_service.dart';
import '../services/order_service.dart';
import '../services/technician_service.dart';
import '../services/speech_service.dart';
import '../services/voice_preferences.dart';
import '../models/order.dart';
import '../models/technician.dart';
import '../l10n/app_localizations.dart';

class CreateServiceOrderScreen extends StatefulWidget {
  const CreateServiceOrderScreen({super.key});

  @override
  State<CreateServiceOrderScreen> createState() =>
      _CreateServiceOrderScreenState();
}

class _CreateServiceOrderScreenState extends State<CreateServiceOrderScreen> {
  bool _isLoading = false;
  bool _isSaving = false;
  List<Map<String, dynamic>> _equipments = [];
  List<Checklist> _checklists = [];
  List<Technician> _technicians = [];
  Map<String, dynamic>? _selectedEquipment;
  Checklist? _selectedChecklist;
  String _priority = 'MEDIA';
  String _orderType = 'MANUTENCAO';
  DateTime? _scheduledFor;
  String? _selectedTechnicianId;
  String? _lastToken;
  final TextEditingController _problemDescriptionController =
      TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final SpeechService _speechService = SpeechService();
  bool _listeningProblem = false;
  String _problemBaseText = '';
  String _problemLocale = 'pt_BR';
  String _problemPartial = '';

  @override
  void initState() {
    super.initState();
    _selectedTechnicianId = 'none';
    _loadVoiceLocale();
    _loadData();
  }

  Future<void> _loadVoiceLocale() async {
    final saved = await VoicePreferences.getLocale();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final fallback = (l10n?.localeName ?? 'pt_BR').startsWith('en')
        ? 'en_US'
        : 'pt_BR';
    setState(() => _problemLocale = saved ?? fallback);
  }

  @override
  void dispose() {
    _problemDescriptionController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  Future<void> _toggleProblemDictation() async {
    final l10n = AppLocalizations.of(context)!;
    final available = await _speechService.ensureInitialized();
    if (!available) {
      _showSnack(l10n.voiceNotAvailable);
      return;
    }
    if (_speechService.isListening) {
      await _speechService.stop();
      if (mounted) setState(() => _listeningProblem = false);
      return;
    }
    _problemBaseText = _problemDescriptionController.text.trim();
    if (mounted) setState(() => _listeningProblem = true);
    await _speechService.start(
      localeId: _problemLocale,
      onResult: (words, isFinal) {
        final prefix = _problemBaseText.isEmpty ? '' : '$_problemBaseText ';
        _problemDescriptionController.text = '$prefix$words';
        _problemDescriptionController.selection = TextSelection.fromPosition(
          TextPosition(offset: _problemDescriptionController.text.length),
        );
        if (mounted) {
          setState(() => _problemPartial = words);
        }
        if (isFinal && mounted) {
          setState(() {
            _listeningProblem = false;
            _problemPartial = '';
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
          opacity: _listeningProblem ? value : 0,
          child: child,
        );
      },
      onEnd: () {
        if (mounted && _listeningProblem) {
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

  Widget _buildLocaleSelector(AppLocalizations l10n) {
    final label = _problemLocale == 'en_US'
        ? l10n.englishUS
        : l10n.portugueseBrazil;
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (mounted) {
          setState(() => _problemLocale = value);
        }
        VoicePreferences.setLocale(value);
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'pt_BR',
          child: Text(l10n.portugueseBrazil),
        ),
        PopupMenuItem(
          value: 'en_US',
          child: Text(l10n.englishUS),
        ),
      ],
      child: OutlinedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.language),
        label: Text(label),
      ),
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final token = Provider.of<UserProvider>(context).token;
    if (token != null && token != _lastToken) {
      _lastToken = token;
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final token = Provider.of<UserProvider>(context, listen: false).token;
      if (token == null) return;
      final equipments = await EquipmentService.getAll(token: token);
      final checklists = await ChecklistService.getAll(token: token);
      final technicians = await TechnicianService.getFavoriteDetails(token: token);
      setState(() {
        _equipments = equipments;
        _checklists = checklists;
        _technicians = technicians;
      });
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorLoadingData(e.toString())),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveOrder() async {
    final l10n = AppLocalizations.of(context)!;
    final needsChecklist = _orderType == 'MANUTENCAO';
    if ((needsChecklist && _selectedEquipment == null) ||
        (needsChecklist && _selectedChecklist == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectEquipmentChecklist)),
      );
      return;
    }
    if (!needsChecklist &&
        _problemDescriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.problemDescriptionRequired)),
      );
      return;
    }
    if (!needsChecklist && _brandController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.brandRequired)),
      );
      return;
    }
    if (!needsChecklist && _modelController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.modelRequired)),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      final token = Provider.of<UserProvider>(context, listen: false).token;
      if (token == null) {
        throw Exception(l10n.userNotAuthenticated);
      }
      final equipmentId = _selectedEquipment != null
          ? (_selectedEquipment!['id'] as num).toInt()
          : null;
      final cliente =
          _selectedEquipment != null ? _selectedEquipment!['cliente'] : null;
      final clienteId = cliente != null ? cliente['id']?.toString() : null;
      final responsavelId = _selectedTechnicianId == 'none'
          ? null
          : _selectedTechnicianId;

      await OrderService.create(
        token: token,
        equipamentoId: equipmentId,
        checklistId: needsChecklist ? _selectedChecklist!.id : null,
        clienteId: clienteId,
        responsavelId: responsavelId,
        prioridade: _priority,
        dataPrevista: _scheduledFor,
        orderType: _orderType,
        problemDescription: needsChecklist
            ? null
            : _problemDescriptionController.text,
        equipmentBrand:
            needsChecklist ? null : _brandController.text,
        equipmentModel:
            needsChecklist ? null : _modelController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.orderCreatedSuccess),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      final raw = e.toString();
      final isTechError =
          _selectedTechnicianId != null &&
          _selectedTechnicianId != 'none' &&
          (raw.contains('400') ||
              raw.contains('422') ||
              raw.contains('responsavel') ||
              raw.contains('tecnico'));
      final message = isTechError
          ? l10n.serverRejectedTechnician
          : l10n.errorCreatingOrder(raw);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final needsChecklist = _orderType == 'MANUTENCAO';
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDarkTheme : AppColors.backgroundLight,
      appBar: AppBar(title: Text(l10n.createServiceOrderTitle)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDarkTheme : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? AppColors.borderDefaultDark
                        : AppColors.borderLight,
                  ),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: AppColors.shadow.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.orderDetailsHeading,
                      style: AppTypography.headline3.copyWith(
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _orderType,
                      decoration: InputDecoration(
                        labelText: l10n.orderTypeLabel,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'MANUTENCAO',
                          child: Text(l10n.orderTypeMaintenance),
                        ),
                        DropdownMenuItem(
                          value: 'CONSERTO',
                          child: Text(l10n.orderTypeRepair),
                        ),
                        DropdownMenuItem(
                          value: 'OUTROS',
                          child: Text(l10n.orderTypeOther),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _orderType = value;
                          if (_orderType != 'MANUTENCAO') {
                            _selectedChecklist = null;
                            _selectedEquipment = null;
                            _brandController.clear();
                            _modelController.clear();
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    if (needsChecklist) ...[
                      DropdownButtonFormField<Map<String, dynamic>>(
                        value: _selectedEquipment,
                        decoration: InputDecoration(
                          labelText: l10n.equipmentLabel,
                        ),
                        items: _equipments
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e['nome'] ?? l10n.equipmentLabel),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedEquipment = value);
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (needsChecklist) ...[
                      DropdownButtonFormField<Checklist>(
                        value: _selectedChecklist,
                        decoration: InputDecoration(
                          labelText: l10n.checklistTitle,
                        ),
                        items: _checklists
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text(c.nome),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedChecklist = value);
                        },
                      ),
                      const SizedBox(height: 12),
                    ] else ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _problemDescriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: l10n.problemDescriptionLabel,
                          hintText: l10n.problemDescriptionHint,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: _toggleProblemDictation,
                            icon: Icon(
                              _listeningProblem ? Icons.mic : Icons.mic_none,
                            ),
                            label: Text(
                              _listeningProblem
                                  ? l10n.listening
                                  : l10n.voiceInput,
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: _speechService.isListening
                                ? () async {
                                    await _speechService.stop();
                                    if (mounted) {
                                      setState(() {
                                        _listeningProblem = false;
                                        _problemPartial = '';
                                      });
                                    }
                                  }
                                : null,
                            icon: const Icon(Icons.stop_circle_outlined),
                            label: Text(l10n.stopListening),
                          ),
                          const SizedBox(width: 8),
                          _buildLocaleSelector(l10n),
                          const Spacer(),
                          if (_listeningProblem)
                            _buildListeningBadge(isDark, l10n.listening),
                        ],
                      ),
                      if (_problemPartial.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          '${l10n.transcribing}: $_problemPartial',
                          style: AppTypography.caption.copyWith(
                            color: isDark
                                ? AppColors.slate300
                                : AppColors.slate600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      TextField(
                        controller: _brandController,
                        decoration: InputDecoration(
                          labelText: l10n.brandLabel,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _modelController,
                        decoration: InputDecoration(
                          labelText: l10n.modelLabel,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _priority,
                      decoration: InputDecoration(
                        labelText: l10n.priorityLabel,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'ALTA',
                          child: Text(l10n.priorityHigh),
                        ),
                        DropdownMenuItem(
                          value: 'MEDIA',
                          child: Text(l10n.priorityMedium),
                        ),
                        DropdownMenuItem(
                          value: 'BAIXA',
                          child: Text(l10n.priorityLow),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _priority = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedTechnicianId,
                      decoration: InputDecoration(
                        labelText: l10n.responsibleTechnician,
                      ),
                      items: _buildTechnicianItems(),
                      onChanged: (value) {
                        setState(() => _selectedTechnicianId = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.scheduledDate),
                      subtitle: Text(
                        _scheduledFor == null
                            ? l10n.selectDate
                            : _scheduledFor!.toLocal().toString(),
                        style: AppTypography.caption.copyWith(
                          color:
                              isDark ? AppColors.slate300 : AppColors.slate600,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: _pickDate,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveOrder,
                      child: Text(
                        _isSaving ? l10n.saving : l10n.createOrder,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null) return;
    setState(() {
      _scheduledFor = DateTime(date.year, date.month, date.day, now.hour, now.minute);
    });
  }

  List<DropdownMenuItem<String>> _buildTechnicianItems() {
    final l10n = AppLocalizations.of(context)!;
    final items = <DropdownMenuItem<String>>[
      DropdownMenuItem(
        value: 'none',
        child: Text(l10n.doNotAssignNow),
      ),
    ];
    final userId = Provider.of<UserProvider>(context, listen: false).id;
    final userName = Provider.of<UserProvider>(context, listen: false).name;
    if (userId != null) {
      items.add(
        DropdownMenuItem(
          value: userId,
          child: Text(
            userName != null ? l10n.meWithName(userName) : l10n.meLabel,
          ),
        ),
      );
    } else {
      items.add(
        DropdownMenuItem(
          value: 'self_unavailable',
          enabled: false,
          child: Text(l10n.meUnavailable),
        ),
      );
    }
    for (final tech in _technicians) {
      if (tech.id == userId) continue;
      final label = tech.role.isNotEmpty ? '${tech.name} • ${tech.role}' : tech.name;
      items.add(
        DropdownMenuItem(
          value: tech.id,
          child: Text(label),
        ),
      );
    }
    return items;
  }
}
