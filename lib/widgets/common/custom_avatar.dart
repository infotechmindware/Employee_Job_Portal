import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CustomAvatar extends StatelessWidget {
  final String? imageUrl;
  final String fallbackText;
  final double radius;
  final IconData? fallbackIcon;

  const CustomAvatar({
    super.key,
    this.imageUrl,
    required this.fallbackText,
    this.radius = 24.0,
    this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    String? finalUrl = imageUrl;

    if (finalUrl != null && finalUrl.trim().isNotEmpty && !finalUrl.startsWith('http')) {
      if (!finalUrl.startsWith('/')) {
        finalUrl = '/$finalUrl';
      }
      finalUrl = 'https://www.mindwareinfotech.com$finalUrl';
    }

    final theme = Theme.of(context);

    if (finalUrl != null && finalUrl.trim().isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: finalUrl,
        imageBuilder: (context, imageProvider) => Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        placeholder: (context, url) => Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.dividerColor.withOpacity(0.05),
          ),
          child: const Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildFallback(theme),
      );
    }

    return _buildFallback(theme);
  }

  Widget _buildFallback(ThemeData theme) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFF1F5F9),
      ),
      child: Center(
        child: fallbackText.trim().isNotEmpty
            ? Text(
                fallbackText.trim()[0].toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: theme.primaryColor,
                  fontSize: radius * 0.8,
                ),
              )
            : Icon(
                fallbackIcon ?? LucideIcons.user,
                color: const Color(0xFF94A3B8),
                size: radius,
              ),
      ),
    );
  }
}
