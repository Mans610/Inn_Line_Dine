import 'package:flutter/material.dart';

import '../../Helper/model.dart';
import '../../main.dart';

class AddHotelScreen extends StatefulWidget {
  final Function(Hotel) onAddHotel;
  const AddHotelScreen({super.key, required this.onAddHotel});

  @override
  _AddHotelScreenState createState() => _AddHotelScreenState();
}

class _AddHotelScreenState extends State<AddHotelScreen> {
  late TextEditingController _nameController;
  late TextEditingController _tablesController;
  List<HotelMenuItem> menu = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _tablesController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tablesController.dispose();
    super.dispose();
  }

  void addMenuItem(String name, double price) {
    setState(() {
      menu.add(HotelMenuItem(name: name, price: price));
    });
  }

  void addHotel() {
    String name = _nameController.text;
    int totalTables = int.tryParse(_tablesController.text) ?? 0;
    Hotel hotel = Hotel(name: name, totalTables: totalTables, menu: menu);
    widget.onAddHotel(hotel);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sColor,
      appBar: AppBar(
        backgroundColor: pColor,
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back, color: Colors.black)),
        title: const Text('Add Hotel',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            )),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                  labelText: 'Hotel Name',
                  fillColor: Colors.white,
                  border: InputBorder.none,
                  filled: true),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _tablesController,
              decoration: const InputDecoration(
                  labelText: 'Total Tables',
                  fillColor: Colors.white,
                  border: InputBorder.none,
                  filled: true),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            const Text('Menu Items:', style: TextStyle(color: Colors.white)),
            ListView.builder(
              shrinkWrap: true,
              itemCount: menu.length,
              itemBuilder: (context, index) {
                return customFoodItem(menu[index].name,menu[index].price);
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: SizedBox(
                    height: 60,
                    width: double.infinity,
                    child: Card(
                        color: pColor,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(menu[index].name,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  )),
                              Text('₹${menu[index].price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  )),
                            ],
                          ),
                        )),
                  ),
                );
                return ListTile(
                  title: Text(menu[index].name),
                  subtitle: Text('₹${menu[index].price.toStringAsFixed(2)}'),
                );
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateColor.resolveWith((states) => pColor)),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AddMenuItemDialog(
                    onAddMenuItem: addMenuItem,
                  ),
                );
              },
              child:
                  Text('Add Menu Item', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        width: double.infinity,
        height: 80,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              addHotel();
            },
            child: Card(
              elevation: 8,
              color: pColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(width: 0.2)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Add Hotel',
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
    );
  }
}

class AddMenuItemDialog extends StatefulWidget {
  final Function(String, double) onAddMenuItem;

  AddMenuItemDialog({required this.onAddMenuItem});

  @override
  _AddMenuItemDialogState createState() => _AddMenuItemDialogState();
}

class _AddMenuItemDialogState extends State<AddMenuItemDialog> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void addMenuItem() {
    String name = _nameController.text.trim(); // Trim to remove extra spaces
    String priceText = _priceController.text.trim(); // Trim to remove extra spaces

    // Check if both name and price are not empty
    if (name.isNotEmpty && priceText.isNotEmpty) {
      double price = double.tryParse(priceText) ?? 0.0;
      widget.onAddMenuItem(name, price);
      Navigator.pop(context);
    } else {
      // Show an error dialog or message to the user indicating that both fields are required
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Both item name and price are required.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Menu Item'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Item Name'),
          ),
          TextField(
            controller: _priceController,
            decoration: InputDecoration(labelText: 'Item Price'),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: addMenuItem,
          child: Text('Add'),
        ),
      ],
    );
  }
}
Widget customFoodItem(String itemName,itemPrice){
  return Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: SizedBox(
      height: 60,
      width: double.infinity,
      child: Card(
          color: pColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(itemName,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    )),
                Text('₹${itemPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          )),
    ),
  );
}