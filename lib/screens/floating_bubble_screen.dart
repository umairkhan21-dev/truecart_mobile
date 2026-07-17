import 'package:flutter/material.dart';
import 'package:truecart_mobile/services/clipboard_service.dart';

// import 'overlay_screen.dart';
import 'package:truecart_mobile/services/app_launcher_service.dart';

class FloatingBubbleScreen extends StatelessWidget {
  const FloatingBubbleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,

      child: Center(
        child: GestureDetector(
          onTap: () async {
            final copiedUrl = await ClipboardService.getCopiedUrl();

            if (copiedUrl != null) {
              debugPrint("Detected URL: $copiedUrl");

              await AppLauncherService.openTrueCartApp(productUrl: copiedUrl);
            } else {
              debugPrint("Copy Amazon or Flipkart link first.");
            }
          },

          child: Container(
            height: 72,
            width: 72,

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF22D3EE)],
              ),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),

            child: const Icon(
              Icons.shopping_cart,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}
