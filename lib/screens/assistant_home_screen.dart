import 'package:flutter/material.dart';
import "../services/overlay_service.dart";
import '../utils/app_color.dart';

class AssistantHomeScreen extends StatelessWidget {
  const AssistantHomeScreen({super.key});

  Future<void> _startFloatingAssistant(BuildContext context) async {
    await OverlayService.startOverlay();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColor.background, Color(0xFF0A1020), Color(0xFF040608)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [AppColor.primary, AppColor.secondary],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x667C5CFF),
                        blurRadius: 28,
                        offset: Offset(0, 18),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColor.textPrimary,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'TrueCart',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: AppColor.textPrimary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'A futuristic shopping copilot built to launch floating guidance, scan storefront context, and prepare for deeper accessibility-powered automation.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColor.textSecondary,
                    height: 1.6,
                  ),
                ),
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColor.surface.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Assistant Launcher',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColor.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'This entry point is ready for future overlay service and accessibility integration.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColor.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => _startFloatingAssistant(context),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColor.primary,
                            foregroundColor: AppColor.textPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Start Floating Assistant',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
