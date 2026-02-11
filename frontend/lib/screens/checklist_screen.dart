import 'package:flutter/material.dart';
import '../models/order.dart';
import 'package:signature/signature.dart';
import 'dart:typed_data';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class ChecklistScreen extends StatefulWidget {
  final Order order;

  ChecklistScreen({required this.order});

  @override
  _ChecklistScreenState createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  final Map<String, bool> _answers = {};
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: Text("Checklist: ${widget.order.checklist.nome}")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            ...widget.order.checklist.itens.map((item) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: const EdgeInsets.all(12),
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
                            color: AppColors.shadow.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                ),
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.descricao),
                  value: _answers[item.id] ?? false,
                  onChanged: (val) {
                    setState(() {
                      _answers[item.id] = val!;
                    });
                  },
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Signature Required",
                  style: AppTypography.subtitle1.copyWith(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
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
                          color: AppColors.shadow.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
              ),
              child: Signature(
                controller: _signatureController,
                backgroundColor: Colors.white,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () => _signatureController.clear(),
                ),
                ElevatedButton(
                  onPressed: _submit,
                  child: Text("Finalize Order"),
                ),
              ],
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_signatureController.isNotEmpty) {
      final Uint8List? signatureBytes = await _signatureController.toPngBytes();
      // Send data to backend:
      // answers map + signatureBytes (base64)
      print("Submitting order ${widget.order.id}");
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Signature missing")));
    }
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }
}
