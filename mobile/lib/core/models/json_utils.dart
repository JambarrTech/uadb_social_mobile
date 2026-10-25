/// Helpers de désérialisation tolérants aux variations de types renvoyées
/// par le backend (nombre en chaîne, booléen en "true", `null` vs absent).
library;

String readString(Object? value) => value?.toString().trim() ?? '';

String? readNullableString(Object? value) {
  final result = readString(value);
  return result.isEmpty ? null : result;
}

int readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(readString(value)) ?? 0;
}

bool readBool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  return const {'true', '1', 'yes'}.contains(
    readString(value).toLowerCase(),
  );
}

/// Première clé présente parmi [keys], sinon `null`.
Object? readFirst(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    if (json.containsKey(key) && json[key] != null) return json[key];
  }
  return null;
}

String readFirstString(Map<String, dynamic> json, List<String> keys) =>
    readString(readFirst(json, keys));

String? readFirstNullableString(Map<String, dynamic> json, List<String> keys) =>
    readNullableString(readFirst(json, keys));

int readFirstInt(Map<String, dynamic> json, List<String> keys) =>
    readInt(readFirst(json, keys));

bool readFirstBool(Map<String, dynamic> json, List<String> keys) =>
    readBool(readFirst(json, keys));
