import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'services/token_store.dart';

/// Stockage local de l'application (session, comptes, publications).
///
/// Surchargé dans `main()` une fois `SharedPreferences` initialisé, afin que
/// l'état soit disponible de façon **synchrone** au premier build du routeur.
final tokenStoreProvider = Provider<TokenStore>((ref) {
  throw UnimplementedError(
    'tokenStoreProvider doit être surchargé dans main() via '
    'ProviderScope(overrides: [...]).',
  );
});
