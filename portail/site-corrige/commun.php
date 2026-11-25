<?php
// commun.php — fonctions partagées par toutes les pages du portail.

session_start();

const VERSION = 'Portail de dépôt 1.4 (correctif de sécurité)';
const BASE = '/var/lib/portail/portail.db';
const ANNEE_EN_COURS = '2027';

// Ouvre la base SQLite. En cas d'erreur SQL, PDO lève une exception.
function base(): PDO
{
    $pdo = new PDO('sqlite:' . BASE);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    return $pdo;
}

// Échappe un texte avant de l'afficher dans la page.
function h($texte): string
{
    return htmlspecialchars((string) $texte, ENT_QUOTES, 'UTF-8');
}

// Renvoie vers la page de connexion si personne n'est connecté.
function exiger_connexion(): void
{
    if (empty($_SESSION['client_id'])) {
        header('Location: connexion.php');
        exit;
    }
}

// Interrupteur « afficher la requête » (cookie posé par requete.php).
function voir_requete(): bool
{
    return ($_COOKIE['voir_requete'] ?? '') === '1';
}

// Affiche la requête envoyée à la base, si l'interrupteur est sur « oui ».
// Requête préparée : les valeurs partent à part, chacune à la place d'un « ? ».
function montrer_requete(string $sql, array $valeurs = []): void
{
    if (voir_requete()) {
        echo '<div class="requete"><p>Requête envoyée à la base :</p><pre>'
            . h($sql) . "</pre>\n";
        foreach ($valeurs as $i => $valeur) {
            echo '<p>Valeur n° ' . ($i + 1) . ', envoyée à part :</p><pre>'
                . h($valeur) . "</pre>\n";
        }
        echo "</div>\n";
    }
}

// Signale une erreur sans rien en dire au visiteur ; le détail part dans le
// journal d'erreurs du serveur web, que seul l'administrateur lit.
function erreur_sql(PDOException $e): void
{
    error_log('portail : erreur SQL : ' . $e->getMessage());
    echo "<p class=\"erreur\">Une erreur est survenue. Réessayez plus tard.</p>\n";
}

function haut(string $titre, string $page): void
{
    $etat = voir_requete() ? 'oui' : 'non';
    $titre = h($titre);
    echo <<<HTML
<!DOCTYPE html>
<html lang="fr">
<head>
<meta charset="utf-8">
<title>{$titre} — Cabinet Brévant &amp; Associés</title>
<link rel="stylesheet" href="style.css">
</head>
<body>
<header>
  <p class="cabinet">Cabinet Brévant &amp; Associés</p>
  <p class="sous-titre">Expertise comptable — Abbeville — Portail de dépôt des pièces</p>
</header>
<nav>

HTML;
    if (!empty($_SESSION['client_id'])) {
        echo '  <span>Connecté : ' . h($_SESSION['client']) . "</span>\n";
        echo "  <a href=\"factures.php\">Mes factures</a>\n";
        echo "  <a href=\"deposer.php\">Déposer une pièce</a>\n";
        echo "  <a href=\"deconnexion.php\">Se déconnecter</a>\n";
    }
    echo "  <a class=\"interrupteur\" href=\"requete.php?retour={$page}\">"
        . "Afficher la requête : <strong>{$etat}</strong></a>\n";
    echo "</nav>\n<main>\n<h1>{$titre}</h1>\n";
}

function bas(): void
{
    echo "</main>\n<footer>" . VERSION . "</footer>\n</body>\n</html>\n";
}
