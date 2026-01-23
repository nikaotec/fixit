import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Status Badge Widget
/// Displays status with semantic colors matching the design system
class StatusBadge extends StatelessWidget {
  final String label;
  final StatusType type;

  const StatusBadge({super.key, required this.label, required this.type});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = _getColors(isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
        border: isDark ? Border.all(color: colors.border!, width: 1) : null,
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.badge.copyWith(
          color: colors.text,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  _BadgeColors _getColors(bool isDark) {
    if (isDark) {
      switch (type) {
        case StatusType.completed:
          return const _BadgeColors(
            background: AppColors.statusCompletedBgDark,
            text: AppColors.statusCompletedTextDark,
            border: AppColors.statusCompletedBorderDark,
          );
        case StatusType.pending:
          return const _BadgeColors(
            background: AppColors.statusPendingBgDark,
            text: AppColors.statusPendingTextDark,
            border: AppColors.statusPendingBorderDark,
          );
        case StatusType.inProgress:
          return const _BadgeColors(
            background: AppColors.statusInProgressBgDark,
            text: AppColors.statusInProgressTextDark,
            border: AppColors.statusInProgressBorderDark,
          );
        case StatusType.failed:
          return const _BadgeColors(
            background: AppColors.statusFailedBgDark,
            text: AppColors.statusFailedTextDark,
            border: AppColors.statusFailedBorderDark,
          );
      }
    } else {
      switch (type) {
        case StatusType.completed:
          return const _BadgeColors(
            background: AppColors.statusCompletedBg,
            text: AppColors.statusCompletedText,
          );
        case StatusType.pending:
          return const _BadgeColors(
            background: AppColors.statusPendingBg,
            text: AppColors.statusPendingText,
          );
        case StatusType.inProgress:
          return const _BadgeColors(
            background: AppColors.statusInProgressBg,
            text: AppColors.statusInProgressText,
          );
        case StatusType.failed:
          return const _BadgeColors(
            background: AppColors.statusFailedBg,
            text: AppColors.statusFailedText,
          );
      }
    }
  }
}

enum StatusType { completed, pending, inProgress, failed }

class _BadgeColors {
  final Color background;
  final Color text;
  final Color? border;

  const _BadgeColors({
    required this.background,
    required this.text,
    this.border,
  });
}

/// Section Header Widget
/// Displays section headers with consistent styling
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const SectionHeader({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.headline2.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Overline Label Widget
/// Small uppercase labels for categorization
class OverlineLabel extends StatelessWidget {
  final String text;
  final Color? color;

  const OverlineLabel({super.key, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTypography.overline.copyWith(color: color ?? AppColors.primary),
    );
  }
}

/// Description List Item
/// Two-column layout for key-value pairs
class DescriptionListItem extends StatelessWidget {
  final String label;
  final String value;
  final bool showDivider;

  const DescriptionListItem({
    super.key,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(
                bottom: BorderSide(color: AppColors.divider, width: 1),
              )
            : null,
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyTextSmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: AppTypography.medium,
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyTextSmall.copyWith(
                color: AppColors.textPrimary,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

/// Icon Container
/// Displays Material Symbols icons with consistent styling
class IconContainer extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double? size;

  const IconContainer({super.key, required this.icon, this.color, this.size});

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: color ?? AppColors.primary, size: size ?? 24);
  }
}
