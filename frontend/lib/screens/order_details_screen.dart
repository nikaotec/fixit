import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../models/order.dart';
import 'qr_flow_screen.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Order order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.surfaceDarkTheme : Colors.white;
    final border = isDark ? AppColors.borderDefaultDark : AppColors.borderLight;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDarkTheme : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(isDark),
            const SizedBox(height: 16),
            _buildMapCard(isDark),
            const SizedBox(height: 16),
            _buildChecklistCard(isDark),
            const SizedBox(height: 16),
            _buildTechnicianCard(isDark),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QRFlowScreen(
                      orderId: order.id,
                      equipmentTitle: order.equipamento.nome,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Maintenance'),
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

  Widget _buildHeader(bool isDark) {
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
                child: Text(
                  order.equipamento.nome,
                  style: AppTypography.headline3.copyWith(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _badge(_mapStatus(order.status), isDark),
              const SizedBox(width: 8),
              _chip(order.priority, isDark),
              const SizedBox(width: 8),
              _chip('ID #${order.id}', isDark),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _buildLocation(order),
            style: AppTypography.caption.copyWith(
              color: isDark ? AppColors.slate300 : AppColors.slate600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapCard(bool isDark) {
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
            'Client & Location',
            style: AppTypography.subtitle1.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: isDark ? AppColors.slate800 : AppColors.slate100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.map, color: AppColors.primary, size: 48),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistCard(bool isDark) {
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
            'Assigned Checklist',
            style: AppTypography.subtitle1.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            order.checklist.nome.isNotEmpty
                ? order.checklist.nome
                : 'Checklist not assigned',
            style: AppTypography.bodyText.copyWith(
              color: isDark ? AppColors.slate300 : AppColors.slate600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicianCard(bool isDark) {
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
                  'Assigned Technician',
                  style: AppTypography.caption.copyWith(
                    color: isDark ? AppColors.slate300 : AppColors.slate600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.responsavel?.name ?? 'Unassigned',
                  style: AppTypography.bodyText.copyWith(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            child: const Text('Reassign'),
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
    switch (status) {
      case 'Overdue':
        bg = AppColors.statusFailedBg;
        text = AppColors.statusFailedText;
        break;
      case 'In Progress':
        bg = AppColors.statusInProgressBg;
        text = AppColors.statusInProgressText;
        break;
      case 'Completed':
        bg = AppColors.statusCompletedBg;
        text = AppColors.statusCompletedText;
        break;
      default:
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

  String _buildLocation(Order order) {
    final equipmentLocation = order.equipamento.localizacao;
    if (equipmentLocation != null && equipmentLocation.isNotEmpty) {
      return equipmentLocation;
    }
    final client = order.cliente;
    if (client == null) return 'Location not specified';
    final parts = [
      if (client.rua != null) client.rua,
      if (client.numero != null) client.numero,
      if (client.bairro != null) client.bairro,
      if (client.cidade != null) client.cidade,
    ].where((e) => e != null && e!.isNotEmpty).map((e) => e!).toList();
    if (parts.isEmpty) return 'Location not specified';
    return parts.join(' • ');
  }

  String _mapStatus(String raw) {
    switch (raw) {
      case 'EM_ANDAMENTO':
        return 'In Progress';
      case 'FINALIZADA':
        return 'Completed';
      case 'ATRASADA':
        return 'Overdue';
      case 'CANCELADA':
        return 'Cancelled';
      default:
        return 'Pending';
    }
  }
}
