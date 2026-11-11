import 'address_model.dart';

/// Lifecycle states an order can be in. Only [placed] is set by the app;
/// the rest are updated store-side (admin app / console).
enum OrderStatus {
  orderPlaced,
  orderReceived,
  delivered,
  placed,
  confirmed,
  packed,
  assigned,
  outForDelivery,
  cancelled,
  completed
}

extension OrderStatusLabel on OrderStatus {
  String get label => switch (this) {
        OrderStatus.orderPlaced => 'ORDER PLACED',
        OrderStatus.orderReceived => 'CONFIRMED',
        OrderStatus.delivered => 'DELIVERED',
        OrderStatus.placed => 'Placed',
        OrderStatus.confirmed => 'Confirmed',
        OrderStatus.packed => 'Packed',
        OrderStatus.assigned => 'Assigned',
        OrderStatus.outForDelivery => 'Out for Delivery',
        OrderStatus.cancelled => 'Cancelled',
        OrderStatus.completed => 'Completed',
      };

  /// Firestore string form (stable — do not localize).
  String get value => name;

  static OrderStatus fromValue(String? value) {
    final v = (value ?? '').trim();
    // Map legacy database values to the canonical enum members.
    switch (v) {
      case 'placed':
      case 'orderPlaced':
        return OrderStatus.orderPlaced;
      case 'confirmed':
      case 'orderReceived':
        return OrderStatus.orderReceived;
      case 'delivered':
        return OrderStatus.delivered;
      case 'packed':
        return OrderStatus.packed;
      case 'assigned':
        return OrderStatus.assigned;
      case 'outForDelivery':
        return OrderStatus.outForDelivery;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'completed':
        return OrderStatus.completed;
      default:
        // Fallback: try exact name match (for any future values).
        for (final s in OrderStatus.values) {
          if (s.name == v) return s;
        }
        return OrderStatus.orderPlaced;
    }
  }
}

/// A product line inside an order — denormalized snapshot of the product at
/// purchase time, so later catalogue edits never rewrite order history.
class OrderItem {
  const OrderItem({
    required this.productId,
    required this.name,
    required this.weight,
    required this.price,
    required this.quantity,
    this.image = '',
  });

  final String productId;
  final String name;
  final String weight;
  final double price;
  final int quantity;
  final String image;

  double get lineTotal => price * quantity;

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'name': name,
        'weight': weight,
        'price': price,
        'quantity': quantity,
        'image': image,
      };

  factory OrderItem.fromMap(Map<String, dynamic> map) => OrderItem(
        productId: (map['productId'] ?? '').toString(),
        name: (map['name'] ?? '').toString(),
        weight: (map['weight'] ?? '').toString(),
        price: (map['price'] as num?)?.toDouble() ?? 0,
        quantity: (map['quantity'] as num?)?.toInt() ?? 0,
        image: (map['image'] ?? '').toString(),
      );
}

/// A placed order as stored in the Firestore `orders` collection.
class OrderModel {
  const OrderModel({
    required this.id,
    required this.customerId,
    required this.userId,
    required this.customerName,
    required this.customerEmail,
    required this.deliveryLocation,
    required this.deliveryLocationEnglish,
    required this.deliveryLocationTelugu,
    required this.phoneNumber,
    required this.address,
    required this.items,
    required this.subtotal,
    required this.deliveryCharge,
    required this.grandTotal,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.villageId = '',
    this.villageName = '',
    this.villageNameTelugu = '',
    this.assignedPartnerId = '',
  });

  /// Human-readable unique order id, e.g. "VK-20260717-483920".
  final String id;

  /// Stable anonymous device/customer identifier (no auth in the app yet).
  final String customerId;

  /// Auth user id linked to the session.
  final String userId;

  final String customerName;
  final String customerEmail;
  final String deliveryLocation;
  final String deliveryLocationEnglish;
  final String deliveryLocationTelugu;
  final String phoneNumber;

