def get_db():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="homefinder123",
        database="home_finder_db"
    )