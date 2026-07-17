import 'package:flutter/services.dart';

class ClipboardService {
  static Future<String?> getCopiedUrl() async {
    final data = await Clipboard.getData(
      'text/plain',
    ); //this reads clipboard text

    if (data == null || data.text == null) {
      return null;
    }
    final text = data.text!.trim();
    if (text.contains("amazon.") || text.contains("flipkart.")) {
      return text;
    }
    return null;
  }
}
