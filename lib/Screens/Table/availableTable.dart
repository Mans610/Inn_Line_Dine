import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inn_dine_hub/Screens/Table/takeOrder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Helper/model.dart';
import '../../main.dart';
import 'tableOrderDetails.dart';

class AvailableTable extends StatefulWidget {
 // int totalTable = 0;
  Hotel hotel;
   AvailableTable({super.key,required this.hotel});

  @override
  State<AvailableTable> createState() => _AvailableTableState();
}

class _AvailableTableState extends State<AvailableTable> {
  List<String> runningTables = [];

  @override
  void initState() {
    super.initState();
    fetchRunningTables();
  }

  void fetchRunningTables() async {
    final prefs = await SharedPreferences.getInstance();
    final runningTablesKey = 'running_tables_${widget.hotel.name}';
    runningTables = prefs.getStringList(runningTablesKey) ?? [];
    setState(() {});
  }

  bool isTableAvailable(int tableNumber) {
    return !runningTables.contains(tableNumber.toString());
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sColor,
      appBar: AppBar(
        backgroundColor: pColor,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Center(
              child: Text('${widget.hotel.totalTables}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  )),
            ),
          ),
        ],
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back, color: Colors.black)),
        title: const Text('Available Table',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            )),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemCount: widget.hotel.totalTables,
        itemBuilder: (context, index) {
          final tableNumber = index + 1;
          final isAvailable = index % 2 == 0; // Example availability, replace with actual availability check
          return Table3D(
            tableNumber: tableNumber,
            isAvailable: isTableAvailable(tableNumber),
            onTap: () {
              if (isTableAvailable(tableNumber)) {
                // Navigate to TakeOrder for a new order
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TableTakeOrder(
                        onFetchCurrentTable: (){
                          fetchRunningTables();
                        },
                        tableNumber: tableNumber, hotel: widget.hotel),
                  ),
                );
              } else {
              //  Navigate to OrderDetails for an existing order
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TableOrderDetails(
                        onFetchCurrentTable: (){
                          fetchRunningTables();
                        },
                        tableNumber: tableNumber, hotel: widget.hotel),
                  ),
                );
              }
            },
            /*onTap: () {
              // Navigate to order screen for the selected table
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TakeOrder(tableNumber: tableNumber,hotel: widget.hotel),
                ),
              );
            },*/
          );
        },
      ),
    );
  }
}
class Table3D extends StatelessWidget {
  final int tableNumber;
  final bool isAvailable;
  final Function()? onTap;

  Table3D({required this.tableNumber, required this.isAvailable, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: isAvailable ? pColor : Colors.white,
         // color: pColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 5,
              offset: const Offset(3, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Text(
              'Table $tableNumber',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            Text(
              isAvailable ? 'Available' : 'Occupied',
              style: TextStyle(
                color: Colors.black,fontSize: 18
              ),
            ),
          ],
        ),
      ),
    );
  }
}