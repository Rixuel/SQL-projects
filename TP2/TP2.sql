PROMPT Création des tables
SET ECHO ON
SET SERVEROUTPUT ON
SPOOL TP2.out


DROP TABLE Inscription
/
DROP TABLE GroupeCours
/
DROP TABLE Préalable
/
DROP TABLE Cours
/
DROP TABLE SessionUQAM
/
DROP TABLE Etudiant
/
DROP TABLE Professeur
/
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY'
/
CREATE TABLE Cours
(sigle 		CHAR(7) 		NOT NULL,
 titre 		VARCHAR(50) 	NOT NULL,
 nbCredits 	INTEGER 		NOT NULL,
 CONSTRAINT ClePrimaireCours PRIMARY KEY 	(sigle)
)
/

CREATE TABLE Préalable
(sigle 			CHAR(7) 	NOT NULL,
 siglePréalable CHAR(7) 	NOT NULL,
 CONSTRAINT ClePrimairePréalable PRIMARY KEY 	(sigle,siglePréalable),
 CONSTRAINT CEsigleRefCours FOREIGN KEY 	(sigle) REFERENCES Cours,
 CONSTRAINT CEsiglePréalableRefCours FOREIGN KEY 	(siglePréalable) REFERENCES Cours(sigle)
)
/
CREATE TABLE SessionUQAM
(codeSession 	INTEGER		NOT NULL,
 dateDebut 		DATE		NOT NULL,
 dateFin 		DATE		NOT NULL,
 CONSTRAINT ClePrimaireSessionUQAM PRIMARY KEY 	(codeSession)
)
/
CREATE TABLE Professeur
(codeProfesseur		CHAR(5)	NOT NULL,
 nom			VARCHAR(10)	NOT NULL,
 prenom			VARCHAR(10)	NOT NULL,
 CONSTRAINT ClePrimaireProfesseur PRIMARY KEY 	(codeProfesseur),
 CONSTRAINT C1FORMATCODEPROF CHECK( (REGEXP_LIKE(codeProfesseur,'[[:alpha:]]{4}[[:digit:]]{1}')) )
)
/
-- C1 Le format du code professeur doit commencer par quatre lettres et suivi d'un chiffre

CREATE TABLE GroupeCours
(sigle 				CHAR(7) 	NOT NULL,
 noGroupe			INTEGER		NOT NULL,
 codeSession		INTEGER		NOT NULL,
 maxInscriptions	INTEGER		NOT NULL,
 codeProfesseur		CHAR(5)		NOT NULL,
CONSTRAINT ClePrimaireGroupeCours PRIMARY KEY 	(sigle,noGroupe,codeSession),
CONSTRAINT CESigleGroupeRefCours FOREIGN KEY 	(sigle) REFERENCES Cours,
CONSTRAINT CECodeSessionRefSessionUQAM FOREIGN KEY 	(codeSession) REFERENCES SessionUQAM,
CONSTRAINT CEcodeProfRefProfesseur FOREIGN KEY(codeProfesseur) REFERENCES Professeur
)
/

CREATE TRIGGER BUINSCRIPTIONC6
BEFORE UPDATE OF maxInscriptions ON GroupeCours
REFERENCING
	OLD AS ligneAvant
	NEW AS ligneApres
FOR EACH ROW 
WHEN ( ligneApres.maxInscriptions < ((ligneAvant.maxInscriptions)-(ligneAvant.maxInscriptions*0.1)) )
BEGIN
	RAISE_APPLICATION_ERROR(-20102,'Diminution de plus de 10% de maxInscription est interdite');
END;
/
-- C6 Il est interdit de faire diminuer la valeur de maxInscriptions de plus de 10% lors d’une mise à jour

