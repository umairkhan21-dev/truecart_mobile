import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:truecart_mobile/utils/analysis_parser.dart';
import 'package:truecart_mobile/utils/app_color.dart';

class AnalysisCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  const AnalysisCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColor.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: child,
    );
  }
}

class VerdictCard extends StatelessWidget {
  final String verdict;
  final String confidence;

  const VerdictCard({
    super.key,
    required this.verdict,
    required this.confidence,
  });

  Color get _color {
    switch (verdict) {
      case "BUY":
        return AppColor.accent;
      case "AVOID":
        return AppColor.danger;
      case "CONSIDER":
      default:
        return AppColor.warning;
    }
  }

  IconData get _icon {
    switch (verdict) {
      case "BUY":
        return Icons.verified_rounded;
      case "AVOID":
        return Icons.cancel_rounded;
      case "CONSIDER":
      default:
        return Icons.tips_and_updates_rounded;
    }
  }

  double get _confidenceValue {
    final numeric = double.tryParse(
      RegExp(r'\d+(\.\d+)?').firstMatch(confidence)?.group(0) ?? "",
    );
    if (numeric != null) {
      return (numeric > 1 ? numeric / 100 : numeric).clamp(0.08, 1);
    }

    final lower = confidence.toLowerCase();
    if (lower.contains("high")) {
      return 0.88;
    }
    if (lower.contains("low")) {
      return 0.38;
    }
    return 0.62;
  }

  @override
  Widget build(BuildContext context) {
    return AnalysisCard(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(_icon, color: _color, size: 29),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "AI VERDICT",
                      style: TextStyle(
                        color: AppColor.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      verdict,
                      style: TextStyle(
                        color: _color,
                        fontSize: 34,
                        height: 1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Confidence",
                style: TextStyle(
                  color: AppColor.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Flexible(
                child: Text(
                  confidence,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColor.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: _confidenceValue,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<String> items;

  const SectionCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final visibleItems = items.take(5).toList();

    return AnalysisCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColor.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final item in visibleItems)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: iconColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: AppColor.textPrimary,
                        fontSize: 15.5,
                        height: 1.38,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const InfoChip({
    super.key,
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColor.secondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: chipColor.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: chipColor),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: chipColor,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RatingRow extends StatelessWidget {
  final String rating;
  final String reviewCount;

  const RatingRow({super.key, required this.rating, required this.reviewCount});

  @override
  Widget build(BuildContext context) {
    final ratingNumber = _ratingNumber(rating);

    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        InfoChip(
          icon: Icons.star_rounded,
          label: ratingNumber.isEmpty
              ? "Rating unavailable"
              : "$ratingNumber / 5",
          color: AppColor.gold,
        ),
        InfoChip(
          icon: Icons.forum_rounded,
          label: reviewCount,
          color: AppColor.secondary,
        ),
      ],
    );
  }

  String _ratingNumber(String rawRating) {
    final match = RegExp(r'\d+(\.\d+)?').firstMatch(rawRating);
    return match?.group(0) ?? "";
  }
}

class PriceBadge extends StatelessWidget {
  final PriceAnalysisData analysis;

  const PriceBadge({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    return AnalysisCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: analysis.color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.payments_rounded,
                  color: analysis.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Price Analysis",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          if (analysis.label != null) ...[
            const SizedBox(height: 14),
            InfoChip(
              icon: Icons.local_offer_rounded,
              label: analysis.label!,
              color: analysis.color,
            ),
          ],
          const SizedBox(height: 12),
          Text(
            analysis.text,
            style: const TextStyle(
              color: AppColor.textPrimary,
              fontSize: 15.5,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class LoadingStep extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isComplete;

  const LoadingStep({
    super.key,
    required this.label,
    required this.isActive,
    required this.isComplete,
  });

  @override
  Widget build(BuildContext context) {
    final color = isComplete || isActive ? AppColor.accent : AppColor.textMuted;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isActive ? 0.14 : 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: isActive ? 0.28 : 0.1),
        ),
      ),
      child: Row(
        children: [
          AnimatedScale(
            duration: const Duration(milliseconds: 260),
            scale: isActive ? 1.08 : 1,
            child: Icon(
              isComplete ? Icons.check_circle_rounded : Icons.auto_awesome,
              color: color,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isActive || isComplete
                    ? AppColor.textPrimary
                    : AppColor.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PremiumLoadingView extends StatefulWidget {
  final String title;

  const PremiumLoadingView({super.key, this.title = "TrueCart AI"});

  @override
  State<PremiumLoadingView> createState() => _PremiumLoadingViewState();
}

class _PremiumLoadingViewState extends State<PremiumLoadingView> {
  static const _steps = [
    "Reading product...",
    "Analyzing reviews...",
    "Checking pricing...",
    "Generating AI insights...",
  ];

  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    _tick();
  }

  Future<void> _tick() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) {
        return;
      }
      setState(() {
        _activeIndex = (_activeIndex + 1) % _steps.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(gradient: AppColor.backgroundGradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.92, end: 1),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (context, scale, child) {
                  return Transform.scale(scale: scale, child: child);
                },
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColor.primary, AppColor.secondary],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.primary.withValues(alpha: 0.28),
                        blurRadius: 34,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColor.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Building your product report",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColor.textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 28),
              for (var index = 0; index < _steps.length; index++) ...[
                LoadingStep(
                  label: _steps[index],
                  isActive: index == _activeIndex,
                  isComplete: index < _activeIndex,
                ),
                if (index != _steps.length - 1) const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class PremiumErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const PremiumErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(gradient: AppColor.backgroundGradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColor.danger.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColor.danger.withValues(alpha: 0.28),
                  ),
                ),
                child: const Icon(
                  Icons.error_rounded,
                  color: AppColor.danger,
                  size: 36,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                "Couldn’t analyze this product",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColor.textPrimary,
                  fontSize: 25,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColor.textSecondary,
                  fontSize: 15,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text("Retry"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filledTonal(
                    tooltip: "Copy error",
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: message));
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Error copied")),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FadeSlideIn extends StatelessWidget {
  final Widget child;
  final int order;

  const FadeSlideIn({super.key, required this.child, required this.order});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + (order * 70)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
