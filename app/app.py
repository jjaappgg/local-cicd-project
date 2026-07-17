from flask import Flask, jsonify

app = Flask(__name__)


@app.get("/")
def home():
    return """
    <!doctype html>
    <html lang="en">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Local CI/CD Project</title>
        <style>
          body { font-family: Arial, sans-serif; max-width: 760px; margin: 80px auto; padding: 0 20px; }
          .card { border: 1px solid #ddd; border-radius: 12px; padding: 32px; box-shadow: 0 4px 16px rgba(0,0,0,.08); }
          h1 { margin-top: 0; }
          code { background: #f4f4f4; padding: 2px 6px; border-radius: 4px; }
        </style>
      </head>
      <body>
        <div class="card">
          <h1>Deployment successful!</h1>
          <p>This Flask application was built by <strong>Jenkins</strong>, deployed by <strong>Terraform</strong>, and is running in <strong>Docker</strong>.</p>
          <p>Health endpoint: <code>/health</code></p>
        </div>
      </body>
    </html>
    """


@app.get("/health")
def health():
    return jsonify(status="ok"), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
