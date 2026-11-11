import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vkart_admin/auth/admin_auth_provider.dart';
import 'package:vkart_admin/materials/vkart_colors.dart';

/// Custom app bar for the VKart admin app.
class VKartAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final double toolbarHeight;

  const VKartAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.toolbarHeight = 64,
  });

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: VKartColors.surface,
      elevation: 0,
      toolbarHeight: toolbarHeight,
      titleSpacing: 20,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: VKartColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.storefront, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: VKartColors.primaryText,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: VKartColors.secondaryText,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
actions: [
        if (context.select<AdminAuthProvider, bool>(
              (auth) => auth.status == AuthStatus.authenticated,
            ))
          IconButton(
            tooltip: 'Logout',
            onPressed: () {
              final auth = context.read<AdminAuthProvider>();
              auth.performLogout(context);
            },
            icon: const Icon(
              Icons.logout_rounded,
              color: VKartColors.error,
              size: 22,
            ),
          ),
        ...?actions,
      ],
    );
  }
}
