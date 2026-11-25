-- base.sql — base du portail de dépôt du cabinet Brévant (cours 027)
--
-- État de la base au lundi 15 mars 2027, jour où tu arrives au cabinet.
-- Les mots de passe sont stockés en clair : c'est l'un des défauts du
-- portail, développé en 2017 et plus maintenu depuis.
--
-- Tout est inventé : clients, personnes, adresses, montants. Les IBAN sont
-- masqués par des X.

CREATE TABLE comptes (
  id            INTEGER PRIMARY KEY,
  identifiant   TEXT NOT NULL UNIQUE,
  mot_de_passe  TEXT NOT NULL,
  client        TEXT NOT NULL,
  contact       TEXT,
  courriel      TEXT,
  iban          TEXT,
  interlocuteur TEXT
);

CREATE TABLE factures (
  id         INTEGER PRIMARY KEY,
  client_id  INTEGER NOT NULL REFERENCES comptes(id),
  annee      TEXT NOT NULL,
  date_depot TEXT NOT NULL,
  document   TEXT NOT NULL,
  montant    REAL
);

-- Le compte « demo » a été créé par le développeur en 2017 pour montrer le
-- portail au cabinet. Personne ne l'a supprimé.
INSERT INTO comptes VALUES
  (1, 'demo', 'demo', 'Compte de démonstration', 'Développeur du portail',
      'demo@depot.cabinet-brevant.example', NULL, NULL),
  (2, 'garage-lefevre', 'Lefevre1987', 'Garage Lefèvre', 'Paul Lefèvre',
      'garage.lefevre@garage-lefevre.example',
      'FR76 XXXX XXXX XXXX XXXX XXXX 117', 'lea@cabinet-brevant.example'),
  (3, 'boulangerie-delattre', 'Pain80100', 'Boulangerie Delattre',
      'Marc Delattre', 'm.delattre@boulangerie-delattre.example',
      'FR76 XXXX XXXX XXXX XXXX XXXX 342', 'lea@cabinet-brevant.example'),
  (4, 'pharmacie-somme', 'Pharmacie2018', 'Pharmacie de la Somme',
      'Isabelle Caron', 'contact@pharmacie-somme.example',
      'FR76 XXXX XXXX XXXX XXXX XXXX 508', 'karim@cabinet-brevant.example'),
  (5, 'taxi-baie', 'azerty', 'Taxi de la Baie', 'Julien Bertin',
      'taxi.baie@courrier-rapide.example',
      'FR76 XXXX XXXX XXXX XXXX XXXX 226', 'lea@cabinet-brevant.example'),
  (6, 'fleurs-marianne', 'Marianne80', 'Fleurs Marianne', 'Marianne Petit',
      'fleurs.marianne@fleurs-marianne.example',
      'FR76 XXXX XXXX XXXX XXXX XXXX 731', 'karim@cabinet-brevant.example'),
  (7, 'plomberie-duval', 'Duval2017', 'Plomberie Duval', 'Thierry Duval',
      'thierry.duval@plomberie-duval.example',
      'FR76 XXXX XXXX XXXX XXXX XXXX 964', 'lea@cabinet-brevant.example'),
  (8, 'hotel-du-port', 'HotelPort!', 'Hôtel du Port', 'Nadia Benali',
      'direction@hotel-du-port.example',
      'FR76 XXXX XXXX XXXX XXXX XXXX 085', 'antoine@cabinet-brevant.example');

INSERT INTO factures (client_id, annee, date_depot, document, montant) VALUES
  -- Garage Lefèvre (compte utilisé en partie 1)
  (2, '2026', '2026-01-08', 'facture-pieces-auto-picardie-2025-12.pdf', 2318.40),
  (2, '2026', '2026-04-09', 'facture-pieces-auto-picardie-2026-03.pdf', 1974.15),
  (2, '2026', '2026-07-10', 'facture-pont-elevateur-entretien.pdf', 486.00),
  (2, '2026', '2026-10-08', 'facture-pieces-auto-picardie-2026-09.pdf', 2602.90),
  (2, '2027', '2027-01-11', 'facture-pieces-auto-picardie-2026-12.pdf', 2140.55),
  (2, '2027', '2027-02-09', 'facture-electricite-2027-01.pdf', 312.70),
  (2, '2027', '2027-03-08', 'facture-pieces-auto-picardie-2027-02.pdf', 1866.30),
  -- Boulangerie Delattre : dépose chaque mois, suivie par Léa
  (3, '2026', '2026-01-12', 'releve-banque-2025-12.pdf', NULL),
  (3, '2026', '2026-02-10', 'releve-banque-2026-01.pdf', NULL),
  (3, '2026', '2026-03-09', 'releve-banque-2026-02.pdf', NULL),
  (3, '2026', '2026-03-09', 'facture-farine-moulin-picard-2026-02.pdf', 1420.80),
  (3, '2026', '2026-06-10', 'releve-banque-2026-05.pdf', NULL),
  (3, '2026', '2026-09-08', 'releve-banque-2026-08.pdf', NULL),
  (3, '2026', '2026-12-09', 'releve-banque-2026-11.pdf', NULL),
  (3, '2027', '2027-01-11', 'releve-banque-2026-12.pdf', NULL),
  (3, '2027', '2027-01-11', 'facture-farine-moulin-picard-2026-12.pdf', 1588.20),
  (3, '2027', '2027-02-10', 'releve-banque-2027-01.pdf', NULL),
  (3, '2027', '2027-02-12', 'facture-reparation-four.pdf', 890.00),
  -- Pharmacie de la Somme
  (4, '2026', '2026-02-16', 'facture-grossiste-2026-01.pdf', 48210.35),
  (4, '2026', '2026-08-17', 'facture-grossiste-2026-07.pdf', 45987.10),
  (4, '2027', '2027-02-15', 'facture-grossiste-2027-01.pdf', 51032.60),
  -- Taxi de la Baie
  (5, '2026', '2026-05-04', 'facture-entretien-vehicule.pdf', 642.30),
  (5, '2027', '2027-01-25', 'facture-carburant-2026-t4.pdf', 2875.40),
  -- Fleurs Marianne
  (6, '2026', '2026-02-02', 'facture-grossiste-fleurs-2026-01.pdf', 1934.00),
  (6, '2027', '2027-02-15', 'facture-grossiste-fleurs-2027-02.pdf', 3120.75),
  -- Plomberie Duval
  (7, '2026', '2026-11-30', 'facture-fournitures-sanitaire-2026-11.pdf', 1288.45),
  (7, '2027', '2027-03-01', 'facture-fournitures-sanitaire-2027-02.pdf', 1012.60),
  -- Hôtel du Port
  (8, '2026', '2026-07-06', 'facture-blanchisserie-2026-06.pdf', 2214.00),
  (8, '2027', '2027-03-05', 'facture-blanchisserie-2027-02.pdf', 1176.50);
