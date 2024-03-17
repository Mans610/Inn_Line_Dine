class Hotel {
  final String name;
  final int totalTables;
  final List<HotelMenuItem> menu;

  Hotel({required this.name, required this.totalTables, required this.menu});

  factory Hotel.fromJson(Map<String, dynamic> json) {
    var menuJson = json['menu'] as List;
    List<HotelMenuItem> menu = menuJson.map((item) => HotelMenuItem.fromJson(item)).toList();
    return Hotel(
      name: json['name'],
      totalTables: json['totalTables'],
      menu: menu,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'totalTables': totalTables,
    'menu': menu.map((item) => item.toJson()).toList(),
  };
}

class HotelMenuItem {
  final String name;
  final double price;

  HotelMenuItem({required this.name, required this.price});

  factory HotelMenuItem.fromJson(Map<String, dynamic> json) => HotelMenuItem(
    name: json['name'],
    price: json['price'],
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'price': price,
  };
}