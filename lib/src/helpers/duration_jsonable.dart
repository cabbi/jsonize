import 'package:jsonize/jsonize.dart';

/// The class used to register [Duration] type serialization
class DurationJsonable {
  final String jsonClassCode;
  final DurationFormat format;

  DurationJsonable({required this.jsonClassCode, required this.format});

  int toJson(Duration v) {
    switch (format) {
      case DurationFormat.microseconds:
        return v.inMicroseconds;
      case DurationFormat.milliseconds:
        return v.inMilliseconds;
      case DurationFormat.seconds:
        return v.inSeconds;
      case DurationFormat.minutes:
        return v.inMinutes;
      case DurationFormat.hours:
        return v.inHours;
      case DurationFormat.days:
        return v.inDays;
      default:
        throw JsonizeException(
            "DurationJsonable", "toJson: '$format' Duration format!");
    }
  }

  Duration? fromJson(dynamic v) {
    if (v is! int) {
      throw JsonizeException(
          "DurationJsonable", "fromJson: Integer value expected!");
    }
    switch (format) {
      case DurationFormat.microseconds:
        return Duration(microseconds: v);
      case DurationFormat.milliseconds:
        return Duration(milliseconds: v);
      case DurationFormat.seconds:
        return Duration(seconds: v);
      case DurationFormat.minutes:
        return Duration(minutes: v);
      case DurationFormat.hours:
        return Duration(hours: v);
      case DurationFormat.days:
        return Duration(days: v);
      default:
        throw JsonizeException(
            "DurationJsonable", "fromJson: '$format' Duration format!)");
    }
  }
}
