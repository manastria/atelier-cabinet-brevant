#!/usr/bin/env bash
# installer-portail.sh — cours 027 (injection SQL), cabinet Brévant
#
# Installe sur la VM le portail de dépôt du cabinet
# (http://depot.cabinet-brevant.example/), tel qu'il était le jour de
# l'incident : PHP + SQLite, développé en 2017, plus maintenu depuis.
#
#   sudo bash installer-portail.sh            version d'origine, vulnérable
#   sudo bash installer-portail.sh --corrige  version corrigée (partie 4)
#
# Le script :
#   - installe les paquets manquants (Apache, PHP, module SQLite de PHP) :
#     il faut un accès à Internet la première fois ;
#   - n'ouvre le site qu'à la VM elle-même (adresse 127.0.0.1) : personne
#     d'autre sur le réseau ne peut l'atteindre ;
#   - copie le site dans /var/www/portail et recrée la base
#     /var/lib/portail/portail.db (les pièces déposées depuis sont perdues).
#
# Relançable. Il ne touche jamais aux journaux d'Apache
# (/var/log/apache2/) : ils gardent la trace de tes requêtes, qui serviront
# de preuves au cours suivant.

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Ce script installe des paquets et un site web : le lancer avec sudo." >&2
  echo "  sudo bash $0" >&2
  exit 1
fi

VERSION=vulnerable
case "${1:-}" in
  '') ;;
  --corrige) VERSION=corrige ;;
  *) echo "Option inconnue : $1 (seule option : --corrige)" >&2; exit 1 ;;
esac

ICI=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
NOM=depot.cabinet-brevant.example
SITE=/var/www/portail
DONNEES=/var/lib/portail
PAQUETS=(apache2 libapache2-mod-php php-cli php-sqlite3)

if [[ $VERSION == corrige ]]; then
  SOURCE="$ICI/site-corrige"
else
  SOURCE="$ICI/site"
fi

echo "== Paquets : ${PAQUETS[*]}"
manquants=()
for p in "${PAQUETS[@]}"; do
  dpkg-query -W -f='${Status}' "$p" 2> /dev/null | grep -q 'install ok installed' \
    || manquants+=("$p")
done
if (( ${#manquants[@]} )); then
  echo "   À installer : ${manquants[*]}"
  if ! { apt-get update && apt-get install -y "${manquants[@]}"; }; then
    echo >&2
    echo "L'installation des paquets a échoué. Vérifie l'accès à Internet" >&2
    echo "(au lycée : voir la fiche « Configurer le proxy pour installer des" >&2
    echo "logiciels sous Debian/Ubuntu »)," >&2
    echo "puis relance ce script." >&2
    exit 1
  fi
else
  echo "   Déjà installés."
fi

echo "== Apache : site $NOM, ouvert à la VM seule (127.0.0.1)"
sed -i 's/^Listen 80$/Listen 127.0.0.1:80/' /etc/apache2/ports.conf
cat > /etc/apache2/sites-available/portail.conf <<EOF
# Portail de dépôt du cabinet Brévant (cours 027), créé par installer-portail.sh
<VirtualHost 127.0.0.1:80>
    ServerName $NOM
    ServerAlias localhost
    DocumentRoot $SITE
    DirectoryIndex index.php
    <Directory $SITE>
        Require all granted
    </Directory>
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF
a2dissite -q 000-default > /dev/null 2>&1 || true
a2ensite -q portail > /dev/null

echo "== Nom $NOM → 127.0.0.1 (/etc/hosts)"
grep -q "[[:space:]]$NOM\$" /etc/hosts || echo "127.0.0.1	$NOM" >> /etc/hosts

echo "== Site : $SITE (version $VERSION)"
rm -rf "$SITE"
mkdir -p "$SITE"
cp "$SOURCE"/* "$SITE"/
chown -R root:root "$SITE"
chmod 0755 "$SITE"
chmod 0644 "$SITE"/*

echo "== Base : $DONNEES/portail.db (état au 15 mars 2027)"
# SQLite écrit un fichier temporaire à côté de la base : le serveur web doit
# pouvoir écrire dans le dossier.
mkdir -p "$DONNEES"
rm -f "$DONNEES"/portail.db*
php -r '
  $pdo = new PDO("sqlite:" . $argv[1]);
  $pdo->exec(file_get_contents($argv[2]));
' "$DONNEES/portail.db" "$ICI/base.sql"
if [[ $VERSION == corrige ]]; then
  echo "   Mots de passe remplacés par leur empreinte (password_hash)"
  php -r '
    $pdo = new PDO("sqlite:" . $argv[1]);
    $maj = $pdo->prepare("UPDATE comptes SET mot_de_passe = ? WHERE id = ?");
    foreach ($pdo->query("SELECT id, mot_de_passe FROM comptes") as $c) {
      $maj->execute([password_hash($c["mot_de_passe"], PASSWORD_DEFAULT), $c["id"]]);
    }
  ' "$DONNEES/portail.db"
fi
chown -R www-data:www-data "$DONNEES"
chmod 0750 "$DONNEES"
chmod 0640 "$DONNEES/portail.db"

echo "== Redémarrage d'Apache"
systemctl enable --quiet apache2
systemctl restart apache2

echo
if [[ $VERSION == corrige ]]; then
  echo "Portail corrigé installé (version 1.4)."
else
  echo "Portail installé (version 1.3 de 2017, vulnérable)."
fi
echo "  Adresse : http://$NOM/"
echo "  Compte client : garage-lefevre / Lefevre1987"
echo "  Journal des requêtes : /var/log/apache2/access.log"
