import 'dart:convert';

/// The encode and decode function prototype
///
/// The convertion function convetrs the serializable object instance into a
/// string for [ConvertType.simple] convertion type, or any kind of jsonable
/// type if convertion type is set to [ConvertType.complex].
typedef ConvertFunction = dynamic Function(dynamic object);

/// The [Jsonize] class used to trasform to and from json string
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

  /// Regiters a new type to the [Jsonize] convertion handling
  static void registerType(Type classType, String classTypeCode,
      ConvertFunction? toJsonFunc, ConvertFunction? fromJsonFunc) {
    _encoders[classType] = _ConvertInfo(classTypeCode, toJsonFunc);
    _decoders[classTypeCode] = _ConvertInfo(classTypeCode, fromJsonFunc);
  }

  /// Regiters a new [Jsonizable] class by it instance.
  static void registerClass(Jsonizable object) {
    registerType(
        object.runtimeType, object.jsonClassCode, null, object.fromJson);
  }

  /// Regiters new [Jsonizable] classes by it instances.
  static void registerClasses(Iterable<Jsonizable> objects) {
    for (var object in objects) {
      registerClass(object);
    }
  }

  /// The [toJson] function transforming an object into a json string.
  static dynamic toJson(dynamic value, [String? indent]) {
    JsonEncoder encoder = indent == null
        ? JsonEncoder(Jsonize._toEncodable)
        : JsonEncoder.withIndent(indent, Jsonize._toEncodable);
    return encoder.convert(value);
  }

  /// The [fromJson] function transforming a json string back to an object.
  static dynamic fromJson(dynamic value) {
    return jsonDecode(value, reviver: _reviver);
  }

  /// The encode functions map
  static final Map<Type, _ConvertInfo> _encoders = {
    DateTime:
        _ConvertInfo(DateTimeJsonable.jsonClassCode, DateTimeJsonable.toJson),
  };

  /// The decode functions map
  static final Map<String, _ConvertInfo> _decoders = {
    DateTimeJsonable.jsonClassCode:
        _ConvertInfo(DateTimeJsonable.jsonClassCode, DateTimeJsonable.fromJson),
  };

  /// A convert helper function
  static dynamic _convert(_ConvertInfo info, dynamic object) {
    if (object is Jsonizable) {
      return object.toJson();
    }
    return info.convert(object);
  }

  /// Makes a class token string
  static String _makeClassToken(String classCode) {
    return "$jsonClassToken$classCode";
  }

  /// Gets the class token string if the value reppresents a class token
  static String? _getClassType(dynamic value) {
    if (value is String && value.startsWith(jsonClassToken)) {
      return value.substring(jsonClassToken.length);
    }
    return null;
  }

  /// The [_toEncodable] function used to convert to json string
  static dynamic _toEncodable(dynamic object) {
    // Find the class encoder
    var convertInfo = _encoders[object.runtimeType];
    if (convertInfo != null) {
      return {
        _makeClassToken(convertInfo.jsonClassCode):
            _convert(convertInfo, object)
      };
    }
    return object;
  }

  /// The [_reviver] function used to convert from json string
  static dynamic _reviver(key, value) {
    // Not the final value? (i.e. key == null)
    if (key != null) {
      var classType = _getClassType(key);
      if (classType != null) {
        var convertInfo = _decoders[classType];
        if (convertInfo != null) {
          return convertInfo.convert(value);
        }
      }
    }
    // Complex value? (i.e. incapsulated into the type map)
    if (value is Map && value.keys.first.startsWith(jsonClassToken)) {
      return value.values.first;
    }
    return value;
  }
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

/// The class used to register [DateTime] type serialization
class DateTimeJsonable {
  static String get jsonClassCode => "dt";
  static dynamic toJson(DateTime v) => v.toIso8601String();
  static DateTime? fromJson(dynamic v) => DateTime.tryParse(v.toString());
}

/// Internal class to keep convertion functions
class _ConvertInfo {
  final String jsonClassCode;
  final dynamic convert;
  _ConvertInfo(this.jsonClassCode, this.convert);
}
