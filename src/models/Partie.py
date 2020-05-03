from src import db,engine
import cx_Oracle

class Partie(db.Model):
    idpartie = db.Column(db.Integer(),primary_key=True)
    id_user = db.Column(db.Integer())
    idniveau = db.Column(db.Integer())
    score = db.Column(db.Integer())
    etat = db.Column(db.Integer())
    hfin = db.Column(db.Integer())
    hdeb = db.Column(db.Integer())
    def get_id(self):
        return (self.idpartie)

    # methode de creation de partie, elle utilise la procedure cree_partie
    @staticmethod
    def create_partie(user_id,niveau_id):
        connection = engine.raw_connection()
        cursor = connection.cursor()
        idpartie  = cursor.var(cx_Oracle.NUMBER)
        cursor.callproc("creer_partie", [int(user_id),int(niveau_id),idpartie])
        cursor.close()
        connection.close()
        idpartie = idpartie.values[0]
        return int(idpartie)

    # methode de mettre a jours les informations apres fin de partie elle appelle la procedurer partie_fini
    @staticmethod
    def end_partie(user_id,idpartie,score,etat):
        connection = engine.raw_connection()
        cursor = connection.cursor()
        r  = cursor.var(cx_Oracle.NUMBER)
        niv_max  = cursor.var(cx_Oracle.NUMBER)
        new_score_joueur  = cursor.var(cx_Oracle.NUMBER)
        cursor.callproc("parie_fini", [int(idpartie),int(user_id),int(etat),int(score),r,niv_max,new_score_joueur])
        cursor.close()
        connection.close()
        return new_score_joueur.values[0]

    # cette methode permet d'appeller la procedure rejouer_partie mais elle n'est pas utilisee
    @staticmethod
    def revoir(idpartie):
        connection = engine.raw_connection()
        cursor = connection.cursor()
        data  = cursor.var(cx_Oracle.CURSOR)
        cursor.callproc("rejouer_partie", [idpartie,data])
        for result in cursor.stored_results():
            people=result.fetchall()

        cursor.close()
        connection.close()
        return people
        
