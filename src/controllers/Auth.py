from src.models.Joueur import Joueur
from src import db,engine
import cx_Oracle
class Auth:
    @staticmethod
    def attempt(username,password):
        j = Joueur.query.filter_by(identifiant=username).first()
        if j and j.mdp == password:
            return j
        else :
            return None

    @staticmethod
    def create(username,password):
        connection = engine.raw_connection()
        cursor = connection.cursor()
        retour = cursor.var(cx_Oracle.NUMBER)
        cursor.callproc("enregistrer_joueur",[username,password,retour])
        cursor.close()
        connection.close()
        joueur = Auth.attempt(username,password)
        return retour.values[0],joueur
