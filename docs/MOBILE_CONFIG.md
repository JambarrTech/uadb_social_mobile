# Configuration de l'application mobile

> **L'application ne fait aucun appel r�seau.** La couche HTTP (`http`,
> `ApiClient`, endpoints) a �t� retir�e tant qu'aucun serveur n'existe. Tout
> fonctionne sur le stockage local de l'appareil. Le contrat d'API reste
> document� plus bas, pour l'�quipe qui d�veloppera le backend.

## Drapeaux de compilation

| Drapeau | D�faut | Effet |
|---|---|---|
| `REQUIRE_AUTH` | `true` | `false` ouvre directement sur l'accueil |
| `AUTH_BYPASS` | `true` | `false` v�rifie r�ellement les identifiants |

```sh
# D�monstration (par d�faut) : n'importe quel email / mot de passe
flutter run

# Comptes r�els, enregistr�s et v�rifi�s sur l'appareil
flutter run --dart-define=AUTH_BYPASS=false

# Ouverture directe sur l'accueil, sans passer par la connexion
flutter run --dart-define=REQUIRE_AUTH=false
```

## Connexion

En mode d�monstration (`AUTH_BYPASS=true`, le d�faut) :

- le formulaire accepte **n'importe quelle adresse e-mail et n'importe quel
  mot de passe**, champs vides compris ;
- la validation des champs est d�sactiv�e (`validator` � `null`) ;
- un profil est d�duit de l'adresse saisie (`fatou.sow@�` ? � Fatou Sow �) pour
  que l'interface reste coh�rente ;
- rien n'est �crit dans le registre des comptes.

En mode strict (`AUTH_BYPASS=false`) :

- les comptes sont enregistr�s sur l'appareil ;
- le mot de passe est sal�-hach� en SHA-256, **jamais stock� en clair** ;
- les identifiants erron�s sont refus�s ;
- � compte inconnu � et � mot de passe faux � renvoient le m�me message, pour
  ne pas r�v�ler quelles adresses sont enregistr�es.

Dans les deux cas, un bandeau le signale � l'�cran : rien n'est envoy� sur le
r�seau.

## Fil d'actualit�

Le fil est **local** (`LocalPostStore`, `shared_preferences`) :

- au premier lancement, trois publications de d�monstration sont inject�es et
  signal�es par un bandeau � Contenu de d�monstration � ;
- une publication cr��e dans l'app est **r�ellement enregistr�e** et
  r�appara�t au red�marrage ;
- les likes et partages sont persist�s ;
- `resetToDemo()` permet de revenir au contenu initial.

`isDemoOnly` devient `false` d�s la premi�re publication ajout�e : le bandeau
dispara�t alors, puisque le fil contient enfin des donn�es r�elles.

## Identifiants d'application

| Plateforme | Identifiant |
|---|---|
| Android (`applicationId` / `namespace`) | `sn.uadb.social` |
| iOS (`PRODUCT_BUNDLE_IDENTIFIER`) | `sn.uadb.social` |
| Activité Android | `sn.uadb.social.MainActivity` |

## Contrat d'API (pour l'équipe backend)

Aucun code client ne consomme encore ces endpoints : la couche HTTP a été
supprimée. Ce tableau est la **spécification** à implémenter côté serveur ; la
couche réseau sera réécrite à partir de celui-ci.

| Méthode | Endpoint | Charge utile | Réponse |
|---|---|---|---|
| `POST` | `/auth/login` | `{ email, password }` | `{ token, user }` |
| `POST` | `/auth/register` | `{ firstName, lastName, email, password, department }` | `{ token, user }` |
| `POST` | `/auth/forgot-password` | `{ email }` | `{ message }` |
| `GET` | `/posts/feed?limit&cursor` | — | liste de publications |
| `POST` | `/posts` | `{ content, visibility, authorId, imageUrls? }` | publication |
| `POST` | `/posts/{id}/like` | — | `{ liked: bool }` |
| `POST` | `/posts/{id}/share` | — | `{ sharesCount: int }` |
| `DELETE` | `/posts/{id}` | — | vide |

### Points de vigilance

- **Visibilité** : l'API attend une valeur technique
  (`public` / `friends` / `communities` / `private`). Les libellés français
  n'existent que dans l'UI — voir `PostVisibility` dans
  `lib/core/models/post.dart`. Un test verrouille cette contrainte.
- **Enveloppe de réponse** : prévoir la liste nue ainsi que
  `{ posts: [...] }` et `{ data: [...] }`.
- **Types tolérants** : un nombre sérialisé en chaîne (`"12"`) et un booléen
  textuel (`"true"`) sont acceptés — voir `lib/core/models/json_utils.dart`.
- **Authentification** : le token est envoyé en `Authorization: Bearer <token>`
  sur toutes les requêtes ; un `401` doit être distingué d'une panne réseau.

## Identité de package

Android a besoin de la permission suivante dans
`android/app/src/main/AndroidManifest.xml` — **absente des manifestes
`debug`/`profile` uniquement**, ce qui rendait toute requête réseau impossible
en release. Elle est conservée pour le branchement futur :

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

## Fonctionnalités non branchées

Ces éléments de l'interface affichent une explication plutôt qu'un
`onTap: () {}` silencieux :

- exploration (contenus de démonstration, bannière d'avertissement à l'écran) ;
- messagerie (aucun endpoint de conversations) ;
- statistiques de profil (aucun endpoint de statistiques) ;
- pièces jointes vidéo, sondage, lieu, événement (aucun endpoint) ;
- connexion Google.

## Lints

`analysis_options.yaml` active des règles au-delà de `flutter_lints`
(`avoid_print`, `avoid_web_libraries_in_flutter`, `unawaited_futures`,
`prefer_const_*`, `prefer_final_locals`…). La CI lance `flutter analyze` **sans**
`--no-fatal-infos` : ces règles bloquent la merge.

## Build Android sous Windows

### « Daemon compilation failed »

Symptôme : le build échoue avec une longue pile Java dont la cause racine est :

```
java.lang.IllegalArgumentException: this and base files have different roots
```

suivi de `Could not close incremental caches in ...\build\<plugin>\kotlin\...`.

Cause : le compilateur incrémental Kotlin utilise des tables `.tab` mappées en
mémoire. Si le projet est sur un lecteur et le cache Gradle sur un autre
(`GRADLE_USER_HOME` par défaut sur `C:` alors que le projet est sur `D:`), il ne
sait pas gérer deux racines distinctes. Le problème apparaît dès qu'un plugin
Android embarquant du code Kotlin est ajouté (`image_picker`,
`shared_preferences`, …), car ces modules sont compilés pour la première fois.

Correctif appliqué dans `android/gradle.properties` :

```properties
kotlin.incremental=false
```

Pour conserver l'incrémentalisation, placer plutôt le cache sur le lecteur du
projet :

```sh
setx GRADLE_USER_HOME D:\gradle-cache
```

### Nettoyage après une erreur de compilation

Les `.dex` générés dépassent souvent `MAX_PATH` (260 caractères) sous Windows :
`Remove-Item` échoue alors **silencieusement**. Utiliser le préfixe étendu :

```powershell
cmd /c "rd /s /q \\?$PWD\build"
```

Penser aussi à arrêter les processus qui verrouillent les fichiers :

```powershell
Get-Process -Name java,dart -ErrorAction SilentlyContinue | Stop-Process -Force
```

### Nettoyage complet

```sh
flutter clean
flutter pub get
flutter run
```
