import 'package:flutter/material.dart';
import 'package:truecart_mobile/screens/analysis_result_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:truecart_mobile/services/api_service.dart';
import 'dart:convert';
import 'package:truecart_mobile/extractor/amazon_extractor.dart';

class WebViewScreen extends StatefulWidget {
  final String productUrl;

  const WebViewScreen({super.key, required this.productUrl});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController controller;

  bool isLoading = true;
  bool hasExtracted = false;

  bool _looksLikeAmazonProductPage(Map<String, dynamic> extractedData) {
    final title = (extractedData["title"] ?? "").toString().trim();
    final rating = (extractedData["rating"] ?? "").toString().trim();
    final prices = extractedData["allPrices"];
    final hasPrices = prices is List && prices.isNotEmpty;

    if (title.isEmpty) {
      return false;
    }

    final lowerTitle = title.toLowerCase();
    final blockedTitles = [
      "amazon.in",
      "amazon sign in",
      "page not found",
      "sorry! something went wrong",
    ];

    if (blockedTitles.contains(lowerTitle)) {
      return false;
    }

    return hasPrices || rating.isNotEmpty;
  }

  Future<void> _showFailureAndExit(String message) async {
    if (!mounted) {
      return;
    }

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));

    Navigator.pop(context);
  }

  dynamic _extractAnalysisPayload(Map<String, dynamic> response) {
    if (response.containsKey("result")) {
      return response["result"];
    }

    if (response.containsKey("response")) {
      return response["response"];
    }

    return response;
  }

  dynamic _decodeJavaScriptResult(dynamic rawResult) {
    dynamic decoded = rawResult;

    for (int i = 0; i < 3; i++) {
      if (decoded is! String) {
        return decoded;
      }

      final text = decoded.trim();
      if (text == "null") {
        return null;
      }

      decoded = jsonDecode(text);
    }

    return decoded;
  }

  List<String> _stringListFrom(dynamic value) {
    if (value is! List) {
      return [];
    }

    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  Map<String, dynamic> _buildAnalysisProductData(
    Map<String, dynamic> extractedData,
  ) {
    final reviewSummary = (extractedData["reviewSummary"] ?? "")
        .toString()
        .trim();
    final extractedReviews = _stringListFrom(extractedData["reviews"]);
    final reviewsForAnalysis = extractedReviews.isNotEmpty
        ? extractedReviews
        : reviewSummary.isNotEmpty
        ? [reviewSummary]
        : <String>[];

    return {
      "title": extractedData["title"],
      "image": extractedData["image"],
      "price": extractedData["price"],
      "rating": extractedData["rating"],
      "reviewCount": extractedData["reviewCount"],
      "reviewSampleCount": reviewsForAnalysis.length,
      "bullets": extractedData["bullets"],
      "reviews": reviewsForAnalysis,
      "reviewSummary": reviewSummary,
      "customerReviewText": reviewsForAnalysis.join("\n\n"),
    };
  }

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) async {
            debugPrint("PAGE FINISHED");

            if (hasExtracted) {
              return;
            }

            hasExtracted = true;

            await Future.delayed(const Duration(seconds: 6));

            await extractProductData();
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.productUrl));
  }

  Future<void> waitForAmazonProductPage() async {
    for (int i = 0; i < 10; i++) {
      final hasTitle = await controller.runJavaScriptReturningResult('''
(()=> {
return !!(
  document.querySelector("#productTitle") ||
  document.querySelector("#title") ||
  document.querySelector("h1")
);
})();
''');
      debugPrint("TITLE CHECK: $hasTitle");
      if (hasTitle.toString() == "true") {
        debugPrint("product page ready");
        return;
      }
      await Future.delayed(const Duration(seconds: 1));
    }
    debugPrint("product page load timeout");
  }

  Future<void> prepareAmazonReviewSection() async {
    for (int i = 0; i < 5; i++) {
      final rawStatus = await controller.runJavaScriptReturningResult(r'''
(() => {
  const reviewSelectors = [
    "#reviewsMedley",
    "#customerReviews",
    "#cm-cr-dp-review-list",
    "[data-hook='reviews-medley-widget']",
    "[data-hook='cr-widget-FocalReviews']",
    "[data-hook='review']",
    "[data-hook='review-body']"
  ];

  const target = reviewSelectors
    .map((selector) => document.querySelector(selector))
    .find((element) => !!element);

  if (target) {
    target.scrollIntoView({ block: "center" });
  } else {
    window.scrollTo(0, Math.floor(document.body.scrollHeight * 0.72));
  }

  const reviewBodyCount = document.querySelectorAll(
    [
      "[data-hook='review']",
      "[data-hook='review-body']",
      "[data-hook='review-collapsed']",
      "#cm-cr-dp-review-list .review-text",
      "#cm-cr-dp-review-list .a-expander-content"
    ].join(",")
  ).length;

  const bodyText = document.body.innerText || "";
  return JSON.stringify({
    reviewBodyCount,
    hasReviewsMedley: !!document.querySelector("#reviewsMedley"),
    hasCustomerReviewsAnchor: !!document.querySelector("#customerReviews"),
    hasCustomerReviewText:
      bodyText.includes("Customer reviews") ||
      bodyText.includes("Top reviews") ||
      bodyText.includes("Customers say"),
    scrollY: Math.floor(window.scrollY),
    documentHeight: document.body.scrollHeight
  });
})();
''');
      final status = _decodeJavaScriptResult(rawStatus);

      debugPrint("REVIEW SECTION STATUS:");
      debugPrint(status.toString());

      if (status is Map<String, dynamic> &&
          (status["reviewBodyCount"] is num) &&
          status["reviewBodyCount"] > 0) {
        return;
      }

      await Future.delayed(const Duration(milliseconds: 1400));
    }
  }

  Future<void> extractProductData() async {
    debugPrint("FUNCTION STARTED");

    try {
      debugPrint("STARTING EXTRACTION");

      await waitForAmazonProductPage();
      await prepareAmazonReviewSection();

      final rawResult = await controller.runJavaScriptReturningResult(
        AmazonExtractor.script,
      );

      debugPrint("RAW JS RESULT:");
      debugPrint(rawResult.toString());

      final decoded = _decodeJavaScriptResult(rawResult);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException("Could not read product data from page");
      }

      final extractedData = decoded;

      debugPrint("FINAL EXTRACTED:");
      debugPrint(extractedData.toString());
      debugPrint("EXTRACTED IMAGE:");
      debugPrint((extractedData["image"] ?? "").toString());

      final extractorError = (extractedData["error"] ?? "").toString().trim();
      if (extractorError.isNotEmpty) {
        throw Exception("Page extraction failed: $extractorError");
      }

      if (!_looksLikeAmazonProductPage(extractedData)) {
        throw Exception(
          "This link did not open a supported Amazon product page. Please use the full product URL.",
        );
      }

      if (extractedData["title"].toString().trim().isEmpty) {
        extractedData["title"] = "Amazon Product";
      }

      final productDataForAnalysis = _buildAnalysisProductData(extractedData);
      final reviewsForAnalysis = _stringListFrom(
        productDataForAnalysis["reviews"],
      );
      final reviewSummary = productDataForAnalysis["reviewSummary"].toString();

      debugPrint("REVIEW COUNT:");
      debugPrint(productDataForAnalysis["reviewCount"].toString());
      debugPrint("REVIEWS LENGTH:");
      debugPrint(reviewsForAnalysis.length.toString());
      debugPrint("REVIEW SUMMARY LENGTH:");
      debugPrint(reviewSummary.length.toString());
      debugPrint("FIRST REVIEW SAMPLE:");
      debugPrint(
        reviewsForAnalysis.isNotEmpty ? reviewsForAnalysis.first : "NONE",
      );

      final response = await ApiService.analyzeProduct(
        productData: productDataForAnalysis,
      );

      debugPrint("FULL RESPONSE:");
      debugPrint(response.toString());

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AnalysisResultScreen(
            productData: productDataForAnalysis,
            analysis: response,
          ),
        ),
      );
    } catch (e, stack) {
      debugPrint("================================");
      debugPrint("REAL ERROR:");
      debugPrint(e.toString());
      debugPrint(stack.toString());
      debugPrint("================================");

      final message = e is FormatException
          ? "Could not read product data from this page."
          : e.toString().replaceFirst("Exception: ", "");

      await _showFailureAndExit(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Opacity(opacity: 0, child: WebViewWidget(controller: controller)),
          Container(
            color: Colors.black,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 30),
                  Text(
                    "TrueCart AI",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 20),
                  Text(
                    "Analyzing Product...",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
