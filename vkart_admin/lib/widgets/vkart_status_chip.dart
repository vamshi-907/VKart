import 'package:flutter/material.dart';
import 'package:vkart_shared/vkart_shared.dart';
import 'package:vkart_admin/materials/vkart_colors.dart';

/// A colored chip that visually represents an order status.
class VKartStatusChip extends StatelessWidget {
  final OrderStatus status;
  final bool outlined;

  const VKartStatusChip({
    super.key,
    required this.status,
    this.outlined = false,
  });

  Color _colorFor(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
        return VKartColors.info;
      case OrderStatus.orderPlaced:
        return VKartColors.info;
      case OrderStatus.confirmed:
        return VKartColors.primary;
      case OrderStatus.orderReceived:
        return VKartColors.primary;
      case OrderStatus.packed:
        return Colors.deepPurple;
      case OrderStatus.assigned:
        return Colors.teal;
      case OrderStatus.outForDelivery:
        return VKartColors.warning;
      case OrderStatus.delivered:
        return VKartColors.success;
      case OrderStatus.cancelled:
        return VKartColors.error;
      case OrderStatus.completed:
        return VKartColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color color = _colorFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: outlined ? Border.all(color: color, width: 1) : null,
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: outlined ? color : color,
        ),
      ),
    );
  }
}
