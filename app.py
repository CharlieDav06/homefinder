import os
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










from flask import Flask, jsonify, send_from_directory, request  # add request

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












if __name__ == '__main__':
    app.run(debug=True)