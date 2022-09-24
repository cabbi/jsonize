part of clonable;

/// The [ClonableEx] class used to clone and serialize future objects and using
/// an optional external parameter.
///
/// The Clonable type cannot be a nullable type.
abstract class ClonableEx<T extends Object> extends BaseClonable {
  // ========== ClonableEx interface ==========

  /// Creates an empty object. [json] map is provided in case of 'final' fields
  /// needed within the class constructor. In that case the [CloneField]
  /// definition might have an empty setter
  T createEx(Map<String, dynamic> json, [dynamic exParam]);

  // ========== ClonableEx events ==========

  /// Raised before the [json] map is filled with the object [fields]
  void beforeEncodeEx(Map<String, dynamic> json, [dynamic exParam]) {}

  /// Raised after the [json] map is filled with the object [fields]
  void afterEncodeEx(Map<String, dynamic> json, [dynamic exParam]) {}

  /// Raised before this object fields are set with the [json] map
  void beforeDecodeEx(Map<String, dynamic> json, [dynamic exParam]) {}

  /// Raised after this object fields are set with the [json] map
  void afterDecodeEx(Map<String, dynamic> json, [dynamic exParam]) {}

  // ========== ClonableEx implementation ==========

  /// Creates an [obj] clone.
  static Clonable cloneEx(ClonableEx obj, [dynamic exParam]) =>
      ((obj.createEx(obj.fields._map, exParam) as Clonable)
        ..setMap(obj.fields._map));

  // ========== [Jsonizable] implementation ==========

  dynamic toJsonEx([dynamic exParam]) {
    Map<String, dynamic> json = {};
    beforeEncodeEx(json, exParam);
    getMap(json);
    afterEncodeEx(json, exParam);
    return json;
  }

  T? fromJsonEx(json, [dynamic exParam]) {
    ClonableEx obj = createEx(json, exParam) as ClonableEx;
    obj.beforeDecodeEx(json, exParam);
    obj.setMap(json);
    obj.afterDecodeEx(json, exParam);
    return obj as T;
  }

  /// Jsonize will NOT call those methods for an [ClonableEx] object type!
  @override
  Object? fromJson(value) => throw UnimplementedError();
  @override
  dynamic toJson() => throw UnimplementedError();
}
