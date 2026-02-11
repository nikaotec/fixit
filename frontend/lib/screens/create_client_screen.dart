import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/firestore_client_service.dart';
import '../services/geocoding_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

enum _LocationMethod { none, gps, address }

/// Screen for creating a new client (individual or corporate)
/// Follows the Fixit design system with premium mobile UI
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
  final _latController = TextEditingController();
  final _longController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;
  bool _isCapturingLocation = false;
  bool _isSearchingAddress = false;
  _LocationMethod _locationMethod = _LocationMethod.none;
  List<GeocodingResult> _addressResults = [];
  String? _selectedAddress;
  Timer? _debounce;

  final MapController _mapController = MapController();
  LatLng _mapCenter = const LatLng(-23.5505, -46.6333); // Default to São Paulo
  final List<Marker> _markers = [];

  bool get _hasLocation =>
      _latController.text.isNotEmpty && _longController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _latController.addListener(_updateMapFromCoords);
    _longController.addListener(_updateMapFromCoords);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _latController.removeListener(_updateMapFromCoords);
    _longController.removeListener(_updateMapFromCoords);
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
    _latController.dispose();
    _longController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _updateMapFromCoords() {
    final latNum = double.tryParse(_latController.text.replaceAll(',', '.'));
    final longNum = double.tryParse(_longController.text.replaceAll(',', '.'));

    if (latNum != null && longNum != null) {
      final newLocation = LatLng(latNum, longNum);
      setState(() {
        _mapCenter = newLocation;
        _markers
          ..clear()
          ..add(
            Marker(
              width: 80,
              height: 80,
              point: newLocation,
              child: const Icon(
                Icons.location_on,
                color: AppColors.primary,
                size: 40,
              ),
            ),
          );
      });
      try {
        _mapController.move(newLocation, 15);
      } catch (_) {}
    }
  }

  Future<void> _lookupZipCode() async {
    final cep = _zipCodeController.text.replaceAll(RegExp(r'\D'), '');
    if (cep.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.zipCodeHint)),
      );
      return;
    }

    setState(() => _isSearchingAddress = true);

    try {
      final response = await http.get(
        Uri.parse('https://viacep.com.br/ws/$cep/json/'),
      );
      if (response.statusCode != 200) throw Exception();

      final data = jsonDecode(response.body);
      if (data['erro'] == true) throw Exception();

      setState(() {
        _streetController.text = data['logradouro'] ?? '';
        _neighborhoodController.text = data['bairro'] ?? '';
        _cityController.text = data['localidade'] ?? '';
        _autoGeocode('${_streetController.text}, ${_cityController.text}');
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('CEP não encontrado')));
      }
    } finally {
      if (mounted) setState(() => _isSearchingAddress = false);
    }
  }

  Future<void> _autoGeocode(String address) async {
    try {
      final results = await GeocodingService.searchAddress(address);
      if (results.isNotEmpty && mounted) {
        setState(() {
          _latController.text = results.first.lat.toString();
          _longController.text = results.first.lon.toString();
          _selectedAddress = results.first.displayName;
        });
      }
    } catch (_) {}
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isCapturingLocation = true);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        setState(() => _isCapturingLocation = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.locationServicesDisabled,
            ),
          ),
        );
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          setState(() => _isCapturingLocation = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.locationPermissionsDenied,
              ),
            ),
          );
        }
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _latController.text = position.latitude.toString();
          _longController.text = position.longitude.toString();
          _isCapturingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCapturingLocation = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.locationFetchError),
          ),
        );
      }
    }
  }

  void _onAddressChanged(String query) {
    _debounce?.cancel();
    if (query.trim().length < 3) {
      setState(() {
        _addressResults = [];
        _isSearchingAddress = false;
      });
      return;
    }

    setState(() => _isSearchingAddress = true);
    _debounce = Timer(const Duration(milliseconds: 600), () async {
      try {
        final results = await GeocodingService.searchAddress(query);
        if (mounted) {
          setState(() {
            _addressResults = results;
            _isSearchingAddress = false;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _addressResults = [];
            _isSearchingAddress = false;
          });
        }
      }
    });
  }

  void _selectAddressResult(GeocodingResult result) {
    setState(() {
      _latController.text = result.lat.toString();
      _longController.text = result.lon.toString();
      _selectedAddress = result.displayName;
      _addressResults = [];
      _addressController.text = result.displayName;
    });
  }

  Future<void> _saveClient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      double? lat;
      double? long;

      if (_latController.text.isNotEmpty) {
        lat = double.tryParse(_latController.text.replaceAll(',', '.'));
      }
      if (_longController.text.isNotEmpty) {
        long = double.tryParse(_longController.text.replaceAll(',', '.'));
      }

      await FirestoreClientService.create(
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
        latitude: lat,
        longitude: long,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.saveClient),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar cliente: ${e.toString()}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDarkTheme
          : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.backgroundDarkTheme
            : AppColors.backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: isDark ? AppColors.borderDefaultDark : AppColors.borderLight,
            height: 1,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.createNewClient,
          style: AppTypography.headline3.copyWith(
            color: isDark ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildClientTypeSelector(l10n, isDark),
                    const SizedBox(height: 24),
                    _buildSectionHeader(l10n.basicInformation, isDark),
                    const SizedBox(height: 12),
                    _buildFormField(
                      controller: _nameController,
                      label: l10n.fullName,
                      hint: l10n.fullNameHint,
                      isDark: isDark,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Nome obrigatório'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _buildFormField(
                      controller: _taxIdController,
                      label: l10n.taxId,
                      hint: l10n.taxIdHint,
                      isDark: isDark,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    _buildFormField(
                      controller: _emailController,
                      label: l10n.emailAddress,
                      hint: l10n.emailHint,
                      isDark: isDark,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _buildFormField(
                      controller: _phoneController,
                      label: l10n.phoneNumber,
                      hint: l10n.phoneHint,
                      isDark: isDark,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader(l10n.locationDetails, isDark),
                    const SizedBox(height: 12),
                    _buildZipLookupField(l10n, isDark),
                    const SizedBox(height: 16),
                    _buildFormField(
                      controller: _streetController,
                      label: l10n.street,
                      hint: l10n.streetHint,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: _buildFormField(
                            controller: _numberController,
                            label: l10n.number,
                            hint: 'Nº',
                            isDark: isDark,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: _buildFormField(
                            controller: _neighborhoodController,
                            label: l10n.neighborhood,
                            hint: l10n.neighborhoodHint,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildFormField(
                      controller: _cityController,
                      label: l10n.city,
                      hint: l10n.cityHint,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader(l10n.locationSectionLabel, isDark),
                    const SizedBox(height: 12),
                    _buildLocationMethodSelector(l10n, isDark),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: _locationMethod == _LocationMethod.gps
                          ? Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: _buildGpsPanel(l10n, isDark),
                            )
                          : _locationMethod == _LocationMethod.address
                          ? Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: _buildAddressPanel(l10n, isDark),
                            )
                          : const SizedBox.shrink(),
                    ),
                    if (_hasLocation) ...[
                      const SizedBox(height: 16),
                      _buildMapPreview(isDark),
                    ],
                    const SizedBox(height: 24),
                    _buildSectionHeader(l10n.primaryContact, isDark),
                    const SizedBox(height: 12),
                    _buildFormField(
                      controller: _contactNameController,
                      label: l10n.contactName,
                      hint: l10n.contactNameHint,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildFormField(
                      controller: _positionController,
                      label: l10n.position,
                      hint: l10n.positionHint,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader(l10n.internalNotes, isDark),
                    const SizedBox(height: 12),
                    _buildFormField(
                      controller: _notesController,
                      label: 'Notas',
                      hint: l10n.internalNotesHint,
                      isDark: isDark,
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildStickyBottomButton(l10n, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildClientTypeSelector(AppLocalizations l10n, bool isDark) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate900 : AppColors.slate100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDefaultDark : AppColors.borderLight,
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildSegmentButton(
              label: l10n.individual,
              isSelected: _clientType == ClientType.individual,
              onTap: () => setState(() => _clientType = ClientType.individual),
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
              ? (isDark ? AppColors.slate800 : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected && !isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.button.copyWith(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.slate400 : AppColors.slate500),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title.toUpperCase(),
      style: AppTypography.overline.copyWith(
        color: isDark ? AppColors.slate400 : AppColors.slate500,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    int maxLines = 1,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodyTextSmall.copyWith(
            color: isDark ? AppColors.slate200 : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          onChanged: onChanged,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: AppTypography.bodyText.copyWith(
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
          decoration: _inputDecoration(
            hint: hint,
            isDark: isDark,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }

  Widget _buildZipLookupField(AppLocalizations l10n, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildFormField(
            controller: _zipCodeController,
            label: l10n.zipCode,
            hint: l10n.zipCodeHint,
            isDark: isDark,
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(top: 24),
          child: SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: _isSearchingAddress ? null : _lookupZipCode,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isSearchingAddress
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationMethodSelector(AppLocalizations l10n, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildMethodChip(
            icon: Icons.my_location,
            label: l10n.locationMethodGps,
            isSelected: _locationMethod == _LocationMethod.gps,
            isDark: isDark,
            onTap: () => setState(
              () => _locationMethod = _locationMethod == _LocationMethod.gps
                  ? _LocationMethod.none
                  : _LocationMethod.gps,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMethodChip(
            icon: Icons.location_on_outlined,
            label: l10n.locationMethodAddress,
            isSelected: _locationMethod == _LocationMethod.address,
            isDark: isDark,
            onTap: () => setState(
              () => _locationMethod = _locationMethod == _LocationMethod.address
                  ? _LocationMethod.none
                  : _LocationMethod.address,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMethodChip({
    required IconData icon,
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.08)
                : (isDark ? AppColors.slate900 : Colors.white),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : (isDark
                        ? AppColors.borderDefaultDark
                        : const Color(0xFFCFDBE7)),
              width: isSelected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? AppColors.primary : AppColors.slate400,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? Colors.white : AppColors.textPrimary),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGpsPanel(AppLocalizations l10n, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate900 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDefaultDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _hasLocation ? Icons.check_circle : Icons.gps_fixed,
            color: _hasLocation ? AppColors.success : AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GPS',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  _isCapturingLocation
                      ? l10n.capturingLocation
                      : _hasLocation
                      ? l10n.locationCaptured
                      : l10n.locationNotCaptured,
                  style: AppTypography.captionSmall,
                ),
              ],
            ),
          ),
          if (_isCapturingLocation)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            OutlinedButton(
              onPressed: _useCurrentLocation,
              child: const Text('GPS'),
            ),
        ],
      ),
    );
  }

  Widget _buildAddressPanel(AppLocalizations l10n, bool isDark) {
    return Column(
      children: [
        _buildFormField(
          controller: _addressController,
          label: 'Buscar Endereço',
          hint: l10n.addressSearchHint,
          isDark: isDark,
          suffixIcon: _isSearchingAddress
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : _addressController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _addressController.clear();
                    setState(() {
                      _addressResults = [];
                      _selectedAddress = null;
                    });
                  },
                )
              : null,
          onChanged: _onAddressChanged,
        ),
        if (_addressResults.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDarkTheme : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? AppColors.borderDefaultDark
                    : AppColors.borderLight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                for (int i = 0; i < _addressResults.length; i++) ...[
                  _buildGeocodingResultItem(
                    _addressResults[i],
                    isDark,
                    isLast: i == _addressResults.length - 1,
                  ),
                  if (i < _addressResults.length - 1)
                    Divider(
                      height: 1,
                      indent: 50,
                      color: isDark
                          ? AppColors.borderDefaultDark
                          : AppColors.divider,
                    ),
                ],
              ],
            ),
          ),
        ],
        if (_selectedAddress != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.locationCaptured,
                    style: AppTypography.captionSmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGeocodingResultItem(
    GeocodingResult result,
    bool isDark, {
    bool isLast = false,
  }) {
    return InkWell(
      onTap: () => _selectAddressResult(result),
      borderRadius: isLast
          ? const BorderRadius.vertical(bottom: Radius.circular(11))
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDark ? AppColors.slate800 : AppColors.slate100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                result.type == 'house'
                    ? Icons.home_outlined
                    : Icons.location_on_outlined,
                size: 16,
                color: AppColors.slate400,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                result.displayName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyTextSmall.copyWith(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontSize: 13,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.slate400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPreview(bool isDark) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      clipBehavior: Clip.antiAlias,
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(initialCenter: _mapCenter, initialZoom: 15),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),
          MarkerLayer(markers: _markers),
        ],
      ),
    );
  }

  Widget _buildStickyBottomButton(AppLocalizations l10n, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDarkTheme : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(0, -4),
            blurRadius: 12,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveClient,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    l10n.saveClient,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required bool isDark,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: isDark ? AppColors.slate900 : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: isDark ? AppColors.borderDefaultDark : const Color(0xFFCFDBE7),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: isDark ? AppColors.borderDefaultDark : const Color(0xFFCFDBE7),
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: AppColors.danger, width: 1),
      ),
      contentPadding: const EdgeInsets.all(16),
      suffixIcon: suffixIcon,
    );
  }
}

enum ClientType { individual, corporate }
