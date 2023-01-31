part of clonable;

/// The [ClonableExInterface] definition
abstract class ClonableExInterface<T> implements ClonableBaseInterface<T> {
  void beforeEncodeEx(Map<String, dynamic> json, [dynamic exParam]);
  void afterEncodeEx(Map<String, dynamic> json, [dynamic exParam]);
  void beforeDecodeEx(Map<String, dynamic> json, [dynamic exParam]);
  void afterDecodeEx(Map<String, dynamic> json, [dynamic exParam]);
  dynamic toJsonEx([dynamic exParam]);
  T? fromJsonEx(json, [dynamic exParam]);
  T createEx(Map<String, dynamic> json, [dynamic exParam]);
}

/// The [ClonableEx] class used to clone and serialize future objects and using
/// an optional external parameter.
abstract class ClonableEx<T> with ClonableBaseMixin<T>, ClonableExMixin<T> {}

/// The [ClonableExMixin] class used to clone and serialize future objects and using
/// an optional external parameter.
mixin ClonableExMixin<T> implements ClonableExInterface<T> {
  /// Creates an [obj] clone.
  ///
  /// If [deep] is true it will perform a deep/recursive set
  /// (i.e. clones filed values in case they are clonable objects)
  T cloneEx(ClonableEx obj, {dynamic exParam, bool deep = false}) =>
      ((createEx(fields.valueMap, exParam) as ClonableMixin)
        ..setMap(fields._map, deep: deep)) as T;

  // ========== ClonableEx interface ==========

  /// Creates an empty object. [json] map is provided in case of 'final' fields
  /// needed within the class constructor. In that case the [CloneField]
  /// definition might have an empty setter
  @override
  T createEx(Map<String, dynamic> json, [dynamic exParam]);

  // ========== ClonableEx events ==========

  /// Raised before the [json] map is filled with the object [fields]
  @override
  void beforeEncodeEx(Map<String, dynamic> json, [dynamic exParam]) {}

  /// Raised after the [json] map is filled with the object [fields]
  @override
  void afterEncodeEx(Map<String, dynamic> json, [dynamic exParam]) {}

  /// Raised before this object fields are set with the [json] map
  @override
  void beforeDecodeEx(Map<String, dynamic> json, [dynamic exParam]) {}

  /// Raised after this object fields are set with the [json] map
  @override
  void afterDecodeEx(Map<String, dynamic> json, [dynamic exParam]) {}

  // ========== ClonableExInterface implementation ==========

  @override
  dynamic toJsonEx([dynamic exParam]) {
    Map<String, dynamic> json = {};
    beforeEncodeEx(json, exParam);
    getMap(json);
    afterEncodeEx(json, exParam);
    return json;
  }

  @override
  T? fromJsonEx(json, [dynamic exParam]) {
    ClonableExInterface obj = createEx(json, exParam) as ClonableExInterface;
    obj.beforeDecodeEx(json, exParam);
    obj.setMap(json);
    obj.afterDecodeEx(json, exParam);
    return obj as T;
  }

  // ========== Jsonizable implementation ==========

  @override
  dynamic toJson() => toJsonEx();

  @override
  T? fromJson(json, [dynamic exParam]) => fromJsonEx(json);
}
