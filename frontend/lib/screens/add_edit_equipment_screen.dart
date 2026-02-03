import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../providers/user_provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/cliente_service.dart';
import '../services/equipment_service.dart';

class AddEditEquipmentScreen extends StatefulWidget {
  final Map<String, dynamic>? equipment;

  const AddEditEquipmentScreen({Key? key, this.equipment}) : super(key: key);

  @override
  State<AddEditEquipmentScreen> createState() => _AddEditEquipmentScreenState();
}

class _AddEditEquipmentScreenState extends State<AddEditEquipmentScreen> {
  final _nameController = TextEditingController();
  final _serialController = TextEditingController();
  final _latController = TextEditingController();
  final _longController = TextEditingController();

  bool _isLoadingClients = false;
  List<Map<String, dynamic>> _clients = [];
  String? _selectedClient;

  final MapController _mapController = MapController();
  LatLng _mapCenter = const LatLng(-23.5505, -46.6333); // Default to Sao Paulo
  final List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _loadClients();
    _latController.addListener(_updateMapFromTextIds);
    _longController.addListener(_updateMapFromTextIds);

    if (widget.equipment != null) {
      _nameController.text = widget.equipment!['nome'] ?? '';
      _serialController.text = widget.equipment!['serial'] ?? '';

      // Handle Location
      if (widget.equipment!['latitude'] != null &&
          widget.equipment!['longitude'] != null) {
        _latController.text = widget.equipment!['latitude'].toString();
        _longController.text = widget.equipment!['longitude'].toString();

        // The listener will trigger _updateMapFromTextIds, but we might want to ensure it runs immediately
        // However, since we are in initState, listeners might not trigger setState correctly or might be redundant if we just set the values.
        // Actually, listeners fires, but better to set state directly here for initial render.

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

      // Handle Client
      if (widget.equipment!['clienteId'] != null) {
        _selectedClient = widget.equipment!['clienteId'].toString();
      }
    }
  }

