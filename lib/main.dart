import 'package:flutter/material.dart';
import 'package:truecart_mobile/utils/app_color.dart';
import 'screens/floating_bubble_screen.dart';
import 'package:truecart_mobile/screens/launch_router_screen.dart';

@pragma("vm:entry-point")
void overlayMain() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: FloatingBubbleScreen(),
      ),
    ),
  );
}

void main() {
  runApp(const TrueCartApp());
}

class TrueCartApp extends StatelessWidget {
  const TrueCartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TrueCart',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColor.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColor.primary,
          secondary: AppColor.secondary,
          surface: AppColor.surface,
          error: AppColor.danger,
        ),
        appBarTheme: const AppBarTheme(
          foregroundColor: AppColor.textPrimary,
          titleTextStyle: TextStyle(
            color: AppColor.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            foregroundColor: AppColor.textPrimary,
            backgroundColor: AppColor.surfaceMuted,
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColor.surfaceMuted,
          contentTextStyle: const TextStyle(color: AppColor.textPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const LaunchRouterScreen(),
    );
  }
}
