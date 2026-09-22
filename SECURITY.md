# Security Policy — UADB Social

## Reporting a Vulnerability

Please **do not open a public issue** for a security vulnerability.

- **Contact :** jambarrtech@gmail.com
- **Subject :** `[SECURITY] <summary>`
- **Acknowledgement :** sous 72 heures
- **Fix / mitigation :** sous 7 jours ouvrés selon la gravité

Merci de inclure :
1. La version / le commit concerné (`git rev-parse --short HEAD`)
2. Les étapes de reproduction
3. L'impact potentiel (accès aux données, contournement d'authentification, etc.)

## Scope

| Dans le scope | Hors scope |
|---|---|
| App mobile Flutter (`mobile/lib/`) | Le backend (pas encore de serveur) |
| Configuration Android / iOS / Web | Les infrastructures de l'UADB |
| Chaîne de build et dépendances (`pubspec.lock`) | Le phishing / ingénierie sociale |

## Supported Versions

Seule la branche **`main`** est maintenue et corrigée.

| Version | Supporté |
|---|---|
| `main` | ✅ |
| Forks / branches anciennes | ❌ |

## Secrets & Credentials

Règles non négociables pour ce dépôt :

- **Aucune clé dans le code.** Utiliser les variables d'environnement de build :
  ```bash
  flutter run --dart-define=API_URL=... --dart-define=API_PUBLIC_KEY=...
  ```
- Les fichiers `.env`, `**/google-services.json`, `**/GoogleService-Info.plist`,
  `**/*.jks`, `**/key.properties` sont **ignorés par `.gitignore`** et ne doivent
  jamais être commités.
- **Côté mobile, uniquement des clés publiques** (clé `anon` + politiques RLS
  côté serveur). Une clé `service_role` / admin ne doit **jamais** figurer dans
  une application cliente.
- Toute clé accidentellement poussée doit être **révoquée immédiatement** côté
  fournisseur, puis considérée comme compromise (le nettoyage de l'historique
  git ne suffit pas).

## Dependabot & Secret Scanning

- **Secret scanning + push protection** : à activer dans
  *Settings → Code security and analysis*.
- **Dependabot alerts / security updates** : idem, plus `.github/dependabot.yml`
  pour les mises à jour de versions.
- **CI** : `.github/workflows/ci.yml` exécute `flutter analyze` et
  `flutter test` sur chaque push et pull request.
