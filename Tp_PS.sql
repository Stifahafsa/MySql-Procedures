create database Achat;
use Achat;

create table Fournisseur(
NumFour int primary key,
RsFour varchar(45),
AdrFour varchar(50),
NbrProduitsFournis int
);

create table ProduitBrut(
CodProBrut int primary key,
NomProBrut varchar(35),
PrixAchat decimal(10,2),
NumFour int,
foreign key(NumFour) references Fournisseur (NumFour)
);

create table ProduitFini(
CodProFini int primary key,
NomProFini varchar(35),
QteEnStock int);

create table Mouvement(
NumMvt int primary key,
TypeMvt varchar(20),
Quantite int,
CodProFini int,
foreign key(CodProFini) references ProduitFini (CodProFini)
);

create table Composition(
CodProFini int,
CodProBrut int,
foreign key (CodProFini) references ProduitFini (CodProFini),
foreign key(CodProBrut) references ProduitBrut (CodProBrut),
primary key (CodProFini,CodProBrut)
);

#Ps1

DELIMITER $$

CREATE PROCEDURE PS1()
BEGIN
    -- Création de la table ProduitBrut
    CREATE TABLE IF NOT EXISTS ProduitBrut (
        CodProBrut INT PRIMARY KEY,
        NomProBrut VARCHAR(35),
        PrixAchat DECIMAL(10,2),
        NumFour INT,
        FOREIGN KEY (NumFour) REFERENCES Fournisseur(NumFour)
    );

    -- Création de la table Composition
    CREATE TABLE IF NOT EXISTS Composition (
        CodProFini INT,
        CodProBrut INT,
        PRIMARY KEY (CodProFini, CodProBrut),
        FOREIGN KEY (CodProFini) REFERENCES ProduitFini(CodProFini),
        FOREIGN KEY (CodProBrut) REFERENCES ProduitBrut(CodProBrut)
    );
END$$

DELIMITER ;

#PS2

DELIMITER $$

CREATE PROCEDURE PS2()
BEGIN
    SELECT pf.NomProFini, COUNT(cb.CodProBrut) AS NbrProduitsBruts
    FROM ProduitFini pf
    LEFT JOIN Composition c ON pf.CodProFini = c.CodProFini
    LEFT JOIN ProduitBrut cb ON c.CodProBrut = cb.CodProBrut
    GROUP BY pf.CodProFini;
END$$

DELIMITER ;


#PS3

DELIMITER $$ 
Create procedure PS3(OUT maximum Decimal(8,2))
begin 
select max(PrixAchat) into maximum from ProduitBrut;
end $$

DELIMITER ;

#PS4
DELIMITER $$

CREATE PROCEDURE PS4()
BEGIN
    SELECT CodProFini, COUNT(CodProBrut) AS NbrProduitsBruts
    FROM Composition
    GROUP BY CodProFini
    HAVING COUNT(CodProBrut) > 2;
END$$

DELIMITER ;



#PS5 


DELIMITER $$

CREATE PROCEDURE PS5(
    IN nomProduitBrut VARCHAR(35),
    OUT raisonSocial VARCHAR(45)
)
BEGIN
    -- Assigner la raison sociale à la variable OUT
    SELECT f.RsFour INTO raisonSocial
    FROM ProduitBrut Pb 
    JOIN Fournisseur f ON Pb.NumFour = f.NumFour
    WHERE Pb.NomProBrut = nomProduitBrut;
END$$

DELIMITER ;


#PS6

DELIMITER $$

Create procedure PS6(IN CodProduitFini int)
BEGIN 

select Pf.CodProFini, M.NumMvt from ProduitFini Pf
join Mouvement M on Pf.CodProFini = M.CodProFini
where M.CodProFini = CodProduitFini;

End $$

DELIMITER ; 

#PS7

DELIMITER $$

Create procedure PS7(IN CodProduitFini int,
IN typeMouvement varchar(20))
BEGIN
select Pf.CodProFini, M.typeMvt from ProduitFini Pf
join Mouvement M on Pf.CodProFini = M.CodProFini
where M.CodProFini = CodProduitFini AND M.typeMvt = typeMouvement;

END $$

DELIMITER ;

#PS8

DELIMITER $$

CREATE PROCEDURE PS8()
BEGIN
    -- Sélectionner chaque produit fini avec ses mouvements et calculer les quantités
    SELECT 
        pf.NomProFini, 
        pf.QteEnStock, 
        GROUP_CONCAT(CONCAT('Mouvement: ', m.TypeMvt, ' | Quantité: ', m.Quantite) SEPARATOR '; ') AS Mouvements,
        SUM(CASE WHEN m.TypeMvt = 'entrée' THEN m.Quantite ELSE 0 END) AS QuantiteEntree,
        SUM(CASE WHEN m.TypeMvt = 'sortie' THEN m.Quantite ELSE 0 END) AS QuantiteSortie,
        CASE 
            WHEN pf.QteEnStock = (SUM(CASE WHEN m.TypeMvt = 'entrée' THEN m.Quantite ELSE 0 END) 
                                  - SUM(CASE WHEN m.TypeMvt = 'sortie' THEN m.Quantite ELSE 0 END)) 
            THEN 'Stock OK' 
            ELSE 'Problème de Stock' 
        END AS EtatStock
    FROM ProduitFini pf
    LEFT JOIN Mouvement m ON pf.CodProFini = m.CodProFini
    GROUP BY pf.CodProFini;
END$$

DELIMITER ;

#PS9

DELIMITER $$

CREATE PROCEDURE PS9(IN CodProFini int, OUT PrixReviens decimal(8,2))
BEGIN
select sum(pb.PrixAchat * c.QteUtilisee) as PrixReviens from ProduitBrut pb
join Composition c on pb.CodProBrut = c.CodProBrut
where c.CodProFini = CodProFini;
END $$
DELIMITER ; 