  Future<void> _loadClients() async {
    setState(() => _isLoadingClients = true);
    try {
      final token = Provider.of<UserProvider>(context, listen: false).token;
      if (token != null) {
        final clients = await ClienteService.listarClientes(token: token);
        if (mounted) {
          setState(() {
            _clients = clients;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar clientes: ${e.toString()}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingClients = false);
      }
    }
  }

  @override
  void dispose() {
    _latController.removeListener(_updateMapFromTextIds);
    _longController.removeListener(_updateMapFromTextIds);
    _nameController.dispose();
    _serialController.dispose();
    _latController.dispose();
    _longController.dispose();
    super.dispose();
  }

  void _updateMapFromTextIds() {
    final latText = _latController.text.replaceAll(',', '.');
    final longText = _longController.text.replaceAll(',', '.');

    final lat = double.tryParse(latText);
    final long = double.tryParse(longText);

    if (lat != null && long != null) {
      final newLocation = LatLng(lat, long);
      setState(() {
        _mapCenter = newLocation;
        _markers.clear();
        _markers.add(
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
      // Ensure the map moves to the new location
      try {
        _mapController.move(newLocation, 15);
      } catch (e) {
        // Map might not be ready yet, or controller not attached
        print('Error moving map: $e');
      }
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      // Show loading indicator in fields if needed, or just block UI
      // For now we rely on the button press being quick or handling async
    });

    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.locationServicesDisabled),
          ),
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.locationPermissionsDenied),
            ),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
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

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    try {
      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _latController.text = position.latitude.toString();
          _longController.text = position.longitude.toString();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.errorGettingLocation(e.toString()),
            ),
          ),
        );
      }
    }
  }

  Future<void> _saveEquipment() async {
    // Basic validation
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.equipmentNameRequired),
        ),
      );
      return;
    }

    setState(() => _isLoadingClients = true);

    try {
      final token = Provider.of<UserProvider>(context, listen: false).token;
      if (token == null) throw Exception('User not authenticated');

      double? lat;
      double? long;

      if (_latController.text.isNotEmpty) {
        lat = double.tryParse(_latController.text.replaceAll(',', '.'));
      }
      if (_longController.text.isNotEmpty) {
        long = double.tryParse(_longController.text.replaceAll(',', '.'));
      }

      if (widget.equipment != null && widget.equipment!['id'] != null) {
        await EquipmentService.updateEquipamento(
          token: token,
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
        await EquipmentService.createEquipamento(
          token: token,
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
      if (mounted) {
        setState(() => _isLoadingClients = false);
      }
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
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Aponte a câmera para o QR/Barcode do equipamento',
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
      setState(() {
        _serialController.text = result;
      });
    }
  }

  Map<String, dynamic> _buildEquipmentQrPayload() {
    double? lat;
    double? long;

    if (_latController.text.isNotEmpty) {
      lat = double.tryParse(_latController.text.replaceAll(',', '.'));
    }
    if (_longController.text.isNotEmpty) {
      long = double.tryParse(_longController.text.replaceAll(',', '.'));
    }

    return {
      'id': widget.equipment?['id'],
      'nome': _nameController.text.trim(),
      'serial': _serialController.text.trim().isEmpty
          ? null
          : _serialController.text.trim(),
      'clienteId': _selectedClient,
      'latitude': lat,
      'longitude': long,
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }

  Future<Uint8List> _buildEquipmentQrPng(String data) async {
    final painter = QrPainter(
      data: data,
      version: QrVersions.auto,
      gapless: true,
      color: const Color(0xFF111827),
      emptyColor: Colors.white,
    );
    final image = await painter.toImage(512);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> _shareEquipmentQrCode({
    required String data,
    required String equipmentName,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final bytes = await _buildEquipmentQrPng(data);
      final fileName = equipmentName.trim().isEmpty
          ? 'qr-code.png'
          : 'qr-${equipmentName.trim().replaceAll(' ', '-')}.png';

      await Share.shareXFiles(
        [
          XFile.fromData(
            bytes,
            name: fileName,
            mimeType: 'image/png',
          ),
        ],
        text: equipmentName.trim().isEmpty ? null : equipmentName.trim(),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorSharingQrCode)),
      );
    }
  }

  Future<void> _printEquipmentQrCode({
    required String data,
    required String equipmentName,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final bytes = await _buildEquipmentQrPng(data);
      final doc = pw.Document();

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Center(
              child: pw.Container(
                padding: const pw.EdgeInsets.all(24),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: PdfColor.fromInt(0xFFE2E8F0),
                  ),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(12),
                  ),
                ),
                child: pw.Column(
                  mainAxisSize: pw.MainAxisSize.min,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Container(
                          width: 32,
                          height: 32,
                          decoration: pw.BoxDecoration(
                            color: PdfColor.fromInt(0xFF2196F3),
                            borderRadius: const pw.BorderRadius.all(
                              pw.Radius.circular(6),
                            ),
                          ),
                          alignment: pw.Alignment.center,
                          child: pw.Text(
                            'F',
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.SizedBox(width: 10),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Fixit',
                              style: pw.TextStyle(
                                fontSize: 18,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColor.fromInt(0xFF0D151C),
                              ),
                            ),
                            pw.Text(
                              l10n.qrCodeSubtitle(
                                equipmentName.trim().isEmpty
                                    ? l10n.qrCodeTitle
                                    : equipmentName.trim(),
                              ),
                              style: pw.TextStyle(
                                fontSize: 12,
                                color: PdfColor.fromInt(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 20),
                    pw.Image(
                      pw.MemoryImage(bytes),
                      width: 240,
                      height: 240,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      await Printing.layoutPdf(onLayout: (_) => doc.save());
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorPrintingQrCode)),
      );
    }
  }

  void _showEquipmentQrCode() {
    final l10n = AppLocalizations.of(context)!;

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.equipmentNameRequired)),
      );
      return;
    }

    final payload = _buildEquipmentQrPayload();
    final data = jsonEncode(payload);
    final equipmentName = payload['nome']?.toString() ?? '';

    showDialog<void>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        final screenWidth = MediaQuery.of(context).size.width;
        final qrSize = (screenWidth * 0.6).clamp(180.0, 260.0);

        return Dialog(
          backgroundColor:
              isDark ? AppColors.surfaceDarkTheme : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.qrCodeTitle,
                    style: AppTypography.headline3.copyWith(
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            isDark ? AppColors.slate700 : AppColors.slate200,
                      ),
                    ),
                    child: QrImageView(
                      data: data,
                      version: QrVersions.auto,
                      size: qrSize,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.equipmentNameLabel(equipmentName),
                    style: AppTypography.bodyTextSmall.copyWith(
                      color: isDark ? AppColors.slate200 : AppColors.slate700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _shareEquipmentQrCode(
                            data: data,
                            equipmentName: equipmentName,
                          ),
                          icon: const Icon(Icons.share),
                          label: Text(
                            l10n.shareQrCode,
                            style: AppTypography.button.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? AppColors.primaryDarkTheme
                                : AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _printEquipmentQrCode(
                            data: data,
                            equipmentName: equipmentName,
                          ),
                          icon: const Icon(Icons.print),
                          label: Text(
                            l10n.printQrCode,
                            style: AppTypography.button.copyWith(
                              color: isDark ? Colors.white : AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                isDark ? Colors.white : AppColors.primary,
                            side: BorderSide(
                              color: isDark
                                  ? AppColors.borderDefaultDark
                                  : AppColors.primary.withOpacity(0.6),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.ok),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
        backgroundColor:
            (isDark ? AppColors.backgroundDarkTheme : AppColors.backgroundLight)
                .withOpacity(0.8),
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: isDark ? AppColors.borderDefaultDark : AppColors.borderLight,
            height: 1,
          ),
        ),
        leadingWidth: 100,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.chevron_left,
            color: AppColors.primary,
            size: 20,
          ),
          label: Text(
            l10n.cancel,
            style: AppTypography.button.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.only(left: 8),
            alignment: Alignment.centerLeft,
          ),
        ),
        title: Text(
          widget.equipment != null ? l10n.editEquipment : l10n.addEquipment,
          style: AppTypography.headline3.copyWith(
            color: isDark ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (widget.equipment != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              onPressed: () async {
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
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.danger,
                        ),
                        child: Text(l10n.deleteAction),
                      ),
                    ],
                  ),
                );

                if (confirm == true && mounted) {
                  try {
                    final token = Provider.of<UserProvider>(
                      context,
                      listen: false,
                    ).token;
                    if (token != null) {
                      await EquipmentService.deleteEquipamento(
                        token: token,
                        id: widget.equipment!['id'].toString(),
                      );
                      if (mounted) {
                        Navigator.pop(
                          context,
                          true,
                        ); // Return true to refresh list
                      }
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n.errorDeletingEquipment(e.toString()),
                        ),
                      ),
                    );
                  }
                }
              },
            ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _isLoadingClients ? null : _saveEquipment,
              child: Text(
                l10n.save,
                style: AppTypography.button.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Headline Section
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.equipmentDetails,
                      style: AppTypography.headline1.copyWith(
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.equipmentDetailsSubtitle,
                      style: AppTypography.bodyTextSmall.copyWith(
                        color: isDark ? AppColors.slate400 : AppColors.slate500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Form Fields

              // Equipment Name
              _buildTextField(
                controller: _nameController,
                label: l10n.equipmentName,
                hint: l10n.equipmentNameHint,
                isDark: isDark,
              ),

              // Serial Code
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.serialCode,
                      style: AppTypography.bodyTextSmall.copyWith(
                        color: isDark
                            ? AppColors.slate200
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        TextField(
                          controller: _serialController,
                          style: AppTypography.bodyText.copyWith(
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                          decoration: _inputDecoration(
                            hint: l10n.serialCodeHint,
                            isDark: isDark,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: IconButton(
                            onPressed: () {
                              _scanBarcode();
                            },
                            icon: const Icon(
                              Icons.qr_code_scanner,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Client Selection
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.clientLocation,
                      style: AppTypography.bodyTextSmall.copyWith(
                        color: isDark
                            ? AppColors.slate200
                            : AppColors.textPrimary,
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
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  l10n.selectClient,
                                  style: TextStyle(
                                    color: isDark
                                        ? AppColors.slate400
                                        : AppColors.slate400,
                                  ),
                                ),
                          isExpanded: true,
                          dropdownColor: isDark
                              ? AppColors.surfaceDarkTheme
                              : Colors.white,
                          style: AppTypography.bodyText.copyWith(
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                          icon: const Icon(
                            Icons.unfold_more,
                            color: AppColors.slate500,
                          ),
                          items: _clients.map((client) {
                            return DropdownMenuItem<String>(
                              value: client['id']?.toString() ?? '',
                              child: Text(
                                client['nome']?.toString() ?? 'Unnamed',
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedClient = value;

                              // Auto-fill location if available
                              final client = _clients.firstWhere(
                                (c) => c['id'].toString() == value,
                                orElse: () => {},
                              );

                              if (client.isNotEmpty) {
                                if (client['latitude'] != null) {
                                  _latController.text = client['latitude']
                                      .toString();
                                }
                                if (client['longitude'] != null) {
                                  _longController.text = client['longitude']
                                      .toString();
                                }
                              }
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Layout Coordinates
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.geoCoordinates,
                      style: AppTypography.bodyTextSmall.copyWith(
                        color: isDark
                            ? AppColors.slate200
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _latController,
                            style: AppTypography.bodyText.copyWith(
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                            decoration: _inputDecoration(
                              hint: l10n.latitude,
                              isDark: isDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _longController,
                            style: AppTypography.bodyText.copyWith(
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                            decoration: _inputDecoration(
                              hint: l10n.longitude,
                              isDark: isDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _useCurrentLocation,
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 2,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.my_location,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.useCurrentLocation,
                              style: AppTypography.button.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Action Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // QR Code Generator Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.primary : AppColors.primary)
                            .withOpacity(isDark ? 0.1 : 0.05),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                        borderRadius: BorderRadius.circular(12),
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
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.slate800 : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.slate700
                                    : AppColors.slate200,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.qr_code_2,
                                color: AppColors.primary,
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.uniqueQrLabel,
                                  style: AppTypography.bodyText.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  l10n.instantTechAccess,
                                  style: AppTypography.captionSmall.copyWith(
                                    color: isDark
                                        ? AppColors.slate400
                                        : AppColors.slate500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _showEquipmentQrCode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark
                                  ? AppColors.slate800
                                  : Colors.white,
                              foregroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(
                                  color: AppColors.primary,
                                ),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              l10n.generateQr,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Primary Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _isLoadingClients ? null : _saveEquipment,
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: Text(
                          l10n.saveEquipment,
                          style: AppTypography.button.copyWith(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          shadowColor: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                    ),

                    // Map Preview (Mock)
                    const SizedBox(height: 24),
                    // Real Map Implementation
                    const SizedBox(height: 24),
                    Container(
                      height: 200, // Increased height for better visibility
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppColors.slate800
                              : AppColors.slate200,
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
                      clipBehavior: Clip.antiAlias,
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _mapCenter,
                          initialZoom: 15,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.fixit',
                          ),
                          MarkerLayer(markers: _markers),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
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
          TextField(
            controller: controller,
            style: AppTypography.bodyText.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
            decoration: _inputDecoration(hint: hint, isDark: isDark),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required bool isDark,
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
      contentPadding: const EdgeInsets.all(16),
    );
  }
}
