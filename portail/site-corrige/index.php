<?php
// index.php — page d'accueil : renvoie vers « Mes factures » ou la connexion.

require 'commun.php';

header('Location: ' . (empty($_SESSION['client_id']) ? 'connexion.php' : 'factures.php'));
