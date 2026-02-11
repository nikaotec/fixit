import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:geolocator/geolocator.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/firestore_client_service.dart';
import '../services/firestore_equipment_service.dart';
import '../services/geocoding_service.dart';
import '../widgets/equipment_qr_dialog.dart';

enum _LocationMethod { none, gps, address }

class AddEditEquipmentScreen extends StatefulWidget {
  final Map<String, dynamic>? equipment;

  const AddEditEquipmentScreen({super.key, this.equipment});

  @override
  State<AddEditEquipmentScreen> createState() => _AddEditEquipmentScreenState();
}

class _AddEditEquipmentScreenState extends State<AddEditEquipmentScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _serialController = TextEditingController();
  final _latController = TextEditingController();
  final _longController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoadingClients = false;
  bool _isSaving = false;
  bool _isCapturingLocation = false;
  bool _isSearchingAddress = false;
  List<Map<String, dynamic>> _clients = [];
  String? _selectedClient;
  _LocationMethod _locationMethod = _LocationMethod.none;
  List<GeocodingResult> _addressResults = [];
  String? _selectedAddress;
  Timer? _debounce;

  final MapController _mapController = MapController();
  LatLng _mapCenter = const LatLng(-23.5505, -46.6333);
  final List<Marker> _markers = [];

  bool get _hasLocation =>
      _latController.text.isNotEmpty && _longController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadClients();
    _latController.addListener(_updateMapFromCoords);
    _longController.addListener(_updateMapFromCoords);

    if (widget.equipment != null) {
      _nameController.text = widget.equipment!['nome'] ?? '';
      if (widget.equipment!['codigo'] != null) {
        _serialController.text = widget.equipment!['codigo'];
      } else if (widget.equipment!['serial'] != null) {
        _serialController.text = widget.equipment!['serial'];
      }

      if (widget.equipment!['latitude'] != null &&
          widget.equipment!['longitude'] != null) {
        _latController.text = widget.equipment!['latitude'].toString();
        _longController.text = widget.equipment!['longitude'].toString();

        final lat = double.tryParse(_latController.text);
        final long = double.tryParse(_longController.text);

        if (lat != null && long != null) {
          _mapCenter = LatLng(lat, long);
          _markers.add(
            Marker(
              width: 80,
              height: 80,
              point: _mapCenter,
              child: const Icon(
                Icons.location_on,
                color: AppColors.primary,
                size: 40,
              ),
            ),
          );
        }
      }

      if (widget.equipment!['clienteId'] != null) {
        _selectedClient = widget.equipment!['clienteId'].toString();
      }
    }
  }

  Future<void> _loadClients() async {
    setState(() => _isLoadingClients = true);
    try {
      final clients = await FirestoreClientService.getAll();
      if (mounted) {
        setState(() {
          _clients = clients.map((c) => c.toMap()..['id'] = c.id).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading clients: ${e.toString()}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingClients = false);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _latController.removeListener(_updateMapFromCoords);
    _longController.removeListener(_updateMapFromCoords);
    _nameController.dispose();
    _serialController.dispose();
    _latController.dispose();
    _longController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _updateMapFromCoords() {
    final latText = _latController.text.replaceAll(',', '.');
    final longText = _longController.text.replaceAll(',', '.');
    final lat = double.tryParse(latText);
    final long = double.tryParse(longText);

    if (lat != null && long != null) {
      final newLocation = LatLng(lat, long);
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

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(() => _isCapturingLocation = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.locationPermissionsDeniedForever,
            ),
          ),
        );
      }
      return;
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
            content: Text(
              AppLocalizations.of(context)!.errorGettingLocation(e.toString()),
            ),
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

  Future<void> _saveEquipment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      double? lat;
      double? long;

      if (_latController.text.isNotEmpty) {
        lat = double.tryParse(_latController.text.replaceAll(',', '.'));
      }
      if (_longController.text.isNotEmpty) {
        long = double.tryParse(_longController.text.replaceAll(',', '.'));
      }

      if (widget.equipment != null && widget.equipment!['id'] != null) {
        await FirestoreEquipmentService.updateEquipamento(
          id: widget.equipment!['id'].toString(),
          nome: _nameController.text,
          serial: _serialController.text.isEmpty
              ? null
              : _serialController.text,
          clienteId: _selectedClient,
          latitude: lat,
          longitude: long,
        );
      } else {
        await FirestoreEquipmentService.createEquipamento(
          nome: _nameController.text,
          serial: _serialController.text.isEmpty
              ? null
              : _serialController.text,
          clienteId: _selectedClient,
          latitude: lat,
          longitude: long,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.saveEquipment),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.errorSavingEquipment(e.toString()),
            ),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _scanBarcode() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Stack(
            children: [
              MobileScanner(
                onDetect: (capture) {
                  final barcode = capture.barcodes.firstOrNull;
                  final value = barcode?.rawValue;
                  if (value != null && value.isNotEmpty) {
                    Navigator.pop(context, value);
                  }
                },
              ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.alignQrInstruction,
                    textAlign: TextAlign.center,
                    style: AppTypography.caption.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      setState(() => _serialController.text = result);
    }
  }

  void _showEquipmentQrCode() {
    final l10n = AppLocalizations.of(context)!;

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.equipmentNameRequired)));
      return;
    }

    final equipmentData = Map<String, dynamic>.from(widget.equipment ?? {});
    equipmentData['id'] = widget.equipment?['id'];
    equipmentData['nome'] = _nameController.text.trim();
    equipmentData['codigo'] = _serialController.text.trim();
    equipmentData['qrCode'] = widget.equipment?['qrCode'];

    EquipmentQrDialog.show(context, equipmentData);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.equipment != null;

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
          isEditing ? l10n.editEquipment : l10n.addEquipment,
          style: AppTypography.headline3.copyWith(
            color: isDark ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              onPressed: () => _confirmDelete(l10n),
            ),
        ],
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
                    Text(
                      l10n.equipmentDetailsSubtitle,
                      style: AppTypography.bodyTextSmall.copyWith(
                        color: isDark ? AppColors.slate400 : AppColors.slate500,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section 1: Basic Info
                    _buildSectionHeader(l10n.basicInfoSection, isDark),
                    const SizedBox(height: 12),
                    _buildFormField(
                      controller: _nameController,
                      label: l10n.equipmentName,
                      hint: l10n.equipmentNameHint,
                      isDark: isDark,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.equipmentNameRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildFormField(
                      controller: _serialController,
                      label: l10n.serialCode,
                      hint: l10n.serialCodeHint,
                      isDark: isDark,
                      suffixIcon: IconButton(
                        onPressed: _scanBarcode,
                        icon: const Icon(
                          Icons.qr_code_scanner,
                          color: AppColors.primary,
                        ),
                      ),
                    ),

                    if (isEditing) ...[
                      const SizedBox(height: 12),
                      _buildQrCodeCard(l10n, isDark),
                    ],

                    const SizedBox(height: 24),

                    // Section 2: Client
                    _buildSectionHeader(l10n.clientSection, isDark),
                    const SizedBox(height: 12),
                    _buildClientDropdown(l10n, isDark),

                    const SizedBox(height: 24),

                    // Section 3: Location
                    _buildSectionHeader(l10n.locationSectionLabel, isDark),
                    const SizedBox(height: 12),
                    _buildLocationMethodSelector(l10n, isDark),

                    // GPS Panel
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: _locationMethod == _LocationMethod.gps
                          ? Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: _buildGpsPanel(l10n, isDark),
                            )
                          : const SizedBox.shrink(),
                    ),

                    // Address Panel
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: _locationMethod == _LocationMethod.address
                          ? Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: _buildAddressPanel(l10n, isDark),
                            )
                          : const SizedBox.shrink(),
                    ),

                    // Map preview (only when location is set)
                    if (_hasLocation) ...[
                      const SizedBox(height: 16),
                      _buildMapPreview(isDark),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Sticky Save Button
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

  // ──────────────────────────────────────────────────
  // Location Method Selector (Toggle Chips)
  // ──────────────────────────────────────────────────

  Widget _buildLocationMethodSelector(AppLocalizations l10n, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildMethodChip(
            icon: Icons.my_location,
            label: l10n.locationMethodGps,
            isSelected: _locationMethod == _LocationMethod.gps,
            isDark: isDark,
            onTap: () {
              setState(() {
                _locationMethod = _locationMethod == _LocationMethod.gps
                    ? _LocationMethod.none
                    : _LocationMethod.gps;
                _addressResults = [];
              });
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMethodChip(
            icon: Icons.location_on_outlined,
            label: l10n.locationMethodAddress,
            isSelected: _locationMethod == _LocationMethod.address,
            isDark: isDark,
            onTap: () {
              setState(() {
                _locationMethod = _locationMethod == _LocationMethod.address
                    ? _LocationMethod.none
                    : _LocationMethod.address;
              });
            },
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
    final selectedBg = AppColors.primary.withValues(
      alpha: isDark ? 0.15 : 0.08,
    );
    final defaultBg = isDark ? AppColors.surfaceDarkTheme : Colors.white;
    final selectedBorder = AppColors.primary.withValues(alpha: 0.4);
    final defaultBorder = isDark
        ? AppColors.borderDefaultDark
        : const Color(0xFFCFDBE7);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : defaultBg,
            border: Border.all(
              color: isSelected ? selectedBorder : defaultBorder,
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
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.slate400 : AppColors.slate500),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyTextSmall.copyWith(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? AppColors.slate300 : AppColors.textPrimary),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────
  // GPS Panel
  // ──────────────────────────────────────────────────

  Widget _buildGpsPanel(AppLocalizations l10n, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkTheme : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDefaultDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _hasLocation
                  ? AppColors.success.withValues(alpha: 0.12)
                  : AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _hasLocation ? Icons.check_circle : Icons.gps_fixed,
              color: _hasLocation ? AppColors.success : AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.useCurrentLocation,
                  style: AppTypography.bodyText.copyWith(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isCapturingLocation
                      ? l10n.capturingLocation
                      : _hasLocation
                      ? l10n.locationCaptured
                      : l10n.locationNotCaptured,
                  style: AppTypography.captionSmall.copyWith(
                    color: _hasLocation
                        ? AppColors.success
                        : (isDark ? AppColors.slate400 : AppColors.slate500),
                  ),
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
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: Text(
                'GPS',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────
  // Address Panel (Geocoding)
  // ──────────────────────────────────────────────────

  Widget _buildAddressPanel(AppLocalizations l10n, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Address input
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDarkTheme : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? AppColors.borderDefaultDark
                  : AppColors.borderLight,
            ),
          ),
          child: Column(
            children: [
              // Search bar with icon
              Row(
                children: [
                  const SizedBox(width: 14),
                  Icon(
                    Icons.search,
                    color: isDark ? AppColors.slate400 : AppColors.slate500,
                    size: 20,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _addressController,
                      onChanged: _onAddressChanged,
                      style: AppTypography.bodyText.copyWith(
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.addressSearchHint,
                        hintStyle: AppTypography.bodyTextSmall.copyWith(
                          color: AppColors.slate400,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 16,
                        ),
                        suffixIcon: _isSearchingAddress
                            ? const Padding(
                                padding: EdgeInsets.all(14),
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
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
                      ),
                    ),
                  ),
                ],
              ),

              // Selected address indicator
              if (_selectedAddress != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.08),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(11),
                      bottomRight: Radius.circular(11),
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
          ),
        ),

        // Address results list
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
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: AppColors.shadow.withValues(alpha: 0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Text(
                    l10n.selectAddress,
                    style: AppTypography.overline.copyWith(
                      color: isDark ? AppColors.slate400 : AppColors.slate500,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ..._addressResults.asMap().entries.map((entry) {
                  final index = entry.key;
                  final result = entry.value;
                  final isLast = index == _addressResults.length - 1;

                  return Column(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _selectAddressResult(result),
                          borderRadius: isLast
                              ? const BorderRadius.only(
                                  bottomLeft: Radius.circular(11),
                                  bottomRight: Radius.circular(11),
                                )
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Icon(
                                    Icons.place_outlined,
                                    size: 18,
                                    color: isDark
                                        ? AppColors.slate400
                                        : AppColors.slate500,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    result.displayName,
                                    style: AppTypography.bodyTextSmall.copyWith(
                                      color: isDark
                                          ? AppColors.slate200
                                          : AppColors.textPrimary,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (!isLast) const Divider(height: 1),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],

        // No results message
        if (!_isSearchingAddress &&
            _addressResults.isEmpty &&
            _addressController.text.length >= 3 &&
            _selectedAddress == null) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceDarkTheme
                  : AppColors.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.warning, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.addressNotFound,
                    style: AppTypography.captionSmall.copyWith(
                      color: isDark
                          ? AppColors.slate300
                          : AppColors.textPrimary,
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

  // ──────────────────────────────────────────────────
  // Shared Widgets
  // ──────────────────────────────────────────────────

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
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
          autovalidateMode: AutovalidateMode.onUserInteraction,
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

  Widget _buildClientDropdown(AppLocalizations l10n, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.clientLocation,
          style: AppTypography.bodyTextSmall.copyWith(
            color: isDark ? AppColors.slate200 : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.slate900 : Colors.white,
            border: Border.all(
              color: isDark
                  ? AppColors.borderDefaultDark
                  : const Color(0xFFCFDBE7),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedClient,
              hint: _isLoadingClients
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      l10n.selectClient,
                      style: TextStyle(color: AppColors.slate400),
                    ),
              isExpanded: true,
              dropdownColor: isDark ? AppColors.surfaceDarkTheme : Colors.white,
              style: AppTypography.bodyText.copyWith(
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
              icon: const Icon(Icons.unfold_more, color: AppColors.slate500),
              items: [
                DropdownMenuItem<String>(
                  value: '',
                  child: Text(
                    l10n.noClientSelected,
                    style: TextStyle(
                      color: isDark ? AppColors.slate400 : AppColors.slate500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                ..._clients.map((client) {
                  return DropdownMenuItem<String>(
                    value: client['id']?.toString() ?? '',
                    child: Text(client['nome']?.toString() ?? 'Unnamed'),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedClient = (value == null || value.isEmpty)
                      ? null
                      : value;

                  if (value != null && value.isNotEmpty) {
                    final client = _clients.firstWhere(
                      (c) => c['id'].toString() == value,
                      orElse: () => {},
                    );

                    if (client.isNotEmpty) {
                      if (client['latitude'] != null) {
                        _latController.text = client['latitude'].toString();
                      }
                      if (client['longitude'] != null) {
                        _longController.text = client['longitude'].toString();
                      }
                    }
                  }
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapPreview(bool isDark) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.slate800 : AppColors.slate200,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: AppColors.shadow.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(initialCenter: _mapCenter, initialZoom: 15),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.fixit',
          ),
          MarkerLayer(markers: _markers),
        ],
      ),
    );
  }

  Widget _buildQrCodeCard(AppLocalizations l10n, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: isDark ? 0.1 : 0.05),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? AppColors.slate800 : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? AppColors.slate700 : AppColors.slate200,
              ),
            ),
            child: const Center(
              child: Icon(Icons.qr_code_2, color: AppColors.primary, size: 24),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.uniqueQrLabel,
                  style: AppTypography.bodyTextSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                Text(
                  l10n.instantTechAccess,
                  style: AppTypography.captionSmall.copyWith(
                    color: isDark ? AppColors.slate400 : AppColors.slate500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: _showEquipmentQrCode,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              l10n.generateQr,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
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
            onPressed: _isSaving ? null : _saveEquipment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    l10n.saveEquipment,
                    style: AppTypography.button.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(AppLocalizations l10n) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteEquipmentTitle),
        content: Text(l10n.deleteEquipmentBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text(l10n.deleteAction),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await FirestoreEquipmentService.deleteEquipamento(
          id: widget.equipment!['id'].toString(),
        );
        if (mounted) Navigator.pop(context, true);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.errorDeletingEquipment(e.toString()))),
          );
        }
      }
    }
  }

  InputDecoration _inputDecoration({
    required String hint,
    required bool isDark,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.bodyText.copyWith(color: AppColors.slate400),
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
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.danger, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.danger, width: 2),
      ),
      contentPadding: const EdgeInsets.all(16),
      suffixIcon: suffixIcon,
    );
  }
}
