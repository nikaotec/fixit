import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../providers/user_provider.dart';
import '../l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
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
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.backgroundDarkTheme : Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
            ),
            child: Icon(Icons.arrow_back_ios_new, size: 20, color: textColor),
          ),
        ),
        title: Text(
          l10n.profileTitle,
          style: AppTypography.headline3.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: borderColor, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDarkTheme : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
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
                children: [
                  Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.1),
                        width: 4,
                      ),
                      image:
                          userProvider.photoURL != null &&
                              userProvider.photoURL!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(userProvider.photoURL!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color:
                          userProvider.photoURL == null ||
                              userProvider.photoURL!.isEmpty
                          ? AppColors.primary.withOpacity(0.12)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child:
                        userProvider.photoURL == null ||
                            userProvider.photoURL!.isEmpty
                        ? Center(
                            child: Text(
                              (userProvider.name ?? 'U')
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: AppTypography.headline1.copyWith(
                                color: AppColors.primary,
                                fontSize: 48,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userProvider.name ?? 'Alex Rivera',
                    style: AppTypography.headline2.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  if (userProvider.role != null &&
                      userProvider.role!.isNotEmpty)
                    Text(
                      userProvider.role!,
                      style: AppTypography.bodyText.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 4),
                  Text(
                    userProvider.email ?? 'alex.rivera@servicedesk.com',
                    style: AppTypography.caption.copyWith(
                      color: textSecondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Account Settings Section
            _buildSectionHeader(l10n.accountSettings, textSecondaryColor),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: surfaceColor,
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(16),
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
                children: [
                  _buildListTile(
                    icon: Icons.person_outline,
                    title: l10n.personalInformation,
                    isDark: isDark,
                    textColor: textColor,
                    borderColor: borderColor,
                    context: context,
                  ),
                  _buildListTile(
                    icon: Icons.lock_outline,
                    title: l10n.securityPassword,
                    isDark: isDark,
                    textColor: textColor,
                    borderColor: borderColor,
                    context: context,
                    isLast: true,
                  ),
                ],
              ),
            ),

            // Preferences Section
            _buildSectionHeader(l10n.preferences, textSecondaryColor),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: surfaceColor,
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(16),
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
                children: [
                  _buildListTile(
                    icon: Icons.language,
                    title: l10n.languageLabel,
                    isDark: isDark,
                    textColor: textColor,
                    borderColor: borderColor,
                    context: context,
                    onTap: () => _showLanguageDialog(context),
                    trailing: _buildLanguageTrailing(
                      isDark,
                      textSecondaryColor,
                      context,
                    ),
                  ),
                  _buildListTile(
                    icon: Icons.notifications_outlined,
                    title: l10n.notifications,
                    isDark: isDark,
                    textColor: textColor,
                    borderColor: borderColor,
                    context: context,
                  ),
                  _buildListTile(
                    icon: isDark ? Icons.dark_mode : Icons.dark_mode_outlined,
                    title: l10n.darkMode,
                    isDark: isDark,
                    textColor: textColor,
                    borderColor: borderColor,
                    context: context,
                    isLast: true,
                    // Connected to UserProvider with theme consistency
                    trailing: Switch(
                      value:
                          userProvider.themeMode == ThemeMode.dark ||
                          (userProvider.themeMode == ThemeMode.system &&
                              MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark),
                      onChanged: (bool value) {
                        userProvider.toggleTheme(value);
                      },
                      activeColor: Colors.white,
                      activeTrackColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        userProvider.logout();
                        context.go('/');
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.danger.withOpacity(0.3),
                        ),
                        foregroundColor: AppColors.danger,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: AppTypography.button,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, size: 20),
                          SizedBox(width: 8),
                          Text(l10n.logoutButton),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '${l10n.maintenancePro} v2.4.1',
                    style: AppTypography.captionSmall.copyWith(
                      color: textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '© 2025 Fixit',
                    style: AppTypography.captionSmall.copyWith(
                      color: textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80), // Bottom nav space
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: AppTypography.overline.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required bool isDark,
    required Color textColor,
    required Color borderColor,
    required BuildContext context,
    Widget? trailing,
    bool isLast = false,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          constraints: const BoxConstraints(minHeight: 56),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : Border(
                    bottom: BorderSide(color: borderColor.withOpacity(0.5)),
                  ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.bodyText.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (trailing != null)
                trailing
              else
                Icon(
                  Icons.chevron_right,
                  color: isDark ? AppColors.slate400 : AppColors.slate300,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final l10n = AppLocalizations.of(context)!;
        final languages = _languageOptions(l10n);
        return AlertDialog(
          title: Text(l10n.languageLabel),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: languages.map((lang) {
              return ListTile(
                title: Text(lang['label']!),
                leading: Text(lang['flag']!),
                onTap: () {
                  userProvider.setLocale(Locale(lang['code']!));
                  Navigator.pop(context);
                },
                selected: userProvider.locale.languageCode == lang['code'],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  List<Map<String, String>> _languageOptions(AppLocalizations l10n) {
    return [
      {'code': 'en', 'label': '${l10n.englishLabel} (US)', 'flag': '🇺🇸'},
      {'code': 'pt', 'label': '${l10n.portugueseLabel} (BR)', 'flag': '🇧🇷'},
      {'code': 'es', 'label': 'Español', 'flag': '🇪🇸'},
      {'code': 'fr', 'label': 'Français', 'flag': '🇫🇷'},
      {'code': 'it', 'label': 'Italiano', 'flag': '🇮🇹'},
      {'code': 'de', 'label': 'Deutsch', 'flag': '🇩🇪'},
      {'code': 'zh', 'label': '简体中文', 'flag': '🇨🇳'},
      {'code': 'ko', 'label': '한국어', 'flag': '🇰🇷'},
      {'code': 'ja', 'label': '日本語', 'flag': '🇯🇵'},
    ];
  }

  Widget _buildLanguageTrailing(
    bool isDark,
    Color textSecondaryColor,
    BuildContext context,
  ) {
    // We need context to access provider here if we want dynamic flag/text,
    // but typically trailing is just display.
    // Ideally pass current language from provider higher up.
    // For now, let's just make it look right.
    // We can use Provider.of(context) here if we change the signature or if context is available.
    final userProvider = Provider.of<UserProvider>(context);
    final l10n = AppLocalizations.of(context)!;
    final current = _languageOptions(l10n).firstWhere(
      (lang) => lang['code'] == userProvider.locale.languageCode,
      orElse: () => {'label': '${l10n.englishLabel} (US)', 'flag': '🇺🇸'},
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 16,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(
              current['flag'] ?? '🇺🇸',
              style: const TextStyle(fontSize: 10),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          current['label'] ?? '${l10n.englishLabel} (US)',
          style: AppTypography.bodyText.copyWith(
            color: textSecondaryColor,
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          Icons.chevron_right,
          color: isDark ? AppColors.slate400 : AppColors.slate300,
          size: 20,
        ),
      ],
    );
  }
}
