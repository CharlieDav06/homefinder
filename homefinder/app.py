"""
HomeFinder Portal — Flask Application
Run: python app.py
Visit: http://localhost:5000/properties
"""
from flask import (
    Flask, render_template, request, redirect, url_for,
    session, flash, jsonify, g
)
import mysql.connector
from mysql.connector import Error
from functools import wraps
import hashlib, os, math

app = Flask(__name__)
app.secret_key = os.environ.get("SECRET_KEY", "homefinder-dev-secret-change-in-prod")

# ──────────────────────────────────────────────────────────────────────
# DB CONFIG — edit these to match your MySQL setup
# ──────────────────────────────────────────────────────────────────────
DB_CONFIG = {
    "host":     os.environ.get("DB_HOST",     "localhost"),
    "user":     os.environ.get("DB_USER",     "root"),
    "password": os.environ.get("DB_PASSWORD", ""),
    "database": os.environ.get("DB_NAME",     "homefinder"),
    "charset":  "utf8mb4",
}

# ──────────────────────────────────────────────────────────────────────
# DB helpers
# ──────────────────────────────────────────────────────────────────────
def get_db():
    if "db" not in g:
        g.db = mysql.connector.connect(**DB_CONFIG)
    return g.db

@app.teardown_appcontext
def close_db(exc=None):
    db = g.pop("db", None)
    if db and db.is_connected():
        db.close()

def query(sql, params=(), one=False, commit=False):
    db  = get_db()
    cur = db.cursor(dictionary=True)
    cur.execute(sql, params)
    if commit:
        db.commit()
        return cur.lastrowid
    result = cur.fetchone() if one else cur.fetchall()
    cur.close()
    return result

# ──────────────────────────────────────────────────────────────────────
# Auth helpers
# ──────────────────────────────────────────────────────────────────────
def hash_password(password):
    return hashlib.sha256(password.encode()).hexdigest()

def login_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        if "user_id" not in session:
            flash("Please log in to access that page.", "warning")
            return redirect(url_for("login", next=request.url))
        return f(*args, **kwargs)
    return decorated

def current_user():
    if "user_id" in session:
        return query("SELECT * FROM users WHERE id=%s", (session["user_id"],), one=True)
    return None

# ──────────────────────────────────────────────────────────────────────
# Favourites helpers  (session-based so guests can also use them)
# ──────────────────────────────────────────────────────────────────────
def get_session_favs():
    return set(session.get("favourites", []))

def set_session_favs(favs):
    session["favourites"] = list(favs)
    session.modified = True

def get_all_favs():
    """Return set of property IDs in favourites (db or session)."""
    if "user_id" in session:
        rows = query("SELECT property_id FROM favourites WHERE user_id=%s", (session["user_id"],))
        return {r["property_id"] for r in rows}
    return get_session_favs()

def toggle_fav(property_id):
    property_id = int(property_id)
    if "user_id" in session:
        existing = query(
            "SELECT id FROM favourites WHERE user_id=%s AND property_id=%s",
            (session["user_id"], property_id), one=True
        )
        if existing:
            query("DELETE FROM favourites WHERE user_id=%s AND property_id=%s",
                  (session["user_id"], property_id), commit=True)
            return False
        else:
            query("INSERT INTO favourites (user_id, property_id) VALUES (%s,%s)",
                  (session["user_id"], property_id), commit=True)
            return True
    else:
        favs = get_session_favs()
        if property_id in favs:
            favs.discard(property_id)
            set_session_favs(favs)
            return False
        else:
            favs.add(property_id)
            set_session_favs(favs)
            return True

# ──────────────────────────────────────────────────────────────────────
# Template context
# ──────────────────────────────────────────────────────────────────────
@app.context_processor
def inject_globals():
    return {
        "current_user": current_user(),
        "fav_ids":      get_all_favs(),
        "fav_count":    len(get_all_favs()),
    }

# ──────────────────────────────────────────────────────────────────────
# ROUTES
# ──────────────────────────────────────────────────────────────────────

@app.route("/")
def index():
    featured = query(
        """SELECT * FROM properties
           WHERE status='available'
           ORDER BY RAND() LIMIT 6"""
    )
    stats = query(
        """SELECT
             COUNT(*) as total,
             SUM(listing_type='sale') as for_sale,
             SUM(listing_type='rent') as to_rent,
             COUNT(DISTINCT city)    as cities
           FROM properties WHERE status IN ('available','under_offer')""",
        one=True
    )
    return render_template("index.html", featured=featured, stats=stats)


