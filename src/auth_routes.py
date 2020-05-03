from flask import Blueprint
from . import db
from . import login_manager
from flask_login import login_user,login_required,logout_user,current_user
from flask import Flask, render_template, Markup, request,redirect
from src.controllers.Auth import Auth
from src.models.Joueur import Joueur
auth = Blueprint('auth', __name__)

@login_manager.user_loader
def load_user(user_id):
    return Joueur.query.get(int(user_id))


@login_manager.unauthorized_handler
def unauthorized_callback():
    return redirect('/auth/login')

@auth.route('/auth/login')
def getLogin():
    return render_template('login.html')

@auth.route('/auth/check',methods=['POST'])
def postLogin():
    identifiant = request.form.get('identifiant')
    mdp = request.form.get('mdp')
    if identifiant is None or mdp is None or identifiant == '' or mdp == '':
        return {
            'action':False,
            'msg':'Merci de verifier vos informations.'
        }
    joueur = Auth.attempt(username=identifiant,password=mdp)
    if not joueur:
        return {
            'action':False,
            'msg':'Merci de verifier vos informations.'
        }
    login_user(joueur)
    return {'action':True}
    # return redirect('/home')

@auth.route('/auth/register')
def signup():
    return render_template('register.html')

@auth.route('/auth/register',methods=['post'])
def post_signup():
    identifiant = request.form.get('identifiant')
    mdp = request.form.get('mdp')
    if identifiant is None or mdp is None or identifiant == '' or mdp == '':
        return redirect('/auth/register?error=0')

    retour,user = Auth.create(identifiant,mdp)
    if retour != 0:
        return redirect('/auth/register?error=1')
    else:
        login_user(user)
        return redirect('/')


@auth.route('/auth/logout')
@login_required
def logout():
    logout_user()
    return redirect('/auth/login?logout=1')