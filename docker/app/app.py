"""
Harrington Capital plc -- Infrastructure Operations Portal
Phase 4: Docker multi-container deployment
"""
from flask import Flask, jsonify
import os
import psycopg2

app = Flask(__name__)


def get_db_connection():
    return psycopg2.connect(
        host=os.environ.get("DB_HOST", "db"),
        port=int(os.environ.get("DB_PORT", 5432)),
        database=os.environ.get("DB_NAME", "harrington_ops"),
        user=os.environ.get("DB_USER", "hcapp"),
        password=os.environ.get("DB_PASSWORD", "HC@AppDB2026!")
    )


@app.route("/")
def index():
    return """
    <html>
    <head><title>Harrington Capital -- Ops Portal</title></head>
    <body style="font-family:sans-serif;padding:40px;background:#0f2d5c;color:white;">
        <h1 style="color:#00b4d8;">Harrington Capital plc</h1>
        <h2>Infrastructure Operations Portal</h2>
        <p>Environment: <strong>Production</strong></p>
        <p>Status: <strong style="color:#4ade80;">Running</strong></p>
        <hr style="border-color:#00b4d8;">
        <ul>
            <li><a href="/health" style="color:#00b4d8;">/health</a> -- Application health check</li>
            <li><a href="/db-check" style="color:#00b4d8;">/db-check</a> -- Database connectivity</li>
            <li><a href="/info" style="color:#00b4d8;">/info</a> -- Environment info</li>
        </ul>
    </body>
    </html>
    """


@app.route("/health")
def health():
    return jsonify({
        "status": "healthy",
        "service": "hc-app",
        "environment": os.environ.get("FLASK_ENV", "production"),
        "version": "1.0.0"
    })


@app.route("/db-check")
def db_check():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(*) FROM infrastructure_log;")
        count = cursor.fetchone()[0]
        cursor.close()
        conn.close()
        return jsonify({
            "status": "ok",
            "database": "connected",
            "host": os.environ.get("DB_HOST", "db"),
            "log_entries": count
        })
    except Exception as e:
        return jsonify({
            "status": "error",
            "database": "disconnected",
            "detail": str(e)
        }), 500


@app.route("/info")
def info():
    return jsonify({
        "app": "hc-app",
        "db_host": os.environ.get("DB_HOST", "db"),
        "flask_env": os.environ.get("FLASK_ENV", "production"),
        "container": os.environ.get("HOSTNAME", "unknown")
    })


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)
