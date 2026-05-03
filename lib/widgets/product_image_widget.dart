import 'dart:io';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

class ProductImageWidget extends StatelessWidget {
  final String? imageUrl;
  final String category;
  final String title;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const ProductImageWidget({
    super.key,
    required this.imageUrl,
    required this.category,
    required this.title,
    this.width,
    this.height,
    this.borderRadius,
  });

  bool get _isLocalFile =>
      imageUrl != null &&
      imageUrl!.isNotEmpty &&
      !imageUrl!.startsWith('http');

  bool get _isNetworkUrl =>
      imageUrl != null &&
      imageUrl!.isNotEmpty &&
      imageUrl!.startsWith('http');

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(16);

    if (_isLocalFile) {
      return ClipRRect(
        borderRadius: radius,
        child: Image.file(
          File(imageUrl!),
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(radius),
        ),
      );
    }

    if (_isNetworkUrl) {
      return ClipRRect(
        borderRadius: radius,
        child: Image.network(
          imageUrl!,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(radius),
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return _loadingPlaceholder(radius);
          },
        ),
      );
    }

    return _placeholder(radius);
  }

  Widget _placeholder(BorderRadius radius) {
    final colors = AppColors.gradientForCategory(category);
    final initial = title.isNotEmpty ? title[0].toUpperCase() : 'M';

    return ClipRRect(
      borderRadius: radius,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -8,
              bottom: -8,
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: (height ?? 120) * 0.65,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withOpacity(0.15),
                  height: 1,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    initial,
                    style: TextStyle(
                      fontSize: (height ?? 120) * 0.3,
                      fontWeight: FontWeight.w300,
                      color: Colors.white.withOpacity(0.9),
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category,
                    style: AppTypography.overline.copyWith(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loadingPlaceholder(BorderRadius radius) {
    return ClipRRect(
      borderRadius: radius,
      child: Container(
        width: width,
        height: height,
        color: AppColors.surfaceVariant,
      ),
    );
  }
}
