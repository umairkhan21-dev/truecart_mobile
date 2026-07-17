import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:truecart_mobile/utils/app_color.dart';

class AnalysisParser {
  const AnalysisParser._();

  static Map<String, dynamic> safeMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }

    if (value is String) {
      final text = value.trim();
      if (text.isEmpty) {
        return {};
      }

      try {
        final decoded = jsonDecode(text);
        return safeMap(decoded);
      } catch (_) {
        return {};
      }
    }

    return {};
  }

  static String safeString(dynamic value, {String fallback = ""}) {
    if (value == null) {
      return fallback;
    }

    if (value is String) {
      final text = value.trim();
      return isUsefulText(text) ? text : fallback;
    }

    if (value is num || value is bool) {
      return value.toString();
    }

    return fallback;
  }

  static List<String> stringList(dynamic value) {
    if (value == null) {
      return [];
    }

    if (value is List) {
      return dedupe(
        value.expand<String>((item) {
          final nested = stringList(item);
          if (nested.isNotEmpty) {
            return nested;
          }

          final text = safeString(item);
          return text.isEmpty ? const <String>[] : [text];
        }).toList(),
      );
    }

    if (value is Map) {
      final map = safeMap(value);
      for (final key in const [
        "items",
        "points",
        "bullets",
        "highlights",
        "complaints",
        "risks",
        "pros",
        "cons",
        "alerts",
      ]) {
        final list = stringList(map[key]);
        if (list.isNotEmpty) {
          return list;
        }
      }

      final text = firstStringFromMap(map);
      return text.isEmpty ? [] : [text];
    }

    final text = safeString(value);
    return text.isEmpty ? [] : splitTextList(text);
  }

  static String firstStringFromMap(Map<String, dynamic> map) {
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
      final text = safeString(map[key]);
      if (text.isNotEmpty) {
        return text;
      }
    }

    return "";
  }

  static List<String> splitTextList(String text) {
    final hasBullets = RegExp(r'(^|\n)\s*(?:[-*•]|\d+[.)])\s+').hasMatch(text);
    final separator = hasBullets ? RegExp(r'\n') : RegExp(r'\n|,(?=\s+\w)');

    return dedupe(
      text
          .split(separator)
          .map(
            (item) => item
                .replaceFirst(RegExp(r'^\s*(?:[-*•]|\d+[.)])\s*'), '')
                .trim(),
          )
          .where(isUsefulText)
          .toList(),
    );
  }

  static List<String> dedupe(List<String> items) {
    final seen = <String>{};
    final output = <String>[];

    for (final item in items) {
      final cleaned = item.trim();
      if (!isUsefulText(cleaned)) {
        continue;
      }

      final key = cleaned
          .toLowerCase()
          .replaceAll(RegExp(r'\s+'), ' ')
          .replaceAll(RegExp(r'[.!]+$'), '');
      if (seen.add(key)) {
        output.add(cleaned);
      }
    }

    return output;
  }

  static bool isUsefulText(String text) {
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
      "undefined",
      "no insight available",
      "no analysis was returned.",
      "{}",
      "[]",
    }.contains(normalized);
  }
}

class AnalysisReport {
  final String title;
  final String price;
  final String rating;
  final String reviewCount;
  final String imageUrl;
  final String verdict;
  final String confidence;
  final List<String> lovedItems;
  final List<String> complaintItems;
  final List<String> riskItems;
  final PriceAnalysisData priceAnalysis;

  const AnalysisReport({
    required this.title,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.verdict,
    required this.confidence,
    required this.lovedItems,
    required this.complaintItems,
    required this.riskItems,
    required this.priceAnalysis,
  });