CREATE TABLE Etudiant
(codePermanent 	CHAR(12) 	NOT NULL,
 nom			VARCHAR(10)	NOT NULL,
 prenom			VARCHAR(10)	NOT NULL,
 codeProgramme	INTEGER,
CONSTRAINT CléPrimaireEtudiant PRIMARY KEY 	(codePermanent)
)
/
CREATE TABLE Inscription
(codePermanent 	CHAR(12) 	NOT NULL,
 sigle 			CHAR(7) 	NOT NULL,
 noGroupe		INTEGER		NOT NULL,
 codeSession	INTEGER		NOT NULL,
 dateInscription DATE		NOT NULL,
 dateAbandon	 DATE,
 note			INTEGER,
CONSTRAINT CléPrimaireInscription PRIMARY KEY 	(codePermanent,sigle,noGroupe,codeSession),
CONSTRAINT CERefGroupeCours FOREIGN KEY 	(sigle,noGroupe,codeSession) REFERENCES GroupeCours ON DELETE CASCADE,
CONSTRAINT CECodePermamentRefEtudiant FOREIGN KEY (codePermanent) REFERENCES Etudiant,
CONSTRAINT C2NOTEENTRE0ET100 CHECK( (note IS NULL) OR (note >= 0 AND note <= 100) ),
CONSTRAINT C3DATEABANDONAPRESINSCRIPTION CHECK (dateInscription < dateAbandon),
CONSTRAINT C4DATEABANDONNOTE CHECK ((dateAbandon IS NOT NULL AND note IS NULL) OR (dateAbandon IS NULL AND note IS NOT NULL))
)
/
-- C2 Note est un entier entre 0 et 100 si elle n'est pas nulle
-- C3 La date d'abandon ne peut pas etre une date avant la date d'inscription
-- C4 S'il y a la date d'abandon, la note est nulle. Sinon, l'inverse.
-- C5 On ajouter ON DELETE CASCADE pour que si un groupe est efface, toutes ses inscription sont efface automatiquement

PROMPT Insertion de données pour les essais

INSERT INTO Cours 
VALUES('INF3180','Fichiers et bases de données',3)
/
INSERT INTO Cours 
VALUES('INF5180','Conception et exploitation d''une base de données',3)
/
INSERT INTO Cours 
VALUES('INF1110','Programmation I',3)
/
INSERT INTO Cours 
VALUES('INF1130','Mathématiques pour informaticien',3)
/
INSERT INTO Cours 
VALUES('INF2110','Programmation II',3)
/
INSERT INTO Cours 
VALUES('INF3123','Programmation objet',3)
/
INSERT INTO Cours 
VALUES('INF2160','Paradigmes de programmation',3)
/

INSERT INTO Préalable 
VALUES('INF2110','INF1110')
/
INSERT INTO Préalable 
VALUES('INF2160','INF1130')
/
INSERT INTO Préalable 
VALUES('INF2160','INF2110')
/
INSERT INTO Préalable 
VALUES('INF3180','INF2110')
/
INSERT INTO Préalable 
VALUES('INF3123','INF2110')
/
INSERT INTO Préalable 
VALUES('INF5180','INF3180')
/

INSERT INTO SessionUQAM
VALUES(32003,'3/09/2003','17/12/2003')
/
INSERT INTO SessionUQAM
VALUES(12004,'8/01/2004','2/05/2004')
/

INSERT INTO Professeur
VALUES('TREJ4','Tremblay','Jean')
/
INSERT INTO Professeur
VALUES('DEVL2','De Vinci','Leonard')
/
INSERT INTO Professeur
VALUES('PASB1','Pascal','Blaise')
/
INSERT INTO Professeur
VALUES('GOLA1','Goldberg','Adele')
/
INSERT INTO Professeur
VALUES('KNUD1','Knuth','Donald')
/
INSERT INTO Professeur
VALUES('GALE9','Galois','Evariste')
/
INSERT INTO Professeur
VALUES('CASI0','Casse','Illa')
/
INSERT INTO Professeur
VALUES('SAUV5','Sauvé','André')
/

