set serveroutput on;
-----------------------------------------------------------------------
--### creation de sequence  ##### 
CREATE SEQUENCE sq_IdPartie START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE sq_Idcoup START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE sq_Idjoueur START WITH 1 INCREMENT BY 1;

------------------------------------------------------------------------------------------------
---###   creation des tables  ###### 
------------------------------------------------------------------------------------------------
--TABLE Niveau
------------------------------------------------------------------------------------------------
CREATE TABLE Niveau(
IdNiveau NUMBER(2) CONSTRAINT pk_niveau PRIMARY KEY,
Nbr_billes NUMBER,
CONSTRAINT ck_niveau CHECK (IdNiveau IN (1,2,3))
);
-------------------------------------------------------------------------------------------------
-- TABLE Joueur
-------------------------------------------------------------------------------------------------
CREATE TABLE Joueur(
id_user number CONSTRAINT pk_joueur PRIMARY KEY,
identifiant VARCHAR(30) NOT NULL UNIQUE,
mdp VARCHAR(10) CONSTRAINT nn_mdp NOT NULL,--obliger l'utilisateur d'avoir un mot de passe 
Scoreperso number,
IdNiveau NUMBER(5),
temps_bloc number,
IdNiveau CONSTRAINT fk_niv_joueur REFERENCES Niveau(IdNiveau) -- le niveau max atteint par le joueur 

);
-----------------------------------------------------------------------------------------------
--TABLE Partie
-----------------------------------------------------------------------------------------------
CREATE TABLE Partie(
IdPartie NUMBER ,-- type qui s'auto-incremente avec saisie manuelle possible si necessaire
id_user number,
IdNiveau NUMBER, 
HDEB Number,
HFIN Number,
Score NUMBER(10),
Etat VARCHAR(10), 
id_user CONSTRAINT fk_idjoueur REFERENCES Joueur(id_user),
IdNiveau CONSTRAINT fk_niv_partie REFERENCES Niveau(IdNiveau),
constraint ck_etat check ( Etat = 1 OR Etat = 0),
CONSTRAINT pk_partie PRIMARY KEY(IdPartie)
);
------------------------------------------------------------------------------------------------
--TBALE Bille
------------------------------------------------------------------------------------------------
CREATE TABLE Bille(
IdBille NUMBER(3),
constraint pk_bille PRIMARY KEY (IdBille)
);
------------------------------------------------------------------------------------------------
--TABLE Coup
------------------------------------------------------------------------------------------------
CREATE TABLE COUP(
IdCoup NUMBER CONSTRAINT pk_Coup PRIMARY KEY, 
IdPartie NUMBER,
depart NUMBER,
arrivee NUMBER,
CONSTRAINT fk_IdBille_c foreign key (idBille) references Bille (idBille),
CONSTRAINT fk_IdPartie_c foreign key (idPartie) references Partie (idPartie)
);
------------------------------------------------------------------------------------------------
--TABLE Contenir
------------------------------------------------------------------------------------------------
CREATE TABLE Construire_niveau(
IdNiveau NUMBER(10),
IdBille NUMBER,
CONSTRAINT pkContenir PRIMARY KEY (IdNiveau, IdBille),
CONSTRAINT IdNiveau_cont foreign key (IdNiveau) references Niveau (IdNiveau),
CONSTRAINT Idbille_cont foreign key (IdBille) references Bille  (IdBille)
);
-----------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------
---###   remplir tables BILLE, Niveaux et Construire_niveau  ###### 
------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------
---  remplir tables des BILLES
------------------------------------------------------------------------------------------------

 --- le maximum de l'idbille est 86 en fonction de coordonnées dans le plateau solitaire pliennes
 -- alors en rempler de 22 jusqu'à 86 

DECLARE 
   i number(2); 
BEGIN  
   FOR i IN 1..49 LOOP 
     insert INTO bille values (i);
   END loop; 
