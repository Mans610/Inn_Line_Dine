import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:inn_dine_hub/Helper/model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Helper/orderModel.dart';
import '../../main.dart';
import '../home.dart';

class TableTakeOrder extends StatefulWidget {
  final int tableNumber;
  Hotel hotel;
  final Function onFetchCurrentTable;

  @override
  TableTakeOrder(
      {Key? key,
      required this.tableNumber,
      required this.hotel,
      required this.onFetchCurrentTable})
      : super(key: key);

  @override
  _TableTakeOrderState createState() => _TableTakeOrderState();
}

class _TableTakeOrderState extends State<TableTakeOrder> {
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

  Widget customFoodItem(String title, subTitle, Widget row) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: SizedBox(
        height: 70,
        width: double.infinity,
        child: Card(
            color: pColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(title,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            )),
                        Text(subTitle,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            )),
                      ],
                    ),
                  ),
                  row,
                ],
              ),
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sColor,
      appBar: AppBar(
        backgroundColor: pColor,
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back, color: Colors.black)),
        title: Text("Order for Table ${widget.tableNumber}",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            )),
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: searchItem,
                decoration: InputDecoration(
                  labelText: 'Search Menu Items',
                  fillColor: Colors.white,
                  border: InputBorder.none,
                  filled: true,
                  suffixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return customFoodItem(
                      item.name,
                      "₹${item.price.toStringAsFixed(2)}",
                      Row(
                        children: [
                          customIcon(Icons.add, () {
                            //deleteHotel(index);
                            addToOrder(item);
                          }),
                        ],
                      ));
                  ListTile(
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
      ),
      bottomNavigationBar: selectedOrders.isNotEmpty ? bottomNav() : SizedBox(),
    );
  }

  Widget buildOrderSummary() {
    return Expanded(
      child: Column(
        children: [
          Text(
            'Order Summary',
            style: Theme.of(context)
                .textTheme
                .headline6!
                .copyWith(color: Colors.white),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: selectedOrders.length,
              itemBuilder: (context, index) {
                final orderItem = selectedOrders[index];
                return customFoodItem(
                    orderItem.menuItem.name,
                    "₹${orderItem.menuItem.price.toStringAsFixed(2)} x ${orderItem.quantity} = ₹${orderItem.totalPrice.toStringAsFixed(2)}",
                    Row(
                      children: [
                        customIcon(Icons.remove, () {
                          //deleteHotel(index);
                          updateOrderItemQuantity(index, false);
                        }),
                        customIcon(Icons.add, () {
                          //deleteHotel(index);
                          updateOrderItemQuantity(index, true);
                        }),
                      ],
                    ));
              },
            ),
          ),
        /*  Text('Total: ₹${totalPrice.toStringAsFixed(2)}'),
          ElevatedButton(
            onPressed: () {
              print('Order saved for table ${widget.tableNumber}');
              saveOrderAndManageTables(
                  Order(
                      hotelName: widget.hotel.name,
                      tableNumber: widget.tableNumber,
                      orderId: '',
                      items: selectedOrders),
                  context);
            },
            child: const Text('Confirm Order'),
          )*/
        ],
      ),
    );
  }

  Widget bottomNav() {
    return Container(
      color: Colors.white,
      width: double.infinity,
      height: 80,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: InkWell(
                onTap: () {
                  saveOrderAndManageTables(
                      Order(
                          hotelName: widget.hotel.name,
                          tableNumber: widget.tableNumber,
                          orderId: '',
                          items: selectedOrders),
                      context);
                },
                child: SizedBox(
                  height: 80,
                  child: Card(
                    elevation: 8,
                    color: pColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(width: 0.2)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Confirm Order',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Colors.black)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 80,
                child: Card(
                  elevation: 8,
                  color: pColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(width: 0.2)),
                  child: Center(
                    child: Text(
                      '₹${totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> saveOrderAndManageTables(
      Order order, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final orderId = getOrderKey(order.tableNumber, order.hotelName);
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
