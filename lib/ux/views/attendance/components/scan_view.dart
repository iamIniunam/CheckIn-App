import 'dart:io';

import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanView extends StatefulWidget {
  const ScanView({super.key});

  @override
  State<ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends State<ScanView> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  MobileScannerController controller = MobileScannerController();

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.stop();
    } else if (Platform.isIOS) {
      controller.start();
    }
  }

  void _onQRViewCreated(
      BarcodeCapture capture, MobileScannerController controller) async {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    result = barcodes.first;
    debugPrint("Scanned code: ${result?.rawValue}");

    if (result?.rawValue == 'res') {
      setState(() {
        isLoading = true;
      });
      controller.stop();

      await Future.delayed(const Duration(milliseconds: 500));
    } else {
      controller.stop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Oops! 🚫 This QR code doesn\'t match today\'s '
              'class session. Please let your lecturer know.'),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  bool flash = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const scanArea = 300.0;

    return Stack(
      children: [
        // Full screen camera
        MobileScanner(
          controller: controller,
          scanWindow: Rect.fromCenter(
            center: size.center(Offset.zero),
            width: scanArea,
            height: scanArea,
          ),
          fit: BoxFit.cover,
          onDetect: (capture) {
            // controller.stop();
            _onQRViewCreated(capture, controller);
          },
        ),

        // White overlay with hole in the middle
        CustomPaint(
          painter: WhiteOverlayPainter(
            scanAreaSize: scanArea,
            borderRadius: 12,
            showLoading: isLoading,
          ),
          child: Container(),
        ),

        // Loading indicator - only in the scan area
        if (isLoading)
          Center(
            child: Container(
              width: scanArea,
              height: scanArea,
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.defaultColor),
              ),
            ),
          ),
      ],
    );
  }
}

class WhiteOverlayPainter extends CustomPainter {
  final double scanAreaSize;
  final double borderRadius;
  final bool showLoading;

  WhiteOverlayPainter({
    required this.scanAreaSize,
    required this.borderRadius,
    this.showLoading = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: scanAreaSize,
      height: scanAreaSize,
    );

    // Draw white overlay with hole
    final overlayPaint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.fill;

    final overlayPath = Path()
      ..addRect(rect)
      ..addRRect(RRect.fromRectAndRadius(
        scanRect,
        Radius.circular(borderRadius),
      ))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(overlayPath, overlayPaint);

    // Draw border around scan area
    final borderPaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        scanRect,
        Radius.circular(borderRadius),
      ),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(WhiteOverlayPainter oldDelegate) {
    return oldDelegate.showLoading != showLoading;
  }
}
