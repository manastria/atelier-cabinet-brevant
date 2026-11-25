<?php
// deconnexion.php — ferme la session du client.

require 'commun.php';

$_SESSION = [];
session_destroy();
header('Location: connexion.php');
