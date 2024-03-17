import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:inn_dine_hub/Helper/model.dart';
import 'package:inn_dine_hub/Helper/orderModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int tableNumber;
  final Hotel hotel;
  final Function onFetchCurrentTable;
  const OrderDetailsScreen({Key? key,required this.onFetchCurrentTable, required this.tableNumber, required this.hotel}) : super(key: key);

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Order? currentOrder;

  @override
  void initState() {
    super.initState();
    fetchCurrentOrder();
    fetchHotelMenu();
  }

  void fetchCurrentOrder() async {
    final prefs = await SharedPreferences.getInstance();
    String orderKey = getOrderKey(widget.tableNumber, widget.hotel.name);//'Order-${widget.hotel.name}-${widget.tableNumber}';
    String? orderJson = prefs.getString(orderKey);
    if (orderJson != null) {
      setState(() {
        currentOrder = Order.fromJson(json.decode(orderJson));
      });
    }
  }

  void updateOrderItemQuantity(int index, bool increment) {
    setState(() {
      if (increment) {
        currentOrder!.items[index].quantity++;
      } else {
        if (currentOrder!.items[index].quantity > 1) {
          currentOrder!.items[index].quantity--;
        } else {
          currentOrder!.items.removeAt(index);
        }
      }
    });
    saveCurrentOrder();
  }
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
  void removeOrderItem(int index) {
    // Check if we're about to remove the last item
    if (currentOrder!.items.length == 1) {
      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Remove Order'),
            content: Text('This will remove the last item. Do you want to cancel the order?'),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel Order'),
                onPressed: () {
                  // User chooses to cancel the order
                  Navigator.of(context).pop(); // Close the dialog
                  completeOrder(); // Proceed to cancel the order
                },
              ),
              TextButton(
                child: const Text('Remove Item'),
                onPressed: () {
                  // User chooses to remove the last item but keep the order active (perhaps to add more items later)
                  setState(() {
                    currentOrder!.items.removeAt(index);
                  });
                  saveCurrentOrder();
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  // User decides not to remove the last item
                  Navigator.of(context).pop(); // Just close the dialog
                },
              ),
            ],
          );
        },
      );
    } else {
      // If it's not the last item, just remove it without showing the dialog
      setState(() {
        currentOrder!.items.removeAt(index);
      });
      saveCurrentOrder();
    }
  }
  List<HotelMenuItem> menuItems = [];
  List<HotelMenuItem> filteredItems = [];
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
  Future<void> saveCurrentOrder() async {
    final prefs = await SharedPreferences.getInstance();
    String orderKey = getOrderKey(widget.tableNumber, widget.hotel.name);
    String orderJson = jsonEncode(currentOrder!.toJson());
    await prefs.setString(orderKey, orderJson);
    widget.onFetchCurrentTable();
  }
  void addToOrder(HotelMenuItem item) {
    setState(() {
      // Try to find an existing order item
      OrderItem? existingOrderItem;
      try {
        existingOrderItem = currentOrder!.items.firstWhere(
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
        currentOrder!.items.add(OrderItem(menuItem: item, quantity: 1));
      }
      saveCurrentOrder();
    });
  }
  void saveCompletedOrder(Order order) async {
    final prefs = await SharedPreferences.getInstance();
    final String completedOrderKey = 'completedOrder-${widget.hotel.name}-${order.tableNumber}-${DateTime.now().toIso8601String()}';
    String orderJson = jsonEncode(order.toJson());
    await prefs.setString(completedOrderKey, orderJson);

    // Optionally, update a list of keys for completed orders for easier retrieval
    List<String> completedOrdersKeys = prefs.getStringList('completedOrdersKeys-${widget.hotel.name}') ?? [];
    completedOrdersKeys.add(completedOrderKey);
    await prefs.setStringList('completedOrdersKeys-${widget.hotel.name}', completedOrdersKeys);
  }
  double get totalPrice =>
      currentOrder!.items.fold(0, (sum, item) => sum + item.totalPrice);
  void completeOrder() async {
    final prefs = await SharedPreferences.getInstance();
    String orderKey = getOrderKey(widget.tableNumber, widget.hotel.name);//'Order-${widget.hotel.name}-${widget.tableNumber}';
    await prefs.remove(orderKey);

    // Update running tables to mark this table as available
    String runningTablesKey = 'running_tables_${widget.hotel.name}';
    List<String> runningTables = (await prefs.getStringList(runningTablesKey)) ?? [];
    runningTables.remove(widget.tableNumber.toString());
    await prefs.setStringList(runningTablesKey, runningTables);
    saveCompletedOrder(currentOrder!);
     widget.onFetchCurrentTable();
    Navigator.pop(context); // Go back to previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details for Table ${widget.tableNumber}'),
      ),
      body: currentOrder == null
          ? CircularProgressIndicator()
          : Column(
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
          Text(
            'Order Summary',
            style: Theme.of(context).textTheme.headline6,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: currentOrder!.items.length,
              itemBuilder: (context, index) {
                final item = currentOrder!.items[index];
                return ListTile(
                  title: Text(item.menuItem.name),
                  subtitle: Text(
                      "₹${item.menuItem.price.toStringAsFixed(2)} x ${item.quantity} = ₹${item.totalPrice.toStringAsFixed(2)}"),
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
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => removeOrderItem(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Text('Total: ₹${totalPrice.toStringAsFixed(2)}'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ElevatedButton(
              onPressed: completeOrder,
              child: Text('Complete Order'),
            ),
          ),
        ],
      ),
    );
  }
}