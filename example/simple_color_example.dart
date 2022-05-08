import 'package:jsonize/jsonize.dart';

class ColorItem extends Clonable<ColorItem> {
  String name;
  int r, g, b;
  ColorItem(this.name, this.r, this.g, this.b);
  factory ColorItem.empty() => ColorItem("", 0, 0, 0);

  @override
  String toString() => "$name - $r.$g.$b";

  // Clonable implementation
  @override
  String get jsonClassCode => "colItem";

  @override
  ColorItem empty() => ColorItem.empty();

  @override
  CloneFields get fields => CloneFields([
        CloneField(name: "name", getter: () => name, setter: (v) => name = v),
        CloneField(
            name: "r", getter: () => r, setter: (v) => r = v, defaultValue: 0),
        CloneField(
            name: "g", getter: () => g, setter: (v) => g = v, defaultValue: 0),
        CloneField(
            name: "b", getter: () => b, setter: (v) => b = v, defaultValue: 0)
      ]);
}

void main() {
  // Register classes
  Jsonize.registerClass(ColorItem.empty());

  List myList = [
    ColorItem("Red", 255, 0, 0),
    ColorItem("Blue", 0, 0, 255),
    ColorItem("Gray", 128, 128, 128)
  ];

  // Zeros will not be serialized since they are defined as default value.
  // This way you might save json data storage space.
  var jsonRep = Jsonize.toJson(myList,
      jsonClassToken: "!", dateTimeFormat: DateTimeFormat.epoch);
  var backToLife = Jsonize.fromJson(jsonRep,
      jsonClassToken: "!", dateTimeFormat: DateTimeFormat.epoch);
  print(backToLife);
}
