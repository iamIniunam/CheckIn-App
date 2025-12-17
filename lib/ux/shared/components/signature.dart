import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/resources/app_images.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DevSignatureTrigger extends StatefulWidget {
  final Widget child;
  final int triggerCount;

  const DevSignatureTrigger({
    super.key,
    required this.child,
    this.triggerCount = 8,
  });

  @override
  State<DevSignatureTrigger> createState() => _DevSignatureTriggerState();
}

class _DevSignatureTriggerState extends State<DevSignatureTrigger> {
  int tapCount = 0;
  DateTime? lastTap;
  bool hintShown = false;

  void handleTap() {
    final now = DateTime.now();

    if (lastTap == null ||
        now.difference(lastTap!) > const Duration(seconds: 2)) {
      tapCount = 1;
      hintShown = false;
    } else {
      tapCount++;
    }

    lastTap = now;

    if (tapCount >= 3 && tapCount < widget.triggerCount) {
      showHint();
    }

    if (tapCount == widget.triggerCount) {
      tapCount = 0;
      hintShown = false;
      showDevSignature(context);
    }
  }

  void showHint() {
    final tapsRemaining = widget.triggerCount - tapCount;

    Fluttertoast.cancel();

    Fluttertoast.showToast(
      msg: 'You are $tapsRemaining taps away from developer credits',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.defaultColor,
      textColor: AppColors.white,
      fontSize: 14.0,
    );
  }

  void showDevSignature(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const DevSignatureModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: handleTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: widget.child,
      ),
    );
  }
}

class DevSignatureModal extends StatefulWidget {
  const DevSignatureModal({super.key});

  @override
  State<DevSignatureModal> createState() => _DevSignatureModalState();
}

class _DevSignatureModalState extends State<DevSignatureModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final horizontalPadding = screenWidth * 0.5;
    final verticalPadding = screenHeight * 0.15;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: EdgeInsets.symmetric(
          horizontal: horizontalPadding.clamp(20.0, 80.0),
          vertical: verticalPadding.clamp(40.0, 120.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: AppColors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    fit: BoxFit.contain,
                    image: AppImages.appLogoIos,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Crafted by Dev ID',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.defaultColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Flutter • Dart',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.defaultColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
