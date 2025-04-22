from flask import Flask, request, render_template
from flask_cors import CORS
from firebase_admin import credentials, firestore, initialize_app
import csv

app = Flask(__name__)
CORS(app)

cred = credentials.Certificate("serviceAccountKey.json")
default_app = initialize_app(cred)
db = firestore.client()
csv_file_path = "data.csv"
data = []


@app.route("/")
def index():
    with open(csv_file_path, "r", encoding="utf-8") as file:
        reader = csv.DictReader(file, quotechar='"')
        for row in reader:
            data.append(row)
    return render_template("index.html", data=data)

@app.route("/fill_firebase")
def fill_firebase():
    dorm_data = {}
    for line in data[1:]:
        dorm_data = {
            "user_id": "",
            "content": line["description"],
            "walkability": int(line["walkability"]),
            "cleanliness": int(line["cleanliness"]),
            "quietness": int(line["quietness"]),
            "comfort": int(line["comfort"]),
            "safety": int(line["safety"]),
            "amenities": int(line["amenities"]),
            "community": int(line["community"]),
        }
        dorm_query = db.collection("schools").document("scu").collection("dorms").where("name", "==", line["dorm"]).stream()
        dorm_doc = next(dorm_query, None)
        if dorm_doc:
          doc_ref = db.collection("schools").document("scu").collection("dorms").document(dorm_doc.id).collection("reviews").add(dorm_data)
        else:
          return {"error": "Dorm not found"}, 404
        dorm_data["id"] = doc_ref[1].id
        db.collection("schools").document("scu").collection("dorms").document(dorm_doc.id).collection("reviews").document(doc_ref[1].id).set(dorm_data)
    return {"message": "Data added successfully"}, 200

@app.route("/dorms")
def dorms():
    return render_template("dorms.html")

@app.route("/upload_dorm")
def create_dorm():
    school_id = request.args.get("school_id")
    dorm_id = request.args.get("dorm_id")
    dorm_data = request.json

if __name__ == "__main__":
    app.run(debug=True)