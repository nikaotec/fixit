import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../models/order.dart';
import '../providers/user_provider.dart';
import '../services/checklist_service.dart';
import 'create_checklist_template_screen.dart';

class ChecklistTemplatesScreen extends StatefulWidget {
  const ChecklistTemplatesScreen({super.key});

  @override
  State<ChecklistTemplatesScreen> createState() =>
      _ChecklistTemplatesScreenState();
}

class _ChecklistTemplatesScreenState extends State<ChecklistTemplatesScreen> {
  bool _isLoading = false;
  String? _error;
  List<Checklist> _templates = [];

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final token = Provider.of<UserProvider>(context, listen: false).token;
      if (token == null) {
        throw Exception('Usuário não autenticado');
      }
      final list = await ChecklistService.getAll(token: token);
      setState(() => _templates = list);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.surfaceDarkTheme : Colors.white;
    final border = isDark ? AppColors.borderDefaultDark : AppColors.borderLight;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDarkTheme : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Checklist Templates'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateChecklistTemplateScreen(),
                ),
              ).then((result) {
                if (result == true) _loadTemplates();
              });
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _buildBody(surface, border, isDark),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateChecklistTemplateScreen(),
            ),
          ).then((result) {
            if (result == true) _loadTemplates();
          });
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody(Color surface, Color border, bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(
          'Erro ao carregar templates',
          style: AppTypography.bodyText.copyWith(
            color: isDark ? AppColors.slate300 : AppColors.slate600,
          ),
        ),
      );
    }
    if (_templates.isEmpty) {
      return Center(
        child: Text(
          'Nenhum template encontrado',
          style: AppTypography.bodyText.copyWith(
            color: isDark ? AppColors.slate300 : AppColors.slate600,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: _templates.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _templates[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.fact_check, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nome,
                      style: AppTypography.bodyText.copyWith(
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.itens.length} items · v${item.versao ?? 1}',
                      style: AppTypography.caption.copyWith(
                        color: isDark ? AppColors.slate300 : AppColors.slate600,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () {},
                child: const Text('Use'),
              ),
            ],
          ),
        );
      },
    );
  }
}
