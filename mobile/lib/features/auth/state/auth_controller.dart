import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/models/auth_user.dart';
import '../../../core/providers.dart';
import '../data/local_account_store.dart';
import '../data/local_auth_repository.dart';
import '../domain/auth_repository.dart';

/// Cycle de vie de la session, utilisé par le `redirect` du routeur.
enum AuthStatus {
  /// Session encore inconnue — le routeur ne redirige rien.
  unknown,

  /// Aucune session valide : seules les routes publiques sont accessibles.
  unauthenticated,

  /// Session valide.
  authenticated,
}

class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final AuthStatus status;
  final AuthUser? user;
  final bool isSubmitting;
  final String? errorMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  /// Message d'erreur lisible par l'utilisateur, à partir de l'exception
  /// remontée par le registre local.
  static String describe(Object error) => switch (error) {
    AuthFailure(:final message) => message,
    _ => 'Une erreur inattendue est survenue.',
  };

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) => AuthState(
    status: status ?? this.status,
    user: user ?? this.user,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );
}

final localAccountStoreProvider = Provider<LocalAccountStore>(
  (ref) => LocalAccountStore(ref.watch(tokenStoreProvider).preferences),
);

/// Source d'authentification active.
///
/// L'application ne parle à aucun serveur : l'implémentation est locale, et
/// son comportement est piloté par [AppConfig.authBypass] (démonstration) ou
/// par des comptes réellement vérifiés.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return LocalAuthRepository(
    store: ref.watch(tokenStoreProvider),
    accounts: ref.watch(localAccountStoreProvider),
  );
});

/// Source de vérité de la session pour toute l'application.
class AuthController extends Notifier<AuthState> {
  late final AuthRepository _repository;

  @override
  AuthState build() {
    _repository = ref.watch(authRepositoryProvider);
    // Le store est déjà initialisé : la lecture est synchrone.
    return _stateFromStore();
  }

  AuthState _stateFromStore() {
    // Le store est déjà chargé : la lecture est synchrone, pas d'état
    // `unknown` au premier build et donc pas de redirection au démarrage.
    final store = ref.read(tokenStoreProvider);
    final token = store.token;
    final user = store.user;
    if (token != null && token.isNotEmpty && user != null) {
      return AuthState(status: AuthStatus.authenticated, user: user);
    }
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<bool> login({required String email, required String password}) =>
      _submit(
        () => _repository.login(email: email, password: password),
      );

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String department,
  }) => _submit(
    () => _repository.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      department: department,
    ),
  );

  /// Demande un lien de réinitialisation. N'établit pas de session : l'écran
  /// affiche une confirmation une fois l'appel réussi.
  Future<bool> requestPasswordReset({required String email}) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _repository.requestPasswordReset(email: email);
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: AuthState.describe(error),
      );
      return false;
    }
  }

  Future<bool> _submit(Future<AuthSession> Function() action) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final session = await action();
      state = AuthState(
        status: AuthStatus.authenticated,
        user: session.user,
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: AuthState.describe(error),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

/// Profil affiché tant qu'aucune session n'existe.
///
/// Tant que la connexion n'est pas obligatoire, l'application s'ouvre sans
/// identité : sans ce repli, l'en-tête, la carte de publication et le profil
/// afficheraient « Membre UADB » partout. Il s'agit explicitement d'un profil
/// de démonstration, à remplacer par les données de session.
const AuthUser demoProfile = AuthUser(
  id: 'demo-user',
  email: 'fatou.sow@uadb.edu.sn',
  fullName: 'Fatou Sow',
  department: 'Licence 3 Informatique',
);

/// Utilisateur de l'interface : la session si elle existe, sinon [demoProfile].
///
/// Jamais `null` : les écrans n'ont donc pas à prévoir de profil absent.
final currentUserProvider = Provider<AuthUser>(
  (ref) => ref.watch(authControllerProvider).user ?? demoProfile,
);

/// L'onboarding n'est proposé qu'une fois par installation.
final onboardingSeenProvider = Provider<bool>(
  (ref) => ref.watch(tokenStoreProvider).onboardingSeen,
);

/// Marque l'onboarding comme vu. Appelé par l'écran d'onboarding une fois le
/// parcours terminé.
final completeOnboardingProvider = Provider<Future<void> Function()>((ref) {
  return () => ref.read(tokenStoreProvider).setOnboardingSeen();
});
