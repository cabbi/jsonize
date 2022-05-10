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