  final AddressModel address;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryCharge;
  final double grandTotal;
  final String paymentMethod;
  final OrderStatus status;
  final DateTime createdAt;

  /// Delivery village snapshot (Firestore delivery_locations doc id + names
  /// at order time), so history stays correct even if the admin renames or
  /// removes the village later.
  final String villageId;
  final String villageName;
  final String villageNameTelugu;
  final String assignedPartnerId;

  int get itemCount {
    var count = 0;
    for (final item in items) {
      count += item.quantity;
    }
    return count;
  }

  Map<String, dynamic> toMap() => {
        'orderId': id,
        'customerId': customerId,
        'userId': userId,
        'customerName': customerName,
        'customerEmail': customerEmail,
        'deliveryLocation': deliveryLocation,
        'deliveryLocationEnglish': deliveryLocationEnglish,
        'deliveryLocationTelugu': deliveryLocationTelugu,
        'phoneNumber': phoneNumber,
        'customerPhone': phoneNumber,
        'address': AddressModel(
          name: customerName,
          phone: phoneNumber,
          village: deliveryLocationEnglish,
          houseNo: '',
          landmark: '',
          pincode: '',
        ).toMap(),
        'items': items.map((i) => i.toMap()).toList(),
        'subtotal': subtotal,
        'deliveryCharge': deliveryCharge,
        'grandTotal': grandTotal,
        'paymentMethod': paymentMethod,
        'status': status.value,
        'villageId': villageId,
        'villageName': villageName,
        'villageNameTelugu': villageNameTelugu,
        'assignedPartnerId': assignedPartnerId,
        // Stored as milliseconds so the model stays Firestore-agnostic;
        // an indexed server timestamp is added by the service layer.
        'createdAtMs': createdAt.millisecondsSinceEpoch,
      };

  factory OrderModel.fromMap(Map<String, dynamic> map) => OrderModel(
        id: (map['orderId'] ?? map['docId'] ?? '').toString(),
        customerId: (map['customerId'] ?? '').toString(),
        userId: (map['userId'] ?? map['customerId'] ?? '').toString(),
        customerName: (map['customerName'] ?? (map['address'] as Map?)?['name']?.toString() ?? '').toString(),
        customerEmail: (map['customerEmail'] ?? '').toString(),
        deliveryLocation: (map['deliveryLocation'] ?? (map['address'] as Map?)?['village']?.toString() ?? '').toString(),
        deliveryLocationEnglish: (map['deliveryLocationEnglish'] ?? (map['address'] as Map?)?['village']?.toString() ?? '').toString(),
        deliveryLocationTelugu: (map['deliveryLocationTelugu'] ?? '').toString(),
        phoneNumber: (map['phoneNumber'] ?? (map['address'] as Map?)?['phone']?.toString() ?? '').toString(),
        address: AddressModel.fromMap(
          (map['address'] as Map?)?.cast<String, dynamic>() ?? const {},
        ),
        items: ((map['items'] as List?) ?? const [])
            .whereType<Map>()
            .map((m) => OrderItem.fromMap(m.cast<String, dynamic>()))
            .toList(),
        subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0,
        deliveryCharge: (map['deliveryCharge'] as num?)?.toDouble() ?? 0,
        grandTotal: (map['grandTotal'] as num?)?.toDouble() ?? 0,
        paymentMethod:
            (map['paymentMethod'] ?? 'Cash on Delivery').toString(),
        status: OrderStatusLabel.fromValue(map['status']?.toString()),
        villageId: (map['villageId'] ?? '').toString(),
        villageName: (map['villageName'] ?? '').toString(),
        villageNameTelugu: (map['villageNameTelugu'] ?? '').toString(),
        assignedPartnerId: (map['assignedPartnerId'] ?? '').toString(),
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          (map['createdAtMs'] as num?)?.toInt() ?? 0,
        ),
      );
}
