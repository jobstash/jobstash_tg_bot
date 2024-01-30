import 'package:firedart/firedart.dart';

extension DocumentReferenceExtension on DocumentReference {
  Future<void> removeItemFromSet(String fieldName, dynamic item) async {
    final data = await getSafe();
    if (data != null) {
      final map = data.map;
      if (map.containsKey(fieldName)) {
        final array = List<dynamic>.from(map[fieldName]);
        array.remove(item);
        await update({fieldName: array});
      }
    }
  }

  Future<void> addItemToSet(String fieldName, dynamic item) async {
    if (!(await exists)) {
      await set({
        fieldName: [item]
      });
    } else {
      final doc = await get();
      final currentItems = doc[fieldName] as List<dynamic>? ?? [];
      if (!currentItems.contains(item)) {
        await update({
          fieldName: [...currentItems, item]
        });
      }
    }
  }

  Future<List<T>?> getWhere<T>(
    String fieldName,
    T Function(Map<String, dynamic>) converter,
    bool Function(T) filter,
  ) async {
    if (!(await exists)) return null;

    final result = await get();
    final itemsJson = result.map[fieldName];
    if (itemsJson == null || itemsJson is! List) return null;

    final items = itemsJson.map((entry) => converter(entry)).toList();

    return items.where(filter).toList();
  }

  /// Gets document field if document exists, otherwise returns null
  Future<T?> getFieldSafe<T>(String fieldName) async {
    if (!(await exists)) {
      return null;
    } else {
      final doc = await get();
      return doc[fieldName];
    }
  }

  Future<Document?> getSafe() async {
    if (!(await exists)) {
      return null;
    } else {
      return await get();
    }
  }
}
