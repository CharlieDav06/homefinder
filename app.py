import os
import bcrypt
import random
from flask import Flask, jsonify, send_from_directory
from flask_mysqldb import MySQL

app = Flask(__name__)

app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'homefinder123'
app.config['MYSQL_DB'] = 'home_finder_db'

mysql = MySQL(app)

CLIENT_FOLDER = os.path.join(os.path.dirname(__file__), 'client')

@app.route('/client/<path:filename>')
def client_files(filename):
    return send_from_directory(CLIENT_FOLDER, filename)

@app.route('/properties')
def index():
    return send_from_directory(CLIENT_FOLDER, 'properties.html')

@app.route('/api/properties')
def get_properties():
    cur = mysql.connection.cursor()
    cur.execute("""
        SELECT p.property_id, p.name, p.location, p.description, p.image_url,
               COALESCE(r.price, re.monthly_rent, c.price) as price,
               CASE 
                   WHEN r.property_id IS NOT NULL THEN 'residential'
                   WHEN re.property_id IS NOT NULL THEN 'rental'
                   WHEN c.property_id IS NOT NULL THEN 'commercial'
               END as type
        FROM property p
        LEFT JOIN residential r ON p.property_id = r.property_id
        LEFT JOIN rental re ON p.property_id = re.property_id
        LEFT JOIN commercial c ON p.property_id = c.property_id
    """)
    rows = cur.fetchall()
    columns = [col[0] for col in cur.description]  # ← fix: get column names
    cur.close()
    return jsonify([dict(zip(columns, row)) for row in rows])  # ← fix: convert to dicts

@app.route('/api/properties/<int:property_id>')
def get_property(property_id):
    cur = mysql.connection.cursor()
    cur.execute("""
        SELECT p.property_id, p.name, p.location, p.description, p.image_url, p.owner_email,
               COALESCE(r.price, re.monthly_rent, c.price) as price,
               CASE 
                   WHEN r.property_id IS NOT NULL THEN 'residential'
                   WHEN re.property_id IS NOT NULL THEN 'rental'
                   WHEN c.property_id IS NOT NULL THEN 'commercial'
               END as type,
               COALESCE(r.num_bedrooms, re.num_bedrooms) AS num_bedrooms,
               r.is_furnished AS residential_furnished,   -- ← fix: aliased
               COALESCE(r.num_bathrooms, re.num_bathrooms) AS num_bathrooms,
               re.is_furnished AS rental_furnished,       -- ← fix: aliased
               re.is_pet_friendly, re.lease_duration, re.security_deposit,
               c.square_ft, c.floors, c.property_usage, c.has_parking, c.zoning_type
        FROM property p
        LEFT JOIN residential r ON p.property_id = r.property_id
        LEFT JOIN rental re ON p.property_id = re.property_id
        LEFT JOIN commercial c ON p.property_id = c.property_id
        WHERE p.property_id = %s
    """, (property_id,))

    row = cur.fetchone()
    columns = [col[0] for col in cur.description]
    cur.close()

    if not row:
        return jsonify(None)

    return jsonify(dict(zip(columns, row)))


@app.route('/api/reservations', methods=['POST'])
def create_reservation():
    data = request.get_json()

    cur = mysql.connection.cursor()
    cur.execute("""
        INSERT INTO Viewing_Reservation 
          (property_id, user_id, reservation_name, schedule_date, 
           reservation_duration, reservation_type, status)
        VALUES (%s, %s, %s, %s, %s, %s, 'pending')
    """, (
        data['property_id'],
        data['user_id'],
        data['reservation_name'],
        data['schedule_date'],
        data['reservation_duration'],
        data['reservation_type'],
    ))
    mysql.connection.commit()
    cur.close()

    return jsonify({ 'success': True })

@app.route('/register')
def register_page():
    return send_from_directory(CLIENT_FOLDER, 'register.html')


@app.route('/login')
def login_page():
    return send_from_directory(CLIENT_FOLDER, 'login.html')


@app.route('/twofa')
def twofa_page():
    return send_from_directory(CLIENT_FOLDER, 'twofa.html')


@app.route('/api/register', methods=['POST'])
def register_user():
    data = request.get_json()

    email = data.get('email')
    password = data.get('password')

    if not email or not password:
        return jsonify({
            'success': False,
            'message': 'Email and password are required.'
        }), 400

    cur = mysql.connection.cursor()

    cur.execute("SELECT user_id FROM users WHERE email = %s", (email,))
    existing_user = cur.fetchone()

    if existing_user:
        cur.close()
        return jsonify({
            'success': False,
            'message': 'This email is already registered.'
        }), 409

    hashed_password = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())

    cur.execute("""
        INSERT INTO users (email, password)
        VALUES (%s, %s)
    """, (email, hashed_password.decode('utf-8')))

    mysql.connection.commit()
    cur.close()

    return jsonify({
        'success': True,
        'message': 'User registered successfully.'
    })


@app.route('/api/login', methods=['POST'])
def login_user():
    data = request.get_json()

    email = data.get('email')
    password = data.get('password')

    if not email or not password:
        return jsonify({
            'success': False,
            'message': 'Email and password are required.'
        }), 400

    cur = mysql.connection.cursor()

    cur.execute("""
        SELECT user_id, email, password
        FROM users
        WHERE email = %s
    """, (email,))

    user = cur.fetchone()

    if not user:
        cur.close()
        return jsonify({
            'success': False,
            'message': 'Invalid login details.'
        }), 401

    user_id = user[0]
    stored_password = user[2]

    password_matches = bcrypt.checkpw(
        password.encode('utf-8'),
        stored_password.encode('utf-8')
    )

    if not password_matches:
        cur.close()
        return jsonify({
            'success': False,
            'message': 'Invalid login details.'
        }), 401

    token = str(random.randint(100000, 999999))
    expires_at = datetime.now() + timedelta(minutes=5)

    cur.execute("""
        INSERT INTO twofa_tokens (user_id, token, expires_at)
        VALUES (%s, %s, %s)
    """, (user_id, token, expires_at))

    mysql.connection.commit()
    cur.close()

    print("2FA CODE:", token)

    return jsonify({
        'success': True,
        'step': '2FA',
        'userId': user_id,
        'message': '2FA code generated.'
    })


@app.route('/api/verify-2fa', methods=['POST'])
def verify_2fa():
    data = request.get_json()

    user_id = data.get('userId')
    token = data.get('token')

    if not user_id or not token:
        return jsonify({
            'success': False,
            'message': 'User ID and token are required.'
        }), 400

    cur = mysql.connection.cursor()

    cur.execute("""
        SELECT token_id, expires_at
        FROM twofa_tokens
        WHERE user_id = %s
          AND token = %s
          AND used = FALSE
        ORDER BY token_id DESC
        LIMIT 1
    """, (user_id, token))

    record = cur.fetchone()

    if not record:
        cur.close()
        return jsonify({
            'success': False,
            'message': 'Invalid 2FA code.'
        }), 401

    token_id = record[0]
    expires_at = record[1]

    if datetime.now() > expires_at:
        cur.close()
        return jsonify({
            'success': False,
            'message': '2FA code has expired.'
        }), 401

    cur.execute("""
        UPDATE twofa_tokens
        SET used = TRUE
        WHERE token_id = %s
    """, (token_id,))

    mysql.connection.commit()
    cur.close()

    return jsonify({
        'success': True,
        'message': 'Login successful.'
    })










if __name__ == '__main__':
    app.run(debug=True)