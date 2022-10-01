part of clonable;

/// The [ClonableAsync] class used to clone and serialize future objects and
/// using an optional external parameter.
///
/// The Clonable type cannot be a nullable type.
abstract class ClonableAsync<T extends Object> extends ClonableEx<T> {
  // ========== ClonableEx interface ==========

  /// Creates an empty object. [json] map is provided in case of 'final' fields
  /// needed within the class constructor. In that case the [CloneField]
  /// definition might have an empty setter
  Future<T> createAsync(Map<String, dynamic> json, [dynamic exParam]);

  // ========== ClonableAsync implementation ==========

  /// Creates an [obj] clone.
  static Future<Clonable> cloneAsync(ClonableAsync obj,
          [dynamic exParam]) async =>
      ((await obj.createAsync(obj.fields._map, exParam) as Clonable)
        ..setMap(obj.fields._map));

  // ========== [Jsonizable] implementation ==========

  Future<T?> fromJsonAsync(json, [dynamic exParam]) async {
    ClonableAsync obj = await createAsync(json, exParam) as ClonableAsync;
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
      field.value = await obj ?? field.defaultValue;
    }
  }

  /// Jsonize will NOT call this method for an [ClonableAsync] object type!
  @override
  T createEx(Map<String, dynamic> json, [dynamic exParam]) =>
      throw UnimplementedError();
}
