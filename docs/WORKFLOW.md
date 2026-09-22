# Workflow Git & GitHub — UADB Social

Guide de référence pour toutes les règles de collaboration : branches, commits, pull requests, CI et protection de `main`.

## 1. Structure des branches

| Branche         | Rôle                                                                  |
|-----------------|-----------------------------------------------------------------------|
| `main`          | Base stable et **protégée**. Ne reçoit que des intégrations validées. |
| `developpement` | Intégration de la plateforme. Branche d'atterrissage des features.    |
| `mobile`        | Développement de l'application mobile Flutter.                        |

```
mobile ──PR──▶ developpement ──PR──▶ main
```

Règles de base :

- On ne pousse **jamais** directement sur `main`.
- Chaque fonctionnalité est développée sur `mobile` puis intégrée dans `developpement`.
- `main` est un point de référence volontairement minimal.

## 2. Développer une fonctionnalité

Pour un petit changement, travailler directement sur `mobile` :

```sh
git checkout mobile
git pull origin mobile
# ... modifications ...
git add .
git commit -m "feat: ajoute l'écran X"
git push origin mobile
```

Pour une fonctionnalité complexe, créer une branche dédiée depuis mobile :

```sh
git checkout mobile
git checkout -b feature/mon-ecran
# ... modifications ...
git push -u origin feature/mon-ecran
# puis PR feature/mon-ecran -> mobile
```

## 3. Messages de commit (Conventional Commits)

| Type        | Usage                                     |
|-------------|-------------------------------------------|
| `feat:`     | Nouvelle fonctionnalité                   |
| `fix:`      | Correction de bug                         |
| `refactor:` | Refactorisation sans changement de comportement |
| `docs:`     | Documentation                            |
| `chore:`    | Tâche d'infrastructure / ménage           |
| `deps:`     | Mise à jour de dépendances                |

## 4. Intégrer dans developpement (PR recommandée)

1. Pousser le travail sur `mobile` (ou une branche dédiée).
2. Ouvrir une **Pull Request** `mobile → developpement` :
   - le template `.github/PULL_REQUEST_TEMPLATE.md` s'applique automatiquement ;
   - la CI se lance (`flutter analyze` + `flutter test`) ;
   - remplir la checklist (tests, secrets, artefacts, cible).
3. Merger la PR après validation.

Alternative rapide en local :

```sh
git checkout developpement
git pull origin developpement
git merge mobile
git push origin developpement
git checkout mobile
```

## 5. Libérer une version (developpement → main)

- Ouvrir une PR `developpement → main`.
- Ne merger que ce qui est **stable et testé**.
- `main` est protégé : push direct et force push bloqués.

## 6. CI / GitHub Actions

- Le workflow `ci.yml` s'exécute sur `main`, `developpement` et `mobile` quand le chemin `mobile/**` change.
- Vérifications : `flutter analyze --no-fatal-infos --no-fatal-warnings` puis `flutter test`.
- Dependabot met à jour `pub`, `github-actions` et `gradle` automatiquement.

## 7. Protection de la branche main (à configurer)

Dans **Settings → Branches → Add branch protection rule** avec la branche `main` :

- ☑ Require a pull request before merging (au moins 1 approbation)
- ☑ Dismiss stale pull request approvals
- ☑ Require conversation resolution
- ☑ Do not allow bypassing the above settings
- ☑ Block force pushes
- ☑ Block deletions

> Nota : `required_status_checks` reste vide tant que `main` ne contient pas la CI ; les PR depuis `mobile`/`developpement` exécutent la CI depuis leur branche.

## 8. Checklist avant chaque PR

- [ ] `flutter analyze` passe
- [ ] `flutter test` passe
- [ ] Aucun secret commité (`.env`, `local.properties`, `google-services.json`…)
- [ ] Aucun artefact de build ajouté (`build/`, `.dart_tool/`, `.gradle/`, `*/ephemeral/`…)
- [ ] La cible est la bonne : `mobile → developpement → main`