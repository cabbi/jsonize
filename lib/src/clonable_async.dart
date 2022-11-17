part of clonable;

/// The [ClonableAsyncInterface] definition
abstract class ClonableAsyncInterface<T extends Object>
    implements ClonableExInterface<T> {
  @override
  Future<void> setMap(Map json);
  Future<T?> fromJsonAsync(json, [dynamic exParam]);
  Future<T> createAsync(Map<String, dynamic> json, [dynamic exParam]);
}

/// The [ClonableAsync] class used to clone and serialize future objects and
/// using an optional external parameter.
///
/// The Clonable type cannot be a nullable type.
abstract class ClonableAsync<T extends Object>
    with ClonableBaseMixin<T>, ClonableExMixin<T>, ClonableAsyncMixin<T> {}

mixin ClonableAsyncMixin<T extends Object>
    implements ClonableEx<T>, ClonableAsyncInterface<T> {
  // ========== ClonableEx interface ==========

  /// Creates an empty object. [json] map is provided in case of 'final' fields
  /// needed within the class constructor. In that case the [CloneField]
  /// definition might have an empty setter
  @override
  Future<T> createAsync(Map<String, dynamic> json, [dynamic exParam]);

  // ========== ClonableAsync implementation ==========

  /// Creates an [obj] clone.
  static Future<ClonableAsyncInterface> cloneAsync(ClonableAsync obj,
          [dynamic exParam]) async =>
      ((await obj.createAsync(obj.fields._map, exParam)
          as ClonableAsyncInterface)
        ..setMap(obj.fields._map));

  @override
  Future<T?> fromJsonAsync(json, [dynamic exParam]) async {
    ClonableAsyncInterface obj =
        await createAsync(json, exParam) as ClonableAsyncInterface;
    obj.beforeDecodeEx(json, exParam);
    await obj.setMap(json);
    obj.afterDecodeEx(json, exParam);
    return obj as T;
  }

  @override
  Future<void> setMap(Map json) async {
    for (var field in fields) {
      var obj = json[field.name];
      if (obj is CloneField) {
        obj = obj.value;
      }
      try {
        field.value = await obj ?? field.defaultValue;
      } catch (e) {
        print(e);
      }
    }
  }

  /// Jsonize will NOT call this method for an [ClonableAsync] object type!
  @override
  T createEx(Map<String, dynamic> json, [dynamic exParam]) =>
      throw UnimplementedError();
}
