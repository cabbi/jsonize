import 'package:jsonize/jsonize.dart';

/// Internal class to keep conversion functions
class ConvertInfo {
  final Type classType;
  final String jsonClassCode;
  final dynamic convert;
  final Jsonizable? emptyObj; // Null if registering a type
  ConvertInfo(this.classType, this.jsonClassCode, this.convert,
      [this.emptyObj]);
}
