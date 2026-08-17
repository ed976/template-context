# Conventions de nommage

## Général
- kebab-case partout (fichiers, dossiers, noms de propriétés HubSpot, noms de flows).
- Pas d'accents, pas d'espaces, pas de majuscules.
- Le nom dit la **nature** du fichier, pas son **sujet**. Ex : `schema.generated.json`
  (nature = généré, jamais édité à la main) plutôt que `hubspot-companies.json`
  (qui ne dit rien sur comment le traiter).

## Marqueurs de nature
- `*.generated.*` — fichier produit par un script/appel API, jamais édité à la main.
  Toute édition manuelle sera écrasée à la prochaine régénération et est bloquée par
  `.claude/settings.json`.
- `OVERVIEW.md` — écrit à la main, à lire en premier dans son dossier. Résume l'état
  et les pièges connus, ne remplace pas la source de vérité générée.

## Chronologique
- Préfixer par une date (`YYYY-MM-DD-`) tout fichier dont l'ordre chronologique compte
  (ex : entrées de journal, décisions datées). `docs/JOURNAL.md` est l'exception :
  append-only avec une ligne datée par entrée, pas un fichier par date.

## Skills
- Nom de skill = verbe + objet, ex : `create-hubspot-property`, `create-hubspot-workflow`.
  Pas de nom vague (`hubspot-helper`) ni de nom en nom commun seul (`property`).

## Définitions HubSpot
- `definitions/properties/<nom-de-la-propriete>.json`
- `definitions/flows/<nom-du-flow>.json`
Le nom de fichier correspond exactement au `name` de la ressource côté HubSpot.
