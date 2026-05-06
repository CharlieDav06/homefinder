import os
import bcrypt
import random
import pymysql
import pymysql.cursors
import smtplib
from email.message import EmailMessage
from flask import Flask, jsonify, send_from_directory, request
from datetime import datetime, timedelta

app = Flask(__name__)

def send_2fa_email(recipient_email, token):
    sender_email = "kaellion9812@gmail.com"
    sender_password = "hrqy rufc zgoa jdzq"

    message = EmailMessage()
    message["Subject"] = "HomeFinder 2FA Verification Code"
    message["From"] = sender_email
    message["To"] = recipient_email
    message.set_content(f"Your HomeFinder verification code is: {token}")

    with smtplib.SMTP_SSL("smtp.gmail.com", 465) as smtp:
        smtp.login(sender_email, sender_password)
        smtp.send_message(message)

db_config = {
    'host': 'localhost',
    'user': 'root',
    'password': 'homefinder123',
    'database': 'home_finder_db',
    'cursorclass': pymysql.cursors.DictCursor
}

def get_db():
    return pymysql.connect(**db_config)

CLIENT_FOLDER = os.path.join(os.path.dirname(__file__), 'client')

@app.route('/client/<path:filename>')
def client_files(filename):
    return send_from_directory(CLIENT_FOLDER, filename)

@app.route('/properties')
def index():
    return send_from_directory(CLIENT_FOLDER, 'properties.html')

@app.route('/api/properties')
def get_properties():
    con = get_db()
    cur = con.cursor()
    cur.execute("""
        SELECT p.property_id, p.name, p.location, p.description, p.image_url,
               COALESCE(r.price, re.monthly_rent, c.price) as price,
               CASE 
                   WHEN r.property_id IS NOT NULL THEN 'residential'
                   WHEN re.property_id IS NOT NULL THEN 'rental'
                   WHEN c.property_id IS NOT NULL THEN 'commercial'
               END as type,
               COALESCE(r.num_bedrooms, re.num_bedrooms) AS num_bedrooms,
               COALESCE(r.is_furnished, re.is_furnished) AS is_furnished
        FROM property p
        LEFT JOIN residential r ON p.property_id = r.property_id
        LEFT JOIN rental re ON p.property_id = re.property_id
        LEFT JOIN commercial c ON p.property_id = c.property_id
    """)
    rows = cur.fetchall()
    cur.close()
    con.close()
    return jsonify(rows)

@app.route('/api/properties/<int:property_id>')
def get_property(property_id):
    con = get_db()
    cur = con.cursor()
    cur.execute("""
        SELECT p.property_id, p.name, p.location, p.description, p.image_url, p.owner_email,
               COALESCE(r.price, re.monthly_rent, c.price) as price,
               CASE 
                   WHEN r.property_id IS NOT NULL THEN 'residential'
                   WHEN re.property_id IS NOT NULL THEN 'rental'
                   WHEN c.property_id IS NOT NULL THEN 'commercial'
               END as type,
               COALESCE(r.num_bedrooms, re.num_bedrooms) AS num_bedrooms,
               r.is_furnished AS residential_furnished,
               COALESCE(r.num_bathrooms, re.num_bathrooms) AS num_bathrooms,
               re.is_furnished AS rental_furnished,
               re.is_pet_friendly, re.lease_duration, re.security_deposit,
               c.square_ft, c.floors, c.property_usage, c.has_parking, c.zoning_type
        FROM property p
        LEFT JOIN residential r ON p.property_id = r.property_id
        LEFT JOIN rental re ON p.property_id = re.property_id
        LEFT JOIN commercial c ON p.property_id = c.property_id
        WHERE p.property_id = %s
    """, (property_id,))
    row = cur.fetchone()
    cur.close()
    con.close()
    if not row:
        return jsonify(None)
    return jsonify(row)

