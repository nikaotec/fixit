import 'package:flutter/material.dart';

import '../models/technician.dart';
import '../services/firestore_technician_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class TechnicianProfileScreen extends StatefulWidget {
  final Technician technician;
  final VoidCallback? onCall;
  final VoidCallback? onAssign;

  const TechnicianProfileScreen({
    super.key,
    required this.technician,
    this.onCall,
    this.onAssign,
  });

  @override
  State<TechnicianProfileScreen> createState() =>
      _TechnicianProfileScreenState();
}

class _TechnicianProfileScreenState extends State<TechnicianProfileScreen> {
  bool _isSubmitting = false;
  bool _isRefreshing = false;
  late Technician _tech;

  @override
  void initState() {
    super.initState();
    _tech = widget.technician;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? AppColors.backgroundDarkTheme
        : AppColors.backgroundLight;
    final surface = isDark ? AppColors.surfaceDarkTheme : Colors.white;
    final border = isDark ? AppColors.borderDefaultDark : AppColors.borderLight;
    final text = isDark ? Colors.white : AppColors.textPrimary;
    final subtitle = isDark ? AppColors.slate300 : AppColors.slate600;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(title: const Text('Perfil do Técnico')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: border),
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
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: _tech.status.color.withOpacity(0.15),
                    backgroundImage: _tech.avatarUrl != null
                        ? NetworkImage(_tech.avatarUrl!)
                        : null,
                    child: _tech.avatarUrl == null
                        ? Text(
                            _tech.name.isNotEmpty ? _tech.name[0] : '?',
                            style: AppTypography.headline3.copyWith(
                              color: _tech.status.color,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _tech.name,
                    style: AppTypography.headline2.copyWith(
                      color: text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _tech.role,
                    style: AppTypography.bodyText.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_tech.email != null && _tech.email!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      _tech.email!,
                      style: AppTypography.caption.copyWith(color: subtitle),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _StatusBadge(status: _tech.status),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildStatsCard(
              surface: surface,
              border: border,
              isDark: isDark,
              subtitle: subtitle,
            ),
            const SizedBox(height: 12),
            Text(
              '${_tech.reviewCount} avaliações registradas',
              style: AppTypography.caption.copyWith(color: subtitle),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'Ligar',
                    icon: Icons.call_outlined,
                    onTap: widget.onCall ?? () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    label: 'Atribuir',
                    icon: Icons.assignment_turned_in_outlined,
                    onTap: widget.onAssign ?? () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ActionButton(
              label: 'Avaliar técnico',
              icon: Icons.rate_review_outlined,
              onTap: _openReviewSheet,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard({
    required Color surface,
    required Color border,
    required bool isDark,
    required Color subtitle,
  }) {
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
                  color: AppColors.shadow.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Row(
        children: [
          _StatItem(
            label: 'Status',
            value: _tech.status.label,
            valueColor: _tech.status.color,
          ),
          _StatDivider(color: subtitle),
          _StatItem(
            label: 'Avaliação',
            value: _tech.rating > 0 ? _tech.rating.toStringAsFixed(1) : '-',
          ),
          _StatDivider(color: subtitle),
          _StatItem(label: 'Tarefas', value: _tech.completed.toString()),
        ],
      ),
    );
  }

  Future<void> _openReviewSheet() async {
    final controller = TextEditingController();
    double rating = 5;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final surface = isDark ? AppColors.surfaceDarkTheme : Colors.white;
        final border = isDark
            ? AppColors.borderDefaultDark
            : AppColors.borderLight;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              border: Border.all(color: border),
            ),
            child: StatefulBuilder(
              builder: (context, setSheetState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Avaliar técnico',
                      style: AppTypography.headline3.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _RatingRow(
                      rating: rating,
                      onChanged: (value) => setSheetState(() => rating = value),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Deixe um comentário (opcional)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ActionButton(
                      label: _isSubmitting ? 'Enviando...' : 'Enviar avaliação',
                      icon: Icons.check_circle_outline,
                      onTap: _isSubmitting
                          ? () {}
                          : () => _submitReview(rating, controller.text),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
    controller.dispose();
  }

  Future<void> _submitReview(double rating, String comment) async {
    setState(() => _isSubmitting = true);
    try {
      await FirestoreTechnicianService.submitReview(
        technicianId: _tech.id,
        rating: rating,
        comment: comment,
      );
      await _refreshTechnician();
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avaliação enviada com sucesso')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erro ao enviar avaliação')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _refreshTechnician() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    try {
      final list = await FirestoreTechnicianService.getAll();
      final updated = list.firstWhere(
        (item) => item.id == _tech.id,
        orElse: () => _tech,
      );
      if (!mounted) return;
      setState(() => _tech = updated);
    } catch (_) {
      // Keep current data if refresh fails.
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: AppTypography.bodyText.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatItem({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitle = isDark ? AppColors.slate300 : AppColors.slate600;
    final text = isDark ? Colors.white : AppColors.textPrimary;
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: AppTypography.captionSmall.copyWith(color: subtitle),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.bodyText.copyWith(
              color: valueColor ?? text,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  final Color color;

  const _StatDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 36, color: color.withOpacity(0.2));
  }
}

class _StatusBadge extends StatelessWidget {
  final TechnicianStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: AppTypography.captionSmall.copyWith(
          color: status.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onChanged;

  const _RatingRow({required this.rating, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        final value = index + 1;
        final selected = rating >= value;
        return IconButton(
          onPressed: () => onChanged(value.toDouble()),
          icon: Icon(
            selected ? Icons.star : Icons.star_border,
            color: AppColors.warning,
          ),
        );
      }),
    );
  }
}
