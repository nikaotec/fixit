import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../models/order.dart';
import 'create_checklist_template_screen.dart';

class ChecklistTemplateDetailsScreen extends StatelessWidget {
  final Checklist checklist;

  const ChecklistTemplateDetailsScreen({super.key, required this.checklist});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.surfaceDarkTheme : Colors.white;
    final border = isDark ? AppColors.borderDefaultDark : AppColors.borderLight;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDarkTheme : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Checklist Details'),
        actions: [
          IconButton(
            onPressed: () async {
              final updated = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateChecklistTemplateScreen(
                    checklist: checklist,
                  ),
                ),
              );
              if (updated == true && context.mounted) {
                Navigator.pop(context, true);
              }
            },
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    checklist.nome,
                    style: AppTypography.headline3.copyWith(
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${checklist.itens.length} items · v${checklist.versao ?? 1}',
                    style: AppTypography.caption.copyWith(
                      color: isDark ? AppColors.slate300 : AppColors.slate600,
                    ),
                  ),
                  if ((checklist.descricao ?? '').isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      checklist.descricao ?? '',
                      style: AppTypography.bodyTextSmall.copyWith(
                        color: isDark ? AppColors.slate300 : AppColors.slate600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Itens do checklist',
                    style: AppTypography.subtitle1.copyWith(
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...checklist.itens.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 6),
                            decoration: BoxDecoration(
                              color: item.critico
                                  ? AppColors.statusFailedText
                                  : AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.descricao,
                                  style: AppTypography.bodyTextSmall.copyWith(
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    _tag(
                                      item.critico ? 'Crítico' : 'Normal',
                                      item.critico
                                          ? AppColors.statusFailedBg
                                          : AppColors.statusInProgressBg,
                                      item.critico
                                          ? AppColors.statusFailedText
                                          : AppColors.statusInProgressText,
                                    ),
                                    const SizedBox(width: 8),
                                    _tag(
                                      item.obrigatorioFoto
                                          ? 'Foto obrigatória'
                                          : 'Sem foto',
                                      item.obrigatorioFoto
                                          ? AppColors.statusPendingBg
                                          : AppColors.slate100,
                                      item.obrigatorioFoto
                                          ? AppColors.statusPendingText
                                          : AppColors.slate600,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: AppTypography.captionSmall.copyWith(
          color: text,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
