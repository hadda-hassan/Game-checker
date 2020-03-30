from sqlalchemy import create_engine
import cx_Oracle
import datetime
from flask_mysqldb import MySQL
import MySQLdb.cursors
import re

from flask import Flask, render_template, Markup, request, session, redirect, url_for
app = Flask(__name__)
mysql = MySQL(app)

engine = create_engine('oracle://cnj3031a:Yoloswag69@telline.univ-tlse3.fr:1521/etupre')


@app.route('/')
def home():

	if not session.get('logged_in'):

		return render_template('login.html')
	else:
		return render_template('index.html')	



#@app.route("/login")
#def login_page():
#	connection = engine.raw_connection()
#	code_html = "<h1> TEST </h1>"
#	
#	return render_template("login.html", content=Markup(code_html))	






@app.route('/login', methods=['GET', 'POST'])
def login():

    # Output message if something goes wrong...
    # msg = ''

    if session.get('logged_in'):
        return redirect(url_for('home'))

    # Check if "username" and "password" POST requests exist (user submitted form)

    if request.method == 'POST' and 'username' in request.form \
        and 'password' in request.form:

        # Create variables for easy access

        username =  request.form['username']
        password = request.form['password']

        # Check if account exists using MySQL
        # cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)

        with engine.connect() as con:
            rs = \
                con.execute('SELECT * FROM sbc2937a.Joueur WHERE identifiant = \''
                             + username + '\' AND mdp = \''
                            + password + '\'')
            for account in rs:
                session['logged_in'] = True
                session['username'] = account['identifiant']
            if session.get('logged_in'):
                return redirect(url_for('home'))
            else:
                return render_template('login.html',
                        msg='Incorrect password')
    return render_template('login.html')
		        

		  



@app.route('/logout')
def logout():
    # remove the username from the session if it's there
    session.pop('username', None)
    session.pop('id', None)
    session.pop('logged_in', None)
    session.pop('password', None)

    return render_template('login.html')



@app.route('/register', methods=['GET', 'POST'])
def register():
    msg = ''
    # Check if "username", "password" and "email" POST requests exist (user submitted form)
    if request.method == 'POST' and 'username' in request.form and 'password' in request.form and 'email' in request.form:
        # Create variables for easy access
        username = request.form['username']
        password = request.form['password']
        email = request.form['email']
        con = engine.raw_connection()
        try:
            cursor = con.cursor()
            error = cursor.var(cx_Oracle.NUMBER)
            cursor.callproc("sbc2937a.Insert_Joueur", [username, password, error])
            cursor.close()
            con.commit()
            msg = error
        finally:
            con.close()

    elif request.method == 'POST':
        # Form is empty... (no POST data)
        msg = 'Please fill out the form!'
    # Show registration form with message (if any)
    return render_template('register.html', msg=msg)


@app.route('/mastermind')
def mastermind():
    return render_template('mastermind.html')


if __name__ == "__main__":
    app.secret_key = 'super secret key'
    app.config['SESSION_TYPE'] = 'filesystem'
    app.run(debug='on')
    	





"""

@app.route('/register', methods=['GET', 'POST'])
def register():
    msg = ''
    # Check if "username", "password" and "email" POST requests exist (user submitted form)
    if request.method == 'POST' and 'username' in request.form and 'password' in request.form and 'email' in request.form:
        # Create variables for easy access
        username = request.form['username']
        password = request.form['password']
        email = request.form['email']
        with engine.connect() as con:

            rs = \
            con.execute('SELECT * FROM accounts WHERE username = \''+username+'\'')
            for account in rs:
                # If account exists show error and validation checks
                if account['username'] ==username:
                    return render_template('register.html', msg='Account already exists!')
            if not re.match(r'[^@]+@[^@]+\.[^@]+', email):
                    msg = 'Invalid email address!'
            elif not re.match(r'[A-Za-z0-9]+', username):
                    msg = 'Username must contain only characters and numbers!'
            elif not username or not password or not email:
                msg = 'Please fill out the form!'
            else:
                trans = con.begin()
                # Account doesnt exists and the form data is valid, now insert new account into accounts table
                try:
                    con.execute('INSERT INTO accounts VALUES (4,\''+username + '\' , \''+password+'\')')
                    trans.commit()
                    msg = 'You have successfully registered!'
                except:
                    trans.rollback()
                    raise

    elif request.method == 'POST':
        # Form is empty... (no POST data)
        msg = 'Please fill out the form!'
    # Show registration form with message (if any)
    return render_template('register.html', msg=msg)

"""