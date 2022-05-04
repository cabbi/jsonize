import 'jsonize.dart';

/// The class used to register [DateTime] type serialization
class DateTimeJsonable {
  final String jsonClassCode;
  final DateTimeFormat format;

  DateTimeJsonable({required this.jsonClassCode, required this.format});

  dynamic toJson(DateTime v) {
    switch (format) {
      case DateTimeFormat.string:
        return _toString(v, false);
      case DateTimeFormat.stringWithMillis:
        return _toString(v, true);
      case DateTimeFormat.stringWithMicros:
        return v.toIso8601String();
      case DateTimeFormat.epoch:
        return v.millisecondsSinceEpoch ~/ 1000;
      case DateTimeFormat.epochWithMillis:
        return v.millisecondsSinceEpoch;
      case DateTimeFormat.epochWithMicros:
        return v.microsecondsSinceEpoch;
      default:
        throw JsonizeException("DateTime->toJson: '$format' DateTime format!");
    }
  }

  DateTime? fromJson(dynamic v) {
    switch (format) {
      case DateTimeFormat.string:
      case DateTimeFormat.stringWithMillis:
      case DateTimeFormat.stringWithMicros:
        if (v is String) {
          return DateTime.tryParse(v.toString());
        }
        throw JsonizeException("DateTime->fromJson: String value expected!");
      case DateTimeFormat.epoch:
        if (v is int) {
          return DateTime.fromMillisecondsSinceEpoch(v * 1000, isUtc: false);
        }
        throw JsonizeException("DateTime->fromJson: Integer value expected!");
      case DateTimeFormat.epochWithMillis:
        if (v is int) {
          return DateTime.fromMillisecondsSinceEpoch(v, isUtc: false);
        }
        throw JsonizeException("DateTime->fromJson: Integer value expected!");
      case DateTimeFormat.epochWithMicros:
        if (v is int) {
          return DateTime.fromMicrosecondsSinceEpoch(v, isUtc: false);
        }
        throw JsonizeException("DateTime->fromJson: Integer value expected!");
      default:
        throw JsonizeException(
            "DateTime->fromJson: '$format' DateTime format!)");
    }
  }

  String padDigits(int num, int pad) {
    if (num >= 0) {
      return num.toString().padLeft(pad, "0");
    }
    throw JsonizeException(
        "DateTime->padDigits: DateTime does not handle nevative values!");
  }

  String _toString(DateTime v, bool withMillis) {
    String y = padDigits(v.year, 4);
    String m = padDigits(v.month, 2);
    String d = padDigits(v.day, 2);
    String h = padDigits(v.hour, 2);
    String min = padDigits(v.minute, 2);
    String sec = padDigits(v.second, 2);
    if (withMillis) {
      String ms = padDigits(v.millisecond, 3);
      return "$y-$m-${d}T$h:$min:$sec.$ms";
    }
    return "$y-$m-${d}T$h:$min:$sec";
  }
}

/// Internal class to keep conversion functions
class ConvertInfo {
  final Type classType;
  final String jsonClassCode;
  final dynamic convert;
  ConvertInfo(this.classType, this.jsonClassCode, this.convert);
}

/// The session class used to store conversion parameters like jsonClassToken.
class JsonizeSession {
  final String jsonClassToken;
  final Map<Type, ConvertInfo> _encoders = {};
  final Map<String, ConvertInfo> _decoders = {};
  final CallbackFunction? convertCallback;

  JsonizeSession(
      {String? jsonClassToken,
      String? dtClassCode,
      DateTimeFormat? dateTimeFormat,
      this.convertCallback})
      : jsonClassToken = jsonClassToken ?? Jsonize.jsonClassToken {
    DateTimeJsonable dt = DateTimeJsonable(
        jsonClassCode: dtClassCode ?? "dt",
        format: dateTimeFormat ?? DateTimeFormat.string);

    _encoders.addAll(Jsonize.encoders);
    _encoders[DateTime] = ConvertInfo(DateTime, dt.jsonClassCode, dt.toJson);
    _decoders.addAll(Jsonize.decoders);
    _decoders[dt.jsonClassCode] =
        ConvertInfo(DateTime, dt.jsonClassCode, dt.fromJson);
  }

  /// The [toEncodable] function used to convert to json string
  dynamic toEncodable(dynamic object) {
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

  /// The [reviver] function used to convert from json string
  dynamic reviver(key, value) {
    // Not the final value? (i.e. key == null)
    if (key != null) {
      var classType = _getClassType(key);
      if (classType != null) {
        var convertInfo = _decoders[classType];
        if (convertInfo != null) {
          if (convertCallback != null) {
            value = convertCallback!(convertInfo.classType, value);
          }
          return convertInfo.convert(value);
        }
      }
    }
    // Is it a Jsonize class token?
    if (value is Map &&
        value.length == 1 &&
        value.keys.first.startsWith(jsonClassToken)) {
      return value.values.first;
    }
    return value;
  }

  /// A convert helper function
  dynamic _convert(ConvertInfo info, dynamic object) {
    dynamic jsonObj =
        object is Jsonizable ? object.toJson() : info.convert(object);
    return convertCallback == null
        ? jsonObj
        : convertCallback!(info.classType, jsonObj);
  }

  /// Makes a class token string
  String _makeClassToken(String classCode) {
    return "$jsonClassToken$classCode";
  }

  /// Gets the class token string if the value represents a class token
  String? _getClassType(dynamic value) {
    if (value is String && value.startsWith(jsonClassToken)) {
      return value.substring(jsonClassToken.length);
    }
    return null;
  }
}