INSERT INTO GroupeCours
VALUES('INF1110',20,32003,100,'TREJ4')
/
INSERT INTO GroupeCours
VALUES('INF1110',30,32003,100,'PASB1')
/
INSERT INTO GroupeCours
VALUES('INF1130',10,32003,100,'PASB1')
/
INSERT INTO GroupeCours
VALUES('INF1130',30,32003,100,'GALE9')
/
INSERT INTO GroupeCours
VALUES('INF2110',10,32003,100,'TREJ4')
/
INSERT INTO GroupeCours
VALUES('INF3123',20,32003,50,'GOLA1')
/
INSERT INTO GroupeCours
VALUES('INF3123',30,32003,50,'GOLA1')
/
INSERT INTO GroupeCours
VALUES('INF3180',30,32003,50,'DEVL2')
/
INSERT INTO GroupeCours
VALUES('INF3180',40,32003,50,'DEVL2')
/
INSERT INTO GroupeCours
VALUES('INF5180',10,32003,50,'KNUD1')
/
INSERT INTO GroupeCours
VALUES('INF5180',40,32003,50,'KNUD1')
/
INSERT INTO GroupeCours
VALUES('INF1110',20,12004,100,'TREJ4')
/
INSERT INTO GroupeCours
VALUES('INF1110',30,12004,100,'TREJ4')
/
INSERT INTO GroupeCours
VALUES('INF2110',10,12004,100,'PASB1')
/
INSERT INTO GroupeCours
VALUES('INF2110',40,12004,100,'PASB1')
/
INSERT INTO GroupeCours
VALUES('INF3123',20,12004,50,'GOLA1')
/
INSERT INTO GroupeCours
VALUES('INF3123',30,12004,50,'GOLA1')
/
INSERT INTO GroupeCours
VALUES('INF3180',10,12004,50,'DEVL2')
/
INSERT INTO GroupeCours
VALUES('INF3180',30,12004,50,'DEVL2')
/
INSERT INTO GroupeCours
VALUES('INF5180',10,12004,50,'DEVL2')
/
INSERT INTO GroupeCours
VALUES('INF5180',40,12004,50,'GALE9')
/

INSERT INTO Etudiant
VALUES('TREJ18088001','Tremblay','Jean',7416)
/
INSERT INTO Etudiant
VALUES('TREL14027801','Tremblay','Lucie',7416)
/
INSERT INTO Etudiant
VALUES('DEGE10027801','Degas','Edgar',7416)
/
INSERT INTO Etudiant
VALUES('MONC05127201','Monet','Claude',7316)
/
INSERT INTO Etudiant
VALUES('VANV05127201','Van Gogh','Vincent',7316)
/
INSERT INTO Etudiant
VALUES('MARA25087501','Marshall','Amanda',null)
/
INSERT INTO Etudiant
VALUES('STEG03106901','Stephani','Gwen',7416)
/
INSERT INTO Etudiant
VALUES('EMEK10106501','Emerson','Keith',7416)
/
INSERT INTO Etudiant
VALUES('DUGR08085001','Duguay','Roger',null)
/
INSERT INTO Etudiant
VALUES('LAVP08087001','Lavoie','Paul',null)
/
INSERT INTO Etudiant
VALUES('TREY09087501','Tremblay','Yvon',7316)
/

