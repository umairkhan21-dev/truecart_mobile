import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:truecart_mobile/utils/app_color.dart';

class AnalysisResultScreen extends StatelessWidget {
  final Map<String, dynamic> productData;
  final dynamic analysis;

  const AnalysisResultScreen({
    super.key,
    required this.productData,
    required this.analysis,
  });

  Map<String, dynamic> get _analysisMap {
    final root = _safeMap(analysis);
    final result = root["result"];

    if (result == null) {
      return root;
    }

    final resultMap = _safeMap(result);
    return resultMap.isEmpty ? root : resultMap;
  }

  String _safeString(dynamic value, {String fallback = ""}) {
    if (value == null) {
      return fallback;
    }

    if (value is String) {
      final trimmed = value.trim();
      return _isUsefulText(trimmed) ? trimmed : fallback;
    }

    if (value is num || value is bool) {
      return value.toString();
    }

    return fallback;
  }

  Map<String, dynamic> _safeMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }

    if (value is String) {
      try {
        final decoded = jsonDecode(value);
        return _safeMap(decoded);
      } catch (_) {
        return {};
      }
    }

    return {};
  }

  List<String> _safeStringList(dynamic value) {
    if (value is List) {
      return _dedupeStrings(
        value.expand<String>((item) {
          final list = _safeStringList(item);
          if (list.isNotEmpty) {
            return list;
          }

          final text = _safeString(item);
          return text.isEmpty ? const <String>[] : [text];
        }).toList(),
      );
    }

    if (value is Map) {
      final map = _safeMap(value);
      for (final key in const [
        "items",
        "points",
        "bullets",
        "highlights",
        "complaints",
        "risks",
        "pros",
        "cons",
      ]) {
        final list = _safeStringList(map[key]);
        if (list.isNotEmpty) {
          return list;
        }
      }

      final text = _firstStringFromMap(map);
      return text.isEmpty ? [] : [text];
    }

    final text = _safeString(value);
    if (text.isEmpty) {
      return [];
    }

    return _splitTextList(text);
  }

  String _firstText(List<String> keys, {String fallback = ""}) {
    for (final key in keys) {
      final text = _safeString(_analysisMap[key]);
      if (text.isNotEmpty) {
        return text;
      }

      final mapText = _firstStringFromMap(_safeMap(_analysisMap[key]));
      if (mapText.isNotEmpty) {
        return mapText;
      }

      final list = _safeStringList(_analysisMap[key]);
      if (list.isNotEmpty) {
        return list.first;
      }
    }

    return fallback;
  }

  List<String> _textList(List<String> keys) {
    for (final key in keys) {
      final items = _safeStringList(_analysisMap[key]);
      if (items.isNotEmpty) {
        return items;
      }
    }

    return [];
  }

  String _firstStringFromMap(Map<String, dynamic> map) {
    for (final key in const [
      "text",
      "title",
      "label",
      "summary",
      "description",
      "insight",
      "reason",
      "value",
      "message",
    ]) {
      final text = _safeString(map[key]);
      if (text.isNotEmpty) {
        return text;
      }
    }

    return "";
  }

  List<String> _splitTextList(String text) {
    final bulletPattern = RegExp(r'(\n|^)\s*(?:[-•*]|\d+[.)])\s+');
    final hasBullets = bulletPattern.hasMatch(text);
    final separator = hasBullets ? RegExp(r'\n') : RegExp(r'\n|,');

    return _dedupeStrings(
      text
          .split(separator)
          .map(
            (item) => item
                .replaceFirst(RegExp(r'^\s*(?:[-•*]|\d+[.)])\s*'), '')
                .trim(),
          )
          .where(_isUsefulText)
          .toList(),
    );
  }

  List<String> _dedupeStrings(List<String> items) {
    final seen = <String>{};
    final deduped = <String>[];

    for (final item in items) {
      final cleaned = item.trim();
      if (!_isUsefulText(cleaned)) {
        continue;
      }

      final key = cleaned.toLowerCase();
      if (seen.add(key)) {
        deduped.add(cleaned);
      }
    }

    return deduped;
  }

  List<String> _reviewSummaryItems({required bool complaints}) {
    final summary = _safeString(productData["reviewSummary"]);
    if (summary.isEmpty) {
      return [];
    }

    final lines = summary
        .split(RegExp(r'\n|\. '))
        .map((line) => line.trim())
        .where(_isUsefulText)
        .toList();

    final items = <String>[];
    var inTargetSection = false;

    for (final line in lines) {
      final lowerLine = line.toLowerCase();
      final startsPraise =
          lowerLine.contains("praise") ||
          lowerLine.contains("love") ||
          lowerLine.contains("like");
      final startsComplaint =
          lowerLine.contains("complaint") ||
          lowerLine.contains("complain") ||
          lowerLine.contains("critic") ||
          lowerLine.contains("issue");

      if (startsPraise || startsComplaint) {
        inTargetSection = complaints ? startsComplaint : startsPraise;
      }

      final cleaned = line
          .replaceFirst(RegExp(r'^\s*(?:[-•*]|\d+[.)])\s*'), '')
          .trim();
      final isBullet =
          line.startsWith("-") ||
          line.startsWith("•") ||
          line.startsWith("*") ||
          RegExp(r'^\d+[.)]\s+').hasMatch(line);

      if (inTargetSection && isBullet && _isUsefulText(cleaned)) {
        items.add(cleaned);
      }
    }

    return _dedupeStrings(items);
  }

  bool _isUsefulText(String text) {
    final normalized = text.trim().toLowerCase();
    if (normalized.isEmpty) {
      return false;
    }

    if ((normalized.startsWith("{") && normalized.endsWith("}")) ||
        (normalized.startsWith("[") && normalized.endsWith("]"))) {
      return false;
    }

    return !{
      "null",
      "none",
      "n/a",
      "na",
      "not found",
      "no insight available",
      "no analysis was returned.",
      "{}",
      "[]",
    }.contains(normalized);
  }

  String _priceLabel(String rawPrice) {
    if (!_isUsefulText(rawPrice)) {
      return "Price not found";
    }

    return rawPrice.contains("₹") ? rawPrice : "₹$rawPrice";
  }

  String _ratingNumber(String rawRating) {
    final match = RegExp(r'\d+(\.\d+)?').firstMatch(rawRating);
    return match?.group(0) ?? rawRating;
  }

  String _starText(String rawRating) {
    final rating = double.tryParse(_ratingNumber(rawRating));
    if (rating == null) {
      return "Rating not found";
    }

    final rounded = rating.round().clamp(0, 5).toInt();
    final filledStars = List.filled(rounded, "★").join();
    final emptyStars = List.filled(5 - rounded, "☆").join();
    return "$filledStars$emptyStars ${rating.toStringAsFixed(1)}";
  }

  _PriceAnalysisData _priceAnalysisData() {
    final value =
        _analysisMap["priceAnalysis"] ?? _analysisMap["price_analysis"];
    final map = _safeMap(value);
    final fallbackText = _firstText(["valueForMoney", "priceVerdict"]);

    if (map.isEmpty) {
      return _PriceAnalysisData(
        label: null,
        color: const Color(0xFF63E6BE),
        text: _safeString(value, fallback: fallbackText),
      );
    }

    final verdict = _safeString(map["verdict"]).toLowerCase();
    final insight = _safeString(map["insight"]);
    final text = insight.isNotEmpty
        ? insight
        : _priceInsightForVerdict(verdict);

    return _PriceAnalysisData(
      label: _priceBadgeForVerdict(verdict),
      color: _priceColorForVerdict(verdict),
      text: text,
    );
  }

  String _priceInsightForVerdict(String verdict) {
    if (verdict.contains("over") || verdict.contains("expensive")) {
      return "Price looks high compared with the value customers are reporting.";
    }

    if (verdict.contains("good") ||
        verdict.contains("great") ||
        verdict.contains("value")) {
      return "Good value considering the features and user satisfaction.";
    }

    if (verdict.contains("fair") || verdict.contains("reasonable")) {
      return "Price seems reasonable considering the features and user satisfaction.";
    }

    return "";
  }

  String? _priceBadgeForVerdict(String verdict) {
    if (verdict.contains("over") || verdict.contains("expensive")) {
      return "Overpriced";
    }

    if (verdict.contains("good") ||
        verdict.contains("great") ||
        verdict.contains("value")) {
      return "Good Value";
    }

    if (verdict.contains("fair") || verdict.contains("reasonable")) {
      return "Fair Price";
    }

    return null;
  }

  Color _priceColorForVerdict(String verdict) {
    if (verdict.contains("over") || verdict.contains("expensive")) {
      return const Color(0xFFFF7A90);
    }

    if (verdict.contains("fair") || verdict.contains("reasonable")) {
      return const Color(0xFFFFC857);
    }

    return const Color(0xFF63E6BE);
  }

  String _normalizedVerdict(String rawVerdict) {
    final normalized = rawVerdict.toLowerCase();
    if (normalized.contains("avoid")) {
      return "AVOID";
    }

    if (normalized.contains("consider")) {
      return "CONSIDER";
    }

    if (normalized.contains("buy")) {
      return "BUY";
    }

    return _safeString(rawVerdict, fallback: "CONSIDER").toUpperCase();
  }

  Color _verdictColor(String verdict) {
    switch (verdict) {
      case "BUY":
        return AppColor.accent;
      case "AVOID":
        return const Color(0xFFFF5C7A);
      case "CONSIDER":
      default:
        return const Color(0xFFFFA94D);
    }
  }

  IconData _verdictIcon(String verdict) {
    switch (verdict) {
      case "BUY":
        return Icons.check_circle_rounded;
      case "AVOID":
        return Icons.cancel_rounded;
      case "CONSIDER":
      default:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _safeString(productData["title"], fallback: "Amazon Product");
    final price = _priceLabel(_safeString(productData["price"]));
    final rating = _safeString(productData["rating"], fallback: "Not found");
    final reviewCount = _safeString(
      productData["reviewCount"],
      fallback: "Not found",
    );
    final imageUrl = _safeString(productData["image"]);

    final verdict = _normalizedVerdict(
      _firstText(["verdict", "recommendation", "decision"], fallback: "BUY"),
    );
    final confidence = _firstText(["confidence"], fallback: "Medium");
    final extractedLovedItems = _textList([
      "whatUsersLove",
      "what_users_love",
      "pros",
      "positives",
    ]);
    final lovedItems = extractedLovedItems.isNotEmpty
        ? extractedLovedItems
        : _reviewSummaryItems(complaints: false);
    final extractedComplaintItems = _textList([
      "commonComplaints",
      "common_complaints",
      "topComplaints",
      "top_complaints",
      "cons",
      "negatives",
    ]);
    final complaintItems = extractedComplaintItems.isNotEmpty
        ? extractedComplaintItems
        : _reviewSummaryItems(complaints: true);
    final riskItems = _textList([
      "riskAlerts",
      "risk_alerts",
      "risks",
      "warnings",
    ]);
    final priceAnalysis = _priceAnalysisData();

    return Scaffold(
      appBar: AppBar(
        title: const Text("TrueCart Analysis"),
        backgroundColor: AppColor.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF070A12), AppColor.background],
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _productImage(imageUrl),
                const SizedBox(height: 18),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 24,
                    height: 1.18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppColor.accent,
                  ),
                ),
                const SizedBox(height: 10),
                _ratingRow(rating, reviewCount),
                const SizedBox(height: 24),
                _verdictCard(verdict, confidence),
                if (lovedItems.isNotEmpty)
                  _analysisSection(
                    icon: Icons.thumb_up_alt_rounded,
                    iconColor: AppColor.accent,
                    title: "What Users Love",
                    items: lovedItems,
                  ),
                if (complaintItems.isNotEmpty)
                  _analysisSection(
                    icon: Icons.thumb_down_alt_rounded,
                    iconColor: const Color(0xFFFF7A90),
                    title: "Common Complaints",
                    items: complaintItems,
                  ),
                if (riskItems.isNotEmpty)
                  _analysisSection(
                    icon: Icons.warning_amber_rounded,
                    iconColor: const Color(0xFFFFC857),
                    title: "Risk Alerts",
                    items: riskItems,
                  ),
                if (priceAnalysis.hasContent)
                  _priceAnalysisSection(priceAnalysis),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _productImage(String imageUrl) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: AppColor.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColor.secondary.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: AppColor.secondary.withValues(alpha: 0.14),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: imageUrl.isEmpty
            ? const Center(
                child: Icon(
                  Icons.image_search_rounded,
                  size: 54,
                  color: Colors.white54,
                ),
              )
            : Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint("PRODUCT IMAGE LOAD ERROR: $error");

                  return const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 54,
                      color: Colors.white54,
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _ratingRow(String rating, String reviewCount) {
    return Row(
      children: [
        Text(
          _starText(rating),
          style: const TextStyle(
            color: Color(0xFFFFD166),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            "$reviewCount Reviews",
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColor.textSecondary, fontSize: 15),
          ),
        ),
      ],
    );
  }

  Widget _verdictCard(String verdict, String confidence) {
    final color = _verdictColor(verdict);
    final icon = _verdictIcon(verdict);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.48)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.14),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "TRUECART VERDICT",
            style: TextStyle(
              color: AppColor.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 34),
              const SizedBox(width: 10),
              Text(
                verdict,
                style: TextStyle(
                  color: color,
                  fontSize: 36,
                  height: 1,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Confidence: $confidence",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _analysisSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<String> items,
  }) {
    final visibleItems = items.take(4).toList();

    return _sectionShell(
      icon: icon,
      iconColor: iconColor,
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: visibleItems
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: iconColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(fontSize: 16, height: 1.32),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _priceAnalysisSection(_PriceAnalysisData analysis) {
    return _sectionShell(
      icon: Icons.payments_rounded,
      iconColor: analysis.color,
      title: "Price Analysis",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (analysis.label != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: analysis.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: analysis.color.withValues(alpha: 0.38),
                ),
              ),
              child: Text(
                analysis.label!,
                style: TextStyle(
                  color: analysis.color,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          Text(
            analysis.text,
            style: const TextStyle(fontSize: 16, height: 1.38),
          ),
        ],
      ),
    );
  }

  Widget _sectionShell({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 19),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _PriceAnalysisData {
  final String? label;
  final Color color;
  final String text;

  const _PriceAnalysisData({
    required this.label,
    required this.color,
    required this.text,
  });

  bool get hasContent => text.trim().isNotEmpty;
}
