import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Helper/model.dart';
import '../../main.dart';
import '../home.dart';

class EditHotelScreen extends StatefulWidget {
  final Hotel hotel;
  final Function() onUpdate;

  EditHotelScreen({required this.hotel, required this.onUpdate});

  @override
  _EditHotelScreenState createState() => _EditHotelScreenState();
}

class _EditHotelScreenState extends State<EditHotelScreen> {
  late TextEditingController _nameController;
  late TextEditingController _tablesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.hotel.name);
    _tablesController =
        TextEditingController(text: widget.hotel.totalTables.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tablesController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    String name = _nameController.text;
    int totalTables = int.tryParse(_tablesController.text) ?? 0;

    // Update hotel data in the hotels list
    // widget.hotel.name = name;
    //  widget.hotel.totalTables = totalTables;
    Hotel updatedHotel = Hotel(
      name: name,
      totalTables: totalTables,
      menu: widget.hotel.menu,
    );
    // Retrieve hotels list from shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String hotelsJson = prefs.getString('hotels') ?? '[]';
    List<dynamic> hotelsData = json.decode(hotelsJson);

    // Find and update the hotel in the hotels list
    int hotelIndex =
        hotelsData.indexWhere((item) => item['name'] == widget.hotel.name);
    if (hotelIndex != -1) {
      hotelsData[hotelIndex] = updatedHotel.toJson();
    }

    // Save updated hotels list to shared preferences
    await prefs.setString('hotels', json.encode(hotelsData));
    widget.onUpdate();
    // Navigate back to the previous screen
    Navigator.pop(context, widget.hotel);
  }

  void _deleteMenuItem(HotelMenuItem menuItem) {
    setState(() {
      widget.hotel.menu.remove(menuItem);
    });
  }

  void _editMenuItem(HotelMenuItem menuItem) async {
    final updatedMenuItem = await showDialog<HotelMenuItem>(
      context: context,
      builder: (context) => EditMenuItemDialog(menuItem: menuItem),
    );
    if (updatedMenuItem != null) {
      // Update the menu item in the list
      setState(() {
        int index =
            widget.hotel.menu.indexWhere((item) => item.name == menuItem.name);
        if (index != -1) {
          widget.hotel.menu[index] = updatedMenuItem;
        }
      });
    }
  }

  void _addMenuItem() async {
    final newMenuItem = await showDialog<HotelMenuItem>(
      context: context,
      builder: (context) =>
          EditMenuItemDialog(menuItem: HotelMenuItem(name: '', price: 0.0)),
    );
    if (newMenuItem != null) {
      // Add the new menu item to the list
      setState(() {
        widget.hotel.menu.add(newMenuItem);
      });
    }
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
            child: Icon(Icons.arrow_back, color: Colors.black)),
        title: Text("Edit Hotel",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            )),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        width: double.infinity,
        height: 80,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              _saveChanges();
              //addHotel();
            },
            child: Card(
              elevation: 8,
              color: pColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(width: 0.2)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Save Changes',
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
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Total Tables',
                  fillColor: Colors.white,
                  border: InputBorder.none,
                  filled: true),
            ),
            SizedBox(height: 16),
            Text(
              'Menu Items:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            widget.hotel.menu.length == 0
                ? Expanded(
                    child: Center(
                        child: Text(
                    'No Food Item Available yet',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  )))
                : Expanded(
                    child: ListView.builder(
                      itemCount: widget.hotel.menu.length,
                      itemBuilder: (context, index) {
                        HotelMenuItem menuItem = widget.hotel.menu[index];
                        return customFoodItem(menuItem);
                        Container(
                          height: 60,
                          width: double.infinity,
                          child: Center(
                            child: Card(
                              color: pColor,
                              child: ListTile(
                                title: Text(menuItem.name),
                                subtitle: Text(
                                    '₹${menuItem.price.toStringAsFixed(2)}'),
                                trailing: IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    _editMenuItem(menuItem);
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateColor.resolveWith((states) => pColor)),
              onPressed: _addMenuItem,
              child: Text('Add Menu Item',
                  style: TextStyle(
                    color: Colors.black,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget customFoodItem(HotelMenuItem hotelMenuItem) {
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
                        Text(hotelMenuItem.name,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            )),
                        Text('₹${hotelMenuItem.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            )),
                      ],
                    ),
                  ),
                  customIcon(Icons.edit, () {
                    //deleteHotel(index);
                    _editMenuItem(hotelMenuItem);
                  }),
                  customIcon(Icons.delete, () {
                    //deleteHotel(index);
                    _deleteMenuItem(hotelMenuItem);
                  }),
                ],
              ),
            )),
      ),
    );
  }
}

class EditMenuItemDialog extends StatefulWidget {
  final HotelMenuItem menuItem;

  EditMenuItemDialog({required this.menuItem});

  @override
  _EditMenuItemDialogState createState() => _EditMenuItemDialogState();
}

class _EditMenuItemDialogState extends State<EditMenuItemDialog> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.menuItem.name);
    _priceController =
        TextEditingController(text: widget.menuItem.price.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    String name = _nameController.text;
    if (name.isEmpty) {
      _showSnackbar('Please enter item name.');
      return;
    }
    double? price = double.tryParse(_priceController.text);
    if (price == null || price <= 0) {
      _showSnackbar('Please enter a valid item price.');
      return;
    }
    HotelMenuItem updatedMenuItem = HotelMenuItem(name: name, price: price);
    // Return the updated menu item back to the previous screen
    Navigator.pop(context, updatedMenuItem);
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Menu Item'),
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
          onPressed: _saveChanges,
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateColor.resolveWith((states) => pColor)),
          child: Text('Save', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}
