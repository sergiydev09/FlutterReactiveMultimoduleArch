import 'package:flutter/material.dart';
import 'package:promotions/domain/promo_banner.dart';
import 'package:promotions/presentation/promo_banner_card.dart';
import 'package:ui/tokens/colors.dart';

/// A horizontal PageView carousel of promotional banners with page indicators.
class PromoCarousel extends StatefulWidget {
  const PromoCarousel({
    required this.banners,
    super.key,
    this.height = 180,
    this.onBannerTap,
  });

  /// List of banners to display.
  final List<PromoBanner> banners;

  /// Height of the carousel.
  final double height;

  /// Callback when a banner is tapped, passing the banner data.
  final void Function(PromoBanner banner)? onBannerTap;

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  final PageController _pageController = PageController(
    viewportFraction: 0.9,
  );
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.banners.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              return PromoBannerCard(
                banner: banner,
                onTap: () => widget.onBannerTap?.call(banner),
              );
            },
          ),
        ),
        if (widget.banners.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.banners.length, (index) {
              final isActive = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? BankingColors.primary
                      : BankingColors.primary.withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
