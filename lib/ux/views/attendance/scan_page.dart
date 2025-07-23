// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:io';

import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/shared/components/app_material.dart';
import 'package:attendance_app/ux/shared/components/global_functions.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/views/attendance/face_verification_page.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
// import 'package:attendance_app/platform/extensions/date_time_extensions.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen(
      (scanData) async {
        result = scanData;
        print(result?.code);
        if (result?.code == 'res') {
          setState(() {
            isLoading = true;
          });
          controller.stopCamera();

          await Future.delayed(const Duration(milliseconds: 500));

          Navigation.navigateToScreenAndClearOnePrevious(
              context: context,
              screen: const FaceVerificationPage(
                mode: FaceVerificationMode.attendance,
              ));
        } else {
          controller.stopCamera();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Oops! 🚫 This QR code doesn’t match today\'s '
                  'class session. Please let your lecturer know.'),
            ),
          );
          Navigator.pop(context);
        }
      },
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  bool flash = false;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        controller?.stopCamera();
      },
      child: Scaffold(
        body: Stack(
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height,
              width: double.infinity,
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(
                    overlayColor: const Color.fromRGBO(71, 37, 37, 0.6),
                    borderColor: Colors.white,
                    borderWidth: 10,
                    borderRadius: 2,
                    cutOutSize: 300),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 30, right: 12),
                child: AppMaterial(
                  inkwellBorderRadius: BorderRadius.circular(10),
                  onTap: () {
                    controller?.stopCamera();
                    Navigation.back(context: context);
                  },
                  child: Ink(
                    width: 85,
                    padding: const EdgeInsets.only(left: 5, top: 5, bottom: 5),
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
                        Icon(
                          Icons.close_sharp,
                          size: 25,
                          color: AppColors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: Container(
                  height: 50,
                  width: 141,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26.5),
                      color: AppColors.white),
                  child: Row(
                    children: [
                      iconBox(
                          icon: Icons.flip_camera_android,
                          onTap: () {
                            controller?.flipCamera();
                          }),
                      Container(
                        width: 1,
                        color: const Color.fromRGBO(102, 102, 102, 1),
                      ),
                      iconBox(
                          icon: flash ? Icons.flash_off : Icons.flash_on,
                          onTap: () async {
                            await controller?.toggleFlash();
                            setState(() {
                              flash = !flash;
                            });
                          }),
                    ],
                  ),
                ),
              ),
            ),
            if (isLoading)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.white),
                ),
              ),
          ],
        ),
      ),
    );
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
}