END; 
/

------------------------------------------------------------------------------------------------
---  remplir table des Niveaux # 3 niveaux
------------------------------------------------------------------------------------------------
insert INTO Niveau values (1,6);
insert INTO Niveau values (2,11);
insert INTO Niveau values (3,16);
insert INTO Niveau values (4,32);

------------------------------------------------------------------------------------------------
---  remplir table de Construire_niveau
------------------------------------------------------------------------------------------------

--- pour initialiser les plateux des parties 

---- Niveau 1 croix de 5 billes

insert INTO Construire_niveau values (1,11);
insert INTO Construire_niveau values (1,17);
insert INTO Construire_niveau values (1,18);
insert INTO Construire_niveau values (1,19);
insert INTO Construire_niveau values (1,25);
insert INTO Construire_niveau values (1,32);

---- Niveau 2 cloche 11 billes


insert INTO Construire_niveau values (2,3);
insert INTO Construire_niveau values (2,4);
insert INTO Construire_niveau values (2,5);
insert INTO Construire_niveau values (2,10);
insert INTO Construire_niveau values (2,11);
insert INTO Construire_niveau values (2,12);
insert INTO Construire_niveau values (2,17);
insert INTO Construire_niveau values (2,18);
insert INTO Construire_niveau values (2,19);
insert INTO Construire_niveau values (2,24);
insert INTO Construire_niveau values (2,26);


---- Niveau 3 Pyramide 16 billes

insert INTO Construire_niveau values (3,11);
insert INTO Construire_niveau values (3,17);
insert INTO Construire_niveau values (3,18);
insert INTO Construire_niveau values (3,19);
insert INTO Construire_niveau values (3,23);
insert INTO Construire_niveau values (3,24);
insert INTO Construire_niveau values (3,25);
insert INTO Construire_niveau values (3,26);
insert INTO Construire_niveau values (3,27);
insert INTO Construire_niveau values (3,29);
insert INTO Construire_niveau values (3,30);
insert INTO Construire_niveau values (3,31);
insert INTO Construire_niveau values (3,32);
insert INTO Construire_niveau values (3,33);
insert INTO Construire_niveau values (3,34);
insert INTO Construire_niveau values (3,35);


---- Niveau 4 difficile solitaire pliennes avec 33 billes

insert INTO Construire_niveau values (4,3);
insert INTO Construire_niveau values (4,4);
insert INTO Construire_niveau values (4,5);
insert INTO Construire_niveau values (4,10);
insert INTO Construire_niveau values (4,11);
insert INTO Construire_niveau values (4,12);
insert INTO Construire_niveau values (4,15);
insert INTO Construire_niveau values (4,16);
insert INTO Construire_niveau values (4,17);
insert INTO Construire_niveau values (4,18);
insert INTO Construire_niveau values (4,19);
insert INTO Construire_niveau values (4,20);
insert INTO Construire_niveau values (4,21);
insert INTO Construire_niveau values (4,22);
insert INTO Construire_niveau values (4,23);
insert INTO Construire_niveau values (4,24);
insert INTO Construire_niveau values (4,26);
insert INTO Construire_niveau values (4,27);
insert INTO Construire_niveau values (4,28);
insert INTO Construire_niveau values (4,29);
insert INTO Construire_niveau values (4,30);
insert INTO Construire_niveau values (4,31);
insert INTO Construire_niveau values (4,32);
insert INTO Construire_niveau values (4,33);
insert INTO Construire_niveau values (4,34);
insert INTO Construire_niveau values (4,35);
insert INTO Construire_niveau values (4,38);
insert INTO Construire_niveau values (4,39);
insert INTO Construire_niveau values (4,40);
insert INTO Construire_niveau values (4,45);
insert INTO Construire_niveau values (4,46);
insert INTO Construire_niveau values (4,47);
----------------------------------------------------------------------------------
---###   creation des procedures  ###### 
------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------
--------- procedure enregistrer_joueur # inserer un joueur avec un niveau de dubétant 1 scorper 0
------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE enregistrer_joueur (p_idJoueur Joueur.Identifiant%type ,p_mdp Joueur.mdp%type,retour out number) IS  
  taille_mdp exception ;
  v_id_user number:=sq_Idjoueur.nextval;

    BEGIN
