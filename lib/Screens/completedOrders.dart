import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Helper/model.dart';
import '../Helper/orderModel.dart';

class CompletedOrdersScreen extends StatefulWidget {
  final Hotel hotel;
  const CompletedOrdersScreen({Key? key, required this.hotel}) : super(key: key);

  @override
  _CompletedOrdersScreenState createState() => _CompletedOrdersScreenState();
}

class _CompletedOrdersScreenState extends State<CompletedOrdersScreen> {
  DateTime? selectedDate;
  List<Order> completedOrders = [];

  @override
  void initState() {
    super.initState();
    fetchAndSetOrders();
  }

  Future<List<Order>> fetchCompletedOrders({DateTime? date}) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> completedOrdersKeys = prefs.getStringList('completedOrdersKeys-${widget.hotel.name}') ?? [];
    List<Order> orders = [];

    for (String key in completedOrdersKeys) {
      String? orderJson = prefs.getString(key);
      if (orderJson != null) {
        Order order = Order.fromJson(json.decode(orderJson));
        if (date == null || DateTime.parse(key.split('-').last).toLocal().isSameDate(date)) {
          orders.add(order);
        }
      }
    }
    return orders;
  }



  void fetchAndSetOrders() async {
    List<Order> orders = await fetchCompletedOrders(date: selectedDate);
    setState(() {
      completedOrders = orders;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Completed Orders'),
      ),
      body: ListView.builder(
        itemCount: completedOrders.length,
        itemBuilder: (context, index) {
          Order order = completedOrders[index];
          return ListTile(
            title: Text('Table ${order.tableNumber} - ${order.orderId}'),
            subtitle: Text('Total: ₹${order.items.fold(0.0, (sum, item) => sum + item.totalPrice).toStringAsFixed(2)}'),
            // Add more order details as needed
          );
        },
      ),
      // Optionally add a date picker to filter orders by date
    );
  }
}
extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}