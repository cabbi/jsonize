import 'package:jsonize/jsonize.dart';

/// Internal class to keep conversion functions
class ConvertInfo {
  final Type classType;
  final String jsonClassCode;
  final dynamic convert;
  final Jsonizable? emptyObj; // Null if registering a type
  ConvertInfo(this.classType, this.jsonClassCode, this.convert,
      [this.emptyObj]);

  dynamic toJson(
      dynamic object, CallbackFunction? convertCallback, dynamic exParam) {
    dynamic jsonObj = object is ClonableEx
        ? object.toJsonEx(exParam)
        : object is Jsonizable
            ? object.toJson()
            : convert(object);
    return convertCallback == null
        ? jsonObj
        : convertCallback(
            classType, jsonObj, object is Jsonizable ? object : null);
  }

  dynamic fromJson(
      dynamic value, CallbackFunction? convertCallback, dynamic exParam) {
    if (convertCallback != null) {
      value = convertCallback(classType, value, emptyObj);
    }
    return emptyObj is ClonableAsync
        ? (emptyObj as ClonableAsync).fromJsonAsync(value, exParam)
        : emptyObj is ClonableEx
            ? (emptyObj as ClonableEx).fromJsonEx(value, exParam)
            : emptyObj is Jsonizable
                ? (emptyObj as Jsonizable).fromJson(value)
                : convert(value);
  }
}