retour :=0;
if LENGTH(p_mdp)<4 then raise taille_mdp;
end if ;
insert into HDH0806A.Joueur (id_user,Identifiant,mdp,Scoreperso,IdNiveau,temps_bloc) values (v_id_user,p_idJoueur,p_mdp,p_nom,p_prenom,0,1,0);
commit;

    EXCEPTION 
when taille_mdp then retour :=1; -- taille de mot de passe est trés court
when others then retour:= SQLCODE;
end ;
/

------# si le mot de passe < 4 retour 1, si tout est bien(enregistrement éffictuer) passer alors retour 0
Declare
x number;
BEGIN
execute enregistrer_joueur('hassan','1234',x);
end;
/

-----------------------------------------------------------------------------------------------
--------- procedure connect_joueur # verification de password
------------------------------------------------------------------------------------------------
create or replace PROCEDURE  connect_joueur(p_idJoueur Joueur.Identifiant%type,p_mdp Joueur.mdp%type,retour out number) is
    v_mdp Joueur.mdp%type;
    mdp_faux exception;
BEGIN
    SELECT mdp into v_mdp FROM JOUEUR where identifiant=p_idJoueur;
    if v_mdp != p_mdp then raise mdp_faux;
    end if;
commit;
retour:=0;
EXCEPTION
    when no_data_found then 
       DBMS_OUTPUT.PUT_LINE('ce joueur n existe pas');
        retour :=2;
    WHEN mdp_faux THEN
        DBMS_OUTPUT.PUT_LINE('le motde passe est faut');
        retour :=1;
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(sqlerrm||' '||sqlcode);
        retour :=3;
END;

------------------------------------------------------------------------------------------------
--------- procedure creer_partie    # partie en état initiale avec des param id(joueur) et niveau
------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE creer_partie (p_idJoueur IN Joueur.id_user%type) IS  

    v_idpartie Number :=sq_IdPartie.nextval;
    level_joueur Niveau.IdNiveau%type;

    BEGIN

    Select idNiveau into level_joueur from Joueur where id_user=p_idJoueur;
    insert into partie(Idpartie,id_user,IdNiveau,HDEB) values(v_idpartie,p_idJoueur,level_joueur,DBMS_UTILITY.GET_TIME);
commit;

end ;
-----------------------------------------
DECLARE
h SYS_REFCURSOR;
begin
 creer_partie ('monster',h);
end;
/

------------------------------------------------------------------------------------------------
--------- procedure enregistrer_coup  # pour enregistrer le déplacement  des billes
------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE enregistrer_coup (p_bille bille.IdBille%type, p_partie partie.IdPartie%type, 
	em_depart bille.IdBille%type, em_arrivee bille.IdBille%type) IS  

p_idcoup=:sq_Idcoup.nextval ;

    BEGIN
insert into HDH0806A.Coup (idcoup,IdBille,IdPartie,depart,arrivee) values 
	(p_idcoup,p_bille,p_partie,em_depart,em_arrivee);
commit;

end ;
/

-----------------------------------------------------------------------------------------------------
--------- procedure parie_fini  # si la partie est fini il faut faire un update sur plusieur attributs
-----------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE parie_fini (p_idPartie Partie.IdPartie%TYPE,p_user partie.id_userr%TYPE,
 p_etat Partie.etat %TYPE, p_score Partie.score%TYPE,
     retour OUT NUMBER, update_niv_max out number, new_score_joueur out number) IS 

