import 'dart:io';

import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/resources/app_dialogs.dart';
import 'package:attendance_app/ux/shared/view_models/attendance_verification_view_model.dart';
import 'package:provider/provider.dart';
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
  bool isProcessing = false;
  // The ScanView should use the AttendanceVerificationViewModel provided by
  // the surrounding widget (VerificationPage supplies one via
  // ChangeNotifierProvider). Creating a local view model here meant moves
  // didn't affect the app state. We'll obtain the provider at runtime.

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
    if (isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    result = barcodes.first;
    final code = result?.rawValue;

    if (code == null) return;

    setState(() {
      isProcessing = true;
    });

    controller.stop();

    debugPrint("Scanned code: $code");

    final viewModel =
        Provider.of<AttendanceVerificationViewModel>(context, listen: false);

    bool isValid = await viewModel.validateQrCode(code);

    if (!mounted) return;

    if (isValid) {
      viewModel.moveToNextStep();
      await viewModel.proceedWithAutomaticFlow();

      if (!mounted) return;
      Navigator.pop(context);
    } else {
      controller.stop();
      AppDialogs.showAlertDialog(
          context: context, message: 'Invalid QR code for this class');
      setState(() {
        isProcessing = false;
      });
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
