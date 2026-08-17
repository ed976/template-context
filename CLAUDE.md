# loyoly-gtm

## Projet
Loyoly — SaaS B2B (loyalty/referral) vendant à des e-commerçants Shopify/Prestashop.
Ce repo teste une expérience TAM/SAM/SOM sur un portail HubSpot de test (Portal ID
149090797, actuellement Free), via API directe (private app / service key), dans le
cadre d'un audit GTM Engineering plus large : peut-on structurer un repo de contexte
pour que Claude exécute correctement des tâches CRM et vérifie lui-même son travail.

## Règles dures
1. Jamais de write HubSpot sans dry-run préalable (tout flow créé avec isEnabled: false)
2. Jamais de propriété créée sans vérifier l'absence de collision dans schema.generated.json
3. Jamais d'objet Contact créé — le design de ce test est volontairement Company-only
4. Jamais d'activation de flow par l'agent — l'activation est une étape humaine
5. Le token HubSpot ne doit jamais apparaître dans une sortie affichée ou un commit
6. Tous les appels HubSpot passent par scripts/hs, jamais par un curl ad hoc
7. Préférer une propriété native existante à la création d'une custom — correspondance
   sémantique (ex: "secteur" → industry), pas seulement textuelle. S'applique à toute
   création de propriété et à tout import de companies. Choix documenté dans docs/JOURNAL.md

## Carte du repo
- context/connectors/hubspot/ — état du portail HubSpot (schéma, portail, pièges)
- context/domain/ — conventions de nommage
- definitions/ — propriétés et flows HubSpot en JSON, source de vérité
- docs/BRIEF.md — tâche en cours (écrasé à chaque nouvelle tâche)
- docs/JOURNAL.md — décisions et leçons, append-only
- scripts/hs — wrapper curl authentifié vers l'API HubSpot
