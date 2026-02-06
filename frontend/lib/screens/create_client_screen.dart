import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../services/cliente_service.dart';
import '../utils/validators.dart';
import '../widgets/floating_warning_card.dart';

/// Screen for creating a new client (individual or corporate)
/// Follows the Fixit design system with iOS-style navigation
class CreateClientScreen extends StatefulWidget {
  const CreateClientScreen({super.key});

  @override
  State<CreateClientScreen> createState() => _CreateClientScreenState();
}

class _CreateClientScreenState extends State<CreateClientScreen> {
  final _formKey = GlobalKey<FormState>();

  // Client type
  ClientType _clientType = ClientType.individual;

  // Form controllers
  final _nameController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _positionController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _taxIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _zipCodeController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _contactNameController.dispose();
    _positionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  Future<void> _lookupZipCode() async {
    final cep = _zipCodeController.text.replaceAll(RegExp(r'\\D'), '');
    if (cep.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CEP inválido')),
      );
      return;
    }
    try {
      final response =
          await http.get(Uri.parse('https://viacep.com.br/ws/$cep/json/'));
      if (response.statusCode != 200) {
        throw Exception('Falha ao consultar CEP');
      }
      final data = jsonDecode(response.body);
      if (data['erro'] == true) {
        throw Exception('CEP não encontrado');
      }
      setState(() {
        _streetController.text = data['logradouro'] ?? '';
        _neighborhoodController.text = data['bairro'] ?? '';
        _cityController.text = data['localidade'] ?? '';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar CEP: ${e.toString()}')),
      );
    }
  }

  Future<void> _saveClient() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = Provider.of<UserProvider>(context, listen: false).token;
      if (token == null) {
        throw Exception('Usuário não autenticado');
      }

