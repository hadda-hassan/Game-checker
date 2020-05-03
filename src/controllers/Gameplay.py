from src.models.Partie import Partie
from src.models.Coup import Coup
from src import db,engine
import cx_Oracle
class Gameplay:
    @staticmethod
    def newgame(user_id,level_id):
        return Partie.create_partie(user_id,level_id)
        
    @staticmethod
    def endgame(user_id,idpartie,etat,score):
        return Partie.end_partie(user_id,idpartie,etat,score)

    @staticmethod
    def savecoup(idbille,idpartie,depart,arrivee):
        connection = engine.raw_connection()
        cursor = connection.cursor()
        cursor.callproc("enregistrer_coup", [int(idbille),int(idpartie),int(depart),int(arrivee)])
        cursor.close()
        connection.close()
        return True

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
