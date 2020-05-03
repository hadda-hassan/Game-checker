from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager
from sqlalchemy import create_engine

# initialisation du projet
db = SQLAlchemy()
login_manager = LoginManager()
ORACLE_URI = 'oracle://HDH0806A:hadda1574@telline.univ-tlse3.fr:1521/etupre'
engine = create_engine(ORACLE_URI)

def create_app():

    # initialisation de la base de donnes et du SECRET KEY qui permet la securisation des sessions de flask
    app = Flask(__name__)
    app.config['SECRET_KEY'] = '9OLWxND4o83j4K4iuopO'
    app.config['SQLALCHEMY_DATABASE_URI'] = ORACLE_URI
    db.init_app(app)
    login_manager.init_app(app)
    
    # blueprint for auth routes in our app
    from .auth_routes import auth as auth_blueprint
    app.register_blueprint(auth_blueprint)
    # blueprint for non-auth parts of app
    from .web_routes import main as main_blueprint
    app.register_blueprint(main_blueprint)

    return app