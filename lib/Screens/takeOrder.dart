import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:inn_dine_hub/Helper/model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Helper/orderModel.dart';

class TakeOrder extends StatefulWidget {
  final int tableNumber;
  Hotel hotel;
  final Function onFetchCurrentTable;
  @override
  TakeOrder({Key? key, required this.tableNumber, required this.hotel,required this.onFetchCurrentTable})
      : super(key: key);

  @override
  _TakeOrderState createState() => _TakeOrderState();
}

class _TakeOrderState extends State<TakeOrder> {

  List<HotelMenuItem> menuItems = [];

  void fetchHotelMenu() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? hotelsJson = prefs.getString('hotels');
    if (hotelsJson != null) {
      List<dynamic> hotelsList = json.decode(hotelsJson);
      Hotel? selectedHotel = hotelsList
          .map((item) => Hotel.fromJson(item))
          .firstWhere((hotel) => hotel.name == widget.hotel.name);
      setState(() {
        menuItems = selectedHotel.menu;
        filteredItems = menuItems;
      });
    }
  }

  List<HotelMenuItem> filteredItems = [];
  List<OrderItem> selectedOrders = [];

  @override
  void initState() {
    super.initState();
    fetchHotelMenu();
  }

  void addToOrder(HotelMenuItem item) {
    setState(() {
      // Try to find an existing order item
      OrderItem? existingOrderItem;
      try {
        existingOrderItem = selectedOrders.firstWhere(
          (orderItem) => orderItem.menuItem.name == item.name,
        );
      } catch (e) {
        existingOrderItem = null;
      }

      if (existingOrderItem != null) {
        // If found, increment its quantity
        existingOrderItem.quantity++;
      } else {
        // Otherwise, add a new item
        selectedOrders.add(OrderItem(menuItem: item, quantity: 1));
      }
    });
  }

  void searchItem(String query) {
    final suggestions = menuItems.where((item) {
      final itemName = item.name.toLowerCase();
      final input = query.toLowerCase();

      return itemName.contains(input);
    }).toList();

    setState(() {
      filteredItems = suggestions;
    });
  }

  double get totalPrice =>
      selectedOrders.fold(0, (sum, item) => sum + item.totalPrice);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order for Table ${widget.tableNumber}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: searchItem,
              decoration: InputDecoration(
                labelText: 'Search Menu Items',
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text("₹${item.price}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => addToOrder(item),
                  ),
                );
              },
            ),
          ),
          if (selectedOrders.isNotEmpty) buildOrderSummary(),
          /* Expanded(
              child: Column(
                children: [
                  Text(
                    'Order Summary',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  buildOrderSummary(),
                */
          /*  Expanded(
                    child: ListView.builder(
                      itemCount: selectedOrders.length,
                      itemBuilder: (context, index) {
                        final order = selectedOrders[index];
                        return ListTile(
                          title: Text(order.menuItem.name),
                          trailing: Text("₹${order.menuItem.price}"),
                        );
                      },
                    ),
                  ),*/
          /*
                  Text('Total: ₹${totalPrice.toStringAsFixed(2)}'),
                  ElevatedButton(
                    onPressed: () {
                      // Add your order saving functionality here
                      print('Order saved for table ${widget.tableNumber}');
                    },
                    child: Text('Confirm Order'),
                  )
                ],
              ),
            ),*/
        ],
      ),
    );
  }

  Widget buildOrderSummary() {
    return Expanded(
      child: Column(
        children: [
          Text(
            'Order Summary',
            style: Theme.of(context).textTheme.headline6,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: selectedOrders.length,
              itemBuilder: (context, index) {
                final orderItem = selectedOrders[index];
                return ListTile(
                  title: Text(orderItem.menuItem.name),
                  subtitle: Text(
                      "₹${orderItem.menuItem.price.toStringAsFixed(2)} x ${orderItem.quantity} = ₹${orderItem.totalPrice.toStringAsFixed(2)}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () => updateOrderItemQuantity(index, false),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () => updateOrderItemQuantity(index, true),
                      ),
                      /* IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            selectedOrders.removeAt(index);
                          });
                        },
                      ),*/
                    ],
                  ),
                );
              },
            ),
          ),
          Text('Total: ₹${totalPrice.toStringAsFixed(2)}'),
          ElevatedButton(
            onPressed: () {
              print('Order saved for table ${widget.tableNumber}');
              saveOrderAndManageTables(Order(
                  hotelName: widget.hotel.name,
                  tableNumber: widget.tableNumber,
                  orderId: '',
                  items: selectedOrders),context);
            },
            child: const Text('Confirm Order'),
          )
        ],
      ),
    );
  }
  Future<void> saveOrderAndManageTables(Order order, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final orderId = getOrderKey(order.tableNumber,order.hotelName);
    //'Order-${order.hotelName}-${order.tableNumber}-${DateTime.now().millisecondsSinceEpoch}';

    // Adjust order with generated ID and save
    order = Order(
        hotelName: order.hotelName,
        tableNumber: order.tableNumber,
        orderId: orderId,
        items: order.items);
    final String orderJson = jsonEncode(order.toJson());
    await prefs.setString(orderId, orderJson);

    // Update running tables
    final runningTablesKey = 'running_tables_${order.hotelName}';
    List<String> runningTables = prefs.getStringList(runningTablesKey) ?? [];
    if (!runningTables.contains(order.tableNumber.toString())) {
      runningTables.add(order.tableNumber.toString());
      await prefs.setStringList(runningTablesKey, runningTables);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order Confirmed'),
        content: Text('Order for Table ${order.tableNumber} has been saved.'),
        actions: [
          TextButton(
            onPressed: () {

              Navigator.of(context).pop(); // Close the dialog
              Navigator.of(context).pop(); // Go back to the previous screen
              widget.onFetchCurrentTable();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
  void updateOrderItemQuantity(int index, bool increment) {
    setState(() {
      if (increment) {
        selectedOrders[index].quantity++;
      } else {
        if (selectedOrders[index].quantity > 1) {
          selectedOrders[index].quantity--;
        } else {
          selectedOrders.removeAt(index);
        }
      }
    });
  }
}


