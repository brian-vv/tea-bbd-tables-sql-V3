set datestyle to 'european'; 

DROP TABLE IF EXISTS membres;
DROP TABLE IF EXISTS producteurs;
DROP TABLE IF EXISTS vins;
DROP TABLE IF EXISTS commandes;

CREATE TABLE membres (
  nomembre INTEGER
    CHECK (nomembre > 50), 
  nom VARCHAR(30) NOT NULL , 
  prenom VARCHAR(30) NOT NULL, 
  ville VARCHAR(50) NOT NULL,
  pxabonnement INTEGER NOT NULL ,
  PRIMARY KEY(nomembre)
);

CREATE TABLE producteurs (
  noprocducteur CHAR(5) NOT NULL
    CHECK (noprocducteur LIKE 'PDT__'),
  nom VARCHAR(30) NOT NULL , 
  prenom VARCHAR(30), 
  ville VARCHAR(50) NOT NULL, 
  PRIMARY KEY(noprocducteur)
    
);

CREATE TABLE vins (

  novin CHAR(5) NOT NULL
    CHECK (novin LIKE 'VIN__'),
  millesime INTEGER NOT NULL , 
  pxvente INTEGER NOT NULL ,
  chargevariable FLOAT NOT NULL,
  chargefixe FLOAT NOT NULL,
  noprocducteur CHAR(5) NOT NULL
    CHECK (noprocducteur LIKE 'PDT%'),
  PRIMARY KEY(novin),
  FOREIGN KEY(noprocducteur) REFERENCES producteurs
    
);


CREATE TABLE commandes (
  nocommande INTEGER NOT NULL,
  datecommande DATE NOT NULL ,
  qtecommandee SMALLINT,
  nomembre INTEGER NOT NULL,
  novin CHAR(5) NOT NULL
    CHECK (novin LIKE 'VIN%'),
  PRIMARY KEY(nocommande),
  FOREIGN KEY(nomembre) REFERENCES membres,
  FOREIGN KEY(novin) REFERENCES vins

    
);


INSERT INTO membres VALUES ( 51, 'Arnaud', 'Jean', 'Bordeaux', 20);
INSERT INTO membres VALUES ( 52, 'Elleau', 'Pierre', 'Bordeaux', 15);
INSERT INTO membres VALUES ( 53, 'Junior', 'Julien', 'Pau', 30);
INSERT INTO membres VALUES ( 54, 'Cassi', 'Amandine', 'Toulouse', 15);
INSERT INTO membres VALUES ( 55, 'François', 'Halle', 'Biarritz', 15);

INSERT INTO producteurs VALUES ('PDT01', 'Yann', NULL, 'Nice');
INSERT INTO producteurs VALUES ('PDT23', 'Jean', 'Corentin', 'Bordeaux');
INSERT INTO producteurs VALUES ('PDT65', 'Bidet', 'Paul', 'Marseille');
INSERT INTO producteurs VALUES ('PDT98', 'Vinet', 'Brian', 'Montpellier');
INSERT INTO producteurs VALUES ('PDT87', 'Kolo', NULL, 'Bordeaux');


INSERT INTO vins VALUES ( 'VIN45', 2006, 50, 6.76, 100, 'PDT01');
INSERT INTO vins VALUES ( 'VIN56', 2002, 42, 8.56, 100, 'PDT23');
INSERT INTO vins VALUES ( 'VIN76', 1999, 37, 9.30, 100, 'PDT87');
INSERT INTO vins VALUES ( 'VIN13', 2003, 41, 5.41, 100, 'PDT65');
INSERT INTO vins VALUES ( 'VIN35', 1999, 54, 7.80, 100, 'PDT98');
INSERT INTO vins VALUES ( 'VIN98', 1998, 65, 11.45, 100, 'PDT87');
INSERT INTO vins VALUES ( 'VIN41', 1998, 76, 10.60, 100, 'PDT23');
INSERT INTO vins VALUES ( 'VIN72', 2002, 45, 8.90, 100, 'PDT23');
INSERT INTO vins VALUES ( 'VIN49', 1999, 38, 7.48, 100, 'PDT98');
INSERT INTO vins VALUES ( 'VIN19', 1999, 61, 12.67, 100, 'PDT01');
INSERT INTO vins VALUES ( 'VIN37', 2003, 50, 9.10, 100, 'PDT23');


