from flask import Flask, render_template, jsonify
import os
import yaml

app = Flask(__name__)

ARCHIVE_DIR = "/opt/yaml_archives/"

@app.route("/")
def index():
    files = os.listdir(ARCHIVE_DIR)
    return render_template("index.html", files=files)

@app.route("/archive/<filename>")
def view_archive(filename):
    file_path = os.path.join(ARCHIVE_DIR, filename)
    with open(file_path, "r", encoding="utf-8") as f:
        data = yaml.safe_load(f)
    return jsonify(data)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)

