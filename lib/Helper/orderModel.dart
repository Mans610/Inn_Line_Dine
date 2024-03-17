import '../Screens/takeOrder.dart';
import 'model.dart';
String getOrderKey(int tableNumber, String hotelName) {
  return 'currentOrder-$hotelName-$tableNumber';
}
class Order {
  final String hotelName;
  final int tableNumber;
  final String orderId;
  final List<OrderItem> items;

  double get totalBill => items.fold(0, (sum, item) => sum + item.totalPrice);

  Order({
    required this.hotelName,
    required this.tableNumber,
    required this.orderId,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
    'hotelName': hotelName,
    'tableNumber': tableNumber,
    'orderId': orderId,
    'items': items.map((item) => item.toJson()).toList(),
  };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    hotelName: json['hotelName'],
    tableNumber: json['tableNumber'],
    orderId: json['orderId'],
    items: List<OrderItem>.from(json['items'].map((x) => OrderItem.fromJson(x))),
  );
}


class OrderItem {
  final HotelMenuItem menuItem;
  int quantity;

  OrderItem({required this.menuItem, required this.quantity});

  double get totalPrice => menuItem.price * quantity;

  Map<String, dynamic> toJson() => {
    'menuItem': menuItem.toJson(),
    'quantity': quantity,
  };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    menuItem: HotelMenuItem.fromJson(json['menuItem']),
    quantity: json['quantity'],
  );
}

