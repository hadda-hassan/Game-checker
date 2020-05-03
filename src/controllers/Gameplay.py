from src.models.Partie import Partie
from src.models.Coup import Coup
from src import db,engine
import cx_Oracle
class Gameplay:

    # la fonction de creation d'une nouvelle partie, elle appelle la fonction create_partie du Model Partie
    @staticmethod
    def newgame(user_id,level_id):
        return Partie.create_partie(user_id,level_id)
        
    # la fonction qui maruqe la fin d'une partie, elle appelle la fonction end_partie du Model Partie
    @staticmethod
    def endgame(user_id,idpartie,etat,score):
        return Partie.end_partie(user_id,idpartie,etat,score)

    # Cette fonction permet l'enregistrement d'un coup, elle appelle la procédure enregistrer_coup de la bdd
    @staticmethod
    def savecoup(idbille,idpartie,depart,arrivee):
        connection = engine.raw_connection()
        cursor = connection.cursor()
        cursor.callproc("enregistrer_coup", [int(idbille),int(idpartie),int(depart),int(arrivee)])
        cursor.close()
        connection.close()
        return True

    # cette fonction retourne toutes la parties à partir d'un Id Utilisateur
    @staticmethod
    def mine(id_user):
        parties = Partie.query.filter_by(id_user=id_user,etat=1).order_by("idpartie").all()
        data = []
        for partie in parties:
            data.append({
                'id':partie.idpartie,
                'lvl':partie.idniveau,
                'score':partie.score,
                'etat':partie.etat,
                'hdeb':partie.hdeb,
                'hfin':partie.hfin,
            })
        return data

    # Cette fonction retourne tout les coups dune partie déjà jouer afin de simuler une partie
    @staticmethod
    def revoire(idpartie):
        coups = Coup.query.filter_by(idpartie=idpartie).order_by("idcoup").all()
        data = []
        for coup in coups:
            data.append({
                'depart':coup.depart,
                'arrivee':coup.arrivee,
            })
        return data
