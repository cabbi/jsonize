import 'package:jsonize/jsonize.dart';

class ColorItem extends Clonable<ColorItem> {
  final String name;
  int r, g, b;
  ColorItem(this.name, {this.r = 0, this.g = 0, this.b = 0});
  factory ColorItem.empty() => ColorItem("");

  @override
  String toString() => "$name - $r.$g.$b";

  // Clonable implementation
  @override
  String get jsonClassCode => "colItem";

  @override
  ColorItem create(json) => ColorItem(json["name"]);

  @override
  CloneFields get fields => CloneFields([
        CloneField("name", getter: () => name, setter: (_) {}),
        CloneField("r", getter: () => r, setter: (v) => r = v, defaultValue: 0),
        CloneField("g", getter: () => g, setter: (v) => g = v, defaultValue: 0),
        CloneField("b", getter: () => b, setter: (v) => b = v, defaultValue: 0)
      ]);
}

class ComplexObj extends Clonable<ComplexObj> {
  Map<String, ColorItem> colors;
  String name;

  ComplexObj({this.name = "", List<ColorItem>? colors})
      : colors = {for (var c in colors ?? []) c.name: c};
  factory ComplexObj.empty() => ComplexObj();

  @override
  String get jsonClassCode => "CmpxObj";

  @override
  ComplexObj create(Map<String, dynamic> json) => ComplexObj();

  @override
  CloneFields<CloneField> get fields => CloneFields([
        CloneField(
          "name",
          getter: () => name,
          setter: (value) => name = value,
        ),
        CloneField("colors",
            getter: () => colors,
            setter: (value) =>
                colors.addAll(Map<String, ColorItem>.from(value))),
      ]);
}

void main() {
  // Register classes
  Jsonize.registerClass(ColorItem.empty());
  Jsonize.registerClass(ComplexObj.empty());

  List<ColorItem> myList = [
    ColorItem("Red", r: 255),
    ColorItem("Blue", b: 255),
    ColorItem("Gray", r: 128, g: 128, b: 128)
  ];

  // Zeros will not be serialized since they are defined as default value.
  // This way you might save json data storage space.
  var jsonRep = Jsonize.toJson(myList);
  var backToLife = Jsonize.fromJson(jsonRep);
  print(backToLife);

  var complex1 = ComplexObj(name: "First", colors: myList);
  var complex2 = complex1.clone(deep: true);
  complex1.colors["Red"]!.g = 128;
  print(complex2.colors);
}
