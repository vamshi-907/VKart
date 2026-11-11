import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vkart_shared/vkart_shared.dart';

import '../../providers/partner_auth_provider.dart';
import '../../src/providers/order_provider.dart';
import '../../src/repositories/order_repository.dart';

class PartnerDashboardScreen extends StatefulWidget {
  const PartnerDashboardScreen({super.key});

  @override
  State<PartnerDashboardScreen> createState() =>
      _PartnerDashboardScreenState();
}

class _PartnerDashboardScreenState extends State<PartnerDashboardScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final auth = context.read<PartnerAuthProvider>();
      final email = await auth.getPartnerEmail();

      if (!mounted) return;

      context
          .read<OrderProvider>()
          .listenToAssignedOrders(email ?? '');
    });
  }

  Future<void> _refreshOrders() async {
    final auth = context.read<PartnerAuthProvider>();
    final email = await auth.getPartnerEmail();

    if (!mounted) return;

    context
        .read<OrderProvider>()
        .listenToAssignedOrders(email ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<PartnerAuthProvider>();
    final orderProvider = context.watch<OrderProvider>();

    final name =
        auth.partnerName?.trim().isNotEmpty == true
            ? auth.partnerName!
            : 'Partner';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,

        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6530),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.delivery_dining,
                color: Colors.white,
                size: 22,
              ),
            ),

            const SizedBox(width: 10),

            const Text(
              'VKart',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF6530),
                fontSize: 20,
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            onPressed: () {
              auth.performLogout(context);
            },
            icon: const Icon(
              Icons.logout_rounded,
              color: Color(0xFF1F2937),
            ),
            tooltip: 'Logout',
          ),
        ],
      ),

      body: RefreshIndicator(
        color: const Color(0xFFFF6530),
        onRefresh: _refreshOrders,

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),

          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Delivery Partner',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Hello, $name',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),

              const SizedBox(height: 24),

              if (orderProvider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(
                      color: Color(0xFFFF6530),
                    ),
                  ),
                ),

              if (!orderProvider.isLoading &&
                  orderProvider.assignedOrders.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      'No orders available.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),

              ...orderProvider.assignedOrders.map(
                (order) => _OrderCard(
                  order: order,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatefulWidget {
  const _OrderCard({
    required this.order,
  });

  final OrderModel order;

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  final OrderRepository _repository = OrderRepository();

  /// Double-tap guard: while a status write is in flight the action button is
  /// disabled, so a card can never fire two concurrent status updates.
  bool _updating = false;

  /// Executes exactly one forward status transition for this order through
  /// the OrderProvider guard (which validates the current document state and
  /// only allows ORDER PLACED → CONFIRMED → DELIVERED). Failures — including
  /// Firestore permission rejections — are surfaced instead of failing
  /// silently; the card itself refreshes from the realtime snapshot.
  Future<void> _updateStatus(OrderStatus next) async {
    if (_updating) return;
    setState(() => _updating = true);
    try {
      await context.read<OrderProvider>().updateOrderStatus(
            widget.order.id,
            next,
          );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not update order ${widget.order.id}. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repository = _repository;

    final collectable = widget.order.grandTotal;
    final status = widget.order.status;

    // Delivery location snapshot from the order (immutable after checkout).
    // `deliveryLocationEnglish` is preferred; `deliveryLocation` is a legacy
    // fallback. Old orders without a location show an unavailable message.
    final locationEnglish = widget.order.deliveryLocationEnglish.trim().isNotEmpty
        ? widget.order.deliveryLocationEnglish.trim()
        : widget.order.deliveryLocation.trim();
    final locationTelugu = widget.order.deliveryLocationTelugu.trim();
    final hasLocation = locationEnglish.isNotEmpty;

    final userIdForPhone =
        widget.order.userId.isNotEmpty
            ? widget.order.userId
            : widget.order.customerId;

    return Card(
      elevation: 3,

      color: Colors.white,

      margin: const EdgeInsets.only(bottom: 16),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // CUSTOMER NAME
            Text(
              widget.order.customerName.isNotEmpty
                  ? widget.order.customerName
                  : 'Unknown Customer',

              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),

            const SizedBox(height: 5),

            // ORDER ID
            Text(
              'Order ID: ${widget.order.id}',

              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),

            // DELIVERY LOCATION
            Container(
              width: double.infinity,

              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),

              decoration: BoxDecoration(
                color: const Color(0xFFFF6530).withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text(
                    'DELIVERY LOCATION',

                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFF6530),
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 20,
                        color: Color(0xFFFF6530),
                      ),

                      const SizedBox(width: 6),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              hasLocation
                                  ? locationEnglish
                                  : 'Delivery location unavailable',

                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F2937),
                              ),
                            ),

                            if (hasLocation && locationTelugu.isNotEmpty) ...[
                              const SizedBox(height: 2),

                              Text(
                                locationTelugu,

                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // COLLECTABLE AMOUNT
            Container(
              width: double.infinity,

              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),

              decoration: BoxDecoration(
                color: const Color(0xFFFF6530).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text(
                    'COLLECTABLE AMOUNT',

                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFF6530),
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '₹${collectable.toStringAsFixed(0)}',

                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFF6530),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // PHONE + STATUS
            Row(
              children: [
                FutureBuilder<String?>(
                  future: repository.fetchCustomerPhone(
                    userIdForPhone,
                    // The order document carries the phone captured at
                    // checkout — no delivery_details access needed.
                    orderPhone: widget.order.phoneNumber,
                  ),

                  builder: (context, snapshot) {
                    final phone = snapshot.data?.trim();

                    final hasPhone =
                        phone != null && phone.isNotEmpty;

                    return Container(
                      width: 46,
                      height: 46,

                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6530)
                            .withValues(alpha: 0.10),

                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: IconButton(
                        tooltip: hasPhone
                            ? 'Call customer'
                            : 'Phone unavailable',

                        icon: const Icon(
                          Icons.phone_outlined,
                          color: Color(0xFFFF6530),
                          size: 24,
                        ),

                        onPressed: hasPhone
                            ? () async {
                                // Normalize number: trim and remove spaces, keep +
                                final rawPhone = phone.trim();
                                final cleanedPhone = rawPhone.replaceAll(' ', '');
                                final phoneNumber = cleanedPhone;

                                final phoneUri = Uri(
                                  scheme: 'tel',
                                  path: phoneNumber,
                                );

                                try {
                                  final launched = await launchUrl(
                                    phoneUri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                  if (!launched) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Phone dialer is not available on this device.',
                                        ),
                                      ),
                                    );
                                  }
                                } catch (_) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Phone dialer is not available on this device.',
                                      ),
                                    ),
                                  );
                                }
                              }
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Customer phone number is unavailable.',
                                    ),
                                  ),
                                );
                              },
                      ),
                    );
                  },
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),

                    decoration: BoxDecoration(
                      color: _statusBackground(status),
                      borderRadius: BorderRadius.circular(10),
                    ),

                    child: Text(
                      status.label,

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _statusColor(status),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ACTION BUTTON
            _buildActionButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final status = widget.order.status;

    // FINAL STATE
    if (status == OrderStatus.delivered) {
      return Container(
        width: double.infinity,

        padding: const EdgeInsets.symmetric(
          vertical: 14,
        ),

        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(10),
        ),

        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: Color(0xFF43A047),
                size: 20,
              ),

              SizedBox(width: 8),

              Text(
                'ORDER DELIVERED',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF43A047),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ORDER PLACED → ACCEPT ORDER
    if (status == OrderStatus.orderPlaced) {
      return SizedBox(
        width: double.infinity,

        child: ElevatedButton(
          // Disabled while a write is in flight — prevents double-accept.
          onPressed:
              _updating ? null : () => _updateStatus(OrderStatus.orderReceived),

          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6530),
            foregroundColor: Colors.white,

            padding: const EdgeInsets.symmetric(
              vertical: 14,
            ),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          child: _updating
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'ACCEPT ORDER',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      );
    }

    // ORDER RECEIVED → DELIVERED
    if (status == OrderStatus.orderReceived) {
      return SizedBox(
        width: double.infinity,

        child: ElevatedButton(
          // Disabled while a write is in flight — prevents double-delivery.
          onPressed:
              _updating ? null : () => _updateStatus(OrderStatus.delivered),

          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6530),
            foregroundColor: Colors.white,

            padding: const EdgeInsets.symmetric(
              vertical: 14,
            ),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          child: _updating
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'DELIVERED',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

Color _statusColor(OrderStatus status) {
  switch (status) {
    case OrderStatus.delivered:
      return const Color(0xFF43A047);

    case OrderStatus.orderReceived:
      return const Color(0xFF2979FF);

    case OrderStatus.orderPlaced:
      return const Color(0xFFFF6530);

    default:
      return const Color(0xFF6B7280);
  }
}

Color _statusBackground(OrderStatus status) {
  switch (status) {
    case OrderStatus.delivered:
      return const Color(0xFFE8F5E9);

    case OrderStatus.orderReceived:
      return const Color(0xFFEAF2FF);

    case OrderStatus.orderPlaced:
      return const Color(0xFFFFF1EC);

    default:
      return const Color(0xFFF3F4F6);
  }
}