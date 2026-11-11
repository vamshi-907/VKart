import 'package:flutter/material.dart';
import 'package:vkart_admin/materials/vkart_colors.dart';

/// A centered loading indicator with optional message.
class VKartLoading extends StatelessWidget {
  final String? message;
  final Color color;
  final double size;

  const VKartLoading({
    super.key,
    this.message,
    this.color = VKartColors.primary,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(strokeWidth: 3, color: color),
          ),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(
              message!,
              style: const TextStyle(
                color: VKartColors.secondaryText,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
