import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../providers/user_provider.dart';
import '../services/checklist_service.dart';
import '../models/order.dart';

class CreateChecklistTemplateScreen extends StatefulWidget {
  final Checklist? checklist;

  const CreateChecklistTemplateScreen({super.key, this.checklist});

  @override
  State<CreateChecklistTemplateScreen> createState() =>
      _CreateChecklistTemplateScreenState();
}

class _CreateChecklistTemplateScreenState
    extends State<CreateChecklistTemplateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  bool _isSaving = false;
  final List<TextEditingController> _itemControllers = [];
  final List<bool> _itemRequiredPhoto = [];
  final List<bool> _itemCritical = [];
  bool _initialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    for (final controller in _itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (!_initialized) {
      _initialized = true;
      _seedFromChecklist();
    }

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDarkTheme : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(widget.checklist == null ? 'New Checklist' : 'Edit Checklist'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDarkTheme : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.borderDefaultDark : AppColors.borderLight,
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.checklist == null
                      ? 'Create Checklist Template'
                      : 'Edit Checklist Template',
                  style: AppTypography.headline3.copyWith(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Define checklist items for maintenance teams.',
                  style: AppTypography.bodyTextSmall.copyWith(
                    color: isDark ? AppColors.slate300 : AppColors.slate600,
                  ),
                ),
                const SizedBox(height: 20),
                _buildSectionTitle('Checklist Details', isDark),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Template name',
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                  ),
                ),
                const SizedBox(height: 20),
                _buildSectionTitle('Checklist Items', isDark),
                const SizedBox(height: 12),
                ..._buildItemFields(),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Add item'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveTemplate,
                  child: Text(_isSaving
                      ? 'Saving...'
                      : 'Save Checklist Template'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: AppTypography.subtitle1.copyWith(
        color: isDark ? Colors.white : AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  List<Widget> _buildItemFields() {
    final fields = <Widget>[];
    for (var i = 0; i < _itemControllers.length; i++) {
      fields.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _itemControllers[i],
                  decoration: InputDecoration(
                    labelText: 'Item ${i + 1}',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _removeItem(i),
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Excluir item',
                color: AppColors.danger,
              ),
            ],
          ),
        ),
      );
    }
    return fields;
  }

  void _addItem() {
    setState(() {
      _itemControllers.add(TextEditingController());
      _itemRequiredPhoto.add(false);
      _itemCritical.add(false);
    });
  }

  void _removeItem(int index) {
    setState(() {
      _itemControllers[index].dispose();
      _itemControllers.removeAt(index);
      if (_itemRequiredPhoto.length > index) {
        _itemRequiredPhoto.removeAt(index);
      }
      if (_itemCritical.length > index) {
        _itemCritical.removeAt(index);
      }
    });
  }

  void _seedFromChecklist() {
    if (widget.checklist == null) {
      _itemControllers.addAll([
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
      ]);
      _itemRequiredPhoto.addAll([false, false, false]);
      _itemCritical.addAll([false, false, false]);
      return;
    }

    _titleController.text = widget.checklist!.nome;
    _categoryController.text = widget.checklist!.descricao ?? '';

    for (final item in widget.checklist!.itens) {
      _itemControllers.add(TextEditingController(text: item.descricao));
      _itemRequiredPhoto.add(item.obrigatorioFoto);
      _itemCritical.add(item.critico);
    }
    if (_itemControllers.isEmpty) {
      _itemControllers.add(TextEditingController());
      _itemRequiredPhoto.add(false);
      _itemCritical.add(false);
    }
  }

  void _saveTemplate() {
    if (!_formKey.currentState!.validate()) return;
    _submitTemplate();
  }

  Future<void> _submitTemplate() async {
    setState(() => _isSaving = true);
    try {
      final token = Provider.of<UserProvider>(context, listen: false).token;
      if (token == null) {
        throw Exception('Usuário não autenticado');
      }
      final items = _itemControllers
          .map((c) => c.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();
      if (items.isEmpty) {
        throw Exception('Adicione pelo menos um item');
      }
      final payload = <Map<String, dynamic>>[];
      for (var i = 0; i < items.length; i++) {
        payload.add({
          'descricao': items[i],
          'ordem': i + 1,
          'obrigatorioFoto': _itemRequiredPhoto.length > i
              ? _itemRequiredPhoto[i]
              : false,
          'critico': _itemCritical.length > i ? _itemCritical[i] : false,
        });
      }
      if (widget.checklist == null) {
        await ChecklistService.create(
          token: token,
          nome: _titleController.text.trim(),
          descricao: _categoryController.text.trim(),
          itens: payload,
        );
      } else {
        await ChecklistService.update(
          token: token,
          id: widget.checklist!.id,
          nome: _titleController.text.trim(),
          descricao: _categoryController.text.trim(),
          itens: payload,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.checklist == null
              ? 'Checklist template saved'
              : 'Checklist template updated'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: ${e.toString()}'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
