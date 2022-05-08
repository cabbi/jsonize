import 'dart:collection';

import 'package:jsonize/jsonize.dart';

/// The [Clonable] class used to clone and serialize objects.
///
/// The Clonable type cannot be a nullable type.
abstract class Clonable<T extends Object> implements Jsonizable<T> {
  // ========== Clonable interface ==========

  /// The object fields collection
  CloneFields get fields;

  /// Creates an empty object
  T empty();

  // ========== Clonable implementation ==========

  /// Creates an [obj] clone.
  static Clonable clone(Clonable obj) =>
      ((obj.empty() as Clonable)..setMap(obj.fields._map));

  /// Sets the map values for this instance.
  void setMap(Map map) {
    for (var field in fields) {
      var obj = map[field.name];
      if (obj is CloneField) {
        obj = obj.value;
      }
      field.value = obj ?? field.defaultValue;
    }
  }

  // ========== [Jsonizable] implementation ==========

  @override
  dynamic toJson() {
    Map<String, dynamic> map = {};
    for (CloneField field in fields) {
      // Avoid storing default value
      var value = field.value;
      if (value != field.defaultValue) {
        map[field.name] = value;
      }
    }
    return map;
  }

  @override
  T? fromJson(value) {
    Clonable obj = empty() as Clonable;
    return (obj..setMap(value)) as T;
  }
}

/// The [CloneField] getter callback function prototype
typedef CloneGetterFunction = dynamic Function();

/// The [CloneField] setter callback function prototype
typedef CloneSetterFunction = void Function(dynamic value);

/// The [CloneField] class implementation
///
/// A field is a [Clonable] object attribute used to clone and serialize it.
class CloneField<T> {
  /// The field name
  final String name;

  /// Gets the field value
  final CloneGetterFunction getter;

  /// Setter (sets the field value
  final CloneSetterFunction setter;

  /// The default value. If not null this value is used to save space within
  /// the json structure (i.e. if the value equals the defaultValue the field
  /// is not stored within the resulting json structure).
  T? defaultValue;

  /// The [CloneField] constructor
  CloneField(
      {required this.name,
      required this.getter,
      required this.setter,
      this.defaultValue});

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
