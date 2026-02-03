import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../providers/user_provider.dart';
import '../services/equipment_service.dart';
import '../services/checklist_service.dart';
import '../services/order_service.dart';
import '../models/order.dart';

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
  Map<String, dynamic>? _selectedEquipment;
  Checklist? _selectedChecklist;
  String _priority = 'MEDIA';
  DateTime? _scheduledFor;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final token = Provider.of<UserProvider>(context, listen: false).token;
      if (token == null) {
        throw Exception('Usuário não autenticado');
      }
      final equipments = await EquipmentService.getAll(token: token);
      final checklists = await ChecklistService.getAll(token: token);
      setState(() {
        _equipments = equipments;
        _checklists = checklists;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar dados: ${e.toString()}'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveOrder() async {
    if (_selectedEquipment == null || _selectedChecklist == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione equipamento e checklist')),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      final token = Provider.of<UserProvider>(context, listen: false).token;
      if (token == null) {
        throw Exception('Usuário não autenticado');
      }
      final equipmentId = (_selectedEquipment!['id'] as num).toInt();
      final cliente = _selectedEquipment!['cliente'];
      final clienteId = cliente != null ? cliente['id']?.toString() : null;

      await OrderService.create(
        token: token,
        equipamentoId: equipmentId,
        checklistId: _selectedChecklist!.id,
        clienteId: clienteId,
        prioridade: _priority,
        dataPrevista: _scheduledFor,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ordem criada com sucesso'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao criar ordem: ${e.toString()}'),
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
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDarkTheme : AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Create Service Order')),
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
                      'Order Details',
                      style: AppTypography.headline3.copyWith(
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Map<String, dynamic>>(
                      value: _selectedEquipment,
                      decoration: const InputDecoration(
                        labelText: 'Equipment',
                      ),
                      items: _equipments
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e['nome'] ?? 'Equipment'),
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
                      decoration: const InputDecoration(
                        labelText: 'Checklist',
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
                    DropdownButtonFormField<String>(
                      value: _priority,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                      ),
                      items: const [
                        DropdownMenuItem(value: 'ALTA', child: Text('High')),
                        DropdownMenuItem(value: 'MEDIA', child: Text('Medium')),
                        DropdownMenuItem(value: 'BAIXA', child: Text('Low')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _priority = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Scheduled Date'),
                      subtitle: Text(
                        _scheduledFor == null
                            ? 'Select date'
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
                      child: Text(_isSaving ? 'Saving...' : 'Create Order'),
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
}
