--  Afficher la liste des artistes, par ordre alphabétique

 select art_nom from mp_artiste 
 order by art_nom

-- Afficher la liste des artistes, dont le nom commence par ‘S’, par ordre alphabétique
select art_nom from mp_artiste 
where art_nom like 'S%'
order by art_nom

-- Afficher la discographie d’un artiste : afficher pour chaque piste : nom, durée, prix et nom de
-- l’album. Classer par album, avec les albums les plus récents en premier

select pi_titre, pi_duree, pi_prix,alb_nom from mp_piste as piste
inner join mp_album as album 
on album.alb_id=piste.#alb_id
group by alb_nom,pi_titre, pi_duree, pi_prix, alb_date_sortie
order by alb_date_sortie desc

-- Afficher tous les albums pour un type de musique donnée (ex : « rock »), classés du plus
-- récent au plus vieux. Lorsque les albums sont sortis au même moment, on classe par ordre
-- alphabétique sur le nom de l’artiste. On souhaite afficher : nom de l’album, date de sortie,
-- prix et nom de l’artiste.

select alb_nom, alb_date_sortie, pi_prix,art_nom from mp_piste as piste
inner join mp_album as album 
on album.alb_id=piste.#alb_id
inner join mp_artiste as artiste
on artiste.art_id=album.#art_id
where pi_type='rock' 
group by alb_date_sortie,art_nom,alb_nom, pi_prix 
order by alb_date_sortie desc, art_nom

-- On souhaite afficher dans la page d’accueil du site le nombre de titres disponibles pour
-- chaque type de musique

select count(*) from mp_piste
group by pi_type


-- Afficher les pistes (nom de la piste, nom de l’album, nom de l’artiste) les mieux notées

select pi_titre,alb_nom, artiste.art_nom from  mp_piste as piste
inner join mp_album as album 
on album.alb_id=piste.#alb_id
inner join mp_artiste as artiste
on artiste.art_id=album.#art_id
where #alb_id in (
select #alb_id from mp_note
group by #alb_id
having avg(not_valeur) = (
select max(NoteMoy) from
(select #alb_id,avg(not_valeur) as NoteMoy from mp_note
group by #alb_id) as matable
))

-- Afficher les pistes (nom de la piste, nom de l’album, nom de l’artiste) de note supérieure ou
-- égale à 4

select pi_titre,alb_nom, artiste.art_nom, not_valeur from  mp_piste as piste
inner join mp_album as album 
on album.alb_id=piste.#alb_id
inner join mp_artiste as artiste
on artiste.art_id=album.#art_id
inner join mp_note as note
on note.#alb_id=album.alb_id
where not_valeur>=4
group by not_valeur,pi_titre,alb_nom, artiste.art_nom 
order by not_valeur desc

-- Afficher les 10 albums (nom de l’album, nom de l’artiste, date de sortie) les plus récents
select top 10 alb_nom, art_nom, alb_date_sortie from mp_album 
inner join mp_artiste 
on art_id=#art_id
group by alb_date_sortie, alb_nom, art_nom
order by alb_date_sortie desc

-- Pour chaque commande, afficher le montant total en euros, la date, le nom du client. Classer
-- de la plus récente à la plus ancienne

select FORMAT(sum(pi_prix), 'C', 'fr-FR') 'Prix en euros', cmd_date, cli_nom from mp_commande
inner join mp_commande_piste
on mp_commande_piste.#cmd_id=mp_commande.cmd_id
inner join mp_piste
on mp_piste.pi_id=mp_commande_piste.#pi_id
inner join mp_client 
on mp_client.cli_id=#cli_id
group by cmd_id, pi_prix, cmd_date, cli_nom
order by cmd_date desc


-- Afficher les commandes du mois de janvier 2012 (montant en euros, date, nom du client),
-- classées par date, la plus récente en premier

select FORMAT(sum(pi_prix), 'C', 'fr-FR') 'Prix en euros', cmd_date, cli_nom from mp_commande
inner join mp_commande_piste
on mp_commande_piste.#cmd_id=mp_commande.cmd_id
inner join mp_piste
on mp_piste.pi_id=mp_commande_piste.#pi_id
inner join mp_client 
on mp_client.cli_id=#cli_id
where cmd_date between '20120101' and '20120131'
group by cmd_id, pi_prix, cmd_date, cli_nom
order by cmd_date desc

