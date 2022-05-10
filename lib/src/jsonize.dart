import 'dart:convert';

import '../jsonize.dart';
import 'helpers.dart';

/// The encode and decode function prototype
typedef ConvertFunction = dynamic Function(dynamic);

/// The encode and decode callback function prototype
///
/// This callback provides:
/// - [type] of the serializing object
/// - [json] representation of the serializing object
/// - the [Jsonizable] or [Clonable] object [obj] to be encoded to json or the
///   empty object during decoding from json.
///   NOTE: [obj] is null if 'registerType' has been used
typedef CallbackFunction = dynamic Function(
    Type type, dynamic json, Jsonizable? obj);

/// The [DateTime] serialization format
///
/// - [string] a human readable date time string representation
/// - [stringWithMillis] a human readable date time string representation
///   with milliseconds
/// - [stringWithMicros] a human readable date time string representation
///   with microseconds
/// - [epoch] a number representing the seconds since the "Unix epoch"
///   1970-01-01T00:00:00Z (json space saver!)
/// - [epochWithMillis] a number representing the milliseconds since the
///   "Unix epoch" 1970-01-01T00:00:00Z
/// - [epochWithMicros] a number representing the microseconds since the
///   "Unix epoch" 1970-01-01T00:00:00Z
enum DateTimeFormat {
  string,
  stringWithMillis,
  stringWithMicros,
  epoch,
  epochWithMillis,
  epochWithMicros
}

/// The [Enum] serialization format
///
/// - [string] the text of the enum item
/// - [indexOf] the index of the enum item
///
/// Both formats have pro & cons.
/// [string]
/// - it is space consuming since it's the text of the item
/// - you can not change the item text
/// - you can add new items without warring about its position
/// [indexOf]
/// - it saves space since it is only a number
/// - you can change the item text
/// - you can not add new items without warring about its position
///
enum EnumFormat { string, indexOf }

/// The [Jsonize] class used to transform to and from json string
class Jsonize {
  /// The class token (you can change this token at runtime)
  ///
  /// Example:
  /// ```dart
  /// {
  ///   "jt#MyClass":
  ///     {"filed_1": 123.45
  ///      "filed_2": {"jt#dt": "2022-04-15T11:09:39.714875"}
  ///      "filed_3": "my instance data"}
  /// }
  /// ```
  static String jsonClassToken = "jt#";

  /// Registers a new [Enum] type.
  static void registerEnum<T>(List<T> values,
      {String? jsonEnumCode, EnumFormat enumFormat = EnumFormat.string}) {
    Type type = values.first.runtimeType;
    jsonEnumCode = jsonEnumCode ?? "e#$type";
    if (enumFormat == EnumFormat.string) {
      Jsonize.registerType(type, jsonEnumCode, (o) => _enumToString(o),
          (o) => values.singleWhere((i) => o == _enumToString(i)));
    } else {
      Jsonize.registerType(
          type, jsonEnumCode, (o) => values.indexOf(o), (o) => values[o]);
    }
  }

  /// Converts an enum item into a string
  static String _enumToString(dynamic o) => o.toString().split(".")[1];

  /// Registers a new type to the [Jsonize] conversion handling.
  static void registerType(Type classType, String classTypeCode,
      ConvertFunction? toJsonFunc, ConvertFunction? fromJsonFunc) {
    _register(classType, classTypeCode, toJsonFunc, fromJsonFunc);
  }

  /// Registers a new [Jsonizable] class by it instance.
  static void registerClass(Jsonizable object) {
    _register(object.runtimeType, object.jsonClassCode, null, object.fromJson,
        object);
  }

  /// Registers new [Jsonizable] classes by it instances.
  static void registerClasses(Iterable<Jsonizable> objects) {
    for (var object in objects) {
      registerClass(object);
    }
  }

  /// The common register method
  static void _register(Type classType, String classTypeCode,
      ConvertFunction? toJsonFunc, ConvertFunction? fromJsonFunc,
      [Jsonizable? emptyObj]) {
    // Some checks on already registered types/classes
    if (encoders.containsKey(classType) &&
        encoders[classType]!.jsonClassCode != classTypeCode) {
      throw JsonizeException(
          "registerType",
          "Class type '$classType' has already being registered with a"
              " different token! [${encoders[classType]!.jsonClassCode}"
              " != $classTypeCode]");
    }
    if (decoders.containsKey(classTypeCode) &&
        decoders[classTypeCode]!.classType != classType) {
      throw JsonizeException(
          "registerType",
          "Class code '$classTypeCode' has already being registered with a"
              " different class! [${decoders[classTypeCode]!.classType}"
              " != $classType]");
    }
    encoders[classType] =
        ConvertInfo(classType, classTypeCode, toJsonFunc, emptyObj);
    decoders[classTypeCode] =
        ConvertInfo(classType, classTypeCode, fromJsonFunc, emptyObj);
  }

  /// The [toJson] function transforms an object into a json string.
  static String toJson(dynamic value,
      {String? indent,
      String? jsonClassToken,
      String? dtClassCode,
      DateTimeFormat dateTimeFormat = DateTimeFormat.string,
      CallbackFunction? convertCallback}) {
    // Create a new session with requested parameters
    JsonizeSession session = JsonizeSession(
        jsonClassToken: jsonClassToken,
        dtClassCode: dtClassCode,
        dateTimeFormat: dateTimeFormat,
        convertCallback: convertCallback);
    // Encode with the current session settings
    JsonEncoder encoder = indent == null
        ? JsonEncoder(session.toEncodable)
        : JsonEncoder.withIndent(indent, session.toEncodable);
    return encoder.convert(value);
  }

  /// The [fromJson] function transforms a json string back to an object.
  static dynamic fromJson(dynamic value,
      {String? jsonClassToken,
      String? dtClassCode,
      DateTimeFormat dateTimeFormat = DateTimeFormat.string,
      CallbackFunction? convertCallback}) {
    // Create a new session with requested parameters
    JsonizeSession session = JsonizeSession(
        jsonClassToken: jsonClassToken,
        dtClassCode: dtClassCode,
        dateTimeFormat: dateTimeFormat,
        convertCallback: convertCallback);
    // Decode with the current session settings
    return jsonDecode(value, reviver: session.reviver);
  }

  /// The encode functions map
  static final Map<Type, ConvertInfo> encoders = {};

  /// The decode functions map
  static final Map<String, ConvertInfo> decoders = {};
}

/// The interface to create a [Jsonizable] class you can register
/// via an object instance using [Jsonize.registerClass].
///
/// Example:
/// ```dart
/// class MyClass implements Jsonizable<MyClass> {
///   String? str;
///   MyClass([this.str]);
///   factory MyClass.empty() => MyClass();
///
///   @override
///   String get jsonClassCode => "mc";
///   @override
///   dynamic toJson() => str;
///   @override
///   MyClass? fromJson(value) => MyClass(value);
/// }
///
/// Jsonize.registerClass(MyClass.empty());
/// ```
abstract class Jsonizable<T> {
  String get jsonClassCode;
  dynamic toJson();
  T? fromJson(dynamic value);
}
