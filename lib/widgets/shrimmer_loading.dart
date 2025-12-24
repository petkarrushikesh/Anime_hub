import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[700]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class AnimeCardShimmer extends StatelessWidget {
  const AnimeCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLoading(
            width: 120,
            height: 160,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 8),
          const ShimmerLoading(width: 100, height: 12),
          const SizedBox(height: 4),
          const ShimmerLoading(width: 80, height: 10),
        ],
      ),
    );
  }
}

class GridShimmer extends StatelessWidget {
  const GridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ShimmerLoading(
                width: double.infinity,
                height: double.infinity,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 8),
            const ShimmerLoading(width: double.infinity, height: 12),
            const SizedBox(height: 4),
            const ShimmerLoading(width: 100, height: 10),
          ],
        );
      },
    );
  }
}