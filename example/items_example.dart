import 'package:jsonize/src/jsonize.dart';

class Item implements Jsonizable<Item> {
  final String code;

  Item(this.code);
  factory Item.empty() => Item("");

  // Jsonizable implementation
  @override
  String get jsonClassCode => "item";
  @override
  Map<String, dynamic> toJson() => {"code": code};
  @override
  Item? fromJson(value) => Item(value["code"]);
}

class DateTimeItem extends Item {
  DateTime dt;
  DateTimeItem(String code, this.dt) : super(code);
  factory DateTimeItem.empty() => DateTimeItem("", DateTime(0));

  // Jsonizable implementation
  @override
  String get jsonClassCode => "dtItem";

  @override
  Map<String, dynamic> toJson() => super.toJson()..["dt"] = dt;

  @override
  DateTimeItem? fromJson(value) => DateTimeItem(value["code"], value["dt"]);
}

class ColorItem extends Item {
  final int r;
  final int g;
  final int b;
  ColorItem(String code, this.r, this.g, this.b) : super(code);
  factory ColorItem.empty() => ColorItem("", 0, 0, 0);

  // Jsonizable implementation
  @override
  String get jsonClassCode => "colItem";

  @override
  Map<String, dynamic> toJson() => super.toJson()
    ..["r"] = r
    ..["g"] = g
    ..["b"] = b;

  @override
  ColorItem? fromJson(value) =>
      ColorItem(value["code"], value["r"], value["g"], value["b"]);
}

void main() {
  // Register classes
  Jsonize.registerClasses(
      [Item.empty(), DateTimeItem.empty(), ColorItem.empty()]);

  Map<String, dynamic> myMap = {
    "item": Item("A base item"),
    "dt_item": DateTimeItem("Now", DateTime.now()),
    "color_item": ColorItem("Red", 255, 0, 0)
  };
  var jsonRep = Jsonize.toJson(myMap);
  var hereIsMyMap = Jsonize.fromJson(jsonRep);
  print(hereIsMyMap);
}
