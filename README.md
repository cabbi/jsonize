A json serialize class to convert 'to' and 'from' json format **DateTime** and any of your own classes.

# Introduction

**Jsonize** solves the problem of serializing and deserializing objects into undefined structures.<br>
This package does not implement the 'toJson' and 'fromJson' methods for you. For that you can use one of the many available packages like [json_serializable](https://pub.dev/packages/json_serializable).

# Usage

By default **Jsonize** supports **DateTime** serialization in any place of your data structure.

```dart
  List<dynamic> myList = [1, "Hello!", DateTime.now()];
  var jsonRep = Jsonize.toJson(myList);
  var myDeserializedList = Jsonize.fromJson(jsonRep);
```

**Jsonize** also supports your own classes. You can register a type or let your class implement one of the **Jsonizable** or **Clonable** interfaces.

```dart
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
```

The **Clonable** interface is more compact, you only have to define fields of your object.
Since it has to set object variables after creation you can not define them as 'final'.
On the other hand the advantage is that you can define optional default values which will 
not be set into the final json representation in order to save space.

``` dart
import 'package:jsonize/jsonize.dart';

class ColorItem extends Clonable<ColorItem> {
  String name;
  int r, g, b;
  ColorItem(this.name, this.r, this.g, this.b);
  factory ColorItem.empty() => ColorItem("", 0, 0, 0);

  @override
  String toString() => "$name - $r.$g.$b";

  // Clonable implementation
  @override
  String get jsonClassCode => "colItem";

  @override
  ColorItem empty() => ColorItem.empty();

  @override
  CloneFields get fields => CloneFields([
        CloneField(name: "name", getter: () => name, setter: (v) => name = v),
        CloneField(
            name: "r", getter: () => r, setter: (v) => r = v, defaultValue: 0),
        CloneField(
            name: "g", getter: () => g, setter: (v) => g = v, defaultValue: 0),
        CloneField(
            name: "b", getter: () => b, setter: (v) => b = v, defaultValue: 0)
      ]);
}

void main() {
  // Register classes
  Jsonize.registerClass(ColorItem.empty());

  List myList = [
    ColorItem("Red", 255, 0, 0),
    ColorItem("Blue", 0, 0, 255),
    ColorItem("Gray", 128, 128, 128)
  ];

  // Zeros will not be serialized since they are defined as default value.
  // This way you might save json data storage space.
  var jsonRep = Jsonize.toJson(myList,
      jsonClassToken: "!", dateTimeFormat: DateTimeFormat.epoch);
  var backToLife = Jsonize.fromJson(jsonRep,
      jsonClassToken: "!", dateTimeFormat: DateTimeFormat.epoch);
  print(backToLife);
}
```
For more complex cases like subclasses, please refer to the examples section.

# Jsonize methods

## toJson

```dart
static String toJson(dynamic value,
      {String? indent,
       String? jsonClassToken,
       String? dtClassCode,
       DateTimeFormat? dateTimeFormat,
       CallbackFunction? convertCallback})
```

Transforms an object/structure of objects into a json string applying the class tokens in order to revert back your original objects.

#### Parameters:

- **_value_**: the value you want to transform to json string.
- **_indent_**: The indentation token. If omitted no indentation is used (space saving!).
- **_jsonClassToken_**: The token used by **Jsonize** to identify a serialized object.
- **_dtClassCode_**: The code used to serialize **DateTime** objects.
- **_dateTimeFormat_**: The **DateTime** serialization format (see **DateTimeFormat** enum).
- **_convertCallback_**: An optional function called before returning the object's encoded json representation.

## fromJson

```dart
  static dynamic fromJson(dynamic value,
      {String? jsonClassToken,
       String? dtClassCode,
       DateTimeFormat? dateTimeFormat,
       CallbackFunction? convertCallback})
```

Transforms a json string back to an object/structure of objects.

#### Parameters:

- **_value_**: the value you want to transform to json string.
- **_jsonClassToken_**: The token used by **Jsonize** to identify a serialized object.
- **_dtClassCode_**: The code used to serialize **DateTime** objects.
- **_dateTimeFormat_**: The **DateTime** serialization format (see **DateTimeFormat** enum).
- **_convertCallback_**: An optional function called before decoding the json representation into the object.

## registerClass

```dart
static void registerClass(Jsonizable object)
```

Registers a new **Jsonizable** class by it instance.

#### Parameters:

- **_object_**: the class instance **jsonize** will be able to serialize.

## registerClasses

```dart
static void registerClasses(Iterable<Jsonizable> objects)
```

Registers new **Jsonizable** classes by it instances.

#### Parameters:

- **_objects_**: the class instances **jsonize** will be able to serialize.

## registerType

```dart
static void registerType(Type classType,
      String classTypeCode,
      ConvertFunction? toJsonFunc,
      ConvertFunction? fromJsonFunc)
```

Registers a new type to the **Jsonize** conversion handling (i.e. used for classes that does not implement **Jsonizable** interface)

#### Parameters:

- **_type_**: the type **jsonize** will be able to serialize.
- **_classTypeCode_**: the class type token **jsonize** will use to identify this object type/class.
- **_toJsonFunc_**: the json encoder function.
- **_fromJsonFunc_**: the json decoder function.

# Jsonize enums

## DateTimeFormat

- **_string_**: a human readable date time string representation.
- **_stringWithMillis_**: a human readable date time string representation with milliseconds.
- **_stringWithMicros_**: a human readable date time string representation with microseconds.
- **_epoch_**: a number representing the seconds since the "Unix epoch" 1970-01-01T00:00:00 (json space saver!).
- **_epochWithMillis_**: a number representing the milliseconds since the "Unix epoch" 1970-01-01T00:00:00.
- **_epochWithMicros_**: a number representing the microseconds since the "Unix epoch" 1970-01-01T00:00:00.

# Additional information

Since current Dart implementation does not really support reflection, **Jsonize** requires what I would define as two extra steps:

1. register all your types/classes you want to serialize
2. In case of implementing the Jsonizable interface, you will need to register a class instance (e.g. factory MyClass.empty() => ...)

I hope future Dart releases will support better reflection and type handling.
