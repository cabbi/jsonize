import 'dart:convert';

import 'helpers.dart';

/// The encode and decode function prototype
typedef ConvertFunction = dynamic Function(dynamic object);

/// The [DateTime] serialization format
///
/// - [string] a human readable date time string representation
/// - [stringWithMillis] a human readable date time string representation
///   with milliseconds
/// - [stringWithMicros] a human readable date time string representation
///   with microseconds
/// - [epoch] a number representing the seconds since the "Unix epoch"
///   1970-01-01T00:00:00Z (json space safer!)
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

  /// Registers a new type to the [Jsonize] conversion handling
  static void registerType(Type classType, String classTypeCode,
      ConvertFunction? toJsonFunc, ConvertFunction? fromJsonFunc) {
    // Some checks on already registered types/classes
    if (encoders.containsKey(classType) &&
        encoders[classType]!.jsonClassCode != classTypeCode) {
      throw JsonizeException(
          "Class type '$classType' has already being registred with a different"
          " token! [${encoders[classType]!.jsonClassCode} != $classTypeCode]");
    }
    if (decoders.containsKey(classTypeCode) &&
        decoders[classTypeCode]!.classType != classType) {
      throw JsonizeException(
          "Class code '$classTypeCode' has already being registred with a"
          " different class! [${decoders[classTypeCode]!.classType}"
          " != $classType]");
    }
    encoders[classType] = ConvertInfo(classType, classTypeCode, toJsonFunc);
    decoders[classTypeCode] =
        ConvertInfo(classType, classTypeCode, fromJsonFunc);
  }

  /// Registers a new [Jsonizable] class by it instance.
  static void registerClass(Jsonizable object) {
    registerType(
        object.runtimeType, object.jsonClassCode, null, object.fromJson);
  }

  /// Registers new [Jsonizable] classes by it instances.
  static void registerClasses(Iterable<Jsonizable> objects) {
    for (var object in objects) {
      registerClass(object);
    }
  }

  /// The [toJson] function transforms an object into a json string.
  static String toJson(dynamic value,
      {String? indent,
      String? jsonClassToken,
      String? dtClassCode,
      DateTimeFormat? dateTimeFormat}) {
    // Create a new session with requested parameters
    JsonizeSession session = JsonizeSession(
        jsonClassToken: jsonClassToken,
        dtClassCode: dtClassCode,
        dateTimeFormat: dateTimeFormat);
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
      DateTimeFormat? dateTimeFormat}) {
    // Create a new session with requested parameters
    JsonizeSession session = JsonizeSession(
        jsonClassToken: jsonClassToken,
        dtClassCode: dtClassCode,
        dateTimeFormat: dateTimeFormat);
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

/// The [Jsonize] package exception class
class JsonizeException implements Exception {
  final String msg;
  const JsonizeException(this.msg);
  @override
  String toString() => '[Jsonize] $msg';
}
