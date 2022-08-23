import 'package:jsonize/jsonize.dart';

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
        throw JsonizeException(
            "DateTimeJsonable", "toJson: '$format' DateTime format!");
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
        throw JsonizeException(
            "DateTimeJsonable", "fromJson: String value expected!");
      case DateTimeFormat.epoch:
        if (v is int) {
          return DateTime.fromMillisecondsSinceEpoch(v * 1000, isUtc: false);
        }
        throw JsonizeException(
            "DateTimeJsonable", "fromJson: Integer value expected!");
      case DateTimeFormat.epochWithMillis:
        if (v is int) {
          return DateTime.fromMillisecondsSinceEpoch(v, isUtc: false);
        }
        throw JsonizeException(
            "DateTimeJsonable", "fromJson: Integer value expected!");
      case DateTimeFormat.epochWithMicros:
        if (v is int) {
          return DateTime.fromMicrosecondsSinceEpoch(v, isUtc: false);
        }
        throw JsonizeException(
            "DateTimeJsonable", "fromJson: Integer value expected!");
      default:
        throw JsonizeException(
            "DateTimeJsonable", "fromJson: '$format' DateTime format!)");
    }
  }

  String padDigits(int num, int pad) {
    if (num >= 0) {
      return num.toString().padLeft(pad, "0");
    }
    throw JsonizeException("DateTimeJsonable",
        "padDigits: DateTime does not handle nevative values!");
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