INSERT INTO Inscription
VALUES('TREJ18088001','INF1110',20,32003,'16/08/2003',null,80)
/
INSERT INTO Inscription
VALUES('LAVP08087001','INF1110',20,32003,'16/08/2003',null,80)
/
INSERT INTO Inscription
VALUES('TREL14027801','INF1110',30,32003,'17/08/2003',null,90)
/
INSERT INTO Inscription
VALUES('MARA25087501','INF1110',20,32003,'20/08/2003',null,80)
/
INSERT INTO Inscription
VALUES('STEG03106901','INF1110',20,32003,'17/08/2003',null,70)
/
INSERT INTO Inscription
VALUES('TREJ18088001','INF1130',10,32003,'16/08/2003',null,70)
/
INSERT INTO Inscription
VALUES('TREL14027801','INF1130',30,32003,'17/08/2003',null,80)
/
INSERT INTO Inscription
VALUES('MARA25087501','INF1130',10,32003,'22/08/2003',null,90)
/
INSERT INTO Inscription
VALUES('DEGE10027801','INF3180',30,32003,'16/08/2003',null,90)
/
INSERT INTO Inscription
VALUES('MONC05127201','INF3180',30,32003,'19/08/2003',null,60)
/
INSERT INTO Inscription
VALUES('VANV05127201','INF3180',30,32003,'16/08/2003','20/09/2003',null)
/
INSERT INTO Inscription
VALUES('EMEK10106501','INF3180',40,32003,'19/08/2003',null,80)
/
INSERT INTO Inscription
VALUES('DUGR08085001','INF3180',40,32003,'19/08/2003',null,70)
/
INSERT INTO Inscription
VALUES('TREJ18088001','INF2110',10,12004,'19/12/2003',null,80)
/
INSERT INTO Inscription
VALUES('TREL14027801','INF2110',10,12004,'20/12/2003',null,90)
/
INSERT INTO Inscription
VALUES('MARA25087501','INF2110',40,12004,'19/12/2003',null,90)
/
INSERT INTO Inscription
VALUES('STEG03106901','INF2110',40,12004, '10/12/2003',null,70)
/
INSERT INTO Inscription
VALUES('VANV05127201','INF3180',10,12004, '18/12/2003',null,90)
/
INSERT INTO Inscription
VALUES('DEGE10027801','INF5180',10,12004, '15/12/2003',null,90)
/
INSERT INTO Inscription
VALUES('MONC05127201','INF5180',10,12004, '19/12/2003','22/01/2004',null)
/
INSERT INTO Inscription
VALUES('EMEK10106501','INF5180',40,12004, '19/12/2003',null,80)
/
INSERT INTO Inscription
VALUES('DUGR08085001','INF5180',10,12004, '19/12/2003',null,80)
/
COMMIT
/
PROMPT Contenu des tables
SELECT * FROM Cours
/
SELECT * FROM Préalable
/
SELECT * FROM SessionUQAM
/
SELECT * FROM Professeur
/
SELECT * FROM GroupeCours
/
SELECT * FROM Etudiant
/
SELECT * FROM Inscription
/


PROMPT Test de violation de la contrainte C1
INSERT INTO Professeur
VALUES('ULLJT','Ullman','Jeffrey')
/

PROMPT Test de violation de la contrainte C2
UPDATE Inscription
SET note = 150
WHERE codePermanent ='TREJ18088001' AND sigle = 'INF1110' AND noGroupe = 20 AND codeSession = 32003
/

PROMPT Test de violation de la contrainte C3
UPDATE Inscription
SET dateAbandon = '15/08/2003'
WHERE codePermanent ='VANV05127201' AND sigle = 'INF3180' AND noGroupe = 30 AND codeSession = 32003
/

PROMPT Test de violation de la contrainte C4
UPDATE Inscription
SET dateAbandon = '17/08/2003'
WHERE codePermanent ='TREJ18088001' AND sigle = 'INF1110' AND noGroupe = 20 AND codeSession = 32003
/

PROMPT Test de la contrainte C5
SELECT * FROM Inscription
WHERE sigle ='INF5180' AND noGroupe = 40 AND codeSession = 12004
/
DELETE FROM GroupeCours
WHERE sigle ='INF5180' AND noGroupe = 40 AND codeSession = 12004
/
SELECT * FROM Inscription
WHERE sigle ='INF5180' AND noGroupe = 40 AND codeSession = 12004
/
ROLLBACK
/

PROMPT Test de violation de la contrainte C6
UPDATE GroupeCours
SET maxInscriptions = maxInscriptions-20
WHERE sigle = 'INF1110' AND noGroupe = 20 AND codeSession = 32003
/