@app.route("/properties")
def properties():
    # ── Filters ──
    listing_type = request.args.get("type",    "")
    prop_type    = request.args.get("prop",    "")
    city         = request.args.get("city",    "")
    min_price    = request.args.get("min",     "")
    max_price    = request.args.get("max",     "")
    beds         = request.args.get("beds",    "")
    sort         = request.args.get("sort",    "newest")
    page         = max(1, int(request.args.get("page", 1)))
    per_page     = 9

    sql    = "SELECT * FROM properties WHERE status IN ('available','under_offer')"
    params = []

    if listing_type:
        sql += " AND listing_type=%s";  params.append(listing_type)
    if prop_type:
        sql += " AND property_type=%s"; params.append(prop_type)
    if city:
        sql += " AND city=%s";          params.append(city)
    if beds:
        sql += " AND bedrooms>=%s";     params.append(int(beds))
    if min_price:
        sql += " AND price>=%s";        params.append(float(min_price))
    if max_price:
        sql += " AND price<=%s";        params.append(float(max_price))

    sort_map = {
        "newest":      "created_at DESC",
        "price_asc":   "price ASC",
        "price_desc":  "price DESC",
        "beds_desc":   "bedrooms DESC",
    }
    sql += f" ORDER BY {sort_map.get(sort, 'created_at DESC')}"

    # count total for pagination
    count_sql = sql.replace("SELECT *", "SELECT COUNT(*) as n", 1)
    count_sql = count_sql.split("ORDER BY")[0]
    total     = query(count_sql, params, one=True)["n"]
    pages     = math.ceil(total / per_page)

    sql      += f" LIMIT {per_page} OFFSET {(page-1)*per_page}"
    props     = query(sql, params)

    cities   = [r["city"] for r in query("SELECT DISTINCT city FROM properties ORDER BY city")]

    return render_template(
        "properties.html",
        properties=props,
        cities=cities,
        total=total,
        page=page,
        pages=pages,
        filters=request.args,
    )


@app.route("/property/<int:pid>")
def property_detail(pid):
    prop    = query("SELECT p.*, a.name as agent_name, a.email as agent_email, a.phone as agent_phone, a.photo_url as agent_photo FROM properties p LEFT JOIN agents a ON p.agent_id=a.id WHERE p.id=%s", (pid,), one=True)
    if not prop:
        flash("Property not found.", "danger")
        return redirect(url_for("properties"))

    images   = query("SELECT * FROM property_images WHERE property_id=%s ORDER BY display_order", (pid,))
    features = query("SELECT feature FROM property_features WHERE property_id=%s", (pid,))
    similar  = query(
        """SELECT * FROM properties
           WHERE id != %s AND city=%s AND status='available'
           ORDER BY ABS(price - %s) LIMIT 3""",
        (pid, prop["city"], prop["price"])
    )
    is_fav   = pid in get_all_favs()
    return render_template("property_detail.html",
                           prop=prop, images=images,
                           features=features, similar=similar, is_fav=is_fav)


@app.route("/favourites")
def favourites():
    fav_ids = get_all_favs()
    props = []
    if fav_ids:
        placeholders = ",".join(["%s"] * len(fav_ids))
        props = query(f"SELECT * FROM properties WHERE id IN ({placeholders})", tuple(fav_ids))
    return render_template("favourites.html", properties=props)


@app.route("/api/favourite/<int:pid>", methods=["POST"])
def api_toggle_fav(pid):
    added = toggle_fav(pid)
    return jsonify({"added": added, "count": len(get_all_favs())})


@app.route("/enquire/<int:pid>", methods=["POST"])
def enquire(pid):
    name    = request.form.get("name", "").strip()
    email   = request.form.get("email", "").strip()
    phone   = request.form.get("phone", "").strip()
    message = request.form.get("message", "").strip()
    etype   = request.form.get("enquiry_type", "general")

    if not name or not email or not message:
        flash("Please fill in all required fields.", "danger")
        return redirect(url_for("property_detail", pid=pid))

    uid = session.get("user_id")
    query(
        "INSERT INTO enquiries (property_id, user_id, name, email, phone, message, enquiry_type) VALUES (%s,%s,%s,%s,%s,%s,%s)",
        (pid, uid, name, email, phone, message, etype), commit=True
    )
    flash("Your enquiry has been sent! We'll be in touch shortly.", "success")
    return redirect(url_for("property_detail", pid=pid))


