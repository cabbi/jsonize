part of clonable;

/// The [ClonableAsyncInterface] definition
abstract class ClonableAsyncInterface<T> implements ClonableExInterface<T> {
  @override
  Future<void> setMap(Map json, {bool deep = false});
  @override
  Future<void> beforeDecodeEx(Map<String, dynamic> json, [dynamic exParam]);
  @override
  Future<void> afterDecodeEx(Map<String, dynamic> json, [dynamic exParam]);

  Future<T?> fromJsonAsync(json, [dynamic exParam]);
  Future<T> createAsync(Map<String, dynamic> json, [dynamic exParam]);
  Future<T> cloneAsync({dynamic exParam, bool deep = false});
}

/// The [ClonableAsync] class used to clone and serialize future objects and
/// using an optional external parameter.
///
/// The Clonable type cannot be a nullable type.
abstract class ClonableAsync<T>
    with ClonableBaseMixin<T>, ClonableExMixin<T>, ClonableAsyncMixin<T> {}

mixin ClonableAsyncMixin<T>
    implements ClonableEx<T>, ClonableAsyncInterface<T> {
  // ========== ClonableEx interface ==========

  /// Creates an empty object. [json] map is provided in case of 'final' fields
  /// needed within the class constructor. In that case the [CloneField]
  /// definition might have an empty setter
  @override
  Future<T> createAsync(Map<String, dynamic> json, [dynamic exParam]);

  // ========== ClonableAsync implementation ==========

  /// Creates an [obj] clone.
  @override
  Future<T> cloneAsync({dynamic exParam, bool deep = false}) async {
    var obj = await createAsync(fields.valueMap, exParam) as ClonableAsyncMixin;
    await obj.setMap(fields._map, deep: deep);
    return obj as T;
  }

  @override
  T clone({Object deep = false}) => throw UnimplementedError();

  @override
  Future<T?> fromJsonAsync(json, [dynamic exParam]) async {
    ClonableAsyncInterface obj =
        await createAsync(json, exParam) as ClonableAsyncInterface;
    await obj.beforeDecodeEx(json, exParam);
    await obj.setMap(json);
    await obj.afterDecodeEx(json, exParam);
    return obj as T;
  }

  @override
  Future<void> setMap(Map json, {bool deep = false}) async {
    for (var field in fields) {
      field.value = await _getFieldObj(json: json, field: field, deep: deep) ??
          field.defaultValue;
    }
  }

  @override
  Future<void> beforeDecodeEx(Map<String, dynamic> json,
      [dynamic exParam]) async {}

  @override
  Future<void> afterDecodeEx(Map<String, dynamic> json,
      [dynamic exParam]) async {}

  /// Jsonize will NOT call this method for an [ClonableAsync] object type!
  @override
  T createEx(Map<String, dynamic> json, [dynamic exParam]) =>
      throw UnimplementedError();
}
