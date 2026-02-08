import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/user_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../l10n/app_localizations.dart';

/// Fixit User Registration Screen
/// Responsive registration screen that adapts to all screen sizes
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedLanguage = 'en';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final result = await userProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      language: _selectedLanguage,
      companyName: _companyController.text.trim().isEmpty
          ? null
          : _companyController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result['success']) {
      final successMessage = result['message'];
      debugPrint('✅ Registration successful: $successMessage');
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
        ),
      );

      // Navigate to home if auto-logged in, or back to login
      if (userProvider.isAuthenticated) {
        context.go('/');
      } else {
        Navigator.of(context).pop();
      }
    } else {
      final errorMessage = result['message'];
      debugPrint('❌ Registration error: $errorMessage');
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDarkTheme
          : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.backgroundDarkTheme
            : AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.registerTitle,
          style: AppTypography.headline3.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16 : 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 24),

                        // Header
                        _buildHeader(isDark),

                        const SizedBox(height: 32),

                        // Form
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.surfaceDarkTheme
                                  : Colors.white,
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
                                        color:
                                            AppColors.shadow.withOpacity(0.08),
                                        blurRadius: 16,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  // Full Name
                                  _buildTextField(
                                    controller: _nameController,
                                    label: 'Full Name',
                                    hint: 'Enter your full name',
                                    isDark: isDark,
                                    keyboardType: TextInputType.name,
                                    textInputAction: TextInputAction.next,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your full name';
                                      }
                                      if (value.length < 3) {
                                        return 'Name must be at least 3 characters';
                                      }
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 16),

                                  // Company Name
                                  _buildTextField(
                                    controller: _companyController,
                                    label: 'Company Name',
                                    hint: 'Enter your company name',
                                    isDark: isDark,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your company name';
                                      }
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 16),

                                  // Email
                                  _buildTextField(
                                    controller: _emailController,
                                    label: 'Email Address',
                                    hint: 'name@company.com',
                                    isDark: isDark,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return l10n.emailRequired;
                                      }
                                      if (!value.contains('@')) {
                                        return l10n.emailInvalid;
                                      }
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 16),

                                  // Language Selector
                                  _buildLanguageSelector(isDark, l10n),

                                  const SizedBox(height: 16),

                                  // Password
                                  _buildPasswordField(
                                    controller: _passwordController,
                                    label: l10n.passwordLabelText,
                                    hint: l10n.passwordHint,
                                    isDark: isDark,
                                    obscureText: _obscurePassword,
                                    onToggleVisibility: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return l10n.passwordRequired;
                                      }
                                      if (value.length < 8) {
                                        return l10n.passwordMin8;
                                      }
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 16),

                                  // Confirm Password
                                  _buildPasswordField(
                                    controller: _confirmPasswordController,
                                    label: l10n.confirmPasswordLabel,
                                    hint: l10n.confirmPasswordHint,
                                    isDark: isDark,
                                    obscureText: _obscureConfirmPassword,
                                    onToggleVisibility: () {
                                      setState(() {
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
                                      });
                                    },
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _submit(),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return l10n.confirmPasswordRequired;
                                      }
                                      if (value != _passwordController.text) {
                                        return l10n.passwordsDoNotMatch;
                                      }
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 40),

                                  // Submit Button
                                  _buildSubmitButton(l10n),

                                  const SizedBox(height: 24),

                                  // Login Link
                                  _buildLoginLink(isDark, l10n),

                                  const SizedBox(height: 32),

                                  // Legal Notice
                                  _buildLegalNotice(isDark, l10n),

                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Bottom Indicator
                        _buildBottomIndicator(),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Join Fixit',
          style: AppTypography.headline1.copyWith(
            fontSize: 32,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage maintenance and service orders globally.',
          style: AppTypography.bodyText.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.label.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction ?? TextInputAction.next,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.all(15),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildLanguageSelector(bool isDark, AppLocalizations l10n) {
    final languages = [
      {'code': 'en', 'name': '🇺🇸 ${l10n.englishLabel} (US)'},
      {'code': 'pt', 'name': '🇧🇷 ${l10n.portugueseLabel} (BR)'},
      {'code': 'es', 'name': '🇪🇸 Español'},
      {'code': 'fr', 'name': '🇫🇷 Français'},
      {'code': 'it', 'name': '🇮🇹 Italiano'},
      {'code': 'de', 'name': '🇩🇪 Deutsch'},
      {'code': 'zh', 'name': '🇨🇳 简体中文'},
      {'code': 'ko', 'name': '🇰🇷 한국어'},
      {'code': 'ja', 'name': '🇯🇵 日本語'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.initialLanguage,
          style: AppTypography.label.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedLanguage,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(15),
            suffixIcon: Icon(
              Icons.expand_more,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          items: languages.map((lang) {
            return DropdownMenuItem<String>(
              value: lang['code'],
              child: Text(lang['name']!),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedLanguage = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    TextInputAction? textInputAction,
    void Function(String)? onFieldSubmitted,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.label.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          textInputAction: textInputAction ?? TextInputAction.next,
          onFieldSubmitted: onFieldSubmitted,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.all(15),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility : Icons.visibility_off,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
              onPressed: onToggleVisibility,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildSubmitButton(AppLocalizations l10n) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                l10n.createAccount,
                style: AppTypography.button.copyWith(
                  fontSize: 18,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Widget _buildLoginLink(bool isDark, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.alreadyHaveAccount,
          style: AppTypography.bodyTextSmall.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textTertiary,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            l10n.logIn,
            style: AppTypography.bodyTextSmall.copyWith(
              color: isDark ? AppColors.primaryDarkTheme : AppColors.primary,
              fontWeight: AppTypography.semiBold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegalNotice(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: AppTypography.captionSmall.copyWith(
              fontSize: 11,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textSecondary,
            ),
            children: [
              TextSpan(text: l10n.termsPrefix),
              TextSpan(
                text: l10n.termsOfService,
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: isDark
                      ? AppColors.primaryDarkTheme
                      : AppColors.primary,
                ),
              ),
              TextSpan(text: l10n.andConjunction),
              TextSpan(
                text: l10n.privacyPolicy,
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: isDark
                      ? AppColors.primaryDarkTheme
                      : AppColors.primary,
                ),
              ),
              const TextSpan(text: '.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomIndicator() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Container(
        width: 128,
        height: 6,
        decoration: BoxDecoration(
          color: isDark ? AppColors.borderDefaultDark : AppColors.slate300,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}
