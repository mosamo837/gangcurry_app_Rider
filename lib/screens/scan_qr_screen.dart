import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../data/sample_parcels.dart';
import '../models/parcel.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handled = false;

  Future<void> _handleDetection(BarcodeCapture capture) async {
    if (_handled) {
      return;
    }

    final String? rawValue = capture.barcodes.firstOrNull?.rawValue;
    if (rawValue == null || rawValue.trim().isEmpty) {
      return;
    }

    final scannedTracking = rawValue.trim().toLowerCase();
    final Parcel? parcel = sampleParcels.cast<Parcel?>().firstWhere(
          (item) => item!.trackingNumber.toLowerCase() == scannedTracking,
          orElse: () => null,
        );

    if (parcel == null) {
      setState(() {
        _handled = true;
      });
      await _controller.stop();
      if (!mounted) {
        return;
      }
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('ไม่พบพัสดุ'),
          content: Text('QR นี้ไม่ตรงกับเลขพัสดุในระบบ\n$rawValue'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ปิด'),
            ),
          ],
        ),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _handled = false;
      });
      await _controller.start();
      return;
    }

    _handled = true;
    await _controller.stop();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(parcel);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('สแกน QR พัสดุ'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleDetection,
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 32,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xCC101318),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'สแกน QR ที่มีเลขพัสดุ เช่น TH240426001 เพื่อเปิดหน้ารายละเอียดทันที',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
