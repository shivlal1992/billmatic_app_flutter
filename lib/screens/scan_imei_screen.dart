import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanImeiScreen extends StatefulWidget {
  const ScanImeiScreen({super.key});

  @override
  State<ScanImeiScreen> createState() => _ScanImeiScreenState();
}

class _ScanImeiScreenState extends State<ScanImeiScreen> {
  bool scanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan IMEI / Serial No"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),

      body: MobileScanner(
        onDetect: (capture) {
          if (scanned) return; // prevent double-scanning
          scanned = true;

          final barcode = capture.barcodes.first;
          final value = barcode.rawValue ?? "";

          Navigator.pop(context, value);
        },
      ),
    );
  }
}
