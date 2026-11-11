import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vkart_admin/materials/vkart_colors.dart';
import 'package:vkart_admin/providers/admin_notification_provider.dart';
import 'package:vkart_admin/widgets/vkart_app_bar.dart';
import 'package:vkart_admin/widgets/vkart_button.dart';
import 'package:vkart_admin/widgets/vkart_card.dart';
import 'package:vkart_admin/widgets/vkart_empty_state.dart';
import 'package:vkart_admin/widgets/vkart_error_view.dart';
import 'package:vkart_admin/widgets/vkart_loading.dart';
import 'package:vkart_admin/widgets/vkart_search_bar.dart';

class NotificationListScreen extends StatelessWidget {
  const NotificationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminNotificationProvider>();

    return Scaffold(
      backgroundColor: VKartColors.background,
      appBar: VKartAppBar(
        title: 'Notifications',
        subtitle: '${provider.notifications.length} notifications',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
child: VKartButton(
              text: 'Send',
              prefixIcon: Icons.send_rounded,
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: VKartSearchBar(hint: 'Search notifications...'),
          ),
          Expanded(
            child: provider.error != null
                ? VKartErrorView(
                    description: provider.error,
                    onRetry: () =>
                        context.read<AdminNotificationProvider>().retry(),
                  )
                : provider.isLoading
                    ? const VKartLoading(message: 'Loading notifications...')
                    : provider.notifications.isEmpty
                    ? const VKartEmptyState(
                        message: 'No notifications yet',
                        description: 'Send notifications to your customers.',
icon: Icons.notifications_off_rounded,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: provider.notifications.length,
                        itemBuilder: (context, index) {
                          final n = provider.notifications[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            child: VKartCard(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: VKartColors.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      _iconForType(n.type),
                                      color: VKartColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          n.title,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: VKartColors.primaryText,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          n.message,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: VKartColors.secondaryText,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Type: ${n.type} · ${n.audience}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: VKartColors.secondaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    n.active
                                        ? Icons.notifications_active
                                        : Icons.notifications_off,
                                    color: n.active
                                        ? VKartColors.success
                                        : VKartColors.disabled,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'offer':
      case 'promotion':
        return Icons.local_offer_rounded;
      case 'festival':
        return Icons.celebration_rounded;
      case 'order_update':
        return Icons.local_shipping_rounded;
      case 'maintenance':
        return Icons.build_rounded;
      default:
        return Icons.campaign_rounded;
    }
  }
}
