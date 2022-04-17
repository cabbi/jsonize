A json serialize class to convert to and from json format [DateTime] and custom classes.

## Features
[Jsonize] solves the problem of serializing and deserializing into undefined structures.

By default [Jsonize] supports [DateTime] serialization in any place of your data structure
'''dart
  List<dynamic> myList = [1, "Hello!", DateTime.now()];
  var jsonRep = Jsonize.toJson(myList);
  var myDeserializedList = Jsonize.fromJson(jsonRep);
'''

[Jsonize] also supports your own classes. You can registrer a type or let your class implement the [Jsonizable] interface.
'''dart
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
  Jsonize.registerClass(MyClass.empty());
  Map<String, dynamic> myMap = {
    "my_num": 1,
    "my_str": "Hello!",
    "my_dt": DateTime.now(),
    "my_class": MyClass("here I am!")
  };
  var jsonRep = Jsonize.toJson(myMap);
  var myDeserializedMap = Jsonize.fromJson(jsonRep);
'''

For more comples examples like subclasses, please refer to the examples section.

## Additional information

Since current Dart implementation does not support reflection, [Jsonize] requires what I would define as two extra steps.
1. register all your types/classes you want to serialize
2. In case of implementing the [Jsonizable] interface, you will need to register a class instance (e.g. factory MyClass.empty() => ...)

I hope future Dart releases will suport better reflaction and type handling.