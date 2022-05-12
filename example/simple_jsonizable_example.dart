import 'package:jsonize/jsonize.dart';

enum Color with JsonizableEnum {
  /// The [jsonValue] must not change in time!
  red(10), // Can be numbers
  blue(20),
  green("myGreen"), // Can be strings as well
  gray(40),
  yellow(50);

  @override
  final dynamic jsonValue;
  const Color(this.jsonValue);
}

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