-- 3

ALTER TABLE GroupeCours
ADD nbInscriptions INTEGER
ADD CONSTRAINT C7VALEURPOSITIVE CHECK(nbInscriptions>=0)
/
-- C7 La valeur ne peut pas etre negative

CREATE OR REPLACE FUNCTION fNbInscriptions 
(unSigle GroupeCours.sigle%TYPE,
unGroupe GroupeCours.noGroupe%TYPE,
unCodeSession GroupeCours.codeSession%TYPE)
RETURN GroupeCours.nbInscriptions%TYPE IS

unNbInscription GroupeCours.sigle%TYPE;
BEGIN
	SELECT	nbInscriptions
	INTO	unNbInscription
	FROM	GroupeCours
	WHERE	sigle = unSigle AND noGroupe = unGroupe AND codeSession = unCodeSession;
	RETURN	unNbInscription;
END fNbInscriptions;
/

UPDATE	GroupeCours
SET		nbInscriptions = 4
WHERE 	sigle = 'INF1110' AND noGroupe = 20 AND codeSession = 32003;
/

UPDATE	GroupeCours
SET		nbInscriptions = 2
WHERE 	(sigle = 'INF1130' AND noGroupe = 10 AND codeSession = 32003) OR
		(sigle = 'INF3180' AND noGroupe = 30 AND codeSession = 32003) OR
		(sigle = 'INF3180' AND noGroupe = 40 AND codeSession = 32003) OR
		(sigle = 'INF2110' AND noGroupe = 10 AND codeSession = 12004) OR
		(sigle = 'INF2110' AND noGroupe = 40 AND codeSession = 12004) OR
		(sigle = 'INF5180' AND noGroupe = 10 AND codeSession = 12004);
/

UPDATE	GroupeCours
SET		nbInscriptions = 1
WHERE 	(sigle = 'INF1110' AND noGroupe = 30 AND codeSession = 32003) OR
		(sigle = 'INF1130' AND noGroupe = 30 AND codeSession = 32003) OR
		(sigle = 'INF3180' AND noGroupe = 10 AND codeSession = 12004) OR
		(sigle = 'INF5180' AND noGroupe = 40 AND codeSession = 12004);
/

UPDATE	GroupeCours
SET		nbInscriptions = 0
WHERE 	(sigle = 'INF2110' AND noGroupe = 10 AND codeSession = 32003) OR
		(sigle = 'INF3123' AND noGroupe = 20 AND codeSession = 32003) OR
		(sigle = 'INF3123' AND noGroupe = 30 AND codeSession = 32003) OR
		(sigle = 'INF5180' AND noGroupe = 10 AND codeSession = 32003) OR
		(sigle = 'INF5180' AND noGroupe = 40 AND codeSession = 32003) OR
		(sigle = 'INF1110' AND noGroupe = 20 AND codeSession = 12004) OR
		(sigle = 'INF1110' AND noGroupe = 30 AND codeSession = 12004) OR
		(sigle = 'INF3123' AND noGroupe = 20 AND codeSession = 12004) OR
		(sigle = 'INF3123' AND noGroupe = 30 AND codeSession = 12004) OR
		(sigle = 'INF3180' AND noGroupe = 30 AND codeSession = 12004);
/

SELECT fNbInscriptions('INF1110',20,32003) from dual
/

SELECT * FROM GroupeCours
/


-- 4
CREATE OR REPLACE PROCEDURE pTacheEnseignement
(leCodeProf Professeur.codeProfesseur%TYPE) IS

-- Declaration de variables
leNom		Professeur.nom%TYPE;
lePrenom	Professeur.prenom%TYPE;
leSigle		GroupeCours.sigle%TYPE;
leGroupe	GroupeCours.noGroupe%TYPE;
laSession	GroupeCours.codeSession%TYPE;