INSERT INTO  commandes VALUES ( 1042, '16/02/2020', 5, 51, 'VIN56');
INSERT INTO  commandes VALUES ( 1043, '19/02/2020', 4, 53, 'VIN49');
INSERT INTO  commandes VALUES ( 1044, '24/03/2020', 4, 51, 'VIN45');
INSERT INTO  commandes VALUES ( 1045, '27/05/2020', 7, 52, 'VIN72');
INSERT INTO  commandes VALUES ( 1046, '21/05/2020', 4, 55, 'VIN19');
INSERT INTO  commandes VALUES ( 1047, '14/06/2020', 8, 54, 'VIN56');
INSERT INTO  commandes VALUES ( 1048, '11/06/2020', 12, 53, 'VIN13');
INSERT INTO  commandes VALUES ( 1049, '26/07/2020', 3, 51, 'VIN45');
INSERT INTO  commandes VALUES ( 1050, '17/12/2020', 5, 55, 'VIN13');
INSERT INTO  commandes VALUES ( 1051, '15/12/2020', 8, 51, 'VIN35');
INSERT INTO  commandes VALUES ( 1052, '29/12/2020', 9, 53, 'VIN56');

-------------------------------------------------------------------------------------------------

--moyenne des commandes, min de commande et max de commande--
select ROUND(AVG(qtecommandee)) as moyenne_commande, 
MIN(qtecommandee), 
MAX(qtecommandee), 
ROUND(AVG(millesime)) as moyenne_age_vin 
from commandes
join vins on vins.novin = commandes.novin

--le novin le plus commandé --
select novin, COUNT(novin) as nb from commandes
GROUP BY novin
HAVING COUNT(novin) >= ALL(select COUNT(novin) as nb from commandes
GROUP BY novin)

--cb de bouteilles commandées entre février/mai et en décembre--
select SUM(qtecommandee) from commandes where datecommande BETWEEN '16/02/2020' AND '27/05/2020'
UNION 
select SUM(qtecommandee) from commandes where datecommande BETWEEN '15/12/2020' AND '29/12/2020'


--le nb de commande par vins et même les vins qui n'ont pas été encore commandés--
select vins.novin, SUM(qtecommandee) AS nb_commande from vins
left join commandes on commandes.novin = vins.novin
GROUP BY vins.novin 
ORDER BY nb_commande DESC


--le résultat de chaque vin et son taux de profit --
select noprocducteur, 
  novin, 
  nb_commande, 
  pxvente, 
  CA, 
  cv, 
  chargefixe,
  resultat, 
  (resultat/CA)*100 as txprofit 
from (
      select producteurs.noprocducteur, vins.novin,
        SUM(commandes.qtecommandee) as nb_commande, 
        pxvente,
        pxvente*SUM(commandes.qtecommandee) as CA, 
        ROUND(chargevariable*SUM(commandes.qtecommandee)) as cv, 
        chargefixe, 
        pxvente*SUM(commandes.qtecommandee)-chargevariable*SUM(commandes.qtecommandee)-chargefixe as resultat
      from producteurs
      join vins on vins.noprocducteur = producteurs.noprocducteur
      join commandes on commandes.novin = vins.novin
      GROUP BY producteurs.noprocducteur, vins.novin, pxvente
      ORDER BY producteurs.nom
    ) as req_sub

GROUP BY noprocducteur, novin, nb_commande, pxvente, CA, cv, chargefixe,resultat, resultat/CA
ORDER BY noprocducteur


--le total qu'a dépensé chaque membres pendant l'annee-
select  
  membres.nomembre, 
  membres.nom, 
  SUM(pxvente*commandes.qtecommandee) as total_depense,
  pxabonnement,
  SUM(pxvente*commandes.qtecommandee)+pxabonnement as total_depence_avec_abo
from membres
join commandes on commandes.nomembre = membres.nomembre
join vins on vins.novin = commandes.novin
GROUP BY membres.nomembre, membres.nom
ORDER BY membres.nomembre 

--ls PDT01 et PDT98 souhaitent conserver le même nb de vente pour leur vins 
--et ils aimeraientt savoir à quel prix minimal doivent-ils vendre leur vins pour qu'ils ne degagent pas de perte
select 
noprocducteur,
pxvente, 
(cv+chargefixe)/qtecommandee as minimal_px_vente
from(
      select 
      producteurs.noprocducteur,
      pxvente, 
      SUM(commandes.qtecommandee) as qtecommandee,
      ROUND(chargevariable*SUM(commandes.qtecommandee)) as cv, 
      chargefixe
      from producteurs
      join vins on vins.noprocducteur = producteurs.noprocducteur
      join commandes on commandes.novin = vins.novin
      GROUP BY producteurs.noprocducteur, pxvente, chargevariable, chargefixe

) as req_sub

WHERE noprocducteur = 'PDT01' OR noprocducteur = 'PDT98'
GROUP BY
noprocducteur,
pxvente, 
(cv+chargefixe)/qtecommandee







