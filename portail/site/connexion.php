<?php
// connexion.php — connexion d'un client au portail.

require 'commun.php';

$message = '';
$sql = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $identifiant = $_POST['identifiant'] ?? '';
    $mot_de_passe = $_POST['mot_de_passe'] ?? '';

    $sql = "SELECT id, client FROM comptes WHERE identifiant = '$identifiant' AND mot_de_passe = '$mot_de_passe'";
    try {
        $compte = base()->query($sql)->fetch(PDO::FETCH_ASSOC);
        if ($compte) {
            $_SESSION['client_id'] = $compte['id'];
            $_SESSION['client'] = $compte['client'];
            header('Location: factures.php');
            exit;
        }
        $message = 'Identifiant ou mot de passe incorrect.';
    } catch (PDOException $e) {
        $erreur = $e;
    }
}

haut('Connexion', 'connexion');
?>
<p>Déposez vos factures et relevés bancaires : votre comptable les retrouve
dès le lendemain.</p>

<form method="post" action="connexion.php" class="formulaire">
  <label>Identifiant <input name="identifiant" required autofocus></label>
  <label>Mot de passe <input name="mot_de_passe" type="password" required></label>
  <button type="submit">Se connecter</button>
</form>
<?php
if ($message) {
    echo '<p class="erreur">' . h($message) . "</p>\n";
}
if (isset($erreur)) {
    erreur_sql($erreur);
}
if ($sql) {
    montrer_requete($sql);
}
bas();
