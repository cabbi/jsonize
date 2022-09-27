import 'dart:convert';

import 'package:jsonize/jsonize.dart';
import 'package:http/http.dart' as http;

/// An async clonable example (not really meaningfully)
class TextItem extends ClonableAsync<TextItem> {
  String get cText => "fText";

  final String fixedText;
  final String retrievalText;
  final DateTime retrievalTime;

  TextItem(this.fixedText)
      : retrievalText = "",
        retrievalTime = DateTime(0);
  TextItem._(this.fixedText, this.retrievalText, this.retrievalTime);
  factory TextItem.empty() => TextItem("");

  /// Gets the current UTC time from internet
  Future<DateTime> exactDateTime() async {
    final response = await http.get(
        Uri.parse('https://timeapi.io/api/Time/current/zone?timeZone=utc'));

    if (response.statusCode == 200) {
      return DateTime.parse(jsonDecode(response.body)["dateTime"]);
    } else {
      throw Exception('Failed to get time from internet!');
    }
  }

  @override
  String toString() => "[$retrievalTime] $fixedText ($retrievalText)";

  // Clonable implementation
  @override
  String get jsonClassCode => "item";

  @override
  Future<TextItem> createAsync(json, [dynamic exParam]) async {
    return TextItem._(json[cText], exParam, await exactDateTime());
  }

  @override
  CloneFields get fields =>
      CloneFields([CloneField(cText, getter: () => fixedText)]);
}

void main() async {
  // Register classes
  Jsonize.registerClass(TextItem.empty());

  var myItem = {
    "myItem": TextItem(
        "A simple example where Jsonize should wait an async response!")
  };

  var jsonRep = Jsonize.toJson(myItem);
  var backToLife = await Jsonize.fromJson(jsonRep,
      exParam: "here is an extra runtime parameter!", awaitNestedFutures: true);
  print(backToLife);
}
