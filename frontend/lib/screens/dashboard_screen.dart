import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../l10n/app_localizations.dart';

import '../theme/app_typography.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.backgroundDarkTheme
        : AppColors.backgroundLight;
    final surfaceColor = isDark
        ? AppColors.surfaceDarkTheme
        : AppColors.surfaceLight;
    final borderColor = isDark
        ? AppColors.borderDefaultDark
        : AppColors.borderLight;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final textSecondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textTertiary;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: _selectedIndex == 0
            ? SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(
                      context,
                      isDark,
                      textSecondaryColor,
                      textColor,
                      borderColor,
                      l10n,
                    ),

                    // Stats Section
                    _buildStatsSection(
                      context,
                      isDark,
                      surfaceColor,
                      borderColor,
                      textColor,
                      textSecondaryColor,
                      l10n,
                    ),

                    // Quick Actions
                    _buildQuickActions(
                      context,
                      isDark,
                      surfaceColor,
                      borderColor,
                      textColor,
                      l10n,
                    ),

                    // Recent Service Orders
                    _buildRecentOrders(
                      context,
                      isDark,
                      surfaceColor,
                      borderColor,
                      textColor,
                      textSecondaryColor,
                      l10n,
                    ),

                    const SizedBox(height: 100), // Space for bottom nav
                  ],
                ),
              )
            : _selectedIndex == 4
            ? const ProfileScreen()
            : Center(
                child: Text(
                  "Tab $_selectedIndex Placeholder",
                  style: TextStyle(color: textColor),
                ),
              ), // Placeholder for other tabs
      ),
      bottomNavigationBar: _buildBottomNavigationBar(
        context,
        isDark,
        surfaceColor,
        borderColor,
        l10n,
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isDark,
    Color textSecondaryColor,
    Color textColor,
    Color borderColor,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.backgroundDarkTheme
            : AppColors.backgroundLight,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor),
                  image: const DecorationImage(
                    image: NetworkImage(
                      "https://lh3.googleusercontent.com/aida-public/AB6AXuC0JyGIBwMgPDUazXA3m9awNDpvKXwvEGmPt3sv7kTgj3j-g7U5c8Ehfke8N_rIHR3EzIz2fEiKR3GXuCoyAiz77RAs1QPghgCkKbfeZOupZ7Ma6iEBvJiWaHEuJ2VJYtTvvrid-smXqyFHHWGgphiap7sgNFjGLQ8XcVdWlh6fcUAqeLbND6N0VMdxXGgypOVEdU-0jC6glJrADSY4i4IbGPXRdmyoLfKV9NKzDOfYQfL9OintehvzikLxTIVtiL4gkIPhsagnNVg",
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.mainDashboard,
                    style: AppTypography.subtitle2.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    'Global Tech Solutions',
                    style: AppTypography.captionSmall.copyWith(
                      color: textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: textColor,
                  size: 24,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.backgroundDark : Colors.white,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(
    BuildContext context,
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color textSecondaryColor,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStatCard(
            l10n.statusOpen,
            '12',
            '+2%',
            AppColors.success,
            isDark,
            surfaceColor,
            borderColor,
            textColor,
            textSecondaryColor,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            l10n.statusFinished, // Used for "Completed"
            '45',
            '+15%',
            AppColors.success,
            isDark,
            surfaceColor,
            borderColor,
            textColor,
            textSecondaryColor,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            l10n.statusOverdue,
            '3',
            '-5%',
            AppColors.danger,
            isDark,
            surfaceColor,
            borderColor,
            textColor,
            textSecondaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String trend,
    Color trendColor,
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color textSecondaryColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: AppTypography.overline.copyWith(
                color: textSecondaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: AppTypography.headline2.copyWith(
                    color:
                        (label == 'Open' ||
                            label == 'Aberta' ||
                            label ==
                                'Open') // Simplistic check, better logic needed if keys change often
                        ? AppColors.primary
                        : ((label == 'Overdue' || label == 'Atrasada')
                              ? AppColors.danger
                              : textColor),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  trend,
                  style: AppTypography.captionSmall.copyWith(
                    color: trendColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.quickActions,
            style: AppTypography.subtitle1.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  Icons.precision_manufacturing_outlined,
                  l10n.createEquipment,
                  isDark,
                  surfaceColor,
                  borderColor,
                  textColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  Icons.rule_outlined,
                  l10n.createChecklist,
                  isDark,
                  surfaceColor,
                  borderColor,
                  textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // New Service Order Button (Full Width)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_circle_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.newOrder,
                      style: AppTypography.button.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    IconData icon,
    String label,
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: AppTypography.bodyTextSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrders(
    BuildContext context,
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color textSecondaryColor,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.recentOrders,
                style: AppTypography.subtitle1.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  l10n.viewAll,
                  style: AppTypography.bodyTextSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildOrderCard(
            'SO-8821',
            'HVAC Unit Replacement',
            'High Priority',
            AppColors.warningLight.withOpacity(0.3), // Mock orange-ish
            Colors.orange[900]!, // Mock orange-ish
            'Warehouse B-12',
            '2h ago',
            isDark,
            surfaceColor,
            borderColor,
            textColor,
            textSecondaryColor,
          ),
          const SizedBox(height: 12),
          _buildOrderCard(
            'SO-8819',
            'Annual Generator Inspection',
            'Medium',
            AppColors.infoLight.withOpacity(0.3),
            AppColors.infoDark,
            'Main Facility',
            '5h ago',
            isDark,
            surfaceColor,
            borderColor,
            textColor,
            textSecondaryColor,
          ),
          const SizedBox(height: 12),
          _buildOrderCard(
            'SO-8815',
            'Conveyor Belt Lubrication',
            'Routine',
            AppColors.slate100,
            AppColors.slate600,
            'Production Line 4',
            '1d ago',
            isDark,
            surfaceColor,
            borderColor,
            textColor,
            textSecondaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(
    String id,
    String title,
    String badgeText,
    Color badgeBg,
    Color badgeTextCol,
    String location,
    String time,
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color textSecondaryColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      id,
                      style: AppTypography.overline.copyWith(
                        color: textSecondaryColor,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: AppTypography.bodyTextSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? badgeBg.withOpacity(0.2) : badgeBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badgeText.toUpperCase(),
                  style: AppTypography.overline.copyWith(
                    fontSize: 10,
                    color: isDark
                        ? badgeTextCol.withOpacity(0.8)
                        : badgeTextCol,
                    letterSpacing: 0.5,
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: textSecondaryColor,
              ),
              const SizedBox(width: 4),
              Text(
                location,
                style: AppTypography.captionSmall.copyWith(
                  color: textSecondaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time, size: 16, color: textSecondaryColor),
              const SizedBox(width: 4),
              Text(
                time,
                style: AppTypography.captionSmall.copyWith(
                  color: textSecondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(
    BuildContext context,
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    AppLocalizations l10n,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            Icons.dashboard_outlined,
            l10n.home,
            _selectedIndex == 0,
            isDark,
            0,
          ),
          _buildNavItem(
            Icons.assignment_turned_in_outlined,
            l10n.ordersTab,
            _selectedIndex == 1,
            isDark,
            1,
          ),
          _buildNavItem(
            Icons.inventory_2_outlined,
            l10n.assets,
            _selectedIndex == 2,
            isDark,
            2,
          ),
          _buildNavItem(
            Icons.analytics_outlined,
            l10n.reports,
            _selectedIndex == 3,
            isDark,
            3,
          ),
          _buildNavItem(
            Icons.settings_outlined,
            l10n.settingsTab,
            _selectedIndex == 4,
            isDark,
            4,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive,
    bool isDark,
    int index,
  ) {
    final color = isActive
        ? AppColors.primary
        : (isDark ? AppColors.slate500 : AppColors.slate400);
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}
