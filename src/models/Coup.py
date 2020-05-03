from src import db
class Coup(db.Model):
    idcoup = db.Column(db.Integer(),primary_key=True)
    idbille = db.Column(db.Integer())
    idpartie = db.Column(db.Integer())
    depart = db.Column(db.Integer())
    arrivee = db.Column(db.Integer())