@app.route("/offer/<int:pid>", methods=["POST"])
@login_required
def make_offer(pid):
    amount = request.form.get("amount", "").strip().replace(",", "")
    msg    = request.form.get("message", "").strip()
    try:
        amount = float(amount)
    except ValueError:
        flash("Please enter a valid offer amount.", "danger")
        return redirect(url_for("property_detail", pid=pid))

    query(
        "INSERT INTO offers (property_id, user_id, offer_amount, message) VALUES (%s,%s,%s,%s)",
        (pid, session["user_id"], amount, msg), commit=True
    )
    flash("Your offer has been submitted! The agent will review it shortly.", "success")
    return redirect(url_for("property_detail", pid=pid))


# ──────────────────────────────────────────────────────────────────────
# Auth routes
# ──────────────────────────────────────────────────────────────────────

@app.route("/register", methods=["GET", "POST"])
def register():
    if request.method == "POST":
        first = request.form.get("first_name", "").strip()
        last  = request.form.get("last_name",  "").strip()
        email = request.form.get("email",      "").strip().lower()
        phone = request.form.get("phone",      "").strip()
        pw    = request.form.get("password",   "")

        if not first or not last or not email or not pw:
            flash("Please complete all required fields.", "danger")
            return render_template("register.html")

        existing = query("SELECT id FROM users WHERE email=%s", (email,), one=True)
        if existing:
            flash("An account with that email already exists.", "warning")
            return render_template("register.html")

        uid = query(
            "INSERT INTO users (first_name, last_name, email, phone, password_hash) VALUES (%s,%s,%s,%s,%s)",
            (first, last, email, phone, hash_password(pw)), commit=True
        )
        # merge session favourites into db
        for fav_id in get_session_favs():
            try:
                query("INSERT IGNORE INTO favourites (user_id, property_id) VALUES (%s,%s)", (uid, fav_id), commit=True)
            except Exception:
                pass
        set_session_favs(set())
        session["user_id"] = uid
        flash(f"Welcome, {first}! Your account has been created.", "success")
        return redirect(url_for("index"))
    return render_template("register.html")


@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        email = request.form.get("email", "").strip().lower()
        pw    = request.form.get("password", "")
        user  = query("SELECT * FROM users WHERE email=%s", (email,), one=True)

        # Note: in production use werkzeug.security.check_password_hash
        if user and user["password_hash"] == hash_password(pw):
            # merge any session favs
            for fav_id in get_session_favs():
                try:
                    query("INSERT IGNORE INTO favourites (user_id, property_id) VALUES (%s,%s)",
                          (user["id"], fav_id), commit=True)
                except Exception:
                    pass
            set_session_favs(set())
            session["user_id"] = user["id"]
            flash(f"Welcome back, {user['first_name']}!", "success")
            return redirect(request.args.get("next") or url_for("index"))
        flash("Invalid email or password.", "danger")
    return render_template("login.html")


@app.route("/logout")
def logout():
    session.clear()
    flash("You have been logged out.", "info")
    return redirect(url_for("index"))


@app.route("/account")
@login_required
def account():
    user    = current_user()
    favs    = []
    fav_ids = get_all_favs()
    if fav_ids:
        ph   = ",".join(["%s"] * len(fav_ids))
        favs = query(f"SELECT * FROM properties WHERE id IN ({ph})", tuple(fav_ids))
    enquiries = query(
        "SELECT e.*, p.title as prop_title FROM enquiries e JOIN properties p ON e.property_id=p.id WHERE e.user_id=%s ORDER BY e.created_at DESC",
        (session["user_id"],)
    )
    offers = query(
        "SELECT o.*, p.title as prop_title, p.price as asking_price FROM offers o JOIN properties p ON o.property_id=p.id WHERE o.user_id=%s ORDER BY o.created_at DESC",
        (session["user_id"],)
    )
    return render_template("account.html", user=user, favs=favs, enquiries=enquiries, offers=offers)


# ──────────────────────────────────────────────────────────────────────
# Template filters
# ──────────────────────────────────────────────────────────────────────
@app.template_filter("currency")
def currency_filter(value):
    try:
        return f"£{float(value):,.0f}"
    except Exception:
        return value

@app.template_filter("monthly")
def monthly_filter(value):
    try:
        return f"£{float(value):,.0f} pcm"
    except Exception:
        return value


if __name__ == "__main__":
    print("=" * 50)
    print("  HomeFinder Portal")
    print("  http://localhost:5000")
    print("  http://localhost:5000/properties")
    print("=" * 50)
    app.run(debug=True, port=5000)
