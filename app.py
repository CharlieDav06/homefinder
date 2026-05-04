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
    cur.close()
    return jsonify(rows)

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
               COALESCE(r.num_bedrooms, re.num_bedrooms) AS num_bedrooms, r.is_furnished,
               COALESCE(r.num_bathrooms, re.num_bathrooms) AS num_bathrooms, re.is_furnished, re.is_pet_friendly, re.lease_duration, re.security_deposit,
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

if __name__ == '__main__':
    app.run(debug=True)