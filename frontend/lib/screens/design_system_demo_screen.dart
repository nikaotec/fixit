import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/design_system_widgets.dart';

/// Example screen demonstrating the Fixit Design System
class DesignSystemDemoScreen extends StatelessWidget {
  const DesignSystemDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Fixit Style Guide'),
            Text(
              'Version 1.0 - Light Mode',
              style: AppTypography.captionSmall.copyWith(
                color: AppColors.textTertiary,
                fontWeight: AppTypography.medium,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Color Palette Section
            const SectionHeader(
              title: 'Color Palette',
              subtitle: 'Brand & Semantic Colors',
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.slate50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Wrap(
                  spacing: 20,
                  runSpacing: 16,
                  children: [
                    _ColorSwatch(color: AppColors.primary, label: 'BRAND'),
                    _ColorSwatch(color: AppColors.success, label: 'SUCCESS'),
                    _ColorSwatch(color: AppColors.warning, label: 'WARN'),
                    _ColorSwatch(color: AppColors.danger, label: 'DANGER'),
                    _ColorSwatch(color: AppColors.textPrimary, label: 'DARK'),
                  ],
                ),
              ),
            ),

            // Color Codes
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  DescriptionListItem(label: 'Brand Blue', value: '#2196F3'),
                  DescriptionListItem(label: 'Success Green', value: '#4CAF50'),
                  DescriptionListItem(label: 'Warning Amber', value: '#FFB300'),
                  DescriptionListItem(
                    label: 'Danger Red',
                    value: '#F44336',
                    showDivider: false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Typography Section
            const SectionHeader(
              title: 'Typography',
              subtitle: 'Font Family: Inter',
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const OverlineLabel(text: 'Headline 1'),
                  const SizedBox(height: 4),
                  Text(
                    'The quick brown fox',
                    style: AppTypography.headline1.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  const OverlineLabel(text: 'Headline 2'),
                  const SizedBox(height: 4),
                  Text(
                    'Jumps over the lazy dog',
                    style: AppTypography.headline2.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  const OverlineLabel(text: 'Body Text'),
                  const SizedBox(height: 4),
                  Text(
                    'Fixit provides professional maintenance and repair services for your home and office. Quality you can trust.',
                    style: AppTypography.bodyText.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  const OverlineLabel(text: 'Caption'),
                  const SizedBox(height: 4),
                  Text(
                    'Updated 2 minutes ago by Admin',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Interactive Elements Section
            const SectionHeader(title: 'Interactive Elements'),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Buttons
                  const OverlineLabel(text: 'Buttons'),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Primary Action'),
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {},
                      child: const Text('Secondary Action'),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Status Badges
                  const OverlineLabel(text: 'Status Badges'),
                  const SizedBox(height: 12),

                  const Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      StatusBadge(
                        label: 'Completed',
                        type: StatusType.completed,
                      ),
                      StatusBadge(label: 'Pending', type: StatusType.pending),
                      StatusBadge(
                        label: 'In Progress',
                        type: StatusType.inProgress,
                      ),
                      StatusBadge(label: 'Failed', type: StatusType.failed),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Input Fields
                  const OverlineLabel(text: 'Input Fields'),
                  const SizedBox(height: 12),

                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'hello@fixit.com',
                    ),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Service Category',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'plumbing',
                        child: Text('Plumbing'),
                      ),
                      DropdownMenuItem(
                        value: 'electrical',
                        child: Text('Electrical'),
                      ),
                      DropdownMenuItem(
                        value: 'carpentry',
                        child: Text('Carpentry'),
                      ),
                    ],
                    onChanged: (value) {},
                  ),

                  const SizedBox(height: 32),

                  // Icons
                  const OverlineLabel(text: 'Icon Samples'),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(Icons.home, color: AppColors.primary, size: 28),
                        Icon(
                          Icons.settings,
                          color: AppColors.primary,
                          size: 28,
                        ),
                        Icon(Icons.person, color: AppColors.primary, size: 28),
                        Icon(
                          Icons.notifications,
                          color: AppColors.primary,
                          size: 28,
                        ),
                        Icon(Icons.search, color: AppColors.primary, size: 28),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final Color color;
  final String label;

  const _ColorSwatch({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderLight, width: 1),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTypography.overline.copyWith(color: AppColors.textDisabled),
        ),
      ],
    );
  }
}
