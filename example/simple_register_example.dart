import 'package:jsonize/src/jsonize.dart';

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
