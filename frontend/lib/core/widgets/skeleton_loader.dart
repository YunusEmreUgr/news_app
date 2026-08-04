import 'package:flutter/material.dart';

class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  // Factory constructor for category chips skeleton
  static Widget categories() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: List.generate(6, (index) {
          return const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: SkeletonLoader(width: 80, height: 32, borderRadius: 16),
          );
        }),
      ),
    );
  }

  // Factory constructor for headline slider skeleton
  static Widget headline() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: SkeletonLoader(
        width: double.infinity,
        height: 200,
        borderRadius: 14,
      ),
    );
  }

  // Factory constructor for news lists skeleton
  static Widget newsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image skeleton
              const SkeletonLoader(width: 100, height: 75, borderRadius: 8),
              const SizedBox(width: 12),
              // Text skeletons
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    const SkeletonLoader(width: double.infinity, height: 16),
                    const SizedBox(height: 6),
                    const SkeletonLoader(width: 160, height: 14),
                    const SizedBox(height: 8),
                    Row(
                      children: const [
                        SkeletonLoader(width: 60, height: 12),
                        SizedBox(width: 12),
                        SkeletonLoader(width: 40, height: 12),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.2, end: 0.55).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}
