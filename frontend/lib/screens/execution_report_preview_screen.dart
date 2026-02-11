import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../services/firestore_execution_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class ExecutionReportPreviewScreen extends StatefulWidget {
  final String executionId;
  final String orderId;

  const ExecutionReportPreviewScreen({
    super.key,
    required this.executionId,
    required this.orderId,
  });

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
      backgroundColor: isDark
          ? AppColors.backgroundDarkTheme
          : AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Visualizar PDF')),
      body: PdfPreview(
        build: (format) async {
          return FirestoreExecutionService.generateReport(
            orderId: widget.orderId,
            executionId: widget.executionId,
          );
        },
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        loadingWidget: Center(
          child: Text(
            'Gerando relatório...',
            style: AppTypography.bodyText.copyWith(
              color: isDark ? AppColors.slate300 : AppColors.slate600,
            ),
          ),
        ),
      ),
    );
  }
}
