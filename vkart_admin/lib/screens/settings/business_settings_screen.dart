import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vkart_admin/materials/vkart_colors.dart';
import 'package:vkart_admin/providers/admin_settings_provider.dart';
import 'package:vkart_admin/utils/currency_formatter.dart';
import 'package:vkart_admin/widgets/vkart_app_bar.dart';
import 'package:vkart_admin/widgets/vkart_card.dart';
import 'package:vkart_admin/widgets/vkart_error_view.dart';
import 'package:vkart_admin/widgets/vkart_loading.dart';

class BusinessSettingsScreen extends StatelessWidget {
  const BusinessSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminSettingsProvider>();

    return Scaffold(
      backgroundColor: VKartColors.background,
      appBar: const VKartAppBar(
        title: 'Business Settings',
        subtitle: 'Store configuration',
      ),
      body: provider.isLoading
          ? const VKartLoading(message: 'Loading settings...')
          : provider.error != null
              ? VKartErrorView(
                  description: provider.error,
                  onRetry: () =>
                      context.read<AdminSettingsProvider>().retry(),
                )
              : provider.settings == null
              ? const Center(
                  child: Text(
                    'No settings found',
                    style: TextStyle(color: VKartColors.secondaryText),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSection(
                        context,
                        'Store Information',
                        Icons.storefront,
                        [
                          _buildSettingRow(
                            context,
                            Icons.store,
                            'Store Name',
                            provider.settings!.storeName,
                          ),
                          _buildSettingRow(
                            context,
                            Icons.description_outlined,
                            'Description',
                            provider.settings!.storeDescription,
                          ),
                          _buildSettingRow(
                            context,
                            Icons.person_outline,
                            'Owner',
                            provider.settings!.ownerName,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSection(
                        context,
                        'Contact & Support',
                        Icons.contact_phone,
                        [
                          _buildSettingRow(
                            context,
                            Icons.email_outlined,
                            'Business Email',
                            provider.settings!.businessEmail,
                          ),
                          _buildSettingRow(
                            context,
                            Icons.support_agent,
                            'Support Email',
                            provider.settings!.supportEmail,
                          ),
                          _buildSettingRow(
                            context,
                            Icons.phone_outlined,
                            'Support Phone',
                            provider.settings!.supportPhone,
                          ),
                          _buildSettingRow(
                            context,
                            Icons.chat_outlined,
                            'WhatsApp',
                            provider.settings!.whatsappNumber,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSection(
                        context,
                        'Business Hours',
                        Icons.access_time,
                        [
                          _buildSettingRow(
                            context,
                            Icons.schedule,
                            'Open Time',
                            provider.settings!.openTime,
                          ),
                          _buildSettingRow(
                            context,
                            Icons.schedule,
                            'Close Time',
                            provider.settings!.closeTime,
                          ),
                          _buildToggleRow(
                            context,
                            Icons.store_mall_directory_outlined,
                            'Store Open',
                            provider.settings!.storeOpen,
                          ),
                          _buildToggleRow(
                            context,
                            Icons.holiday_village,
                            'Holiday Mode',
                            provider.settings!.holidayMode,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSection(
                        context,
                        'Delivery Settings',
                        Icons.delivery_dining_rounded,
                        [
                          _buildSettingRow(
                            context,
                            Icons.currency_rupee_rounded,
                            'Free Delivery Threshold',
                            CurrencyFormatter.format(
                              provider.settings!.freeDeliveryThreshold,
                            ),
                          ),
                          _buildSettingRow(
                            context,
                            Icons.currency_rupee_rounded,
                            'Min Order Amount',
                            CurrencyFormatter.format(
                              provider.settings!.minOrderAmount,
                            ),
                          ),
                          _buildSettingRow(
                            context,
                            Icons.currency_rupee_rounded,
                            'Delivery Charge',
                            CurrencyFormatter.format(
                              provider.settings!.deliveryCharge,
                            ),
                          ),
                          _buildSettingRow(
                            context,
                            Icons.radar,
                            'Max Delivery Radius',
                            '${provider.settings!.maxDeliveryRadius} km',
                          ),
                          _buildSettingRow(
                            context,
                            Icons.timer_outlined,
                            'Estimated Delivery',
                            provider.settings!.estimatedDeliveryTime,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSection(
                        context,
                        'Address & Legal',
                        Icons.location_on_outlined,
                        [
                          _buildSettingRow(
                            context,
                            Icons.location_on_outlined,
                            'Address',
                            provider.settings!.businessAddress,
                          ),
                          _buildSettingRow(
                            context,
                            Icons.verified_user_outlined,
                            'GST Number',
                            provider.settings!.gstNumber,
                          ),
                          _buildSettingRow(
                            context,
                            Icons.map_outlined,
                            'Google Maps',
                            provider.settings!.googleMapsLink,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSection(
                        context,
                        'Customer Settings',
                        Icons.people_alt_rounded,
                        [
                          _buildToggleRow(
                            context,
                            Icons.shopping_cart_outlined,
                            'Guest Checkout',
                            provider.settings!.guestCheckout,
                          ),
                          _buildToggleRow(
                            context,
                            Icons.app_registration,
                            'Registration Required',
                            provider.settings!.registrationRequired,
                          ),
                          _buildSettingRow(
                            context,
                            Icons.shopping_cart,
                            'Max Cart Items',
                            '${provider.settings!.maxCartItems}',
                          ),
                          _buildSettingRow(
                            context,
                            Icons.favorite_outline,
                            'Wishlist Limit',
                            '${provider.settings!.wishlistLimit}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSection(
                        context,
                        'App Settings',
                        Icons.settings_applications_rounded,
                        [
                          _buildSettingRow(
                            context,
                            Icons.info_outline,
                            'App Version',
                            provider.settings!.appVersion,
                          ),
                          _buildToggleRow(
                            context,
                            Icons.system_update,
                            'Force Update',
                            provider.settings!.forceUpdate,
                          ),
                          _buildSettingRow(
                            context,
                            Icons.build_outlined,
                            'Maintenance Message',
                            provider.settings!.maintenanceMessage,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return VKartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: VKartColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: VKartColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: VKartColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: VKartColors.secondaryText),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: VKartColors.secondaryText,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value.isEmpty ? '—' : value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: VKartColors.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(
    BuildContext context,
    IconData icon,
    String label,
    bool value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: VKartColors.secondaryText),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: VKartColors.secondaryText,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (value ? VKartColors.success : VKartColors.disabled)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value ? 'Yes' : 'No',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: value ? VKartColors.success : VKartColors.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
