import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../providers/user_provider.dart';
import '../services/firestore_equipment_service.dart';
import '../services/firestore_checklist_service.dart';
import '../services/firestore_order_service.dart';
import '../services/firestore_technician_service.dart';
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
  List<Equipamento> _equipments = [];
  List<Checklist> _checklists = [];
  List<Technician> _technicians = [];
  Equipamento? _selectedEquipment;
  Checklist? _selectedChecklist;
  String _priority = 'MEDIA';
  String _orderType = 'MANUTENCAO';
  DateTime? _scheduledFor;
  String? _selectedTechnicianId;
  final TextEditingController _problemDescriptionController =
      TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final SpeechService _speechService = SpeechService();
  bool _listeningProblem = false;
  bool _speechAvailable = true;
  String _problemBaseText = '';
  String _problemLocale = 'pt_BR';
  String _problemPartial = '';

  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _selectedTechnicianId = 'none';
    _loadVoiceLocale();
    _checkSpeechAvailability();
    _loadData();
    _problemDescriptionController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _analyzeText(_problemDescriptionController.text);
      }
    });
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

  Future<void> _checkSpeechAvailability() async {
    final available = await _speechService.ensureInitialized();
    if (!mounted) return;
    setState(() => _speechAvailable = available);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _problemDescriptionController.removeListener(_onTextChanged);
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
        print('UI received words: "$words"');
        final prefix = _problemBaseText.isEmpty ? '' : '$_problemBaseText ';
        _problemDescriptionController.text = '$prefix$words';
        _problemDescriptionController.selection = TextSelection.fromPosition(
          TextPosition(offset: _problemDescriptionController.text.length),
        );
        if (mounted) {
          setState(() => _problemPartial = words);
        }
        if (isFinal && mounted) {
          _analyzeText(words);
          setState(() {
            _listeningProblem = false;
            _problemPartial = '';
          });
        }
      },
    );
  }

  void _analyzeText(String text) {
    if (text.isEmpty) return;
    final lowerText = text.toLowerCase();
    bool updated = false;

    // Helper to capitalize first letter
    String capitalize(String s) {
      if (s.isEmpty) return s;
      return s[0].toUpperCase() + s.substring(1);
    }

    // 1. Analyze Brand (Marca)
    final commonBrands = [
      'samsung',
      'apple',
      'motorola',
      'xiaomi',
      'lg',
      'sony',
      'dell',
      'hp',
      'lenovo',
      'asus',
      'acer',
      'philips',
      'consul',
      'brastemp',
      'electrolux',
      'arno',
      'mondial',
      'britânia',
      'epson',
      'canon',
      'hp',
      'multilaser',
      'positivo',
    ];

    String? detectedBrand;
    // Explicit 'marca' check first (stronger signal)
    final marcaMatch = RegExp(r'marca\s+([\w\d]+)').firstMatch(lowerText);
    if (marcaMatch != null) {
      detectedBrand = marcaMatch.group(1);
    } else {
      // Implicit check from list
      for (final brand in commonBrands) {
        if (lowerText.contains(brand)) {
          detectedBrand = brand;
          break; // Stop at first match
        }
      }
    }

    if (detectedBrand != null && _brandController.text.isEmpty) {
      _brandController.text = capitalize(detectedBrand);
      updated = true;
    }

    // 2. Analyze Model (Modelo)
    // Capture until next keyword or end of string.
    // We add more stop words to prevent capturing "modelo x com defeito y" as "x com defeito y"
    final stopWords = [
      'marca',
      'defeito',
      'problema',
      'dia',
      'para',
      'agendar',
      'prioridade',
      'urgente',
      'gravíssimo',
      'alta',
      'baixa',
      'média',
      'normal',
      'simples',
    ];
    final stopWordsPattern = stopWords.join('|');

    final modeloMatch = RegExp(
      r'modelo\s+(.+?)(?=\s+(?:' + stopWordsPattern + r')|$)',
      caseSensitive: false,
      dotAll: false,
    ).firstMatch(lowerText);

    if (modeloMatch != null) {
      final model = modeloMatch.group(1)!.trim();
      // Filter out small noise
      if (model.isNotEmpty &&
          model.length > 1 &&
          _modelController.text.isEmpty) {
        _modelController.text = capitalize(model);
        updated = true;
      }
    }

    // 3. Analyze Priority (Prioridade)
    String? detectedPriority;
    if (lowerText.contains('urgente') ||
        lowerText.contains('gravíssimo') ||
        lowerText.contains('prioridade alta') ||
        lowerText.contains('alta prioridade')) {
      detectedPriority = 'ALTA';
    } else if (lowerText.contains('prioridade baixa') ||
        lowerText.contains('simples') ||
        lowerText.contains('tranquilo') ||
        lowerText.contains('baixa prioridade')) {
      detectedPriority = 'BAIXA';
    } else if (lowerText.contains('prioridade média') ||
        lowerText.contains('normal') ||
        lowerText.contains('média prioridade')) {
      detectedPriority = 'MEDIA';
    }

    if (detectedPriority != null && _priority != detectedPriority) {
      setState(() => _priority = detectedPriority!);
      updated = true;
    }

    // 4. Analyze Date (Data)
    DateTime? detectedDate;

    // Relative keywords
    if (lowerText.contains('amanhã')) {
      detectedDate = DateTime.now().add(const Duration(days: 1));
    } else if (lowerText.contains('hoje')) {
      detectedDate = DateTime.now();
    } else {
      // Weekdays
      final weekdays = {
        'segunda': DateTime.monday,
        'terça': DateTime.tuesday,
        'terca': DateTime.tuesday,
        'quarta': DateTime.wednesday,
        'quinta': DateTime.thursday,
        'sexta': DateTime.friday,
        'sábado': DateTime.saturday,
        'sabado': DateTime.saturday,
        'domingo': DateTime.sunday,
      };

      for (final entry in weekdays.entries) {
        if (lowerText.contains(entry.key)) {
          final now = DateTime.now();
          final todayWeekday = now.weekday;
          final targetWeekday = entry.value;

          // Calculate days until target
          int daysUntil = targetWeekday - todayWeekday;
          if (daysUntil <= 0) {
            daysUntil += 7; // Next week occurrence
          }

          // Handle "próxima" (start searching AFTER the first occurrence)
          // E.g. If today is Monday, "próxima segunda" usually means next week's Monday (7 days),
          // but "segunda" might mean today? Context matters.
          // Let's assume: "segunda" = coming one. "próxima segunda" = coming one + 7 days?
          // NO, usually "próxima segunda" is just the coming one if we are far away,
          // or the *next* next if we are close.
          // Let's keep it simple: "próxima" adds 7 days if found before the day name?
          // Actually, "próxima segunda" usually just emphasizes the coming one in Portuguese context
          // UNLESS we are already on Sunday, then "segunda" is tomorrow, "próxima" is +8 days.
          // Let's stick to: Find next occurrence. If "próxima" is detected and the next occurrence is very close (e.g. tomorrow), add 7?
          // Or simpler: Just find next occurrence.

          if (lowerText.contains('próxima ${entry.key}') ||
              lowerText.contains('proxima ${entry.key}')) {
            // If user explicitly says "next", ensure at least a buffer?
            // Logic: If today is Sunday(7), "Próxima Segunda"(1) is day+1.
            // If today is Monday(1), "Próxima Segunda" is day+7.
            // Let's just blindly rely on the calculated next occurrence for now,
            // unless we want to support "na outra segunda".
          }

          detectedDate = now.add(Duration(days: daysUntil));
          break;
        }
      }
    }

    // Explicit date 'dia 15'
    if (detectedDate == null) {
      final dateMatch = RegExp(
        r'dia\s+(\d{1,2})(?:\/(\d{1,2}))?',
      ).firstMatch(lowerText);
      if (dateMatch != null) {
        final now = DateTime.now();
        final day = int.parse(dateMatch.group(1)!);
        final month = dateMatch.group(2) != null
            ? int.parse(dateMatch.group(2)!)
            : now.month;
        var year = now.year;
        detectedDate = DateTime(year, month, day, now.hour, now.minute);
      }
    }

    // 5. Analyze Time (Horário)
    TimeOfDay? detectedTime;

    // Regex for time: "às 14h", "as 14:30", "14h30", "14:00"
    // We look for patterns like: (às|as)\s*(\d{1,2})[:hH]?(\d{2})?
    final timeMatch = RegExp(
      r'(?:às|as|hora|horas)\s*(\d{1,2})(?:[:hH](\d{2}))?',
      caseSensitive: false,
    ).firstMatch(lowerText);

    if (timeMatch != null) {
      final hour = int.parse(timeMatch.group(1)!);
      final minute = timeMatch.group(2) != null
          ? int.parse(timeMatch.group(2)!)
          : 0;
      if (hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59) {
        detectedTime = TimeOfDay(hour: hour, minute: minute);
      }
    }

    if (detectedTime != null) {
      final baseDate = detectedDate ?? _scheduledFor ?? DateTime.now();
      final newDateTime = DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        detectedTime.hour,
        detectedTime.minute,
      );

      if (_scheduledFor == null || _scheduledFor != newDateTime) {
        setState(() => _scheduledFor = newDateTime);
        updated = true;
      }
    } else if (detectedDate != null) {
      // Only date changed, preserve existing time or default to 08:00
      final existingTime = _scheduledFor != null
          ? TimeOfDay(hour: _scheduledFor!.hour, minute: _scheduledFor!.minute)
          : const TimeOfDay(hour: 8, minute: 0);

      final newDateTime = DateTime(
        detectedDate.year,
        detectedDate.month,
        detectedDate.day,
        existingTime.hour,
        existingTime.minute,
      );

      if (_scheduledFor == null || _scheduledFor != newDateTime) {
        setState(() => _scheduledFor = newDateTime);
        updated = true;
      }
    }

    if (updated) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dados extraídos do texto automaticamente ✨'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.overline.copyWith(
          color: isDark ? AppColors.slate400 : AppColors.slate500,
        ),
      ),
    );
  }

  Widget _buildSelectionCard<T>({
    required T value,
    required T selectedValue,
    required String label,
    required IconData icon,
    required Function(T) onSelected,
    required bool isDark,
  }) {
    final isSelected = value == selectedValue;
    final color = isSelected
        ? AppColors.primary
        : (isDark ? AppColors.surfaceDarkTheme : Colors.white);
    final textColor = isSelected
        ? Colors.white
        : (isDark ? AppColors.slate300 : AppColors.slate700);
    final borderColor = isSelected
        ? AppColors.primary
        : (isDark ? AppColors.borderDefaultDark : AppColors.borderLight);

    return Expanded(
      child: GestureDetector(
        onTap: () => onSelected(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: !isSelected && !isDark
                ? [
                    BoxShadow(
                      color: AppColors.shadow.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: isSelected ? Colors.white : AppColors.primary),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTypography.captionSmall.copyWith(
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
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
        PopupMenuItem(value: 'pt_BR', child: Text(l10n.portugueseBrazil)),
        PopupMenuItem(value: 'en_US', child: Text(l10n.englishUS)),
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // No token check needed for Firestore updates usually, unless we want to reload on auth change
    // For now, _loadData is called in initState. we can keep it simple.
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final equipments = await FirestoreEquipmentService.getAll();
      final checklists = await FirestoreChecklistService.getAll();
      final technicians = await FirestoreTechnicianService.getAll();
      if (!mounted) return;
      final favoriteIds = await FirestoreTechnicianService.loadFavoriteIds();
      setState(() {
        _equipments = equipments;
        _checklists = checklists;
        _technicians = technicians;
        for (var tech in _technicians) {
          tech.isFavorite = favoriteIds.contains(tech.id);
        }
        _technicians.sort((a, b) {
          if (a.isFavorite && !b.isFavorite) return -1;
          if (!a.isFavorite && b.isFavorite) return 1;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.selectEquipmentChecklist)));
      return;
    }
    if (!needsChecklist && _problemDescriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.problemDescriptionRequired)));
      return;
    }
    if (!needsChecklist && _brandController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.brandRequired)));
      return;
    }
    if (!needsChecklist && _modelController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.modelRequired)));
      return;
    }
    setState(() => _isSaving = true);
    try {
      final equipmentId = _selectedEquipment?.id;
      final clienteId = _selectedEquipment?.cliente?.id;
      final responsavelId = _selectedTechnicianId == 'none'
          ? null
          : _selectedTechnicianId;

      final selectedTech = responsavelId != null
          ? _technicians.where((t) => t.id == responsavelId).firstOrNull
          : null;

      await FirestoreOrderService.create(
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
        equipmentBrand: needsChecklist ? null : _brandController.text,
        equipmentModel: needsChecklist ? null : _modelController.text,
        equipamentoData: _selectedEquipment?.toMap(),
        checklistData: needsChecklist ? _selectedChecklist!.toMap() : null,
        clienteData: _selectedEquipment?.cliente?.toMap(),
        responsavelData: selectedTech != null
            ? {'id': selectedTech.id, 'name': selectedTech.name}
            : null,
      );
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
        SnackBar(content: Text(message), backgroundColor: AppColors.danger),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledFor ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        final existingTime = _scheduledFor != null
            ? TimeOfDay(
                hour: _scheduledFor!.hour,
                minute: _scheduledFor!.minute,
              )
            : const TimeOfDay(hour: 8, minute: 0);

        _scheduledFor = DateTime(
          picked.year,
          picked.month,
          picked.day,
          existingTime.hour,
          existingTime.minute,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: _scheduledFor != null
          ? TimeOfDay(hour: _scheduledFor!.hour, minute: _scheduledFor!.minute)
          : now,
    );

    if (picked != null) {
      final baseDate = _scheduledFor ?? DateTime.now();
      setState(() {
        _scheduledFor = DateTime(
          baseDate.year,
          baseDate.month,
          baseDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final needsChecklist = _orderType == 'MANUTENCAO';

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDarkTheme
          : AppColors.backgroundLight,
      appBar: AppBar(title: Text(l10n.createServiceOrderTitle), elevation: 0),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSectionHeader(l10n.orderTypeLabel, isDark),
                      Row(
                        children: [
                          _buildSelectionCard(
                            value: 'MANUTENCAO',
                            selectedValue: _orderType,
                            label: l10n.orderTypeMaintenance,
                            icon: Icons.build_circle_outlined,
                            isDark: isDark,
                            onSelected: (val) => setState(() {
                              _orderType = val;
                              _selectedChecklist = null;
                              _selectedEquipment = null;
                            }),
                          ),
                          const SizedBox(width: 12),
                          _buildSelectionCard(
                            value: 'CONSERTO',
                            selectedValue: _orderType,
                            label: l10n.orderTypeRepair,
                            icon: Icons.handyman_outlined,
                            isDark: isDark,
                            onSelected: (val) => setState(() {
                              _orderType = val;
                              _selectedChecklist = null;
                              _selectedEquipment = null;
                            }),
                          ),
                          const SizedBox(width: 12),
                          _buildSelectionCard(
                            value: 'OUTROS',
                            selectedValue: _orderType,
                            label: l10n.orderTypeOther,
                            icon: Icons.more_horiz_outlined,
                            isDark: isDark,
                            onSelected: (val) => setState(() {
                              _orderType = val;
                              _selectedChecklist = null;
                              _selectedEquipment = null;
                            }),
                          ),
                        ],
                      ),

                      if (needsChecklist) ...[
                        _buildSectionHeader(l10n.equipmentLabel, isDark),
                        DropdownButtonFormField<Equipamento>(
                          initialValue: _selectedEquipment,
                          decoration: InputDecoration(
                            hintText: l10n.equipmentLabel,
                            prefixIcon: const Icon(Icons.qr_code_scanner),
                          ),
                          items: _equipments
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.nome),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedEquipment = value);
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<Checklist>(
                          value: _selectedChecklist,
                          decoration: InputDecoration(
                            hintText: l10n.checklistTitle,
                            prefixIcon: const Icon(Icons.checklist),
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
                      ] else ...[
                        _buildSectionHeader(l10n.orderDetailsHeading, isDark),
                        TextField(
                          controller: _problemDescriptionController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: l10n.problemDescriptionLabel,
                            hintText: l10n.problemDescriptionHint,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildVoiceInputRow(l10n, isDark),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _brandController,
                                decoration: InputDecoration(
                                  labelText: l10n.brandLabel,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _modelController,
                                decoration: InputDecoration(
                                  labelText: l10n.modelLabel,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      _buildSectionHeader(l10n.priorityLabel, isDark),
                      Row(
                        children: [
                          _buildSelectionCard(
                            value: 'BAIXA',
                            selectedValue: _priority,
                            label: l10n.priorityLow,
                            icon: Icons.keyboard_arrow_down,
                            isDark: isDark,
                            onSelected: (val) =>
                                setState(() => _priority = val),
                          ),
                          const SizedBox(width: 12),
                          _buildSelectionCard(
                            value: 'MEDIA',
                            selectedValue: _priority,
                            label: l10n.priorityMedium,
                            icon: Icons.remove,
                            isDark: isDark,
                            onSelected: (val) =>
                                setState(() => _priority = val),
                          ),
                          const SizedBox(width: 12),
                          _buildSelectionCard(
                            value: 'ALTA',
                            selectedValue: _priority,
                            label: l10n.priorityHigh,
                            icon: Icons.keyboard_arrow_up,
                            isDark: isDark,
                            onSelected: (val) =>
                                setState(() => _priority = val),
                          ),
                        ],
                      ),

                      _buildSectionHeader(l10n.responsibleTechnician, isDark),
                      _buildTechnicianSelection(l10n, isDark),

                      _buildSectionHeader(l10n.scheduledDate, isDark),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _pickDate,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.surfaceDarkTheme
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.borderDefaultDark
                                        : AppColors.borderLight,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_month,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _scheduledFor == null
                                          ? l10n.selectDate
                                          : '${_scheduledFor!.day.toString().padLeft(2, '0')}/${_scheduledFor!.month.toString().padLeft(2, '0')}/${_scheduledFor!.year}',
                                      style: AppTypography.bodyTextSmall
                                          .copyWith(
                                            color: isDark
                                                ? Colors.white
                                                : AppColors.textPrimary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: _pickTime,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.surfaceDarkTheme
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.borderDefaultDark
                                        : AppColors.borderLight,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _scheduledFor == null
                                          ? 'Horário' // TODO generic label if text not set
                                          : '${_scheduledFor!.hour.toString().padLeft(2, '0')}:${_scheduledFor!.minute.toString().padLeft(2, '0')}',
                                      style: AppTypography.bodyTextSmall
                                          .copyWith(
                                            color: isDark
                                                ? Colors.white
                                                : AppColors.textPrimary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildBottomAction(l10n, isDark),
                ),
              ],
            ),
    );
  }

  Widget _buildVoiceInputRow(AppLocalizations l10n, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilterChip(
              label: Text(_listeningProblem ? l10n.listening : l10n.voiceInput),
              selected: _listeningProblem,
              onSelected: _speechAvailable
                  ? (_) => _toggleProblemDictation()
                  : null,
              avatar: Icon(
                _listeningProblem ? Icons.mic : Icons.mic_none,
                size: 18,
                color: _listeningProblem ? Colors.white : AppColors.primary,
              ),
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: _listeningProblem ? Colors.white : AppColors.primary,
              ),
            ),
            _buildLocaleSelector(l10n),
          ],
        ),
        if (!_speechAvailable) ...[
          const SizedBox(height: 4),
          Text(
            l10n.voiceNotAvailable,
            style: AppTypography.captionSmall.copyWith(
              color: AppColors.danger,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        if (_problemPartial.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            '${l10n.transcribing}: $_problemPartial',
            style: AppTypography.captionSmall.copyWith(
              color: isDark ? AppColors.slate400 : AppColors.slate500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTechnicianSelection(AppLocalizations l10n, bool isDark) {
    final userId = Provider.of<UserProvider>(context, listen: false).id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_technicians.any((t) => t.isFavorite)) ...[
          SizedBox(
            height: 70,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Quick Assign to Me
                _buildQuickTechAvatar(
                  id: userId ?? 'me',
                  name: l10n.meLabel,
                  isSelected: _selectedTechnicianId == userId,
                  isDark: isDark,
                  onTap: () => setState(() => _selectedTechnicianId = userId),
                ),
                ..._technicians
                    .where((t) => t.isFavorite && t.id != userId)
                    .map(
                      (tech) => _buildQuickTechAvatar(
                        id: tech.id,
                        name: tech.name,
                        imageUrl: tech.avatarUrl,
                        isSelected: _selectedTechnicianId == tech.id,
                        isDark: isDark,
                        onTap: () =>
                            setState(() => _selectedTechnicianId = tech.id),
                      ),
                    ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        DropdownButtonFormField<String>(
          initialValue: _selectedTechnicianId,
          decoration: InputDecoration(
            hintText: l10n.responsibleTechnician,
            prefixIcon: const Icon(Icons.person_outline),
          ),
          items: _buildTechnicianItems(),
          onChanged: (value) {
            setState(() => _selectedTechnicianId = value);
          },
        ),
      ],
    );
  }

  Widget _buildQuickTechAvatar({
    required String id,
    required String name,
    String? imageUrl,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: isDark
                    ? AppColors.slate800
                    : AppColors.slate200,
                backgroundImage: imageUrl != null
                    ? NetworkImage(imageUrl)
                    : null,
                child: imageUrl == null
                    ? Text(
                        name[0].toUpperCase(),
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.slate500,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              name.split(' ')[0],
              style: AppTypography.captionSmall.copyWith(
                color: isSelected ? AppColors.primary : AppColors.slate500,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction(AppLocalizations l10n, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDarkTheme : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveOrder,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(l10n.createOrder, style: AppTypography.button),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildTechnicianItems() {
    final l10n = AppLocalizations.of(context)!;
    final items = <DropdownMenuItem<String>>[
      DropdownMenuItem(value: 'none', child: Text(l10n.doNotAssignNow)),
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
      final label = tech.role.isNotEmpty
          ? '${tech.name} • ${tech.role}'
          : tech.name;
      items.add(DropdownMenuItem(value: tech.id, child: Text(label)));
    }
    return items;
  }
}
