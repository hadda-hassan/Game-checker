---- proce enrigestrement joueur  

CREATE PROCEDURE get_count (OUT nb INT) 
    BEGIN
        SELECT COUNT(*) INTO nb FROM T1;
  END;
  /
  
 ---- proce enrigestrement game 
CREATE PROCEDURE get_count (OUT nb INT) 
    BEGIN
        SELECT COUNT(*) INTO nb FROM T1;
    END;
    /
--- enrigestrement coup
CREATE PROCEDURE get_count (OUT nb INT) 
    BEGIN
        SELECT COUNT(*) INTO nb FROM T1;
    END;
    /
--- cas initiale de case
CREATE PROCEDURE get_count (OUT nb INT) 
    BEGIN
        SELECT COUNT(*) INTO nb FROM T1;
    END;
    /
    
    
    
    
-------------TRIGGER

--TRIGGERS--


--Trigger Insertion Partie : gérer le niveau de la partie, la date
Create or replace Trigger t_b_i_partie 
Before insert on partie
For each row
Declare
    --cursor PartiesJouées is select DateP from Partie where IdJoueur = NEW.IdJoueur;
    vNiveau Partie.numniveau%TYPE;
    vDateLimite date;
Begin
    Select numniveau into vNiveau
    from Joueur 
    where IdJoueur = :NEW.IdJoueur;

    if :NEW.NumNiveau > vNiveau then
        raise_application_error(-20001, 'Niveau joueur inferieur au niveau requis de la partie');
    end if;
    Select DateLimite into vDatelimite from Joueur where IdJoueur = :NEW.IdJoueur;
    if vDateLimite > sysdate then 
        raise_application_error(-20002, 'Impossible de lancer une nouvelle parties car 5 perdues dans l heure');
    end if;
    if :New.estFinie = 1 then
        raise_application_error(-20003, 'Impossible de créer la partie si deja finie');
    end if;
    
end t_b_i_partie;
/
----TRIGGER AVANT enrigestrement joueur





-----trigger apres coup




