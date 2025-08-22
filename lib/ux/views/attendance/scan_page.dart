// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:io';

import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/shared/components/app_material.dart';
import 'package:attendance_app/ux/shared/components/blurred_loading_overlay.dart';
import 'package:attendance_app/ux/shared/components/global_functions.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/views/attendance/face_verification_page.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:attendance_app/platform/extensions/date_time_extensions.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  MobileScannerController controller = MobileScannerController();

  // // In order to get hot reload to work we need to pause the camera if the platform
  // // is android, or resume the camera if the platform is iOS.
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

      Navigation.navigateToScreenAndClearOnePrevious(
          context: context,
          screen: const FaceVerificationPage(
            mode: FaceVerificationMode.attendance,
          ));
    } else {
      controller.stop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Oops! 🚫 This QR code doesn’t match today\'s '
              'class session. Please let your lecturer know.'),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool flash = false;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        controller.stop();
      },
      child: Scaffold(
        body: Stack(
          children: [
            /// Scanner + cutout window
            MobileScanner(
              controller: controller,
              scanWindow: Rect.fromCenter(
                center: size.center(Offset.zero),
                width: 300,
                height: 300,
              ),
              fit: BoxFit.cover,
              onDetect: (capture) => _onQRViewCreated(capture, controller),
            ),

            /// Dark overlay outside scan window
            Container(
              color: const Color.fromRGBO(0, 0, 0, 0.6),
              child: Center(
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 0),
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            /// Exit button
            Positioned(
              top: MediaQuery.of(context).padding.top + 30,
              right: 12,
              child: AppMaterial(
                inkwellBorderRadius: BorderRadius.circular(10),
                onTap: () {
                  controller.stop();
                  Navigation.back(context: context);
                },
                child: Ink(
                  width: 85,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Exit',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.white),
                      ),
                      SizedBox(width: 5),
                      Icon(Icons.close_sharp, size: 25, color: AppColors.white),
                    ],
                  ),
                ),
              ),
            ),

            /// Bottom controls
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  height: 50,
                  width: 141,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26.5),
                    color: AppColors.white,
                  ),
                  child: Row(
                    children: [
                      iconBox(
                        icon: Icons.flip_camera_android,
                        onTap: () => controller.switchCamera(),
                      ),
                      Container(
                          width: 1,
                          color: const Color.fromRGBO(102, 102, 102, 1)),
                      iconBox(
                        icon: flash ? Icons.flash_off : Icons.flash_on,
                        onTap: () async {
                          await controller.toggleTorch();
                          setState(() => flash = !flash);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            /// Loading overlay
            BlurredLoadingOverlay(showLoader: isLoading)
          ],
        ),
      ),
    );
  }
}

Widget iconBox({required IconData icon, required VoidCallback onTap}) {
  return AppMaterial(
    inkwellBorderRadius: icon == Icons.flip_camera_android
        ? const BorderRadius.only(
            topLeft: Radius.circular(26.5), bottomLeft: Radius.circular(26.5))
        : const BorderRadius.only(
            topRight: Radius.circular(26.5),
            bottomRight: Radius.circular(26.5)),
    onTap: onTap,
    child: Ink(
      height: 50,
      width: 70,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Icon(
        icon,
        size: 27,
        color: AppColors.black,
      ),
    ),
  );
}