nbr_partie NUMBER;
flag NUMBER;
v_nivpartie NUMBER;-- niveau de partie
v_1scoreperso Number;-- score actuelle de joueur 
v_2scoreperso Number;--score sortie de joueur
v_niv_max number;-- niveau max si il gagne
v_niv_aut number;-- niveau auto si il gagne ou pas

BEGIN 
-- extrire le niveau de partie et le score personnel de joueur
SELECT scoreperso into v_1scoreperso from joueur where id_user=p_user;
SELECT idniveau into v_nivpartie from partie where idpartie=p_idPartie; 
flag :=1;
-- update etat partie et score et HFIN
UPDATE PARTIE 
SET etat = p_etat , score = p_score, HFIN = DBMS_UTILITY.GET_TIME WHERE idPartie = p_idPartie;

flag := 2;
-- Calculer le nombre des parties perdus pendans une heure
SELECT COUNT(IdPARTIE) INTO nbr_partie FROM Partie WHERE (id_user = p_user )AND (etat = 0) 
AND (DBMS_UTILITY.GET_TIME - HFIN) < 3600000;-- nombre des partie perdus pendat une heure=3600000 ms

IF nbr_partie >4 THEN -- dépassant 5 parties

    UPDATE JOUEUR SET
    temps_bloc = DBMS_UTILITY.GET_TIME WHERE id_user = p_user;--ajouter le temps de blocage
END IF ;

SELECT idNiveau into v_niv_max from joueur where id_user=p_user;

v_niv_aut:=v_nivpartie;--rest en même niveau 
v_2scoreperso:=v_1scoreperso;-- rest au même scoreperso
nif p_etat=1 then -- gagne
v_niv_aut:=v_nivpartie+1; -- s'il gagne on augmente le niveau autorisern
v_2scoreperso:=v_1scoreperso+p_score; -- s'il gagne on ajoute le score de partie au score personnel
end if;

-- augmenterle niveau de joueur en cas de gagner la partie
if p_etat=1 and v_niv_max<v_niv_aut and v_niv_aut<=4 then
update joueur set idNiveau=v_niv_aut where id_user=p_user;
end if;

-- augmenter le scoreperso de joueur en cas de gagner la partie
if p_etat=1 ;
update joueur set Scoreperso=v_2scoreperso where id_user=p_user;
end if;
-- remplire  les sorties
SELECT idNiveau into update_niv_max from joueur where id_user=p_user;
SELECT Scoreperso into new_score_joueur from joueur where id_user=p_user;
COMMIT;
retour :=0;
EXCEPTION 

WHEN NO_DATA_FOUND THEN
    IF flag = 1 THEN
        DBMS_OUTPUT.PUT_LINE('identifiant n est existe pas');
        retour :=1;
    ELSE
        DBMS_OUTPUT.PUT_LINE('partie n existe pas');
        retour :=2;
    END IF;
WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(sqlerrm||' '||sqlcode);
    retour :=3;
    
END;
/

------------------------------------------------------------------------------------------------
--------- procedure rejouer_partie  # rejouer les partie avec id partie 
------------------------------------------------------------------------------------------------


create or replace Procedure rejouer_partie(p_idPartie in Partie.IdPartie%type,retour out number, cur_coup out SYS_REFCURSOR) IS
  nbre_Partie number(2);
  partie_notefound exception; 
  
BEGIN  
  open cur_coup for SELECT DEPART,ARRIVEE  from COUP where idpartie=p_idPartie ORDER by idcoup;
  select count(*) into nbre_Partie from Partie where idPartie = p_idPartie ; 
  if nbre_Partie != 1 then raise partie_notefound ; 
  end if ; 
commit;
 retour := 0 ; 
EXCEPTION 
  when partie_notefound then 
        DBMS_OUTPUT.PUT_LINE('cette partie n existe pas');
        retour :=1; 
  when others then 
   DBMS_OUTPUT.PUT_LINE(sqlerrm||' '||sqlcode);
    retour :=2;
