#!/usr/bin/env bash
# installer-cabinet.sh — cours 026 (habilitations et accès), cabinet Brévant
#
# Recrée sur la VM l'état fautif du serveur de fichiers du cabinet :
#   - sept comptes (claire, antoine, sonia, karim, lea, hugo, maxime) ;
#   - un seul groupe, « cabinet », qui contient tout le monde ;
#   - quatre dossiers partagés sous /srv/cabinet, ouverts à tous ;
#   - Léa membre du groupe sudo « pour installer l'imprimante » ;
#   - le compte de Maxime, stagiaire parti en juillet 2026, toujours actif.
#
# Relançable : chaque lancement remet cet état fautif, quels que soient les
# réglages faits depuis (permissions, ACL, groupe sudo, compte verrouillé).
# Les groupes créés par l'étudiant ne sont pas supprimés, mais plus aucun
# dossier ne les utilise.
#
# Usage : sudo bash installer-cabinet.sh
#
# Tout est inventé : personnes, clients, montants, numéros de sécurité
# sociale (masqués par des X).

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Ce script modifie des comptes et des dossiers : le lancer avec sudo." >&2
  echo "  sudo bash $0" >&2
  exit 1
fi

RACINE=/srv/cabinet
COMPTES=(claire antoine sonia karim lea hugo maxime)

# Mots de passe : celui de Léa est celui que l'escroc a obtenu le 5 mars
# (cours 025, partie 3). Les autres sont le mot de passe initial posé en 2020
# par l'ancien prestataire, que personne n'a changé.
mot_de_passe() {
  case "$1" in
    lea) echo 'Brevant2019!' ;;
    *)   echo 'Cabinet2020!' ;;
  esac
}

nom_complet() {
  case "$1" in
    claire)  echo 'Claire Brevant (associee, gerante)' ;;
    antoine) echo 'Antoine Morel (associe)' ;;
    sonia)   echo 'Sonia (gestionnaire de paie)' ;;
    karim)   echo 'Karim (collaborateur comptable)' ;;
    lea)     echo 'Lea (accueil et secretariat)' ;;
    hugo)    echo 'Hugo (alternant en comptabilite)' ;;
    maxime)  echo 'Maxime (stagiaire, parti en juillet 2026)' ;;
  esac
}

echo "== Groupe unique « cabinet »"
getent group cabinet > /dev/null || groupadd cabinet

echo "== Comptes"
for c in "${COMPTES[@]}"; do
  if ! id "$c" > /dev/null 2>&1; then
    useradd --create-home --shell /bin/bash --comment "$(nom_complet "$c")" "$c"
  fi
  usermod --append --groups cabinet "$c"
  echo "$c:$(mot_de_passe "$c")" | chpasswd
  # Compte actif, quoi qu'on ait fait depuis (verrouillage, expiration).
  usermod --unlock "$c" > /dev/null 2>&1 || true
  usermod --expiredate '' "$c"
done

echo "== Léa dans le groupe sudo (« pour installer l'imprimante »)"
usermod --append --groups sudo lea

echo "== Dossiers partagés sous $RACINE"
mkdir -p "$RACINE"/{clients,paie,direction,accueil}

ecrire() { # ecrire CHEMIN : contenu lu sur l'entrée standard
  mkdir -p "$(dirname "$1")"
  cat > "$1"
}

ecrire "$RACINE/clients/boulangerie-delattre/releve-2027-01.txt" <<'EOF'
Boulangerie Delattre - relevé bancaire de janvier 2027 (extrait)
Solde au 31/01/2027 : 18 412,60 EUR
Déposé par le client sur le portail le 10/02/2027.
EOF
ecrire "$RACINE/clients/boulangerie-delattre/bilan-2026.txt" <<'EOF'
Boulangerie Delattre - bilan 2026 (projet)
Chiffre d'affaires : 412 300 EUR ; résultat : 38 950 EUR
EOF
ecrire "$RACINE/clients/garage-lefevre/honoraires-2027-02.txt" <<'EOF'
Garage Lefèvre - honoraires de février 2027 : 1 840,00 EUR
Statut : impayé (relance envoyée le 12/03/2027)
EOF
ecrire "$RACINE/clients/garage-lefevre/declaration-tva-2027-02.txt" <<'EOF'
Garage Lefèvre - déclaration de TVA de février 2027 (brouillon)
TVA collectée : 9 812 EUR ; TVA déductible : 4 130 EUR
EOF

ecrire "$RACINE/paie/2027-02/garage-lefevre/bulletin-dupuis-marion.txt" <<'EOF'
BULLETIN DE PAIE - février 2027 - Garage Lefèvre
Salariée : Marion Dupuis, mécanicienne
N° de sécurité sociale : 2 91 04 80 XXX XXX XX
Adresse : 4 rue des Prés, Abbeville
Salaire brut : 2 150,00 EUR ; net à payer : 1 684,72 EUR
IBAN : FR76 XXXX XXXX XXXX XXXX XXXX 117
EOF
ecrire "$RACINE/paie/2027-02/boulangerie-delattre/bulletin-roussel-kevin.txt" <<'EOF'
BULLETIN DE PAIE - février 2027 - Boulangerie Delattre
Salarié : Kévin Roussel, boulanger
N° de sécurité sociale : 1 88 11 80 XXX XXX XX
Adresse : 17 chemin du Moulin, Mareuil-Caubert
Salaire brut : 2 010,00 EUR ; net à payer : 1 571,30 EUR
Arrêt maladie du 08/02 au 14/02/2027
IBAN : FR76 XXXX XXXX XXXX XXXX XXXX 342
EOF

ecrire "$RACINE/direction/remunerations-associes-2027.txt" <<'EOF'
Rémunération des associés - prévisionnel 2027 - CONFIDENTIEL
Claire Brévant : 96 000 EUR ; Antoine Morel : 84 000 EUR
EOF
ecrire "$RACINE/direction/projet-rachat-cabinet-dumont.txt" <<'EOF'
Projet de rachat de la clientèle du cabinet Dumont (Amiens) - CONFIDENTIEL
Prix envisagé : 310 000 EUR. Signature visée : juin 2027.
Ne pas en parler aux salariés avant l'accord.
EOF

ecrire "$RACINE/accueil/planning-semaine-11.txt" <<'EOF'
Planning de l'accueil - semaine du 15 mars 2027
Lundi 9 h : M. Lefèvre (garage) avec Claire Brévant
Mardi 14 h : Mme Delattre (boulangerie) avec Karim
EOF
ecrire "$RACINE/accueil/annuaire-clients.csv" <<'EOF'
client;contact;courriel
Boulangerie Delattre;Marc Delattre;m.delattre@boulangerie-delattre.example
Garage Lefèvre;Paul Lefèvre;garage.lefevre@garage-lefevre.example
EOF

echo "== Permissions fautives : tout le cabinet lit et modifie tout"
# On retire d'abord ce que l'étudiant a pu poser (ACL, setgid), puis on remet
# l'état d'origine : dossiers et fichiers au groupe « cabinet », écriture pour
# le groupe, lecture pour tous.
if command -v setfacl > /dev/null; then
  setfacl -R -b "$RACINE"
fi
chown -R root:cabinet "$RACINE"
find "$RACINE" -type d -exec chmod 0775 {} +
find "$RACINE" -type f -exec chmod 0664 {} +

echo
echo "État fautif installé."
echo "  Comptes : ${COMPTES[*]}"
echo "  Mots de passe : lea = Brevant2019! (celui que l'escroc a obtenu) ; les autres = Cabinet2020!"
echo "  Dossiers : $RACINE/{clients,paie,direction,accueil}"
