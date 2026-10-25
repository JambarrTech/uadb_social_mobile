import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/providers.dart';
import 'core/services/token_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Le stockage est initialisé avant `runApp` : l'état d'authentification est
  // ainsi connu de façon synchrone au premier build et le routeur peut
  // rediriger sans passer par un état de chargement intermédiaire.
  final store = await TokenStore.create();

  runApp(
    ProviderScope(
      overrides: [tokenStoreProvider.overrideWithValue(store)],
      child: const UadbSocialApp(),
    ),
  );
}
