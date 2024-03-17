import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Helper/model.dart';

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
    _tablesController = TextEditingController(text: widget.hotel.totalTables.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tablesController.dispose();
    super.dispose();
  }

  void _saveChanges1() {
    String name = _nameController.text;
    int totalTables = int.tryParse(_tablesController.text) ?? 0;
    Hotel updatedHotel = Hotel(
      name: name,
      totalTables: totalTables,
      menu: widget.hotel.menu,
    );
    print('_nameController.text=====${_nameController.text}');
    print('updatedHotel=====${updatedHotel.name}');
    // Pass the updated hotel back to the previous screen
    Navigator.pop(context, updatedHotel);
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
    int hotelIndex = hotelsData.indexWhere((item) => item['name'] == widget.hotel.name);
    if (hotelIndex != -1) {
      hotelsData[hotelIndex] = updatedHotel.toJson();
    }

    // Save updated hotels list to shared preferences
    await prefs.setString('hotels', json.encode(hotelsData));
    widget.onUpdate();
    // Navigate back to the previous screen
    Navigator.pop(context, widget.hotel);
  }


  void _editMenuItem(HotelMenuItem menuItem) async {
    final updatedMenuItem = await showDialog<HotelMenuItem>(
      context: context,
      builder: (context) => EditMenuItemDialog(menuItem: menuItem),
    );
    if (updatedMenuItem != null) {
      // Update the menu item in the list
      setState(() {
        int index = widget.hotel.menu.indexWhere((item) => item.name == menuItem.name);
        if (index != -1) {
          widget.hotel.menu[index] = updatedMenuItem;
        }
      });
    }
  }

  void _addMenuItem() async {
    final newMenuItem = await showDialog<HotelMenuItem>(
      context: context,
      builder: (context) => EditMenuItemDialog(menuItem: HotelMenuItem(name: '', price: 0.0)),
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
      appBar: AppBar(
        title: Text('Edit Hotel'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Hotel Name'),
            ),
            TextField(
              controller: _tablesController,
              decoration: const InputDecoration(labelText: 'Total Tables'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            Text(
              'Menu Items:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.hotel.menu.length,
                itemBuilder: (context, index) {
                  HotelMenuItem menuItem = widget.hotel.menu[index];
                  return ListTile(
                    title: Text(menuItem.name),
                    subtitle: Text('\$${menuItem.price.toStringAsFixed(2)}'),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        _editMenuItem(menuItem);
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addMenuItem,
              child: Text('Add Menu Item'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveChanges,
              child: Text('Save Changes'),
            ),
          ],
        ),
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
    _priceController = TextEditingController(text: widget.menuItem.price.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    String name = _nameController.text;
    double price = double.tryParse(_priceController.text) ?? 0.0;
    HotelMenuItem updatedMenuItem = HotelMenuItem(name: name, price: price);
    // Return the updated menu item back to the previous screen
    Navigator.pop(context, updatedMenuItem);
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
          child: Text('Save'),
        ),
      ],
    );
  }
}
