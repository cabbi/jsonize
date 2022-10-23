part of clonable;

/// The [ClonableExInterface] definition
abstract class ClonableExInterface<T extends Object>
    implements ClonableBaseInterface<T> {
  void beforeEncodeEx(Map<String, dynamic> json, [dynamic exParam]);
  void afterEncodeEx(Map<String, dynamic> json, [dynamic exParam]);
  void beforeDecodeEx(Map<String, dynamic> json, [dynamic exParam]);
  void afterDecodeEx(Map<String, dynamic> json, [dynamic exParam]);
  dynamic toJsonEx([dynamic exParam]);
  T? fromJsonEx(json, [dynamic exParam]);
}

/// The [ClonableEx] class used to clone and serialize future objects and using
/// an optional external parameter.
abstract class ClonableEx<T extends Object>
    with ClonableBaseMixin<T>, ClonableExMixin<T> {}

/// The [ClonableExMixin] class used to clone and serialize future objects and using
/// an optional external parameter.
mixin ClonableExMixin<T extends Object> implements ClonableExInterface<T> {
  /// Creates an [obj] clone.
  static ClonableEx cloneEx(ClonableEx obj, [dynamic exParam]) =>
      ((obj.createEx(obj.fields._map, exParam) as ClonableEx)
        ..setMap(obj.fields._map));

  // ========== ClonableEx interface ==========

  /// Creates an empty object. [json] map is provided in case of 'final' fields
  /// needed within the class constructor. In that case the [CloneField]
  /// definition might have an empty setter
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
