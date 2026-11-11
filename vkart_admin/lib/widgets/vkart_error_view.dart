import 'package:flutter/material.dart';
import 'package:vkart_admin/materials/vkart_colors.dart';
import 'package:vkart_admin/widgets/vkart_button.dart';

/// A friendly error state shown when Firestore / network requests fail.
///
/// Displays a "No Internet Connection" message with an optional retry action.
class VKartErrorView extends StatelessWidget {
  final String message;
  final String? description;
  final VoidCallback? onRetry;

  const VKartErrorView({
    super.key,
    this.message = 'No Internet Connection',
    this.description,
    this.onRetry,
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
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: VKartColors.hover,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 44,
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
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              VKartButton(
                text: 'Retry',
                prefixIcon: Icons.refresh_rounded,
                onPressed: onRetry!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

