# UADB Social

Réseau social interne de l'Université Alioune Diop de Bambey (UADB).

## Organisation des branches

| Branche         | Rôle                                                      |
|-----------------|-----------------------------------------------------------|
| `main`          | Base de référence du dépôt (volontairement vide)          |
| `developpement` | Développement de la plateforme (web, API, etc.)           |
| `mobile`        | Application mobile Flutter (`mobile/`)                    |

Le code de l'application mobile se trouve sur la branche `mobile` :

```sh
git checkout mobile
```

Tous les travaux de développement se font sur une branche dédiée ;
`main` ne reçoit que des intégrations validées.