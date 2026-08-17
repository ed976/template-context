---
name: create-hubspot-property
description: Crée une propriété custom sur l'objet Company HubSpot via l'API Properties.
disable-model-invocation: true
---

# create-hubspot-property

Procédure pour créer une propriété custom sur l'objet Company. Ne s'applique qu'à
Company — jamais Contact (voir règle dure #3 du CLAUDE.md).

## Étapes

1. **Vérifier l'absence de collision.**
   Chercher le nom de propriété envisagé dans `context/connectors/hubspot/schema.generated.json`
   (nom exact et variantes proches). Si une propriété existante couvre déjà le besoin,
   s'arrêter ici et le signaler plutôt que de créer un doublon.

1bis. **Préférer le natif.**
   Avant de créer une propriété custom, chercher dans `schema.generated.json` si un
   concept équivalent existe déjà sous forme de propriété native HubSpot (ex : un
   champ "secteur" correspond probablement à `industry`, un champ "effectif" à
   `numberofemployees`, un champ "domaine" à `domain`). La correspondance est
   sémantique, pas un match texte exact sur le nom du champ source. Si une
   propriété native couvre le concept, l'utiliser et NE PAS créer de custom, même
   si le nom du champ source ne correspond pas mot pour mot. Documenter ce choix
   dans `docs/JOURNAL.md`, une ligne par mapping, au format :
   `YYYY-MM-DD — source: <champ source> → HubSpot: <nom propriété> (native|créée) — <pourquoi>`

2. **Construire le payload.**
   Format conforme à l'API Properties HubSpot (`name`, `label`, `type`, `fieldType`,
   `groupName`, `description`, `options` si `enumeration`). Respecter les conventions
   de `context/domain/naming.md`.

3. **Écrire la définition.**
   Sauvegarder le payload dans `definitions/properties/<nom>.json` — c'est la source
   de vérité versionnée, à créer/modifier avant tout appel API.

4. **Appliquer via scripts/hs.**
   `./scripts/hs POST /crm/v3/properties/companies "$(cat definitions/properties/<nom>.json)"`
   Jamais de curl ad hoc (règle dure #6).

5. **Régénérer schema.generated.json.**
   Re-dumper le schéma Company complet (`./scripts/hs GET /crm/v3/properties/companies`)
   et écraser `context/connectors/hubspot/schema.generated.json`.

6. **Confirmer.**
   Vérifier que la nouvelle propriété apparaît bien dans le dump régénéré. Si absente,
   traiter comme un échec — ne pas déclarer la tâche terminée.

## Interdits

- Ne jamais créer de propriété sans être passé par les étapes 1 et 1bis.
- Ne jamais créer une propriété custom quand une propriété native couvre déjà le
  concept (même sous un nom différent) sans le justifier dans `docs/JOURNAL.md`.
- Ne jamais éditer `schema.generated.json` à la main — uniquement via régénération.
- Ne jamais créer de propriété sur Contact.
