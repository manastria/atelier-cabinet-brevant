# atelier-cabinet-brevant

Fichiers des cours de cybersécurité du « cabinet Brévant » (BTS SIO SISR,
1re année). Le cabinet, ses salariés, ses clients et ses domaines sont
inventés. Les domaines se terminent par `.example` et les adresses IP
appartiennent aux plages réservées à la documentation (RFC 2606 et
RFC 5737) : aucun ne désigne une machine réelle.

## Récupérer les fichiers (étudiant)

Sur la machine virtuelle :

```bash
cd ~
git clone https://github.com/manastria/atelier-cabinet-brevant.git
cd atelier-cabinet-brevant
```

## Contenu

| Dossier | Cours | Contenu |
|---|---|---|
| `courriels/` | 025, partie 2 | Trois courriels en texte brut (`.eml`) : un relevé ordinaire d'un client, le courriel piégé reçu par Léa, le courriel au faux RIB envoyé aux clients |
| `poste-lea/` | 025, partie 4 | Relevé du poste de l'accueil (système, mises à jour, antivirus, logiciels) |
| `cabinet/` | 026, parties 1 à 4 | `installer-cabinet.sh` : recrée sur la VM le serveur de fichiers du cabinet dans son état fautif (comptes, groupe unique, dossiers `/srv/cabinet` ouverts à tous). À lancer avec `sudo` ; relançable, il remet l'état fautif |
| `portail/` | 027 | `installer-portail.sh` : installe le portail de dépôt des clients (Apache, PHP, SQLite), `http://depot.cabinet-brevant.example/`, ouvert à la VM seule. À lancer avec `sudo`, avec un accès à Internet la première fois ; `--corrige` installe la version corrigée. Relançable : il recrée la base, sans toucher aux journaux d'Apache |

Les fichiers du dernier cours (preuves) s'ajouteront dans un autre dossier.

## Mettre à jour les fichiers

Si le dépôt a déjà été récupéré lors d'un cours précédent :

```bash
cd ~/atelier-cabinet-brevant
git pull
```
