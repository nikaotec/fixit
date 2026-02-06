import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../services/execution_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class ExecutionReportPreviewScreen extends StatefulWidget {
  final int executionId;

  const ExecutionReportPreviewScreen({super.key, required this.executionId});

  @override
  State<ExecutionReportPreviewScreen> createState() =>
      _ExecutionReportPreviewScreenState();
}

class _ExecutionReportPreviewScreenState
    extends State<ExecutionReportPreviewScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDarkTheme : AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Visualizar PDF')),
      body: PdfPreview(
        build: (format) async {
          final token = Provider.of<UserProvider>(context, listen: false).token;
          if (token == null) {
            throw Exception('Usuário não autenticado');
          }
          return ExecutionService.downloadReport(
            token: token,
            executionId: widget.executionId,
          );
        },
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        loadingWidget: Center(
          child: Text(
            'Carregando relatório...',
            style: AppTypography.bodyText.copyWith(
              color: isDark ? AppColors.slate300 : AppColors.slate600,
            ),
          ),
        ),
      ),
    );
  }
}