-- Declaration d'un curseur
	CURSOR 	lignesGroupeCours (unCodeProf Professeur.codeProfesseur%TYPE) IS
	SELECT	sigle, noGroupe, codeSession
	FROM	GroupeCours
	WHERE	GroupeCours.codeProfesseur = unCodeProf;

BEGIN
-- Les Outputs
DBMS_OUTPUT.PUT_LINE('code professeur :'|| TO_CHAR(leCodeProf));

	SELECT	nom, prenom
	INTO	leNom, lePrenom
	FROM	Professeur
	WHERE	codeProfesseur = leCodeProf;
	
DBMS_OUTPUT.PUT_LINE('nom:'||TO_CHAR(leNom));
DBMS_OUTPUT.PUT_LINE('prenom:'||TO_CHAR(lePrenom));
DBMS_OUTPUT.PUT_LINE('sigle	'||'noGroupe '||'session');

-- Pour ouvrir le Curseur en lui passant les parametres
OPEN lignesGroupeCours(leCodeProf);

-- Afficher le sigle, le groupe et la session qui ont un lien avec le code professeur
LOOP
	FETCH lignesGroupeCours INTO leSigle, leGroupe, laSession;
	EXIT WHEN lignesGroupeCours%NOTFOUND;
	DBMS_OUTPUT.PUT_LINE(leSigle||'	'||leGroupe||'  	 '||laSession);
END LOOP;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
			DBMS_OUTPUT.PUT_LINE('Code de professeur inexistant');
	WHEN	OTHERS THEN
			RAISE_APPLICATION_ERROR(-20001,'Exception levee par la procedure');
			
END pTacheEnseignement;
/

EXECUTE pTacheEnseignement('TREJ4');


-- 5 

CREATE TRIGGER BIInscription
BEFORE INSERT ON Inscription
FOR EACH ROW
DECLARE
	num INTEGER:=1;
BEGIN
	IF :new.noGroupe>0 THEN
		WHILE num<=:new.noGroupe LOOP
			INSERT INTO GroupeCours (noGroupe) VALUES (:new.nbInscriptions,num);
			num:=num+1;
		END LOOP;
	END IF;
END;
/

INSERT INTO Inscription
VALUES('TREY09087501','INF5180',10,12004, '19/12/2003',null,80)
/

SELECT * FROM GroupeCours
WHERE sigle = 'INF5180' AND noGroupe = 10 AND codeSession = 12004
/
ROLLBACK
/


-- 6

CREATE OR REPLACE VIEW MoyenneParGroupe AS
	SELECT sigle, noGroupe, codeSession, AVG(note) as "MOYENNENOTE"
	FROM Inscription
	GROUP BY sigle, noGroupe, codeSession;


SELECT * FROM MoyenneParGroupe
/

CREATE OR REPLACE TRIGGER InsteadUpdateMoyenneParGroupe
INSTEAD OF UPDATE ON MoyenneParGroupe
REFERENCING
	OLD AS ligneAvant
	NEW AS ligneApres
FOR EACH ROW
BEGIN
	UPDATE Inscription
	SET
		sigle = :ligneApres.sigle,
		noGroupe = :ligneApres.noGroupe,
		codeSession = :ligneApres.codeSession,
		note = :ligneApres.moyenneNote
	WHERE 	sigle = :ligneAvant.sigle AND
			noGroupe = :ligneAvant.noGroupe AND
			codeSession = :ligneAvant.codeSession;
END;
/

UPDATE MoyenneParGroupe
SET moyenneNote = 70
WHERE sigle = 'INF1130'AND noGroupe = 10 AND codeSession = 32003
/

SELECT * FROM MoyenneParGroupe
WHERE sigle = 'INF1130'AND noGroupe = 10 AND codeSession = 32003
/

SELECT * FROM Inscription
WHERE sigle = 'INF1130'AND noGroupe = 10 AND codeSession = 32003
/




SPOOL OFF
SET ECHO OFF