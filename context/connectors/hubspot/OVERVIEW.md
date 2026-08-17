# HubSpot — état du portail de test

Portal ID: 149090797
Tier au 17/08/2026: Free (upgrade Pro en trial prévu, pas encore actif)
Scopes de la clé de service: crm.schemas.companies.write, crm.objects.companies.read/write, automation

## État actuel
Portail vide : aucune company, aucune propriété custom sur Company, pipeline deal par défaut.

## Ce qui existe déjà et pourrait entrer en collision
Aucune collision détectée sur un premier passage (recherche sur "tier", "segment",
"score", "lifecycle"). Une seule propriété pertinente trouvée : lifecyclestage
(native, sync Contact→Company). Voir schema.generated.json pour le détail complet.

## Pièges connus
lifecyclestage suppose un objet Contact associé pour se peupler correctement —
non pertinent ici puisque le design n'utilise pas de Contact.
