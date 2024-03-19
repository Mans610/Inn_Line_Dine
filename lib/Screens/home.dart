import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:inn_dine_hub/Screens/Hotel/viewHotel.dart';
import 'package:inn_dine_hub/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Helper/model.dart';
import 'Hotel/addHotel.dart';
import 'Hotel/editHotel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Hotel> hotels = [];

  @override
  void initState() {
    super.initState();
    loadHotels();
  }

  void loadHotels() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String hotelsJson = prefs.getString('hotels') ?? '[]';
    setState(() {
      hotels = (json.decode(hotelsJson) as List)
          .map((item) => Hotel.fromJson(item))
          .toList();
    });
    print('hotels====>${hotels}');
  }

  void saveHotels() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String hotelsJson = json.encode(hotels);
    prefs.setString('hotels', hotelsJson);
  }

  void addHotel(Hotel hotel) {
    setState(() {
      hotels.add(hotel);
    });
    saveHotels();
  }

  void deleteHotel(int index) {
    setState(() {
      hotels.removeAt(index);
    });
    saveHotels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sColor,
      appBar: AppBar(
        backgroundColor: pColor,
        title: Text(appName,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            )),
      ),
      body: Column(
        children: [
          const SizedBox(height: 50),
          hotels.length == 0
              ? const Expanded(
                  child: Center(
                      child: Text(
                  'Hotel Not Available Yet!\n',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                )))
              : ListView.builder(
                  itemCount: hotels.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        title: Text(hotels[index].name),
                        subtitle: Text(
                            "Total Table : ${hotels[index].totalTables} | Total Menu Item: ${hotels[index].menu.length}",
                            style: const TextStyle(fontSize: 10)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  HotelDetailScreen(hotel: hotels[index]),
                            ),
                          );
                        },
                        leading: customIcon(Icons.restaurant_rounded, () {
                          //deleteHotel(index);
                        }),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            customIcon(Icons.edit, () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditHotelScreen(
                                    hotel: hotels[index],
                                    onUpdate: loadHotels,
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(
                              width: 5,
                            ),
                            customIcon(Icons.delete, () {
                              deleteHotel(index);
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        width: double.infinity,
        height: 80,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddHotelScreen(
                    onAddHotel: addHotel,
                  ),
                ),
              );
            },
            child: Card(
              elevation: 8,
              color: pColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Add New Hotel',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.black)),
                ],
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(width: 0.2)),
            ),
          ),
        ),
      ),
    );
  }
}

Widget customIcon(IconData icon, Function onTap) {
  return GestureDetector(
    onTap: () => onTap(),
    child: SizedBox(
      height: 45,
      width: 45,
      child: Card(
        color: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(width: 0.2)),
        child: Center(
            child: Icon(
          icon,
          color: Colors.black,
        )),
      ),
    ),
  );
}