@app.route('/api/reservations', methods=['POST'])
def create_reservation():
    data = request.get_json()
    con = get_db()
    cur = con.cursor()
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
    con.commit()
    cur.close()
    con.close()
    return jsonify({'success': True})

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
    first_name = data.get('first_name')
    last_name = data.get('last_name')
    phone_number = data.get('phone_number')
    gdpr_consent_given = data.get('gdpr_consent_given')

    if not email or not password or not first_name or not last_name or not phone_number:
        return jsonify({
            'success': False,
            'message': 'All fields are required.'
        }), 400

    if gdpr_consent_given is not True:
        return jsonify({
            'success': False,
            'message': 'You must give GDPR consent to register.'
        }), 400

    con = get_db()
    cur = con.cursor()

    cur.execute("SELECT user_id FROM user WHERE email = %s", (email,))
    existing_user = cur.fetchone()

    if existing_user:
        cur.close()
        con.close()
        return jsonify({
            'success': False,
            'message': 'This email is already registered.'
        }), 409

    hashed_password = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())

    cur.execute("""
        INSERT INTO user 
            (email, password, first_name, last_name, phone_number, gdpr_consent_given)
        VALUES (%s, %s, %s, %s, %s, %s)
    """, (
        email,
        hashed_password.decode('utf-8'),
        first_name,
        last_name,
        phone_number,
        gdpr_consent_given
    ))

    con.commit()
    cur.close()
    con.close()

    return jsonify({
        'success': True,
        'message': 'User registered successfully.'
    })

@app.route('/api/login', methods=['POST'])
def login_user():
    data = request.get_json()

    email = data.get('email')
    password = data.get('password')

    con = get_db()
    cur = con.cursor()

    cur.execute("""
        SELECT user_id, email, password
        FROM user
        WHERE email = %s
    """, (email,))

    user = cur.fetchone()

    if not user:
        cur.close()
        con.close()
        return jsonify({'success': False, 'message': 'Invalid login details.'}), 401

    user_id = user['user_id']
    stored_password = user['password']

    if not bcrypt.checkpw(password.encode('utf-8'), stored_password.encode('utf-8')):
        cur.close()
        con.close()
        return jsonify({'success': False, 'message': 'Invalid login details.'}), 401

    token = str(random.randint(100000, 999999))
    expires_at = datetime.now() + timedelta(minutes=5)

    cur.execute("""
        INSERT INTO twofa_tokens (user_id, token, expires_at)
        VALUES (%s, %s, %s)
    """, (user_id, token, expires_at))

    con.commit()
    cur.close()
    con.close()

    send_2fa_email(email, token)

    return jsonify({
        'success': True,
        'step': '2FA',
        'userId': user_id,
        'message': '2FA code sent to your email.'
    })

@app.route('/api/verify-2fa', methods=['POST'])
@app.route('/api/verify-2fa', methods=['POST'])
def verify_2fa():
    data = request.get_json()
    user_id = data.get('userId')
    token = data.get('token')

    if not user_id or not token:
        return jsonify({'success': False, 'message': 'User ID and token are required.'}), 400

    con = get_db()
    cur = con.cursor()
    cur.execute("""
        SELECT token_id, expires_at FROM twofa_tokens
        WHERE user_id = %s AND token = %s AND used = FALSE
        ORDER BY token_id DESC LIMIT 1
    """, (user_id, token))
    record = cur.fetchone()

    if not record:
        cur.close()
        con.close()
        return jsonify({'success': False, 'message': 'Invalid 2FA code.'}), 401

    if datetime.now() > record['expires_at']:
        cur.close()
        con.close()
        return jsonify({'success': False, 'message': '2FA code has expired.'}), 401

    cur.execute("UPDATE twofa_tokens SET used = TRUE WHERE token_id = %s", (record['token_id'],))
    con.commit()

    ip_address = request.remote_addr
    cur.execute("""
        INSERT INTO Session (user_id, session_start_time, last_input_time, ip_address, is_active)
        VALUES (%s, %s, %s, %s, TRUE)
    """, (user_id, datetime.now(), datetime.now(), ip_address))
    con.commit()

    cur.execute("SELECT first_name FROM user WHERE user_id = %s", (user_id,))
    user = cur.fetchone()

    cur.execute("SELECT * FROM Admin WHERE user_id = %s", (user_id,))
    admin = cur.fetchone()
    role = 'admin' if admin else 'user'

    cur.close()
    con.close()

    return jsonify({
        'success': True,
        'message': 'Login successful.',
        'firstName': user['first_name'],
        'role': role
    })