end;
----------------------------------------
DECLARE 
  cc SYS_REFCURSOR;
  a number(2);

BEGIN
rejouer_partie(2,a,cc)
DBMS_OUTPUT.PUT_LINE(cc);
DBMS_OUTPUT.PUT_LINE(a);
end;




------------------------------------------------------------------------------------------------
---###   creation des Trigges  ###### 
------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------
--------- trigger max_5_g_perdu # 5 Partie maximum à perdre pendans 1 heure
-----------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER max_5_g_perdu BEFORE INSERT ON Partie FOR EACH ROW
Declare

nbre_bloc NUMBER;
h_bloc number;
this_time NUMBER;

Begin
SELECT DBMS_UTILITY.GET_TIME INTO this_time FROM DUAL; 
SELECT count(temps_bloc) INTO nbre_bloc FROM JOUEUR WHERE id_user = :NEW.id_user;
IF nbre_bloc != 0 THEN
    SELECT temps_bloc INTO h_bloc FROM JOUEUR WHERE id_user = :NEW.id_user;
    IF this_time - h_bloc < 4*3600000 THEN
        raise_application_error(-20003,'Vous avez pas le droit de joueur une autre partie , attendez 1H SvP!');
    END IF;
END IF;

END;
/



-----------------------------------------------------------------------------------------------
--------- trigger Niveau_adapte # le niveau de partie autorisée par joueur
-----------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER Niveau_adapte BEFORE INSERT ON Partie FOR EACH ROW

    DECLARE
    lev_max NUMBER;

    BEGIN
    SELECT IdNiveau INTO lev_max FROM Joueur WHERE id_user = :NEW.id_user;

    IF (:NEW.idNiveau>  lev_max) THEN
        raise_application_error(-20005,'le Niveau choisi n est pas autorisé');
    
    END IF;
END;
/

-----------------------------------------------------------------------------------------------
-------- trigger verif_idjoueur # verrifier est ce que l'identifiant est déja dans la BD bef,ins
------------------------------------------------------------------------------------------------

Create or replace Trigger verif_idjoueur Before insert on Joueur For each row
    	Declare
	nbre_idj number (3);
	
	    BEGIN
	Select count(*) into nbre_idj from HDH0806A.Joueur where Identifiant =:NEW.Identifiant ; 

	if nbre_idj >0 then  
	raise_application_error(-20001, 'ce identifiant est déja inscrit');
	end if ;
end ;
/ 


-----------------------------------------------------------------------------------------------
--------#### Views 
-----------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------
-------- View affichage de score personnel
-----------------------------------------------------------------------------------------------
create or replace view score_personnel as
select identifiant,Scoreperso
from JOUEUR ;

-----------------------------------------------------------------------------------------------
-------- View affichage de highscore 
-----------------------------------------------------------------------------------------------

--ERROR

create or replace view highscore as
select max(Scoreperso) 
from JOUEUR ;

-----------------------------------------------------------------------------------------------
--------View affichage des parties jouers
-----------------------------------------------------------------------------------------------
create or replace view Parties_finis as
select idpartie,IdNiveau, score
from partie ;





GRANT SELECT, INSERT, UPDATE, DELETE ON <nomtable1> TO gdn2950a;
GRANT SELECT, INSERT, UPDATE, DELETE ON <nomtable2> TO gdn2950a;
GRANT SELECT, INSERT, UPDATE, DELETE ON <nomtable3> TO gdn2950a;
GRANT SELECT, INSERT, UPDATE, DELETE ON <nomtable4> TO gdn2950a;
GRANT SELECT, INSERT, UPDATE, DELETE ON <nomtable5> TO gdn2950a;
GRANT SELECT, INSERT, UPDATE, DELETE ON <nomtable6> TO gdn2950a;
GRANT SELECT, INSERT, UPDATE, DELETE ON <nomtable7> TO gdn2950a;


