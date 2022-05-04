## Implementing the Jsonizable interface 
```dart
import 'package:jsonize/jsonize.dart';

class MyClass implements Jsonizable<MyClass> {
  String? str;
  MyClass([this.str]);
  factory MyClass.empty() => MyClass();

  // Jsonizable implementation
  @override
  String get jsonClassCode => "mc";
  @override
  dynamic toJson() => str;
  @override
  MyClass? fromJson(value) => MyClass(value);
}

void main() {
  // Register classes
  Jsonize.registerClass(MyClass.empty());

  Map<String, dynamic> myMap = {
    "my_num": 1,
    "my_str": "Hello!",
    "my_dt": DateTime.now(),
    "my_class": MyClass("here I am!")
  };
  var jsonRep = Jsonize.toJson(myMap);
  var hereIsMyMap = Jsonize.fromJson(jsonRep);
  print(hereIsMyMap);
}
```

## Registering a Type without implementing Jsonizable interface 
```dart
import 'package:jsonize/jsonize.dart';

class MyClass {
  final String str;
  final bool b;
  final DateTime? dt;

  MyClass(this.str, [this.b = true, this.dt]);

  // Static Jsonizable implementation
  static const String jsonClassCode = "moc";

  static dynamic toJson(dynamic value) {
    return {"str": value.str, "b": value.b, "dt": value.dt};
  }

  static dynamic fromJson(dynamic value) {
    return MyClass(value["str"], value["b"], value["dt"]);
  }
}

void main() {
  // Register classes
  Jsonize.registerType(
      MyClass, MyClass.jsonClassCode, MyClass.toJson, MyClass.fromJson);

  Map<String, dynamic> myMap = {
    "my_num": 1,
    "my_str": "Hello!",
    "my_dt": DateTime.now(),
    "my_class": MyClass("here I am!")
  };
  var jsonRep = Jsonize.toJson(myMap);
  var hereIsMyMap = Jsonize.fromJson(jsonRep);
  print(hereIsMyMap);
}
```

## A more complex example  
```dart
import 'package:jsonize/jsonize.dart';

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
  var jsonRep = Jsonize.toJson(myMap,
      jsonClassToken: "!", dateTimeFormat: DateTimeFormat.epoch);
  var hereIsMyMap = Jsonize.fromJson(jsonRep,
      jsonClassToken: "!", dateTimeFormat: DateTimeFormat.epoch);
  print(hereIsMyMap);
}
```