@app.route('/api/logout', methods=['POST'])
def logout():
    data = request.get_json()
    user_id = data.get('userId')

    con = get_db()
    cur = con.cursor()
    cur.execute("""
        UPDATE Session SET is_active = FALSE
        WHERE user_id = %s AND is_active = TRUE
    """, (user_id,))
    con.commit()
    cur.close()
    con.close()

    return jsonify({'success': True})




@app.route('/admin')
def admin_page():
    return send_from_directory(CLIENT_FOLDER, 'admin.html')

@app.route('/api/admin/add-property', methods=['POST'])
def add_property():
    data = request.get_json()
    user_id = data.get('user_id')
    prop_type = data.get('type')

    con = get_db()
    cur = con.cursor()

    cur.execute("""
        INSERT INTO Property (user_id, name, location, description, image_url)
        VALUES (%s, %s, %s, %s, %s)
    """, (user_id, data['name'], data['location'], data['description'], data['image_url']))
    con.commit()

    property_id = cur.lastrowid

    if prop_type == 'residential':
        cur.execute("""
            INSERT INTO Residential (property_id, num_bedrooms, num_bathrooms, is_furnished, price)
            VALUES (%s, %s, %s, %s, %s)
        """, (property_id, data['num_bedrooms'], data['num_bathrooms'], data['is_furnished'], data['price']))

    elif prop_type == 'rental':
        cur.execute("""
            INSERT INTO Rental (property_id, num_bedrooms, num_bathrooms, monthly_rent, security_deposit, lease_duration, is_pet_friendly, lease_terms, is_furnished)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (property_id, data['num_bedrooms'], data['num_bathrooms'], data['monthly_rent'],
              data['security_deposit'], data['lease_duration'], data['is_pet_friendly'],
              data['lease_terms'], data['is_furnished']))

    elif prop_type == 'commercial':
        cur.execute("""
            INSERT INTO Commercial (property_id, square_ft, floors, property_usage, has_parking, zoning_type, price)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, (property_id, data['square_ft'], data['floors'], data['property_usage'],
              data['has_parking'], data['zoning_type'], data['price']))

    con.commit()
    cur.close()
    con.close()

    return jsonify({'success': True, 'message': 'Property added successfully!'})




@app.route('/api/favourites/toggle', methods=['POST'])
def toggle_favourite():
    data = request.get_json()
    user_id = data.get('user_id')
    property_id = data.get('property_id')

    if not user_id or not property_id:
        return jsonify({'success': False, 'message': 'Missing data.'}), 400

    con = get_db()
    cur = con.cursor()

    cur.execute("""
        SELECT favourite_id FROM Favourites 
        WHERE user_id = %s AND property_id = %s
    """, (user_id, property_id))
    existing = cur.fetchone()

    if existing:
        cur.execute("DELETE FROM Favourites WHERE user_id = %s AND property_id = %s", (user_id, property_id))
        con.commit()
        cur.close()
        con.close()
        return jsonify({'success': True, 'favourited': False})
    else:
        cur.execute("INSERT INTO Favourites (user_id, property_id) VALUES (%s, %s)", (user_id, property_id))
        con.commit()
        cur.close()
        con.close()
        return jsonify({'success': True, 'favourited': True})

@app.route('/api/favourites/<int:user_id>')
def get_favourites(user_id):
    con = get_db()
    cur = con.cursor()
    cur.execute("""
        SELECT p.property_id, p.name, p.location, p.description, p.image_url,
               COALESCE(r.price, re.monthly_rent, c.price) as price,
               CASE 
                   WHEN r.property_id IS NOT NULL THEN 'residential'
                   WHEN re.property_id IS NOT NULL THEN 'rental'
                   WHEN c.property_id IS NOT NULL THEN 'commercial'
               END as type
        FROM Favourites f
        JOIN Property p ON f.property_id = p.property_id
        LEFT JOIN Residential r ON p.property_id = r.property_id
        LEFT JOIN Rental re ON p.property_id = re.property_id
        LEFT JOIN Commercial c ON p.property_id = c.property_id
        WHERE f.user_id = %s
    """, (user_id,))
    rows = cur.fetchall()
    cur.close()
    con.close()
    return jsonify(rows)

@app.route('/favourites')
def favourites_page():
    return send_from_directory(CLIENT_FOLDER, 'favourites.html')

if __name__ == '__main__':
    app.run(debug=True)