-- Afficher le montant moyen d’une commande, pour les commandes passées en 2011

select FORMAT(avg(somme), 'C', 'fr-FR') from 
(select sum(pi_prix) as somme from mp_commande
inner join mp_commande_piste
on mp_commande_piste.#cmd_id=mp_commande.cmd_id
inner join mp_piste
on mp_piste.pi_id=mp_commande_piste.#pi_id
inner join mp_client 
on mp_client.cli_id=#cli_id
where cmd_date between '20110101' and '20111231'
group by cmd_id
) as p

/*
Pour un client donné, afficher l’historique des pistes achetées, classées par date d’achat, la
plus récente en premier (afficher : nom de la piste, nom de l’album, nom de l’artiste, date
d’achat, numéro de commande). Lorsqu’un album a été acheté, on affiche toutes les pistes
de l’album.
*/

select pi_titre, alb_nom,art_nom , cmd_date,cmd_id, #cli_id from mp_commande
inner join mp_commande_piste
on mp_commande_piste.#cmd_id=mp_commande.cmd_id
inner join mp_piste
on mp_piste.pi_id=mp_commande_piste.#pi_id
inner join mp_album
on mp_album.alb_id=mp_piste.#alb_id
inner join mp_artiste 
on mp_artiste.art_id=mp_album.#art_id

group by #cli_id, cmd_date, cmd_id,pi_titre, alb_nom, art_nom
order by cmd_date desc

-- Afficher le nombre de pistes vendues par artiste

select count(mp_commande_piste.#pi_id),art_nom  from mp_commande_piste
inner join mp_piste
on mp_piste.pi_id=#pi_id
inner join mp_album
on mp_album.alb_id=#alb_id
inner join mp_artiste
on art_id=#art_id
group by art_nom 

-- Pour chaque artiste, afficher le nombre d’albums disponibles (on affiche uniquement les
-- artistes qui ont au moins un album)

select count(alb_id) as 'alb dispo', art_nom from mp_album
inner join mp_artiste
on art_id=#art_id
group by mp_album.#art_id, art_nom 
order by [alb dispo] desc

--Pour chaque artiste, afficher le nombre d’albums disponibles (on veut afficher « 0 » pour les
--artistes qui n’ont pas encore d’album sur notre site)

select count(alb_id) as 'alb dispo', art_nom from mp_album
right join mp_artiste
on art_id=#art_id
group by mp_album.#art_id, art_nom 
order by [alb dispo] desc

--Afficher l’artiste pour lequel le plus d’albums ont été téléchargés

select art_nom  from mp_commande_piste
inner join mp_piste
on mp_piste.pi_id=#pi_id
inner join mp_album
on mp_album.alb_id=#alb_id
inner join mp_artiste
on art_id=#art_id
group by art_nom
having count(mp_commande_piste.#pi_id)=(
select max(compte)from
(select count(mp_commande_piste.#pi_id) as compte, art_nom  from mp_commande_piste
inner join mp_piste
on mp_piste.pi_id=#pi_id
inner join mp_album
on mp_album.alb_id=#alb_id
inner join mp_artiste
on art_id=#art_id
group by art_nom) as liste
)

--Afficher les 5 clients qui ont commandé le plus de pistes


select top 5 count(mp_commande_piste.#pi_id) as nbpistesVendu ,cli_nom from mp_client 
inner join mp_commande
on mp_commande.#cli_id=mp_client.cli_id
inner join mp_commande_piste
on mp_commande_piste.#cmd_id=mp_commande.cmd_id
group by cli_id,cli_nom 
 
--Afficher pour chaque année combien de titres ont étés vendus et la part que cela représente par rapport au total


select year (cmd_date) as annee,count(#pi_id),count(#pi_id)/CONVERT(decimal,(select count(*) from mp_commande_piste))*100 from mp_commande
inner join mp_commande_piste
on mp_commande_piste.#cmd_id=mp_commande.cmd_id
group by year(cmd_date) 

--Afficher le nombre de ventes de pistes par mois, par année et au global

select  year (cmd_date) as annee, month( cmd_date) as mois, count(#pi_id)as NbVentes, (select count(*) from mp_commande_piste) as total from mp_commande
inner join mp_commande_piste
on mp_commande_piste.#cmd_id=mp_commande.cmd_id
group by year (cmd_date) , month( cmd_date)
order by annee,mois