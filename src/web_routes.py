from flask import Blueprint
import sqlalchemy,cx_Oracle
from . import db
from . import login_manager
from flask import Flask, render_template, Markup, request,redirect,jsonify
main = Blueprint('main', __name__)
from src.controllers.Auth import Auth
from src.controllers.Gameplay import Gameplay
from src.models.Joueur import Joueur
from src.models.Partie import Partie
from flask_login import login_required,current_user
import json

@login_manager.user_loader
def load_user(id_user):
    return Joueur.query.get(int(id_user))

@main.route('/')
@login_required
def index():
    user = current_user
    return render_template('index.html',user=user)

@main.route('/jouer')
@login_required
def jouer():
    user = current_user
    return render_template('game.html',user=user)

@main.route('/aide')
@login_required
def aide():
    user = current_user
    return render_template('aide.html',user=user)

@main.route('/rejouer')
@login_required
def rejouer():
    user = current_user
    parties = Gameplay.mine(user.id_user)
    return render_template('rejouer.html',user=user,parties=parties)

@main.route('/rejouer/<partie_id>')
@login_required
def rejouerpartie(partie_id):
    user = current_user
    partie_id = int(partie_id)
    coups = Gameplay.revoire(partie_id)
    partie = Partie.query.get(int(partie_id)).idniveau
    return render_template('simulation.html',user=user,coups=coups,partie=partie)




# Game Play ajax routes
@main.route('/backend/play')
@login_required
def backend_play():
    try:
        user = current_user
        level = request.args.get('niveau')
        if int(level) > int(user.idniveau):
            return {'action':False,'msg':"Vous n'avez pas le niveau pour jouer cette partie"}
        else:
            idpartie = Gameplay.newgame(user.id_user,int(level))
            return {'action':True,'idpartie':idpartie}
    except cx_Oracle.DatabaseError as e:
        errorObj, = e.args
        msg = errorObj.message.split('\n')[0].split(': ')[1]
        return {'action':False,'msg':msg}
    
@main.route('/backend/coup',methods=['POST'])
@login_required
def backend_coup():
    user = current_user
    idpartie = request.form.get('idpartie',None)
    idbille = request.form.get('idbille',None)
    depart = request.form.get('depart',None)
    arrivee = request.form.get('arrivee',None)
    # return {'idpartie':idpartie,'idbille':idbille,'depart':depart,'arrivee':arrivee}
    if not idpartie or not idbille or not depart or not arrivee:
        return {'action':False}
    coup = Gameplay.savecoup(idbille,idpartie,depart,arrivee)
    return {'action':True}
    
@main.route('/backend/endgame',methods=['POST'])
@login_required
def backend_endgame():
    user = current_user
    idpartie = request.form.get('idpartie',None)
    score = request.form.get('score',None)
    etat = request.form.get('etat',None)
    if not idpartie or not score or not etat:
        return {'action':False}
    score_n = Gameplay.endgame(user.id_user,idpartie,score,etat)
    return {'action':True,'score':score_n}
    

