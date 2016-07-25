SET ECHO ON
SPOOL requetes.out

ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY/'
/

-- TP1 VENTES DE LA PEPINIERE PLEIN DE FOIN

-- 1.   Les numéros des clients (sans répétition) qui ont placé au moins une commande

SELECT		DISTINCT noClient
FROM 		Commande
WHERE		noCommande >= 1
/
-- 2.   Le numéro et la description des articles dont le numéro est entre 20 et 80 (inclusivement) et le prix est 10.99 ou 25.99

SELECT		noArticle, description
FROM 		Article
WHERE		(noArticle >= 20 AND noArticle <= 80) AND (prixUnitaire = 10.99 OR prixUnitaire = 25.99)
/
-- 3.   Le numéro et la description des articles dont la description débute par la lettre C ou contient la chaîne 'bl'

SELECT		noArticle, description 
FROM 		Article
WHERE		description LIKE 'C%' OR description LIKE '%bl%'
/
-- 4.   Le numéro et le nom des clients qui ont placé une commande le 9 juillet 2000

SELECT		Client.noClient, Client.nomClient
FROM 		Client, Commande
WHERE		Client.noCLient = Commande.noClient AND dateCommande = '09/07/2000'
/
-- 5.   Les noms des clients, numéros de commande, date de commande et noArticle pour les articles livrés le 4 juin 2000 dont la quantité livrée est supérieure à 1

SELECT		Client.nomClient, DetailLivraison.noCommande, Commande.dateCommande, DetailLivraison.noArticle
FROM 		Client, Commande, DetailLivraison, Livraison
WHERE		Client.noClient = Commande.noClient 
			AND Commande.noCommande = DetailLivraison.noCommande 
			AND DetailLivraison.noLivraison = Livraison.noLivraison 
			AND dateLivraison = '04/06/2000' 
			AND quantiteLivree > 1
/
-- 6.   La liste des dates du mois de juin 2000 pour lesquelles il y a au moins une livraison ou une commande. Les résultats sont produits en une colonne nommée DateÉvénement.

(SELECT		dateLivraison as DateEvenement
FROM		Livraison
WHERE		dateLivraison BETWEEN '01/06/2000' AND '30/06/2000')
UNION
(SELECT		dateCommande as DateEvenement
FROM		Commande
WHERE		dateCommande BETWEEN '01/06/2000' AND '30/06/2000')
/
-- 7.   Les noArticle et la quantité totale livrée de l’article incluant les articles dont la quantité totale livrée est égale à 0.

(SELECT		noArticle, SUM(quantiteLivree) AS Quantite_Livree
FROM		DetailLivraison
GROUP BY	noArticle)
UNION
(SELECT		noArticle, 0 AS Quantite_Livree
FROM		Article)
MINUS
(SELECT		noArticle, 0 AS Quantite_Livree
FROM		DetailLivraison)
/
-- 8.   Les noArticle et la quantité totale livrée de l’article pour les articles dont le prix est inférieur à $20 et dont la quantité totale livrée est inférieure à 5

(SELECT		D.noArticle, SUM(D.quantiteLivree) AS Quantite_Livree
FROM		Article A, DetailLivraison D
WHERE		A.noArticle = D.noArticle
			AND A.prixUnitaire < 20
GROUP BY	D.noArticle
HAVING		SUM(D.quantiteLivree) < 5)
UNION
(SELECT		A.noArticle, 0 AS Quantite_Livree
FROM		Article A, DetailLivraison D
WHERE		A.noArticle = D.noArticle (+)
			AND D.quantiteLivree is null
			AND A.prixUnitaire < 20
GROUP BY 	A.noArticle)
/
-- 9.   Le noLivraison, noCommande, noArticle, la date de la commande, la quantité commandée, la date de la livraison, la quantitée livrée et le nombre de jours écoulés entre la commande et la livraison dans le cas où ce nombre a dépassé 2 jours et le nombre de jours écoulés depuis la commande jusqu’à aujourh’hui est supérieur à 100

SELECT		DetailLivraison.noLivraison, DetailLivraison.noCommande, DetailLivraison.noArticle, Commande.dateCommande, LigneCommande.quantite, Livraison.dateLivraison, DetailLivraison.quantiteLivree, (Livraison.dateLivraison - Commande.dateCommande) AS Nombre_Jours_Ecoules
FROM		Commande, DetailLivraison, LigneCommande, Livraison
WHERE		DetailLivraison.noLivraison = Livraison.noLivraison
			AND DetailLivraison.noCommande = LigneCommande.noCommande 
			AND LigneCommande.noCommande = Commande.noCommande
			AND	DetailLivraison.noArticle = LigneCommande.noArticle
			AND	(Livraison.dateLivraison - Commande.dateCommande) > 2
			AND	(SYSDATE - Commande.dateCommande) > 100
ORDER BY	DetailLivraison.noLivraison			
/
-- 10.  La liste des Articles triée en ordre décroissant de prix et pour chacun des prix en ordre croissant de numéro

SELECT		noArticle, description, prixUnitaire, quantiteEnStock
FROM		Article
ORDER BY	prixUnitaire DESC, noArticle ASC
/
-- 11.  Le nombre d’articles dont le prix est supérieur à 25 et le nombre d'articles dont le prix est inférieur à 15 (en deux colonnes)

SELECT		COUNT(DISTINCT Asup.noArticle) AS NombrePlusCherQue25, COUNT(DISTINCT Article.noArticle) AS NombreMoinsCherQue15
FROM		Article Asup, Article
WHERE		Asup.prixUnitaire > 25 AND Article.prixUnitaire < 15
/
-- 12.  Les noCommande des commandes qui n'ont aucune livraison correspondante

(SELECT		DISTINCT noCommande
FROM		LigneCommande)
MINUS
(SELECT		DISTINCT LigneCommande.noCommande
FROM		LigneCommande, DetailLivraison
WHERE		LigneCommande.noCommande = DetailLivraison.noCommande)
/
-- 13.  En deux colonnes, les paires de numéros de commandes (différentes) qui sont faites à la même date ainsi que la date de commande. Il faut éviter de répéter deux fois la même paire.

SELECT		Commande.noCommande, C.noCommande, Commande.dateCommande
FROM		Commande, Commande C
WHERE		Commande.dateCommande = C.dateCommande 
			AND Commande.noCommande != C.noCommande
			AND Commande.noCommande < C.noCommande
/
-- 14.  Le montant total commandé pour chaque paire (dateCommande, noArticle) dans les cas où le montant total dépasse 50$.

SELECT		Commande.dateCommande, LigneCommande.noArticle, SUM(Article.prixUnitaire * LigneCommande.quantite) AS Montant_Total_Commande
FROM		Article, Commande, LigneCommande
WHERE		LigneCommande.noArticle = Article.noArticle
			AND Commande.noCommande = LigneCommande.noCommande
GROUP BY	Commande.dateCommande, LigneCommande.noArticle
HAVING 		SUM(quantite * prixUnitaire) > 50
/
-- 15.  Les noArticle des articles commandés dans toutes et chacune des commandes du client 20

SELECT		DISTINCT LigneCommande.noArticle
FROM		Commande, LigneCommande
WHERE		Commande.noClient = 20
			AND Commande.noCommande = LigneCommande.noCommande
			AND LigneCommande.noArticle = 40
/

SPOOL OFF
SET ECHO OFF