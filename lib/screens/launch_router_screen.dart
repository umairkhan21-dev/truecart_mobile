import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/api_service.dart';
import 'analysis_result_screen.dart';
import 'url_input_screen.dart';
import 'package:truecart_mobile/widgets/analysis_widgets.dart';

class LaunchRouterScreen extends StatefulWidget {
  const LaunchRouterScreen({super.key});

  @override
  State<LaunchRouterScreen> createState() => _LaunchRouterScreenState();
}

class _LaunchRouterScreenState extends State<LaunchRouterScreen> {
  static const MethodChannel _launchChannel = MethodChannel(
    'truecart_mobile/launch',
  );

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _routeLaunch();
  }

  Future<void> _routeLaunch() async {
    try {
      final launchPayload = await _launchChannel
          .invokeMapMethod<String, dynamic>('consumeLaunchPayload');

      final productUrl = launchPayload?['product_url'] as String?;
      final launchSource = launchPayload?['launch_source'] as String?;

      if (launchSource == 'overlay_bubble' &&
          productUrl != null &&
          productUrl.isNotEmpty) {
        final result = await ApiService.analyzeUrl(url: productUrl);

        if (!mounted) {
          return;
        }

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => AnalysisResultScreen(
              productData: Map<String, dynamic>.from(
                (result['productData'] as Map?) ?? <String, dynamic>{},
              ),
              analysis: result['result'],
            ),
          ),
        );
        return;
      }
    } catch (error) {
      _errorMessage = 'Failed to open AI panel: $error';
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: PremiumLoadingView());
    }

    return UrlInputScreen(initialErrorMessage: _errorMessage);
  }
}
