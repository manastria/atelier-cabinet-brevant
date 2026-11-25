<?php
// factures.php — « Mes factures » : les pièces déposées par le client
// connecté, année par année (paramètre « annee » dans l'adresse).

require 'commun.php';
exiger_connexion();

if (!isset($_GET['annee'])) {
    header('Location: factures.php?annee=' . ANNEE_EN_COURS);
    exit;
}

$annee = $_GET['annee'];
$client_id = $_SESSION['client_id'];

haut("Mes factures — $annee", 'factures');
?>
<p class="annees">Année :
  <a href="factures.php?annee=2026">2026</a>
  <a href="factures.php?annee=2027">2027</a>
</p>
<?php
$sql = "SELECT date_depot, document, montant FROM factures WHERE client_id = ? AND annee = ? ORDER BY date_depot";

try {
    $requete = base()->prepare($sql);
    $requete->execute([$client_id, $annee]);
    $lignes = $requete->fetchAll(PDO::FETCH_NUM);
    if (!$lignes) {
        echo "<p>Aucune pièce déposée pour cette année.</p>\n";
    } else {
        echo "<table>\n<tr><th>Déposé le</th><th>Document</th><th>Montant</th></tr>\n";
        foreach ($lignes as [$date, $document, $montant]) {
            if (is_numeric($montant)) {
                $montant = number_format((float) $montant, 2, ',', ' ') . ' €';
            } elseif ($montant === null) {
                $montant = '—';
            }
            echo '<tr><td>' . h($date) . '</td><td>' . h($document)
                . '</td><td class="montant">' . h($montant) . "</td></tr>\n";
        }
        echo "</table>\n";
    }
} catch (PDOException $e) {
    erreur_sql($e);
}

montrer_requete($sql, [$client_id, $annee]);
bas();
