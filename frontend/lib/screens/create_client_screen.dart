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
import 'package:country_picker/country_picker.dart';

/// Screen for creating a new client (individual or corporate)
/// Follows the Fixit design system with premium mobile UI
class CreateClientScreen extends StatefulWidget {
  final Map<String, dynamic>? client;
  const CreateClientScreen({super.key, this.client});

  @override
  State<CreateClientScreen> createState() => _CreateClientScreenState();
}

class _CreateClientScreenState extends State<CreateClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final MapController _mapController = MapController();

  // Client type
  ClientType _clientType = ClientType.individual;

  // Form controllers
  final _nameController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController(); // Re-introduced
  Country? _selectedCountry;

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
  // _addressController removed

  bool _isLoading = false;
  bool _isCapturingLocation = false;
  bool _isSearchingAddress = false;
  bool _isProgrammaticUpdate = false;
  // _LocationMethod and _addressResults removed
  Timer? _debounce;

  LatLng _mapCenter = const LatLng(-23.5505, -46.6333); // Default to São Paulo
  final List<Marker> _markers = [];

  bool get _hasLocation =>
      _latController.text.isNotEmpty && _longController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _latController.addListener(_updateMapFromCoords);
    _longController.addListener(_updateMapFromCoords);
    _streetController.addListener(_onAddressFieldsChanged);
    _numberController.addListener(_onAddressFieldsChanged);
    _cityController.addListener(_onAddressFieldsChanged);

    if (widget.client != null) {
      final c = widget.client!;
      _clientType = (c['tipo'] == 'CORPORATE')
          ? ClientType.corporate
          : ClientType.individual;
      _nameController.text = c['nome'] ?? '';
      _taxIdController.text = c['documento'] ?? '';
      _emailController.text = c['email'] ?? '';
      _phoneController.text = c['telefone'] ?? '';
      _zipCodeController.text = c['cep'] ?? '';
      _streetController.text = c['rua'] ?? '';
      _numberController.text = c['numero'] ?? '';
      _neighborhoodController.text = c['bairro'] ?? '';
      _cityController.text = c['cidade'] ?? '';
      _contactNameController.text = c['nomeContato'] ?? '';
      _positionController.text = c['cargoContato'] ?? '';
      _notesController.text = c['notasInternas'] ?? '';

      if (c['latitude'] != null && c['longitude'] != null) {
        _latController.text = c['latitude'].toString();
        _longController.text = c['longitude'].toString();
        // The listener will update the map automatically, but we might need to wait for build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateMapFromCoords(c['latitude'], c['longitude']);
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selectedCountry == null) {
      final locale = Localizations.localeOf(context);
      try {
        _selectedCountry = CountryParser.parseCountryCode(
          locale.countryCode ?? 'BR',
        );
      } catch (_) {
        _selectedCountry = CountryParser.parseCountryCode('BR');
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _streetController.removeListener(_onAddressFieldsChanged);
    _numberController.removeListener(_onAddressFieldsChanged);
    _cityController.removeListener(_onAddressFieldsChanged);
    _latController.removeListener(_updateMapFromCoords);
    _longController.removeListener(_updateMapFromCoords);
    _nameController.dispose();
    _taxIdController.dispose();
    _emailController.dispose();

    _phoneController.dispose(); // Re-introduced
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
    super.dispose();
  }

  void _updateMapFromCoords([double? lat, double? long]) {
    double? latNum = lat;
    double? longNum = long;

    if (latNum == null || longNum == null) {
      latNum = double.tryParse(_latController.text.replaceAll(',', '.'));
      longNum = double.tryParse(_longController.text.replaceAll(',', '.'));
    }

    if (latNum != null && longNum != null) {
      _latController.text = latNum.toString();
      _longController.text = longNum.toString();
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

      if (mounted) {
        _isProgrammaticUpdate = true;
        setState(() {
          _streetController.text = data['logradouro'] ?? '';
          _neighborhoodController.text = data['bairro'] ?? '';
          _cityController.text = data['localidade'] ?? '';
        });

        // Trigger geocode explicitly to update map
        final components = [
          _streetController.text,
          if (_numberController.text.isNotEmpty) _numberController.text,
          if (_neighborhoodController.text.isNotEmpty)
            _neighborhoodController.text,
          _cityController.text,
          'Brasil',
        ];
        await _autoGeocode(components.join(', '));

        // Reset flag
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _isProgrammaticUpdate = false;
        });
      }
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
        final result = results.first;
        setState(() {
          _latController.text = result.lat.toString();
          _longController.text = result.lon.toString();
        });
        _updateMapFromCoords(result.lat, result.lon);
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
      final lat = position.latitude;
      final long = position.longitude;

      if (mounted) {
        _isProgrammaticUpdate = true;

        setState(() {
          _latController.text = position.latitude.toString();
          _longController.text = position.longitude.toString();
        });

        _updateMapFromCoords(lat, long);

        // Reverse geocode to fill address fields
        final result = await GeocodingService.reverseGeocode(lat, long);
        if (result != null && mounted) {
          setState(() {
            _streetController.text = result.street ?? '';
            _numberController.text = result.number ?? '';
            _neighborhoodController.text = result.neighborhood ?? '';
            _cityController.text = result.city ?? '';
            _zipCodeController.text = result.zipCode ?? '';
          });
        }

        // Reset flag after a short delay to allow UI to settle
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) _isProgrammaticUpdate = false;
        });

        setState(() => _isCapturingLocation = false);
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

  void _onAddressFieldsChanged() {
    if (_isProgrammaticUpdate) return;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      if (_streetController.text.isNotEmpty &&
          _cityController.text.isNotEmpty) {
        final components = [
          _streetController.text,
          if (_numberController.text.isNotEmpty) _numberController.text,
          if (_neighborhoodController.text.isNotEmpty)
            _neighborhoodController.text,
          _cityController.text,
          'Brasil',
        ];
        _autoGeocode(components.join(', '));
      }
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

      if (widget.client != null) {
        await FirestoreClientService.update(
          id: widget.client!['id'],
          tipo: _clientType == ClientType.individual
              ? 'INDIVIDUAL'
              : 'CORPORATE',
          nome: _nameController.text,
          documento: _taxIdController.text,
          email: _emailController.text.isEmpty ? null : _emailController.text,
          telefone: _phoneController.text.isEmpty
              ? null
              : _phoneController.text,
          cep: _zipCodeController.text.isEmpty ? null : _zipCodeController.text,
          rua: _streetController.text.isEmpty ? null : _streetController.text,
          numero: _numberController.text.isEmpty
              ? null
              : _numberController.text,
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
      } else {
        await FirestoreClientService.create(
          tipo: _clientType == ClientType.individual
              ? 'INDIVIDUAL'
              : 'CORPORATE',
          nome: _nameController.text,
          documento: _taxIdController.text,
          email: _emailController.text.isEmpty ? null : _emailController.text,
          telefone: _phoneController.text.isEmpty
              ? null
              : _phoneController.text,
          cep: _zipCodeController.text.isEmpty ? null : _zipCodeController.text,
          rua: _streetController.text.isEmpty ? null : _streetController.text,
          numero: _numberController.text.isEmpty
              ? null
              : _numberController.text,
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
      }

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
          widget.client != null ? 'Editar Cliente' : l10n.createNewClient,
          style: AppTypography.headline3.copyWith(
            color: isDark ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      // Replaced Stack with Column for better layout stability
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
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
                        _buildPhoneInput(l10n, isDark),
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
            ),
          ),
          _buildStickyBottomButton(l10n, isDark),
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
    Widget? prefixIcon,
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
            prefixIcon: prefixIcon,
          ),
        ),
      ],
    );
  }

  Widget _buildZipLookupField(AppLocalizations l10n, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: SizedBox(
            height: 52,
            width: 52,
            child: OutlinedButton(
              onPressed: _isCapturingLocation ? null : _useCurrentLocation,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isCapturingLocation
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
            ),
          ),
        ),
        const SizedBox(width: 8),
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
          padding: const EdgeInsets.only(bottom: 2),
          child: SizedBox(
            height: 52,
            width: 52,
            child: OutlinedButton(
              onPressed: _isSearchingAddress ? null : _lookupZipCode,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
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
            userAgentPackageName: 'com.fixit.app',
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
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
                        widget.client != null ? 'Atualizar' : l10n.saveClient,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
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
    Widget? prefixIcon,
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
      prefixIcon: prefixIcon,
    );
  }

  Widget _buildPhoneInput(AppLocalizations l10n, bool isDark) {
    return _buildFormField(
      controller: _phoneController,
      label: l10n.phoneNumber,
      hint: _selectedCountry != null
          ? '+${_selectedCountry!.phoneCode} 00000-0000'
          : l10n.phoneHint,
      isDark: isDark,
      keyboardType: TextInputType.phone,
      prefixIcon: _selectedCountry != null
          ? Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
              child: InkWell(
                onTap: () {
                  showCountryPicker(
                    context: context,
                    showPhoneCode: true,
                    onSelect: (Country country) {
                      setState(() {
                        _selectedCountry = country;
                      });
                    },
                    countryListTheme: CountryListThemeData(
                      backgroundColor: isDark
                          ? AppColors.backgroundDarkTheme
                          : Colors.white,
                      textStyle: TextStyle(
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                      bottomSheetHeight: 500,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      inputDecoration: InputDecoration(
                        labelText: 'Pesquisar',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.borderDefaultDark
                                : AppColors.borderLight,
                          ),
                        ),
                      ),
                      searchTextStyle: TextStyle(
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedCountry!.flagEmoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+${_selectedCountry!.phoneCode}',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      color: isDark ? AppColors.slate400 : AppColors.slate500,
                      size: 20,
                    ),
                  ],
                ),
              ),
            )
          : null,
      validator: (value) {
        if (value == null || value.isEmpty) return null;
        // Basic validation could be added here
        return null;
      },
    );
  }
}

enum ClientType { individual, corporate }
