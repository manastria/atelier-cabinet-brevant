<?php
// deposer.php — dépôt d'une pièce (facture, relevé) par le client connecté.
// Version d'exercice : le fichier n'est pas conservé, seul son nom est
// enregistré dans la base.

require 'commun.php';
exiger_connexion();

$sql = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $document = $_FILES['fichier']['name'] ?? '';
    $montant = str_replace(',', '.', $_POST['montant'] ?? '');
    $montant = $montant === '' ? null : $montant;
    $date = date('Y-m-d');
    $annee = date('Y');
    $client_id = $_SESSION['client_id'];

    if ($document === '') {
        $message = 'Choisissez un fichier.';
    } else {
        $sql = "INSERT INTO factures (client_id, annee, date_depot, document, montant) VALUES (?, ?, ?, ?, ?)";
        try {
            base()->prepare($sql)->execute([$client_id, $annee, $date, $document, $montant]);
            if (!voir_requete()) {
                header("Location: factures.php?annee=$annee");
                exit;
            }
            $message = "Pièce enregistrée : $document.";
        } catch (PDOException $e) {
            $erreur = $e;
        }
    }
}

haut('Déposer une pièce', 'deposer');
?>
<form method="post" action="deposer.php" enctype="multipart/form-data" class="formulaire">
  <label>Fichier <input type="file" name="fichier" required></label>
  <label>Montant TTC (facultatif) <input name="montant" inputmode="decimal" placeholder="1234,56"></label>
  <button type="submit">Déposer</button>
</form>
<?php
if (!empty($message)) {
    echo '<p>' . h($message) . "</p>\n";
}
if (isset($erreur)) {
    erreur_sql($erreur);
}
if ($sql) {
    montrer_requete($sql, [$client_id, $annee, $date, $document, $montant ?? 'NULL']);
}
bas();
