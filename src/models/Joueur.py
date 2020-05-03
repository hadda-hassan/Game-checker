from src import db
from flask_login import UserMixin

class Joueur(UserMixin,db.Model):
    id_user = db.Column(db.Integer(),primary_key=True)
    identifiant = db.Column(db.String(30))
    mdp = db.Column(db.String(30))
    scoreperso = db.Column(db.Integer())
    idniveau = db.Column(db.Integer())
    def get_id(self):
        return (self.id_user)