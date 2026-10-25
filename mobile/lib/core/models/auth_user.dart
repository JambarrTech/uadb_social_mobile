import 'json_utils.dart';

/// Profil utilisateur minimal renvoyé par le backend après auth.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.fullName,
    this.department,
    this.avatarUrl,
    this.isOfficial = false,
  });

  final String id;
  final String email;
  final String fullName;
  final String? department;
  final String? avatarUrl;
  final bool isOfficial;

  /// Initiales utilisées par les avatars sans image.
  String get initials {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  /// Identifiant court affiché sous le nom (`@fatou.sow`).
  String get handle {
    final source = email.split('@').first;
    final cleaned = source.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '.');
    return '@${cleaned.toLowerCase()}';
  }

  AuthUser copyWith({
    String? id,
    String? email,
    String? fullName,
    String? department,
    String? avatarUrl,
    bool? isOfficial,
  }) => AuthUser(
    id: id ?? this.id,
    email: email ?? this.email,
    fullName: fullName ?? this.fullName,
    department: department ?? this.department,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    isOfficial: isOfficial ?? this.isOfficial,
  );

  /// Tolère les variations de casse du backend (`fullName` / `name` /
  /// `username`, `department` / `filiere`).
  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final firstName = readString(json['firstName']);
    final lastName = readString(json['lastName']);
    final composed = [firstName, lastName].where((v) => v.isNotEmpty).join(' ');
    final name = readFirstString(json, const ['fullName', 'name', 'username']);

    return AuthUser(
      id: readFirstString(json, const ['id', '_id', 'userId']),
      email: readFirstString(json, const ['email']),
      fullName: name.isNotEmpty ? name : (composed.isEmpty ? 'Membre UADB' : composed),
      department: readFirstNullableString(json, const ['department', 'filiere']),
      avatarUrl: readFirstNullableString(json, const ['avatarUrl', 'avatar']),
      isOfficial: readFirstBool(json, const ['isOfficial', 'official']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'fullName': fullName,
    if (department != null) 'department': department,
    if (avatarUrl != null) 'avatarUrl': avatarUrl,
    'isOfficial': isOfficial,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthUser &&
          other.id == id &&
          other.email == email &&
          other.fullName == fullName &&
          other.department == department &&
          other.avatarUrl == avatarUrl &&
          other.isOfficial == isOfficial;

  @override
  int get hashCode =>
      Object.hash(id, email, fullName, department, avatarUrl, isOfficial);
}
