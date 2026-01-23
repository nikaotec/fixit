import 'package:flutter/material.dart';
import '../models/order.dart';
import 'package:signature/signature.dart';
import 'dart:typed_data';

class ChecklistScreen extends StatefulWidget {
  final Order order;

  ChecklistScreen({required this.order});

  @override
  _ChecklistScreenState createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  final Map<int, bool> _answers = {};
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Checklist: ${widget.order.checklist.nome}")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ...widget.order.checklist.itens.map((item) {
              return CheckboxListTile(
                title: Text(item.descricao),
                value: _answers[item.id] ?? false,
                onChanged: (val) {
                  setState(() {
                    _answers[item.id] = val!;
                  });
                },
              );
            }).toList(),
            SizedBox(height: 20),
            Text("Signature Required"),
            Container(
              height: 200,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
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
