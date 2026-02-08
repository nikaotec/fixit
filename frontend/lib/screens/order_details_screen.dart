import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../l10n/app_localizations.dart';
import '../models/order.dart';
import '../providers/user_provider.dart';
import '../services/order_service.dart';
import '../services/api_service.dart';
import '../services/order_event_utils.dart';
import 'maintenance_execution_entry_screen.dart';
import 'execution_flow_screen.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Order order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  LatLng? _coords;
  bool _isGeocoding = false;
  String? _geoError;
  late Order _order;
  String? _lastToken;
  WebSocketChannel? _ordersChannel;
  StreamSubscription? _ordersSub;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _coords = _orderCoords(_order);
    if (_coords == null) {
      _loadCachedCoords().then((cached) {
        if (cached != null) {
          setState(() => _coords = cached);
        } else {
          _fetchGeocodedCoords();
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final token = Provider.of<UserProvider>(context).token;
    if (token != null && token != _lastToken) {
      _lastToken = token;
      _connectRealtime(token);
      _loadOrder();
    }
  }

  @override
  void dispose() {
    _ordersSub?.cancel();
    _ordersChannel?.sink.close();
    super.dispose();
  }

  Future<void> _loadOrder() async {
    try {
      final token = Provider.of<UserProvider>(context, listen: false).token;
      if (token == null) return;
      final updated = await OrderService.getById(token: token, id: _order.id);
      if (!mounted) return;
      setState(() {
        _order = updated;
        _coords = _orderCoords(_order) ?? _coords;
      });
    } catch (_) {}
  }

  void _connectRealtime(String token) {
    _ordersSub?.cancel();
    _ordersChannel?.sink.close();
    final url = '${ApiService.wsBaseUrl}/ws/orders?token=$token';
    _ordersChannel = IOWebSocketChannel.connect(Uri.parse(url));
    _ordersSub = _ordersChannel!.stream.listen((event) {
      try {
        final data = jsonDecode(event);
        if (data is Map &&
            OrderEventUtils.isOrderEvent(data, orderId: _order.id)) {
          _handleOrderEvent(data);
        }
      } catch (_) {}
    });
  }

  Future<void> _handleOrderEvent(Map data) async {
    final payload = OrderEventUtils.extractOrderPayload(data);
    if (payload != null) {
      if (!mounted) return;
      setState(() {
        _order = Order.fromJson(payload);
        _coords = _orderCoords(_order) ?? _coords;
      });
      return;
    }
    await _loadOrder();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final currentUserId =
        int.tryParse(Provider.of<UserProvider>(context).id ?? '');
    final surface = isDark ? AppColors.surfaceDarkTheme : Colors.white;
    final border = isDark ? AppColors.borderDefaultDark : AppColors.borderLight;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDarkTheme : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(l10n.orderDetailsTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(isDark, currentUserId, l10n),
            const SizedBox(height: 16),
            _buildMapCard(isDark, l10n),
            const SizedBox(height: 16),
            _buildChecklistCard(isDark, l10n),
            const SizedBox(height: 16),
            _buildTechnicianCard(isDark, currentUserId, l10n),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _showStartMaintenanceOptions,
              icon: const Icon(Icons.play_arrow),
              label: Text(l10n.startMaintenance),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    bool isDark,
    int? currentUserId,
    AppLocalizations l10n,
  ) {
    final roleLabel = _roleLabelForOrder(_order, currentUserId, l10n);
    final typeLabel = _orderTypeLabel(l10n);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkTheme : Colors.white,
        borderRadius: BorderRadius.circular(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.build, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _order.equipamento.nome,
                      style: AppTypography.headline3.copyWith(
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_order.equipamento.codigo.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        l10n.equipmentCodeValue(_order.equipamento.codigo),
                        style: AppTypography.caption.copyWith(
                          color:
                              isDark ? AppColors.slate300 : AppColors.slate600,
                        ),
                      ),
                    ],
                    if (_order.equipamento.qrCode.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        l10n.qrCodeValue(_order.equipamento.qrCode),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(
                          color:
                              isDark ? AppColors.slate300 : AppColors.slate600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _badge(_statusLabel(_order.status, l10n), isDark),
              const SizedBox(width: 8),
              _chip(_order.priority, isDark),
              const SizedBox(width: 8),
              _chip(typeLabel, isDark),
              const SizedBox(width: 8),
              _chip(l10n.orderNumberLabel(_order.id.toString()), isDark),
              if (roleLabel != null) ...[
                const SizedBox(width: 8),
                _roleChip(roleLabel, isDark),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _buildLocation(_order, l10n.locationNotSpecified),
            style: AppTypography.caption.copyWith(
              color: isDark ? AppColors.slate300 : AppColors.slate600,
            ),
          ),
        ],
      ),
    );
  }

  String _orderTypeLabel(AppLocalizations l10n) {
    switch (_order.orderType) {
      case 'MANUTENCAO':
        return l10n.orderTypeMaintenance;
      case 'CONSERTO':
        return l10n.orderTypeRepair;
      case 'OUTROS':
        return l10n.orderTypeOther;
      default:
        return l10n.orderTypeMaintenance;
    }
  }

  Widget _buildMapCard(bool isDark, AppLocalizations l10n) {
    final LatLng? coords = _coords;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkTheme : Colors.white,
        borderRadius: BorderRadius.circular(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.clientAndLocation,
            style: AppTypography.subtitle1.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? AppColors.slate800 : AppColors.slate100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.slate700 : AppColors.slate200,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: coords == null
                ? _buildMapPlaceholder(isDark)
                : FlutterMap(
                    options: MapOptions(
                      initialCenter: coords,
                      initialZoom: 15,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.fixit',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: coords,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_on,
                              color: AppColors.primary,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            _buildLocation(_order, l10n.locationNotSpecified),
            style: AppTypography.caption.copyWith(
              color: isDark ? AppColors.slate300 : AppColors.slate600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistCard(bool isDark, AppLocalizations l10n) {
    final isMaintenance = _order.orderType == 'MANUTENCAO';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkTheme : Colors.white,
        borderRadius: BorderRadius.circular(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isMaintenance ? l10n.assignedChecklist : l10n.problemDescriptionLabel,
            style: AppTypography.subtitle1.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isMaintenance
                ? (_order.checklist.nome.isNotEmpty
                    ? _order.checklist.nome
                    : l10n.checklistNotAssigned)
                : (_order.problemDescription?.isNotEmpty == true
                    ? _order.problemDescription!
                    : l10n.problemDescriptionEmpty),
            style: AppTypography.bodyText.copyWith(
              color: isDark ? AppColors.slate300 : AppColors.slate600,
            ),
          ),
          if (!isMaintenance &&
              (_order.equipmentBrand?.isNotEmpty == true ||
                  _order.equipmentModel?.isNotEmpty == true)) ...[
            const SizedBox(height: 8),
            Text(
              '${l10n.brandLabel}: ${_order.equipmentBrand ?? '-'}',
              style: AppTypography.caption.copyWith(
                color: isDark ? AppColors.slate300 : AppColors.slate600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${l10n.modelLabel}: ${_order.equipmentModel ?? '-'}',
              style: AppTypography.caption.copyWith(
                color: isDark ? AppColors.slate300 : AppColors.slate600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTechnicianCard(
    bool isDark,
    int? currentUserId,
    AppLocalizations l10n,
  ) {
    final roleLabel = _roleLabelForOrder(_order, currentUserId, l10n);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkTheme : Colors.white,
        borderRadius: BorderRadius.circular(16),
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
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.assignedTechnician,
                  style: AppTypography.caption.copyWith(
                    color: isDark ? AppColors.slate300 : AppColors.slate600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _order.responsavel?.name ?? l10n.unassigned,
                  style: AppTypography.bodyText.copyWith(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_order.criador != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    l10n.createdBy(_order.criador!.name),
                    style: AppTypography.captionSmall.copyWith(
                      color: isDark ? AppColors.slate300 : AppColors.slate600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                if (roleLabel != null) ...[
                  const SizedBox(height: 6),
                  _roleChip(roleLabel, isDark),
                ],
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            child: Text(l10n.reassign),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate800 : AppColors.slate100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTypography.captionSmall.copyWith(
          color: isDark ? AppColors.slate200 : AppColors.slate600,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _badge(String status, bool isDark) {
    Color bg;
    Color text;
    final normalized = status.toLowerCase();
    if (normalized.contains('atras')) {
        bg = AppColors.statusFailedBg;
        text = AppColors.statusFailedText;
    } else if (normalized.contains('andamento')) {
        bg = AppColors.statusInProgressBg;
        text = AppColors.statusInProgressText;
    } else if (normalized.contains('conclu') ||
        normalized.contains('finaliz')) {
        bg = AppColors.statusCompletedBg;
        text = AppColors.statusCompletedText;
    } else {
        bg = AppColors.statusPendingBg;
        text = AppColors.statusPendingText;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: AppTypography.captionSmall.copyWith(
          color: text,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _buildLocation(Order order, String locationNotSpecified) {
    final equipmentLocation = order.equipamento.localizacao;
    if (equipmentLocation != null && equipmentLocation.isNotEmpty) {
      return equipmentLocation;
    }
    final client = order.cliente;
    if (client == null) return locationNotSpecified;
    final parts = [
      if (client.rua != null) client.rua,
      if (client.numero != null) client.numero,
      if (client.bairro != null) client.bairro,
      if (client.cidade != null) client.cidade,
    ].where((e) => e != null && e!.isNotEmpty).map((e) => e!).toList();
    if (parts.isEmpty) return locationNotSpecified;
    return parts.join(' • ');
  }

  String? _roleLabelForOrder(
    Order order,
    int? currentUserId,
    AppLocalizations l10n,
  ) {
    if (currentUserId == null) return null;
    final isCreator = order.criador?.id == currentUserId;
    final isResponsible = order.responsavel?.id == currentUserId;
    if (isCreator && isResponsible) return l10n.roleCreatorResponsible;
    if (isCreator) return l10n.roleCreator;
    if (isResponsible) return l10n.roleResponsible;
    return null;
  }

  Widget _roleChip(String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate800 : AppColors.slate100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTypography.captionSmall.copyWith(
          color: isDark ? AppColors.slate200 : AppColors.slate700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _showStartMaintenanceOptions() async {
    if (_order.orderType != 'MANUTENCAO') {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ExecutionFlowScreen(
            orderId: _order.id,
            orderType: _order.orderType,
          ),
        ),
      );
      return;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = isDark ? Colors.white : AppColors.textPrimary;
    final subtitle = isDark ? AppColors.slate300 : AppColors.slate600;
    final surface = isDark ? AppColors.surfaceDarkTheme : Colors.white;
    final l10n = AppLocalizations.of(context)!;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.slate700 : AppColors.slate200,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.maintenanceExecutionStartTitle,
                style: AppTypography.subtitle1.copyWith(
                  color: text,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.chooseEquipmentIdentification,
                style: AppTypography.bodyTextSmall.copyWith(color: subtitle),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MaintenanceExecutionEntryScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: Text(l10n.scanQrCodeButton),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await _showManualCodeDialog();
                },
                icon: const Icon(Icons.keyboard),
                label: Text(l10n.typeCodeButton),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showManualCodeDialog() async {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    final code = await showDialog<String?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.equipmentCodeLabel),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: l10n.equipmentCodeHint,
            ),
            textInputAction: TextInputAction.done,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final value = controller.text.trim();
                Navigator.pop(context, value.isEmpty ? null : value);
              },
              child: Text(l10n.continueButton),
            ),
          ],
        );
      },
    );

    if (code == null || code.isEmpty || !mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MaintenanceExecutionEntryScreen(
          initialEquipmentCode: code,
        ),
      ),
    );
  }

  Widget _buildMapPlaceholder(bool isDark) {
    final textColor = isDark ? AppColors.slate300 : AppColors.slate600;
    if (_isGeocoding) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(height: 8),
          Text('Buscando localização...', style: AppTypography.caption.copyWith(color: textColor)),
        ],
      );
    }
    if (_geoError != null) {
      return Center(
        child: Text(
          _geoError!,
          style: AppTypography.caption.copyWith(color: textColor),
          textAlign: TextAlign.center,
        ),
      );
    }
    return const Center(
      child: Icon(Icons.map, color: AppColors.primary, size: 48),
    );
  }

  Future<void> _fetchGeocodedCoords() async {
    final query = _buildAddressQuery(_order);
    if (query == null) {
      setState(() => _geoError = 'Localização indisponível');
      return;
    }
    setState(() {
      _isGeocoding = true;
      _geoError = null;
    });
    try {
      final uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/search',
        {
          'q': query,
          'format': 'jsonv2',
          'limit': '1',
        },
      );
      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'fixit-app',
          'Accept-Language': 'pt-BR',
        },
      );
      if (response.statusCode != 200) {
        setState(() {
          _geoError = 'Não foi possível localizar';
          _isGeocoding = false;
        });
        return;
      }
      final data = jsonDecode(response.body);
      if (data is List && data.isNotEmpty) {
        final item = data.first;
        final lat = double.tryParse(item['lat']?.toString() ?? '');
        final lon = double.tryParse(item['lon']?.toString() ?? '');
        if (lat != null && lon != null) {
          await _saveCachedCoords(query, lat, lon);
          setState(() {
            _coords = LatLng(lat, lon);
            _isGeocoding = false;
          });
          return;
        }
      }
      setState(() {
        _geoError = 'Localização indisponível';
        _isGeocoding = false;
      });
    } catch (_) {
      setState(() {
        _geoError = 'Erro ao buscar localização';
        _isGeocoding = false;
      });
    }
  }

  String? _buildAddressQuery(Order order) {
    final client = order.cliente;
    if (client == null) return null;
    final parts = [
      if (client.rua != null) client.rua,
      if (client.numero != null) client.numero,
      if (client.bairro != null) client.bairro,
      if (client.cidade != null) client.cidade,
      if (client.estado != null) client.estado,
    ].where((e) => e != null && e!.isNotEmpty).map((e) => e!).toList();
    if (parts.isEmpty) return null;
    return parts.join(', ');
  }

  Future<LatLng?> _loadCachedCoords() async {
    final query = _buildAddressQuery(_order);
    if (query == null) return null;
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_cacheKeyForAddress(query));
    if (value == null) return null;
    final parts = value.split(',');
    if (parts.length != 2) return null;
    final lat = double.tryParse(parts[0]);
    final lng = double.tryParse(parts[1]);
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  Future<void> _saveCachedCoords(String query, double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKeyForAddress(query), '$lat,$lng');
  }

  String _cacheKeyForAddress(String query) {
    return 'geo_cache_${query.toLowerCase()}';
  }

  LatLng? _orderCoords(Order order) {
    final lat = order.equipamento.latitude;
    final lng = order.equipamento.longitude;
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  String _statusLabel(String raw, AppLocalizations l10n) {
    switch (raw) {
      case 'EM_ANDAMENTO':
        return l10n.statusInProgress;
      case 'FINALIZADA':
        return l10n.statusFinished;
      case 'ATRASADA':
        return l10n.statusOverdue;
      case 'CANCELADA':
        return l10n.statusCancelled;
      default:
        return l10n.statusPending;
    }
  }
}
