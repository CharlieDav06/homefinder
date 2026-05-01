import os
from flask import Flask, jsonify, send_from_directory
from flask_mysqldb import MySQL

app = Flask(__name__)

# MySQL config
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'homefinder123'
app.config['MYSQL_DB'] = 'home_finder_db'

mysql = MySQL(app)

CLIENT_FOLDER = os.path.join(os.path.dirname(__file__), 'client')

# Serve all client files (html, css, js, images)
@app.route('/client/<path:filename>')
def client_files(filename):
    return send_from_directory(CLIENT_FOLDER, filename)

# Serve booking page
@app.route('/booking')
def booking():
    return send_from_directory(CLIENT_FOLDER, 'booking.html')

# Get all properties
@app.route('/properties')
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

if __name__ == '__main__':
    app.run(debug=True)