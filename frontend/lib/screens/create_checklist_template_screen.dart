import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../services/firestore_checklist_service.dart';
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
      backgroundColor: isDark
          ? AppColors.backgroundDarkTheme
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          widget.checklist == null ? 'New Checklist' : 'Edit Checklist',
        ),
      ),
      body: SingleChildScrollView(
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
                  decoration: const InputDecoration(labelText: 'Template name'),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
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
                  child: Text(
                    _isSaving ? 'Saving...' : 'Save Checklist Template',
                  ),
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
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.slate800
                : AppColors.slate50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.borderDefaultDark
                  : AppColors.borderLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Item ${i + 1}',
                      style: AppTypography.subtitle2.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _removeItem(i),
                    icon: const Icon(Icons.delete_outline, size: 20),
                    tooltip: 'Excluir item',
                    color: AppColors.danger,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _itemControllers[i],
                decoration: InputDecoration(
                  hintText: 'Describe the task...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.slate900
                      : Colors.white,
                ),
                maxLines: 2,
                minLines: 1,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildToggle(
                      label: 'Require Photo',
                      value: _itemRequiredPhoto[i],
                      icon: Icons.camera_alt_outlined,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() {
                          _itemRequiredPhoto[i] = val;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildToggle(
                      label: 'Critical Item',
                      value: _itemCritical[i],
                      icon: Icons.warning_amber_rounded,
                      activeColor: AppColors.danger,
                      onChanged: (val) {
                        setState(() {
                          _itemCritical[i] = val;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    return fields;
  }

  Widget _buildToggle({
    required String label,
    required bool value,
    required IconData icon,
    required Color activeColor,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: value ? activeColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value
                ? activeColor
                : (isDark ? AppColors.slate700 : AppColors.slate300),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: value
                  ? activeColor
                  : (isDark ? AppColors.slate400 : AppColors.slate500),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: AppTypography.captionSmall.copyWith(
                  color: value
                      ? activeColor
                      : (isDark ? AppColors.slate300 : AppColors.slate600),
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
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
        await FirestoreChecklistService.create(
          nome: _titleController.text.trim(),
          descricao: _categoryController.text.trim(),
          itens: payload,
        );
      } else {
        await FirestoreChecklistService.update(
          id: widget.checklist!.id,
          nome: _titleController.text.trim(),
          descricao: _categoryController.text.trim(),
          itens: payload,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.checklist == null
                ? 'Checklist template saved'
                : 'Checklist template updated',
          ),
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
