import 'package:android_intent_plus/android_intent.dart';

class AppLauncherService {
  static Future<void> openTrueCartApp({required String productUrl}) async {
    final intent = AndroidIntent(
      action: 'action_view',
      package: 'com.example.truecart_mobile',
      arguments: <String, dynamic>{
        'launch_source': 'overlay_bubble',
        'product_url': productUrl,
      },
    );

    await intent.launch();
  }
}
