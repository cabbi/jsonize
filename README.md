A JSON serialize class to convert 'to' and 'from' JSON format **Enums**, **DateTime**, **Duration** and any of your own classes.

# Introduction

**Jsonize** solves the problem of serializing and deserializing in JSON format objects into undefined structures.<br>
This package does not implement the 'toJson' and 'fromJson' methods for you. For that you can use one of the many available packages like [json_serializable](https://pub.dev/packages/json_serializable).

# Usage

By default **Jsonize** supports **Enums**, **DateTime** and **Duration** serialization in any place of your data structure.

```dart
import 'package:jsonize/jsonize.dart';

enum Color { red, blue, green, gray, yellow }

void main() {
  Jsonize.registerEnum(Color.values);

  List<dynamic> myList = [1, "Hello!", Color.blue, DateTime.now(), Duration(seconds: 30)];

  var jsonRep = Jsonize.toJson(myList);
  var myDeserializedList = Jsonize.fromJson(jsonRep);
  print(myDeserializedList);
}
```

**Jsonize** also supports your own classes. You can register a type or let your class implement one of the **Jsonizable** or **Clonable** interfaces for classes and **JsonizableEnum** interface for keeping Enum serialization safe.

```dart
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
```

The **Clonable** interface is more compact, you only have to define fields of your object. An advantage of defining fields is that you can define optional default values which will not be set into the final JSON representation in order to save space.<br>
Since it has to set object variables after creation you might not define them as 'final'. 
In case of 'final' members you can call the class constructor using the 'json' parameter within the 'create' method.<br>
The **Clonable** interface has the 'before' and 'after' encoding and decoding events you can override to customize as you wish.<br>

``` dart
import 'package:jsonize/jsonize.dart';

class ColorItem extends Clonable<ColorItem> {
  final String name;
  int r, g, b;
  ColorItem(this.name, {this.r = 0, this.g = 0, this.b = 0});
  factory ColorItem.empty() => ColorItem("");

  @override
  String toString() => "$name - $r.$g.$b";

  // Clonable implementation
  @override
  String get jsonClassCode => "colItem";

  @override
  ColorItem create(json) => ColorItem(json["name"]);

  @override
  CloneFields get fields => CloneFields([
        CloneField("name", getter: () => name, setter: (_) {}),
        CloneField("r", getter: () => r, setter: (v) => r = v, defaultValue: 0),
        CloneField("g", getter: () => g, setter: (v) => g = v, defaultValue: 0),
        CloneField("b", getter: () => b, setter: (v) => b = v, defaultValue: 0)
      ]);
}

void main() {
  // Register classes
  Jsonize.registerClass(ColorItem.empty());

  List myList = [
    ColorItem("Red", r: 255),
    ColorItem("Blue", b: 255),
    ColorItem("Gray", r: 128, g: 128, b: 128)
  ];

  // Zeros will not be serialized since they are defined as default value.
  // This way you might save json data storage space.
  var jsonRep = Jsonize.toJson(myList);
  var backToLife = Jsonize.fromJson(jsonRep);
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
       DateTimeFormat dateTimeFormat = DateTimeFormat.string,
       CallbackFunction? convertCallback})
```

Transforms an object/structure of objects into a JSON string applying the class tokens in order to revert back your original objects.

#### Parameters:
- **_value_**: the value you want to transform to JSON string.
- **_indent_**: The indentation token. If omitted no indentation is used (space saving!).
- **_jsonClassToken_**: The token used by **Jsonize** to identify a serialized object.
- **_dtClassCode_**: The code used to serialize **DateTime** objects.
- **_dateTimeFormat_**: The **DateTime** serialization format (see **DateTimeFormat** enum).
- **_convertCallback_**: An optional function called before returning the object's encoded JSON representation.

## fromJson
```dart
  static dynamic fromJson(dynamic value,
      {String? jsonClassToken,
       String? dtClassCode,
       DateTimeFormat dateTimeFormat = DateTimeFormat.string,
       CallbackFunction? convertCallback})
```

Transforms a JSON string back to an object/structure of objects.

#### Parameters:
- **_value_**: the value you want to transform to JSON string.
- **_jsonClassToken_**: The token used by **Jsonize** to identify a serialized object.
- **_dtClassCode_**: The code used to serialize **DateTime** objects.
- **_dateTimeFormat_**: The **DateTime** serialization format (see **DateTimeFormat** enum).
- **_convertCallback_**: An optional function called before decoding the JSON representation into the object.

## registerEnum
```dart
  static void registerEnum<T>(List<T> values,
      {String? jsonEnumCode, 
      EnumFormat enumFormat = EnumFormat.string,
      Enum? unknownEnumValue}) {
```

Registers a new **Enum** type.

#### Parameters:
- **_values_**: The values of the enumeration type (i.e. myEnum.values).
- **_jsonEnumCode_**: An optional code used to serialize these **Enum** items. If not provided the Enum name will be taken.
- **_enumFormat_**: The serialization format (see **EnumFormat**).
- **_unknownEnumValue_**: This optional parameter is used during decoding in case of an unrecognized value. This can happen if an old json holds a removed enum.
  Note: 'unknownEnumValue' is not applicable to 'EnumFormat.indexOf'

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
- **_toJsonFunc_**: the JSON encoder function.
- **_fromJsonFunc_**: the JSON decoder function.

# Jsonize enums

## DateTimeFormat
- **_string_**: a human readable date time string representation.
- **_stringWithMillis_**: a human readable date time string representation with milliseconds.
- **_stringWithMicros_**: a human readable date time string representation with microseconds.
- **_epoch_**: a number representing the seconds since the "Unix epoch" 1970-01-01T00:00:00 (JSON space saver!).
- **_epochWithMillis_**: a number representing the milliseconds since the "Unix epoch" 1970-01-01T00:00:00.
- **_epochWithMicros_**: a number representing the microseconds since the "Unix epoch" 1970-01-01T00:00:00.

## EnumFormat
- **_string_**: the text of the enum item.
- **_indexOf_**: the index of the enum item.

Both formats have pro & cons.

### string
- it is space consuming since it's the text of the item
- you can not change the item text
- you can add new items without warring about its position

### indexOf
- it saves space since it is only a number
- you can change the item text
- you can not add new items without warring about its position

# Additional information

Since current Dart implementation does not really support reflection, **Jsonize** requires what I would define as two extra steps:

1. register all your types/classes you want to serialize
2. In case of implementing the Jsonizable interface, you will need to register a class instance (e.g. factory MyClass.empty() => ...)

I hope future Dart releases will support better reflection and type handling.