  factory AnalysisReport.from({
    required Map<String, dynamic> productData,
    required dynamic analysis,
  }) {
    final root = AnalysisParser.safeMap(analysis);
    final resultMap = AnalysisParser.safeMap(root["result"]);
    final analysisMap = resultMap.isEmpty ? root : resultMap;

    String firstText(List<String> keys, {String fallback = ""}) {
      for (final key in keys) {
        final text = AnalysisParser.safeString(analysisMap[key]);
        if (text.isNotEmpty) {
          return text;
        }

        final mapText = AnalysisParser.firstStringFromMap(
          AnalysisParser.safeMap(analysisMap[key]),
        );
        if (mapText.isNotEmpty) {
          return mapText;
        }

        final list = AnalysisParser.stringList(analysisMap[key]);
        if (list.isNotEmpty) {
          return list.first;
        }
      }

      return fallback;
    }

    List<String> textList(List<String> keys) {
      for (final key in keys) {
        final items = AnalysisParser.stringList(analysisMap[key]);
        if (items.isNotEmpty) {
          return items;
        }
      }

      return [];
    }

    final extractedLovedItems = textList([
      "whatUsersLove",
      "what_users_love",
      "pros",
      "positives",
    ]);
    final extractedComplaintItems = textList([
      "commonComplaints",
      "common_complaints",
      "topComplaints",
      "top_complaints",
      "cons",
      "negatives",
    ]);

    return AnalysisReport(
      title: AnalysisParser.safeString(
        productData["title"],
        fallback: "Amazon Product",
      ),
      price: _priceLabel(AnalysisParser.safeString(productData["price"])),
      rating: AnalysisParser.safeString(productData["rating"], fallback: "0"),
      reviewCount: AnalysisParser.safeString(
        productData["reviewCount"],
        fallback: "Review count unavailable",
      ),
      imageUrl: AnalysisParser.safeString(productData["image"]),
      verdict: _normalizedVerdict(
        firstText(["verdict", "recommendation", "decision"], fallback: "BUY"),
      ),
      confidence: firstText(["confidence"], fallback: "Medium"),
      lovedItems: extractedLovedItems.isNotEmpty
          ? extractedLovedItems
          : _reviewSummaryItems(productData, complaints: false),
      complaintItems: extractedComplaintItems.isNotEmpty
          ? extractedComplaintItems
          : _reviewSummaryItems(productData, complaints: true),
      riskItems: textList([
        "riskAlerts",
        "risk_alerts",
        "risks",
        "warnings",
        "alerts",
      ]),
      priceAnalysis: _priceAnalysisData(analysisMap, firstText),
    );
  }

  static String _priceLabel(String rawPrice) {
    if (!AnalysisParser.isUsefulText(rawPrice)) {
      return "Price not found";
    }

    final hasCurrency = RegExp(r'[₹$€£]').hasMatch(rawPrice);
    return hasCurrency ? rawPrice : "₹$rawPrice";
  }

  static String _normalizedVerdict(String rawVerdict) {
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

    return "CONSIDER";
  }

  static PriceAnalysisData _priceAnalysisData(
    Map<String, dynamic> analysisMap,
    String Function(List<String> keys, {String fallback}) firstText,
  ) {
    final value = analysisMap["priceAnalysis"] ?? analysisMap["price_analysis"];
    final map = AnalysisParser.safeMap(value);
    final fallbackText = firstText(["valueForMoney", "priceVerdict"]);

    if (map.isEmpty) {
      return PriceAnalysisData(
        label: null,
        color: AppColor.accent,
        text: AnalysisParser.safeString(value, fallback: fallbackText),
      );
    }

    final verdict = AnalysisParser.safeString(map["verdict"]).toLowerCase();
    final insight = AnalysisParser.safeString(map["insight"]);
    final text = insight.isNotEmpty
        ? insight
        : _priceInsightForVerdict(verdict);

    return PriceAnalysisData(
      label: _priceBadgeForVerdict(verdict),
      color: _priceColorForVerdict(verdict),
      text: text,
    );
  }

  static String _priceInsightForVerdict(String verdict) {
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

  static String? _priceBadgeForVerdict(String verdict) {
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

  static Color _priceColorForVerdict(String verdict) {
    if (verdict.contains("over") || verdict.contains("expensive")) {
      return AppColor.danger;
    }

    if (verdict.contains("fair") || verdict.contains("reasonable")) {
      return AppColor.warning;
    }

    return AppColor.accent;
  }

  static List<String> _reviewSummaryItems(
    Map<String, dynamic> productData, {
    required bool complaints,
  }) {
    final summary = AnalysisParser.safeString(productData["reviewSummary"]);
    if (summary.isEmpty) {
      return [];
    }

    final lines = summary
        .split(RegExp(r'\n|\. '))
        .map((line) => line.trim())
        .where(AnalysisParser.isUsefulText)
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
          .replaceFirst(RegExp(r'^\s*(?:[-*•]|\d+[.)])\s*'), '')
          .trim();
      final isBullet =
          line.startsWith("-") ||
          line.startsWith("•") ||
          line.startsWith("*") ||
          RegExp(r'^\d+[.)]\s+').hasMatch(line);

      if (inTargetSection && isBullet && AnalysisParser.isUsefulText(cleaned)) {
        items.add(cleaned);
      }
    }

    return AnalysisParser.dedupe(items);
  }
}

class PriceAnalysisData {
  final String? label;
  final Color color;
  final String text;

  const PriceAnalysisData({
    required this.label,
    required this.color,
    required this.text,
  });

  bool get hasContent => AnalysisParser.isUsefulText(text);
}
