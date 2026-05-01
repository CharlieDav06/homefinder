from flask import Flask, jsonify, request
from flask_mysqldb import MySQL

app = Flask(__name__)

# MySQL config
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'homefinder123'
app.config['MYSQL_DB'] = 'home_finder_db'

mysql = MySQL(app)

# Test route - visit this first to check connection works
@app.route('/')
def home():
    return "Flask is running!"

# Get all properties
@app.route('/properties')
def get_properties():
    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM property")
    rows = cur.fetchall()
    cur.close()
    return jsonify(rows)

# Get all users
@app.route('/users')
def get_users():
    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM user")
    rows = cur.fetchall()
    cur.close()
    return jsonify(rows)

# Login route
@app.route('/login', methods=['POST'])
def login():
    data = request.json
    email = data['email']
    password = data['password']
    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM user WHERE email = %s AND password = %s", (email, password))
    user = cur.fetchone()
    cur.close()
    if user:
        return jsonify({"message": "Login successful"})
    else:
        return jsonify({"message": "Invalid credentials"}), 401

if __name__ == '__main__':
    app.run(debug=True)