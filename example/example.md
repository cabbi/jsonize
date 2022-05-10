## Implementing the Jsonizable interface 
```dart
import 'package:jsonize/jsonize.dart';

enum Color { red, blue, green, gray, yellow }

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
  // Register enums and classes
  Jsonize.registerEnum(Color.values);
  Jsonize.registerClass(MyClass.empty());

  Map<String, dynamic> myMap = {
    "my_num": 1,
    "my_str": "Hello!",
    "my_color": Color.green,
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

## A more complex example using the 'Clonable' interface
```dart
import 'package:jsonize/jsonize.dart';

class Item extends Clonable<Item> {
  String get cCode => "code";

  final String code;

  Item(this.code);
  factory Item.empty() => Item("");
  static CloneFields getFields(Item o) => CloneFields(
      [CloneField(o.cCode, getter: () => o.code, setter: (v) => {})]);

  @override
  String toString() => code;

  // Clonable implementation
  @override
  String get jsonClassCode => "item";

  @override
  Item create(json) => Item(json[cCode]);

  @override
  CloneFields get fields => Item.getFields(this);
}

class DateTimeItem extends Item {
  DateTime dt;
  DateTimeItem(String code, [DateTime? dt])
      : dt = dt ?? DateTime(0),
        super(code);
  factory DateTimeItem.empty() => DateTimeItem("");

  @override
  String toString() => "$code - $dt";

  // Clonable implementation
  @override
  String get jsonClassCode => "dtItem";

  @override
  DateTimeItem create(json) => DateTimeItem(json[cCode]);

  @override
  CloneFields get fields => Item.getFields(this)
    ..add(CloneField<DateTime>("dt", getter: () => dt, setter: (v) => dt = v));
}

class ColorItem extends Item {
  int r, g, b;
  ColorItem(String code, {this.r = 0, this.g = 0, this.b = 0}) : super(code);
  factory ColorItem.empty() => ColorItem("");

  @override
  String toString() => "$code - $r.$g.$b";

  // Clonable implementation
  @override
  String get jsonClassCode => "colItem";

  @override
  ColorItem create(json) => ColorItem(json[cCode]);

  @override
  CloneFields get fields => Item.getFields(this)
    ..addAll([
      CloneField<int>("r",
          getter: () => r, setter: (v) => r = v, defaultValue: 0),
      CloneField<int>("g",
          getter: () => g, setter: (v) => g = v, defaultValue: 0),
      CloneField<int>("b",
          getter: () => b, setter: (v) => b = v, defaultValue: 0)
    ]);
}

void main() {
  // Register classes
  Jsonize.registerClasses(
      [Item.empty(), DateTimeItem.empty(), ColorItem.empty()]);

  List myList = [
    Item("A base item"),
    DateTimeItem("Now", DateTime.now()),
    DateTimeItem("A Date", DateTime(2022, 4, 20)),
    ColorItem("Red", r: 255),
    ColorItem("Blue", b: 255),
    ColorItem("Gray", r: 128, g: 128, b: 128)
  ];

  var jsonRep = Jsonize.toJson(myList,
      jsonClassToken: "!", dateTimeFormat: DateTimeFormat.epoch);
  var backToLife = Jsonize.fromJson(jsonRep,
      jsonClassToken: "!", dateTimeFormat: DateTimeFormat.epoch);
  print(backToLife);
}
```
