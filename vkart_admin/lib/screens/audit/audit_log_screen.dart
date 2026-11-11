import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vkart_admin/materials/vkart_colors.dart';
import 'package:vkart_admin/providers/admin_audit_provider.dart';
import 'package:vkart_admin/widgets/vkart_app_bar.dart';
import 'package:vkart_admin/widgets/vkart_card.dart';
import 'package:vkart_admin/widgets/vkart_empty_state.dart';
import 'package:vkart_admin/widgets/vkart_error_view.dart';
import 'package:vkart_admin/widgets/vkart_loading.dart';
import 'package:vkart_admin/widgets/vkart_search_bar.dart';

class AuditLogScreen extends StatelessWidget {
  const AuditLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminAuditProvider>();

    return Scaffold(
      backgroundColor: VKartColors.background,
      appBar: VKartAppBar(
        title: 'Audit Logs',
        subtitle: '${provider.logs.length} log entries',
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: VKartSearchBar(hint: 'Search audit logs...'),
          ),
          Expanded(
            child: provider.error != null
                ? VKartErrorView(
                    description: provider.error,
                    onRetry: () =>
                        context.read<AdminAuditProvider>().retry(),
                  )
                : provider.isLoading
                    ? const VKartLoading(message: 'Loading audit logs...')
                    : provider.logs.isEmpty
? const VKartEmptyState(
                        message: 'No audit logs found',
                        description: 'Admin actions will be recorded here.',
                        icon: Icons.history_rounded,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: provider.logs.length,
                        itemBuilder: (context, index) {
                          final log = provider.logs[index];
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
                                      color: _colorForAction(
                                        log.action,
                                      ).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      _iconForAction(log.action),
                                      color: _colorForAction(log.action),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${log.adminName} · ${log.module}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: VKartColors.primaryText,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          log.description,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: VKartColors.secondaryText,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          log.createdAt
                                              .toLocal()
                                              .toString()
                                              .split('.')[0],
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: VKartColors.secondaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: log.status
                                          ? VKartColors.success.withValues(
                                              alpha: 0.1,
                                            )
                                          : VKartColors.error.withValues(
                                              alpha: 0.1,
                                            ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      log.status ? 'Success' : 'Failed',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: log.status
                                            ? VKartColors.success
                                            : VKartColors.error,
                                      ),
                                    ),
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

  IconData _iconForAction(String action) {
    switch (action.toLowerCase()) {
case 'create':
      case 'add':
        return Icons.add_box_rounded;
      case 'update':
      case 'edit':
        return Icons.edit_rounded;
      case 'delete':
        return Icons.delete_rounded;
      case 'status':
        return Icons.swap_horiz_rounded;
      default:
        return Icons.shopping_bag_rounded;
    }
  }

  Color _colorForAction(String action) {
    switch (action.toLowerCase()) {
      case 'create':
      case 'add':
        return VKartColors.success;
      case 'update':
      case 'edit':
        return VKartColors.info;
      case 'delete':
        return VKartColors.error;
      default:
        return VKartColors.primary;
    }
  }
}
