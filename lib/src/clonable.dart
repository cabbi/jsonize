library clonable;

import 'dart:collection';

import 'package:jsonize/jsonize.dart';

part 'clonable_ex.dart';
part 'clonable_async.dart';

/// The [ClonableBaseInterface] definition
abstract class ClonableBaseInterface<T> implements Jsonizable<T> {
  CloneFields get fields;

  /// Sets the [json] map values for this instance.
  void setMap(Map json, {bool deep = false});

  /// Gets the [json] map values for this instance.
  void getMap(Map json);

  /// Creates an [obj] clone.
  ///
  /// If [deep] is true it will perform a deep/recursive clone
  /// (i.e. clones filed values in case they are clonable objects)
  T clone({bool deep = false});

  /// Sets this object as a copy of [obj]
  ///
  /// If [deep] is true it will perform a deep/recursive set
  /// (i.e. clones filed values in case they are clonable objects)
  void set(ClonableBaseInterface<T> obj, {bool deep = false});
}

/// The [ClonableInterface] definition
abstract class ClonableInterface<T> implements ClonableBaseInterface<T> {
  void beforeEncode(Map<String, dynamic> json);
  void afterEncode(Map<String, dynamic> json);
  void beforeDecode(Map<String, dynamic> json);
  void afterDecode(Map<String, dynamic> json);
}

/// The [Clonable] class used to clone and serialize objects.
abstract class Clonable<T> with ClonableBaseMixin<T>, ClonableMixin<T> {}

dynamic _getFieldObj(
    {required Map json, required CloneField field, required bool deep}) {
  var obj = json[field.name];
  if (obj is CloneField) {
    obj = obj.value;
  }
  if (deep) {
    // NOTE: the resulting inside lists or maps will be of type dynamic and
    // not of specific type!
    dynamic recur(dynamic obj) {
      if (obj is List) {
        var list = [];
        for (int i = 0; i < obj.length; i++) {
          list.add(recur(obj[i]));
        }
        return list;
      }
      if (obj is Map) {
        var map = <String, dynamic>{};
        for (var entry in obj.entries) {
          map[entry.key] = recur(entry.value);
        }
        return map;
      }
      if (obj is ClonableAsyncMixin) {
        return obj.cloneAsync(deep: true);
      }
      if (obj is ClonableMixin) {
        return obj.clone(deep: true);
      }
      if (obj is CloneField) {
        return obj.value;
      }
      return obj;
    }

    obj = recur(obj);
  }
  return obj;
}

/// The [ClonableBaseMixin] mixin class used to clone and serialize objects.
mixin ClonableBaseMixin<T> implements ClonableBaseInterface<T> {
  @override
  void setMap(Map json, {bool deep = false}) {
    for (var field in fields) {
      field.value = _getFieldObj(json: json, field: field, deep: deep) ??
          field.defaultValue;
    }
  }

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

  @override
  void set(ClonableBaseInterface<T> obj, {bool deep = false}) =>
      setMap(obj.fields._map, deep: deep);
}

/// The [ClonableMixin] mixin class used to clone and serialize objects.
mixin ClonableMixin<T> implements ClonableInterface<T>, Jsonizable<T> {
  /// Creates an empty object. [json] map is provided in case of 'final' fields
  /// needed within the class constructor. In that case the [CloneField]
  /// definition might have an empty setter
  T create(Map<String, dynamic> json);

  // ========== ClonableBaseInterface implementation ==========
  @override
  T clone({bool deep = false}) => ((create(fields.valueMap) as ClonableMixin)
    ..setMap(fields._map, deep: deep)) as T;

  // ========== ClonableInterface implementation ==========

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

  bool containsKey(String key) => _map.containsKey(key);

  void clear() => _map.clear();

  CloneField? remove(Object? key) => _map.remove(key);

  Iterable<String> get keys => _map.keys;

  Iterable<CloneField> get fields => _map.values;

  Iterable<MapEntry<String, CloneField<dynamic>>> get entries => _map.entries;

  Map<String, dynamic> get valueMap =>
      _map.map((k, v) => MapEntry(k, v.getter()));
}
