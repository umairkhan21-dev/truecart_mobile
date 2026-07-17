import 'package:flutter/material.dart';
import 'package:truecart_mobile/utils/analysis_parser.dart';
import 'package:truecart_mobile/utils/app_color.dart';
import 'package:truecart_mobile/widgets/analysis_widgets.dart';

class AnalysisResultScreen extends StatelessWidget {
  final Map<String, dynamic> productData;
  final dynamic analysis;

  const AnalysisResultScreen({
    super.key,
    required this.productData,
    required this.analysis,
  });

  @override
  Widget build(BuildContext context) {
    final report = AnalysisReport.from(
      productData: productData,
      analysis: analysis,
    );
    var order = 0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Product Report"),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColor.backgroundGradient),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
                sliver: SliverList.list(
                  children: [
                    FadeSlideIn(
                      order: order++,
                      child: _ProductHeader(report: report),
                    ),
                    const SizedBox(height: 16),
                    FadeSlideIn(
                      order: order++,
                      child: VerdictCard(
                        verdict: report.verdict,
                        confidence: report.confidence,
                      ),
                    ),
                    if (report.lovedItems.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      FadeSlideIn(
                        order: order++,
                        child: SectionCard(
                          icon: Icons.favorite_rounded,
                          iconColor: AppColor.accent,
                          title: "What users love",
                          items: report.lovedItems,
                        ),
                      ),
                    ],
                    if (report.complaintItems.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      FadeSlideIn(
                        order: order++,
                        child: SectionCard(
                          icon: Icons.report_problem_rounded,
                          iconColor: AppColor.warning,
                          title: "Common complaints",
                          items: report.complaintItems,
                        ),
                      ),
                    ],
                    if (report.riskItems.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      FadeSlideIn(
                        order: order++,
                        child: SectionCard(
                          icon: Icons.shield_rounded,
                          iconColor: AppColor.danger,
                          title: "Risk alerts",
                          items: report.riskItems,
                        ),
                      ),
                    ],
                    if (report.priceAnalysis.hasContent) ...[
                      const SizedBox(height: 14),
                      FadeSlideIn(
                        order: order++,
                        child: PriceBadge(analysis: report.priceAnalysis),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductHeader extends StatelessWidget {
  final AnalysisReport report;

  const _ProductHeader({required this.report});

  @override
  Widget build(BuildContext context) {
    return AnalysisCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProductImage(imageUrl: report.imageUrl),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const InfoChip(
                  icon: Icons.auto_awesome_rounded,
                  label: "AI product report",
                  color: AppColor.primary,
                ),
                const SizedBox(height: 14),
                Text(
                  report.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColor.textPrimary,
                    height: 1.12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  report.price,
                  style: const TextStyle(
                    color: AppColor.accent,
                    fontSize: 32,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                RatingRow(
                  rating: report.rating,
                  reviewCount: report.reviewCount,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String imageUrl;

  const _ProductImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.38,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        child: Container(
          color: Colors.white.withValues(alpha: 0.04),
          child: imageUrl.isEmpty
              ? const Center(
                  child: Icon(
                    Icons.image_search_rounded,
                    color: AppColor.textMuted,
                    size: 52,
                  ),
                )
              : Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) {
                      return child;
                    }

                    return const Center(
                      child: Icon(
                        Icons.image_search_rounded,
                        color: AppColor.textMuted,
                        size: 42,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint("PRODUCT IMAGE LOAD ERROR: $error");

                    return const Center(
                      child: Icon(
                        Icons.image_not_supported_rounded,
                        color: AppColor.textMuted,
                        size: 50,
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
