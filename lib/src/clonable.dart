library clonable;

import 'dart:collection';

import 'package:jsonize/jsonize.dart';

part 'clonable_ex.dart';
part 'clonable_async.dart';

/// The [ClonableBaseInterface] definition
abstract class ClonableBaseInterface<T> implements Jsonizable<T> {
  CloneFields get fields;
  void setMap(Map json);
  void getMap(Map json);
}

/// The [ClonableInterface] definition
abstract class ClonableInterface<T> implements ClonableBaseInterface<T> {
  void beforeEncode(Map<String, dynamic> json);
  void afterEncode(Map<String, dynamic> json);
  void beforeDecode(Map<String, dynamic> json);
  void afterDecode(Map<String, dynamic> json);
}

/// The [Clonable] class used to clone and serialize objects.
abstract class Clonable<T extends Object>
    with ClonableBaseMixin<T>, ClonableMixin<T> {}

/// The [ClonableBaseMixin] mixin class used to clone and serialize objects.
mixin ClonableBaseMixin<T extends Object> implements ClonableBaseInterface<T> {
  /// Sets the [json] map values for this instance.
  @override
  void setMap(Map json) {
    for (var field in fields) {
      var obj = json[field.name];
      if (obj is CloneField) {
        obj = obj.value;
      }
      field.value = obj ?? field.defaultValue;
    }
  }

  /// Gets the [json] map values for this instance.
  @override
  void getMap(Map json) {
    for (CloneField field in fields) {
      // Avoid storing default value
      var value = field.value;
      if (value != field.defaultValue) {
        json[field.name] = value;
      }
    }
  }
}

/// The [ClonableMixin] mixin class used to clone and serialize objects.
mixin ClonableMixin<T extends Object> implements ClonableInterface<T> {
  /// Creates an empty object. [json] map is provided in case of 'final' fields
  /// needed within the class constructor. In that case the [CloneField]
  /// definition might have an empty setter
  T create(Map<String, dynamic> json);

  // ========== Clonable events ==========

  /// Raised before the [json] map is filled with the object [fields]
  @override
  void beforeEncode(Map<String, dynamic> json) {}

  /// Raised after the [json] map is filled with the object [fields]
  @override
  void afterEncode(Map<String, dynamic> json) {}

  /// Raised before this object fields are set with the [json] map
  @override
  void beforeDecode(Map<String, dynamic> json) {}

  /// Raised after this object fields are set with the [json] map
  @override
  void afterDecode(Map<String, dynamic> json) {}

  // ========== Clonable implementation ==========

  /// Creates an [obj] clone.
  static Clonable clone(Clonable obj) =>
      ((obj.create(obj.fields._map) as Clonable)..setMap(obj.fields._map));

  // ========== [Jsonizable] implementation ==========

  @override
  dynamic toJson() {
    Map<String, dynamic> json = {};
    beforeEncode(json);
    getMap(json);
    afterEncode(json);
    return json;
  }

  @override
  T? fromJson(json) {
    ClonableInterface obj = create(json) as ClonableInterface;
    obj.beforeDecode(json);
    obj.setMap(json);
    obj.afterDecode(json);
    return obj as T;
  }
}

/// The [CloneField] getter callback function prototype
typedef CloneGetterFunction = dynamic Function();

/// The [CloneField] setter callback function prototype
typedef CloneSetterFunction = void Function(dynamic value);

/// The [CloneField] class implementation
///
/// A field is a [Clonable] object's attribute used to clone and serialize it.
class CloneField<T> {
  /// The field name
  final String name;

  /// Gets the field value.
  late CloneGetterFunction getter;

  /// Setter (sets the field value)
  late CloneSetterFunction setter;

  /// The default value. If not null this value is used to save space within
  /// the json structure (i.e. if the value equals the defaultValue the field
  /// is not stored within the resulting json structure).
  T? defaultValue;

  /// The [CloneField] constructor
  ///
  /// Note: need to set 'getter' and 'setter' as late since some functions might
  ///       not be const and are not definable within the constructor parameters
  CloneField(this.name,
      {CloneGetterFunction? getter,
      CloneSetterFunction? setter,
      this.defaultValue}) {
    this.getter = getter ?? () => null;
    this.setter = setter ?? (_) {};
  }

  /// True if the filed holds a nullable type
  bool get isNullable => null is T;

  T get value => getter();
  set value(T v) => setter(v);

  @override
  bool operator ==(Object other) => other is CloneField && other.name == name;

  @override
  int get hashCode => 293645 + name.hashCode;
}

/// The [CloneField] collection
class CloneFields<T extends CloneField> extends IterableBase<T> {
  final Map<String, T> _map = {};

  CloneFields([Iterable<T>? list]) {
    addAll(list ?? []);
  }

  @override
  Iterator<T> get iterator => _map.values.iterator;

  // ========== Some utility methods ==========

  T? operator [](String key) => _map[key];

  void operator []=(String key, T value) => _map[key] = value;

  void add(T field) => _map[field.name] = field;

  void addAll(Iterable<T> fields) {
    for (T field in fields) {
      _map[field.name] = field;
    }
  }

  void clear() => _map.clear();

  CloneField? remove(Object? key) => _map.remove(key);

  Iterable<String> get keys => _map.keys;

  Iterable<CloneField> get fields => _map.values;

  Iterable<MapEntry<String, CloneField<dynamic>>> get entries => _map.entries;
}
