import 'package:jsonize/jsonize.dart';
import 'package:jsonize/src/helpers/duration_jsonable.dart';

import 'convert_info.dart';
import 'datetime_jsonable.dart';

/// The session class used to store conversion parameters like jsonClassToken.
class JsonizeSession {
  final String jsonClassToken;
  final Map<String, ConvertInfo> _encoders = {};
  final Map<String, ConvertInfo> _decoders = {};
  final CallbackFunction? convertCallback;

  JsonizeSession(
      {String? jsonClassToken,
      String? dtClassCode,
      DateTimeFormat? dateTimeFormat,
      String? durationClassCode,
      DurationFormat? durationFormat,
      this.convertCallback})
      : jsonClassToken = jsonClassToken ?? Jsonize.jsonClassToken {
    var dt = DateTimeJsonable(
        jsonClassCode: dtClassCode ?? "dt",
        format: dateTimeFormat ?? DateTimeFormat.string);
    var duration = DurationJsonable(
        jsonClassCode: durationClassCode ?? "dr",
        format: durationFormat ?? DurationFormat.microseconds);

    _encoders.addAll(Jsonize.encoders);
    _encoders[Jsonize.getClassName(DateTime)] =
        ConvertInfo(DateTime, dt.jsonClassCode, dt.toJson);
    _encoders[Jsonize.getClassName(Duration)] =
        ConvertInfo(Duration, duration.jsonClassCode, duration.toJson);
    _decoders.addAll(Jsonize.decoders);
    _decoders[dt.jsonClassCode] =
        ConvertInfo(DateTime, dt.jsonClassCode, dt.fromJson);
    _decoders[duration.jsonClassCode] =
        ConvertInfo(Duration, duration.jsonClassCode, duration.fromJson);
  }

  /// The [toEncodable] function used to convert to json string
  dynamic toEncodable(dynamic object) {
    // Find the class encoder
    var convertInfo = _encoders[Jsonize.getClassName(object.runtimeType)];
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
            value = convertCallback!(
                convertInfo.classType, value, convertInfo.emptyObj);
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
        : convertCallback!(
            info.classType, jsonObj, object is Jsonizable ? object : null);
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
