<?php
// requete.php — interrupteur « afficher la requête » (exercice) : montre ou
// cache, sous chaque page, la requête SQL que le site envoie à la base.

$nouvel_etat = (($_COOKIE['voir_requete'] ?? '') === '1') ? '0' : '1';
setcookie('voir_requete', $nouvel_etat, ['expires' => time() + 86400 * 30, 'path' => '/']);

$pages = ['connexion', 'factures', 'deposer'];
$retour = in_array($_GET['retour'] ?? '', $pages, true) ? $_GET['retour'] : 'connexion';
header("Location: $retour.php");
