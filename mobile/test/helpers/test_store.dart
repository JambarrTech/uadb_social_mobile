import 'package:shared_preferences/shared_preferences.dart';
import 'package:uadb_social/core/models/auth_user.dart';
import 'package:uadb_social/core/services/token_store.dart';

/// Crée un [TokenStore] adossé à des préférences en mémoire.
///
/// `SharedPreferences.setMockInitialValues` remplace le canal natif, ce qui
/// permet de tester la persistance réelle — sérialisation comprise — sans
/// avoir à stubber la classe [TokenStore] elle-même.
Future<TokenStore> createTestStore({
  String? token,
  AuthUser? user,
  bool onboardingSeen = false,
  int unreadMessages = 0,
}) async {
  SharedPreferences.setMockInitialValues({
    'auth.token': ?token,
    'auth.user': ?(user == null ? null : _encode(user)),
    'onboarding.seen': onboardingSeen,
    'messages.unread': unreadMessages,
  });
  return TokenStore.create();
}

String _encode(AuthUser user) =>
    '{"id":"${user.id}","email":"${user.email}",'
    '"fullName":"${user.fullName}"}';
