import 'package:flutter/material.dart';

class PageLoadingIndicator extends StatelessWidget {
  const PageLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