      await ClienteService.criarCliente(
        token: token,
        tipo: _clientType == ClientType.individual ? 'INDIVIDUAL' : 'CORPORATE',
        nome: _nameController.text,
        documento: _taxIdController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        telefone: _phoneController.text.isEmpty ? null : _phoneController.text,
        cep: _zipCodeController.text.isEmpty ? null : _zipCodeController.text,
        rua: _streetController.text.isEmpty ? null : _streetController.text,
        numero: _numberController.text.isEmpty ? null : _numberController.text,
        bairro: _neighborhoodController.text.isEmpty
            ? null
            : _neighborhoodController.text,
        cidade: _cityController.text.isEmpty ? null : _cityController.text,
        nomeContato: _contactNameController.text.isEmpty
            ? null
            : _contactNameController.text,
        cargoContato: _positionController.text.isEmpty
            ? null
            : _positionController.text,
        notasInternas: _notesController.text.isEmpty
            ? null
            : _notesController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.saveClient),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        if (e is DuplicateClientException) {
          _showFloatingWarning(e);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao salvar cliente: ${e.toString()}'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showFloatingWarning(DuplicateClientException e) {
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: FloatingWarningCard(
            onDismiss: () {
              overlayEntry.remove();
            },
            onViewProfile: () async {
              overlayEntry.remove();
              if (e.conflictId != null) {
                Navigator.pop(context); // Close create screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cliente já existe na lista.'),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    // Auto dismiss after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // iOS-style navigation bar
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            l10n.cancel,
            style: AppTypography.button.copyWith(color: AppColors.primary),
          ),
        ),
        title: Text(
          l10n.createNewClient,
          style: AppTypography.headline3.copyWith(
            fontWeight: AppTypography.bold,
          ),
        ),
        centerTitle: true,
        leadingWidth: 80,
        actions: const [SizedBox(width: 80)], // Spacer for balance
      ),

      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Scrollable form content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Client Type Segmented Control
                    _buildClientTypeSelector(l10n, isDark),

                    const SizedBox(height: 24),

                    // Basic Information Section
                    _buildSection(
                      title: l10n.basicInformation,
                      child: _buildBasicInformationFields(l10n),
                    ),

                    const SizedBox(height: 24),

                    // Location Details Section
                    _buildSection(
                      title: l10n.locationDetails,
                      child: _buildLocationFields(l10n),
                    ),

                    const SizedBox(height: 24),

                    // Primary Contact Section (Optional)
                    _buildSection(
                      title: l10n.primaryContact,
                      optional: true,
                      child: _buildPrimaryContactFields(l10n),
                      highlighted: true,
                    ),

                    const SizedBox(height: 24),

                    // Internal Notes Section
                    _buildSection(
                      title: l10n.internalNotes,
                      child: _buildNotesField(l10n),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Fixed bottom button
            _buildBottomButton(l10n, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildClientTypeSelector(AppLocalizations l10n, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDarkTheme : AppColors.slate100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.borderDefaultDark : AppColors.borderLight,
          ),
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
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Expanded(
              child: _buildSegmentButton(
                label: l10n.individual,
                isSelected: _clientType == ClientType.individual,
                onTap: () =>
                    setState(() => _clientType = ClientType.individual),
                isDark: isDark,
              ),
            ),
            Expanded(
              child: _buildSegmentButton(
                label: l10n.corporate,
                isSelected: _clientType == ClientType.corporate,
                onTap: () => setState(() => _clientType = ClientType.corporate),
                isDark: isDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.surfaceDarkTheme : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.button.copyWith(
            color: isSelected
                ? (isDark ? AppColors.textPrimaryDark : AppColors.primary)
                : (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary),
            fontWeight: AppTypography.semiBold,
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    bool optional = false,
    bool highlighted = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Row(
              children: [
                Text(
                  title.toUpperCase(),
                  style: AppTypography.overline.copyWith(
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiary,
                    fontWeight: AppTypography.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                if (optional) ...[
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.optional,
                    style: AppTypography.captionSmall.copyWith(
                      color: AppColors.textDisabled,
                      fontWeight: AppTypography.medium,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Section content
          Container(
            decoration: BoxDecoration(
              color: highlighted
                  ? (isDark
                        ? AppColors.primaryDarkTheme.withValues(alpha: 0.1)
                        : AppColors.primary.withValues(alpha: 0.05))
                  : (isDark
                        ? AppColors.surfaceDarkTheme.withValues(alpha: 0.5)
                        : Colors.white),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: highlighted
                    ? (isDark
                          ? AppColors.primaryDarkTheme.withValues(alpha: 0.3)
                          : AppColors.primary.withValues(alpha: 0.2))
                    : (isDark
                          ? AppColors.borderLightDark
                          : AppColors.borderLight),
              ),
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
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInformationFields(AppLocalizations l10n) {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: l10n.fullName,
            hintText: l10n.fullNameHint,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _taxIdController,
          decoration: InputDecoration(
            labelText: '${l10n.taxId} (${l10n.optional})',
            hintText: l10n.taxIdHint,
            errorMaxLines: 2,
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return null;
            }
            return Validators.validateDocumento(value);
          },
        ),
        const SizedBox(height: 16),

        // Contact details in responsive grid
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              // Desktop/tablet: side by side
              return Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: l10n.emailAddress,
                        hintText: l10n.emailHint,
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: l10n.phoneNumber,
                        hintText: l10n.phoneHint,
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              );
            } else {
              // Mobile: stacked
              return Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: l10n.emailAddress,
                      hintText: l10n.emailHint,
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: l10n.phoneNumber,
                      hintText: l10n.phoneHint,
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildLocationFields(AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // ZIP Code with lookup button
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _zipCodeController,
                decoration: InputDecoration(
                  labelText: l10n.zipCode,
                  hintText: l10n.zipCodeHint,
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _lookupZipCode,
              icon: const Icon(Icons.search, size: 18),
              label: Text(l10n.lookup),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? AppColors.primaryDarkTheme.withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.1),
                foregroundColor: isDark
                    ? AppColors.primaryDarkTheme
                    : AppColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Street and number
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _streetController,
                decoration: InputDecoration(
                  labelText: l10n.street,
                  hintText: l10n.streetHint,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: TextFormField(
                controller: _numberController,
                decoration: InputDecoration(
                  labelText: l10n.number,
                  hintText: l10n.numberHint,
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Neighborhood and City
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _neighborhoodController,
                      decoration: InputDecoration(
                        labelText: l10n.neighborhood,
                        hintText: l10n.neighborhoodHint,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        labelText: l10n.city,
                        hintText: l10n.cityHint,
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  TextFormField(
                    controller: _neighborhoodController,
                    decoration: InputDecoration(
                      labelText: l10n.neighborhood,
                      hintText: l10n.neighborhoodHint,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: l10n.city,
                      hintText: l10n.cityHint,
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildPrimaryContactFields(AppLocalizations l10n) {
    return Column(
      children: [
        TextFormField(
          controller: _contactNameController,
          decoration: InputDecoration(
            labelText: l10n.contactName,
            hintText: l10n.contactNameHint,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _positionController,
          decoration: InputDecoration(
            labelText: l10n.position,
            hintText: l10n.positionHint,
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField(AppLocalizations l10n) {
    return TextFormField(
      controller: _notesController,
      decoration: InputDecoration(
        hintText: l10n.internalNotesHint,
        border: const OutlineInputBorder(),
      ),
      maxLines: 3,
      keyboardType: TextInputType.multiline,
    );
  }

  Widget _buildBottomButton(AppLocalizations l10n, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.backgroundDarkTheme.withValues(alpha: 0.9)
            : AppColors.backgroundLight.withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderLightDark : AppColors.borderLight,
          ),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -6),
                ),
              ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _saveClient,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.person_add),
            label: Text(_isLoading ? 'Salvando...' : l10n.saveClient),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum ClientType { individual, corporate }
