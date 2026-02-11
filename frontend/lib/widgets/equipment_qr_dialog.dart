import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class EquipmentQrDialog extends StatelessWidget {
  final Map<String, dynamic> equipment;

  const EquipmentQrDialog({super.key, required this.equipment});

  static void show(BuildContext context, Map<String, dynamic> equipment) {
    showDialog(
      context: context,
      builder: (context) => EquipmentQrDialog(equipment: equipment),
    );
  }

  Map<String, dynamic> _buildPayload() {
    return {
      'id': equipment['id'],
      'qrCode': equipment['qrCode'],
      'nome': equipment['nome'],
      'serial': equipment['codigo'],
      'clienteId': equipment['clienteId'],
      'latitude': equipment['latitude'],
      'longitude': equipment['longitude'],
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }

  Future<Uint8List> _generateQrPng(String data) async {
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

  Future<void> _share(BuildContext context, String data, String name) async {
    try {
      final bytes = await _generateQrPng(data);
      final fileName = name.trim().isEmpty
          ? 'qr-code.png'
          : 'qr-${name.trim().replaceAll(' ', '-')}.png';

      await Share.shareXFiles([
        XFile.fromData(bytes, name: fileName, mimeType: 'image/png'),
      ], text: name.trim().isEmpty ? null : name.trim());
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorSharingQrCode),
          ),
        );
      }
    }
  }

  Future<void> _print(BuildContext context, String data, String name) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final bytes = await _generateQrPng(data);
      final doc = pw.Document();

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context pwContext) {
            return pw.Center(
              child: pw.Container(
                padding: const pw.EdgeInsets.all(24),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColor.fromInt(0xFFE2E8F0)),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(12),
                  ),
                ),
                child: pw.Column(
                  mainAxisSize: pw.MainAxisSize.min,
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
                              ),
                            ),
                            pw.Text(
                              l10n.qrCodeSubtitle(
                                name.isEmpty ? l10n.qrCodeTitle : name,
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
                    pw.Image(pw.MemoryImage(bytes), width: 240, height: 240),
                  ],
                ),
              ),
            );
          },
        ),
      );
      await Printing.layoutPdf(onLayout: (_) => doc.save());
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorPrintingQrCode)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final payload = _buildPayload();
    final data = jsonEncode(payload);
    final equipmentName = payload['nome']?.toString() ?? '';
    final qrSize = (MediaQuery.of(context).size.width * 0.6).clamp(
      180.0,
      260.0,
    );

    return Dialog(
      backgroundColor: isDark ? AppColors.surfaceDarkTheme : Colors.white,
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
                    color: isDark ? AppColors.slate700 : AppColors.slate200,
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
                      onPressed: () => _share(context, data, equipmentName),
                      icon: const Icon(Icons.share, size: 18),
                      label: Text(l10n.shareQrCode),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? AppColors.primaryDarkTheme
                            : AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
                      onPressed: () => _print(context, data, equipmentName),
                      icon: const Icon(Icons.print, size: 18),
                      label: Text(l10n.printQrCode),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark
                            ? Colors.white
                            : AppColors.primary,
                        side: BorderSide(
                          color: isDark
                              ? AppColors.borderDefaultDark
                              : AppColors.primary.withOpacity(0.6),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
  }
}
