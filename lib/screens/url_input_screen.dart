import 'package:flutter/material.dart';
import 'package:truecart_mobile/screens/webview_screen.dart';
import '../services/api_service.dart';
import 'analysis_result_screen.dart';

class UrlInputScreen extends StatefulWidget {
  final String? initialErrorMessage;

  const UrlInputScreen({super.key, this.initialErrorMessage});

  @override
  State<UrlInputScreen> createState() => _UrlInputScreenState();
}

class _UrlInputScreenState extends State<UrlInputScreen> {
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    final initialErrorMessage = widget.initialErrorMessage;
    if (initialErrorMessage != null && initialErrorMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(initialErrorMessage)));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("TrueCart")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: controller,

              decoration: const InputDecoration(hintText: "Paste product URL"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                final url = controller.text.trim();

                if (url.isEmpty) {
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WebViewScreen(productUrl: url),
                  ),
                );
              },

              child: const Text("Analyze"),
            ),
          ],
        ),
      ),
    );
  }
}
