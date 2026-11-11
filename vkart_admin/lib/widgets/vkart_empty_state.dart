import 'package:flutter/material.dart';
import 'package:vkart_admin/materials/vkart_colors.dart';

/// An empty-state placeholder with an icon, message, and optional action.
class VKartEmptyState extends StatelessWidget {
  final String message;
  final String? description;
  final IconData icon;
  final Widget? action;
  final double iconSize;

  const VKartEmptyState({
    super.key,
    required this.message,
    this.description,
    this.icon = Icons.inbox_outlined,
    this.action,
    this.iconSize = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: iconSize + 24,
              height: iconSize + 24,
              decoration: const BoxDecoration(
                color: VKartColors.hover,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: VKartColors.secondaryText,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: VKartColors.primaryText,
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: VKartColors.secondaryText,
                ),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}
