import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../models/execution_models.dart';
import '../providers/user_provider.dart';
import '../services/execution_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'execution_flow_screen.dart';

class MaintenanceExecutionEntryScreen extends StatefulWidget {
  final String? initialEquipmentCode;
  final String? initialQrPayload;

  const MaintenanceExecutionEntryScreen({
    super.key,
    this.initialEquipmentCode,
    this.initialQrPayload,
  });

  @override
  State<MaintenanceExecutionEntryScreen> createState() =>
      _MaintenanceExecutionEntryScreenState();
}

class _MaintenanceExecutionEntryScreenState
    extends State<MaintenanceExecutionEntryScreen> {
  final _codeController = TextEditingController();
  int _step = 0;
  bool _isLoading = false;
  String? _error;
  ExecutionLookupResponse? _lookup;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialEquipmentCode != null &&
        widget.initialEquipmentCode!.isNotEmpty) {
      _codeController.text = widget.initialEquipmentCode!;
      WidgetsBinding.instance.addPostFrameCallback((_) => _lookupByCode());
    } else if (widget.initialQrPayload != null &&
        widget.initialQrPayload!.isNotEmpty) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _lookupByQr(widget.initialQrPayload!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDarkTheme : AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Maintenance Execution')),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _buildStep(context, isDark),
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, bool isDark) {
    switch (_step) {
      case 0:
        return _entryStep(isDark);
      case 1:
        return _scanStep(isDark);
      case 2:
        return _successStep(isDark);
      default:
        return _errorStep(isDark);
    }
  }

  Widget _entryStep(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Iniciar manutenção',
            style: AppTypography.headline3.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Digite o código do equipamento ou escaneie o QR code.',
            style: AppTypography.bodyText.copyWith(
              color: isDark ? AppColors.slate300 : AppColors.slate600,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _codeController,
            decoration: const InputDecoration(
              labelText: 'Código do equipamento',
              hintText: 'Ex: GER-001',
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _isLoading ? null : _lookupByCode,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Buscar ordem'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Divider(color: AppColors.slate300.withOpacity(0.4))),
              const SizedBox(width: 12),
              Text(
                'ou',
                style: AppTypography.caption.copyWith(
                  color: isDark ? AppColors.slate400 : AppColors.slate500,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Divider(color: AppColors.slate300.withOpacity(0.4))),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _isLoading ? null : () => setState(() => _step = 1),
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Escanear QR code'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              _error!,
              style: AppTypography.caption.copyWith(color: AppColors.danger),
            ),
          ],
        ],
      ),
    );
  }

  Widget _scanStep(bool isDark) {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: AppColors.shadow.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: MobileScanner(
                onDetect: (capture) {
                  final barcode = capture.barcodes.firstOrNull;
                  final value = barcode?.rawValue;
                  if (value != null && value.isNotEmpty && !_isLoading) {
                    _lookupByQr(value);
                  }
                },
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            children: [
              Text(
                'Alinhe o QR code dentro da moldura',
                style: AppTypography.bodyTextSmall.copyWith(
                  color: isDark ? AppColors.slate300 : AppColors.slate600,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => setState(() => _step = 0),
                child: const Text('Digitar código'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _successStep(bool isDark) {
    final equipmentName = _lookup?.equipmentName ?? 'Equipamento';
    final equipmentCode = _lookup?.equipmentCode ?? '-';
    final orderId = _lookup?.maintenanceOrderId;
    final orderStatus = _formatStatus(_lookup?.maintenanceOrderStatus);
    final clientName = _lookup?.clientName ?? '-';
    final scheduledFor = _formatScheduledFor(_lookup?.scheduledFor);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.statusCompletedBg,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.check_circle,
              size: 56,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Ordem encontrada',
            style: AppTypography.headline3.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$equipmentName • $equipmentCode',
            style: AppTypography.bodyText.copyWith(
              color: isDark ? AppColors.slate300 : AppColors.slate600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.slate800 : AppColors.slate100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'Ordem #${orderId ?? '-'}',
                  style: AppTypography.bodyText.copyWith(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  orderStatus,
                  style: AppTypography.caption.copyWith(
                    color: isDark ? AppColors.slate300 : AppColors.slate600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Cliente: $clientName',
                  style: AppTypography.caption.copyWith(
                    color: isDark ? AppColors.slate300 : AppColors.slate600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Prevista: $scheduledFor',
                  style: AppTypography.caption.copyWith(
                    color: isDark ? AppColors.slate300 : AppColors.slate600,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _startExecutionFlow,
            child: const Text('Ir para checklist'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => setState(() {
              _lookup = null;
              _step = 0;
            }),
            child: const Text('Buscar outro equipamento'),
          ),
        ],
      ),
    );
  }

  Widget _errorStep(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.statusFailedBg,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 56,
              color: AppColors.danger,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Não encontramos uma ordem',
            style: AppTypography.headline3.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Tente novamente com outro código.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyText.copyWith(
              color: isDark ? AppColors.slate300 : AppColors.slate600,
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () => setState(() => _step = 0),
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Future<void> _lookupByCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _error = 'Informe o código do equipamento');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final token = Provider.of<UserProvider>(context, listen: false).token;
      if (token == null) throw Exception('Usuário não autenticado');
      final response = await ExecutionService.lookupExecution(
        token: token,
        equipmentCode: code,
      );
      if (!mounted) return;
      setState(() {
        _lookup = response;
        _step = 2;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Não foi possível localizar a ordem';
        _step = 3;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _lookupByQr(String payload) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final token = Provider.of<UserProvider>(context, listen: false).token;
      if (token == null) throw Exception('Usuário não autenticado');
      final response = await ExecutionService.lookupExecution(
        token: token,
        qrCodePayload: payload,
      );
      if (!mounted) return;
      setState(() {
        _lookup = response;
        _step = 2;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'QR code não reconhecido';
        _step = 3;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startExecutionFlow() {
    final data = _lookup;
    if (data == null) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ExecutionFlowScreen(
          orderId: data.maintenanceOrderId,
          qrPayload: data.qrCodePayload,
          equipmentTitle: data.equipmentName,
          orderType: 'MANUTENCAO',
        ),
      ),
    );
  }

  String _formatStatus(String? raw) {
    switch (raw) {
      case 'EM_ANDAMENTO':
        return 'Em andamento';
      case 'FINALIZADA':
        return 'Finalizada';
      case 'ATRASADA':
        return 'Atrasada';
      case 'CANCELADA':
        return 'Cancelada';
      case 'ABERTA':
        return 'Aberta';
      default:
        return 'Status indisponível';
    }
  }

  String _formatScheduledFor(String? raw) {
    if (raw == null || raw.isEmpty) return 'Não definida';
    try {
      final date = DateTime.parse(raw);
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$day/$month/$year $hour:$minute';
    } catch (_) {
      return raw;
    }
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
