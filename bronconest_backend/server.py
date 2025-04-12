from flask import Flask, request
from flask_cors import CORS
from firebase_admin import credentials, firestore, initialize_app

app = Flask(__name__)
CORS(app)

cred = credentials.Certificate("serviceAccountKey.json")
default_app = initialize_app(cred)
db = firestore.client()


@app.route("/")
def hello_world():
    return {"message": "Hello, World!"}


@app.route("/get_schools")
def get_school():
    schools = db.collection("schools").get()
    return {"schools": [school.to_dict() for school in schools]}


@app.route("/get_all_dorms")
def get_all_dorms():
    dorms = {}
    for school in db.collection("schools").get():
        dorms[school.id] = [
            dorm.to_dict()
            for dorm in db.collection("schools")
            .document(school.id)
            .collection("dorms")
            .get()
        ]
    return dorms


@app.route("/get_dorms")
def get_dorms():
    school_id = request.args.get("school_id")
    dorms = db.collection("schools").document(school_id).collection("dorms").get()
    dorms = [dorm.to_dict() for dorm in dorms]
    return dorms


@app.route("/get_dorm")
def get_dorm():
    school_id = request.args.get("school_id")
    dorm_id = request.args.get("dorm_id")
    dorm = (
        db.collection("schools")
        .document(school_id)
        .collection("dorms")
        .document(dorm_id)
        .get()
        .to_dict()
    )
    return dorm


@app.route("/create_dorm", methods=["POST"])
def create_dorm():
    school_id = request.json["school_id"]
    dorm = request.json["dorm"]
    dorm_id = dorm["id"]
    dorm.pop("id")
    db.collection("schools").document(school_id).collection("dorms").document(
        dorm_id
    ).set(dorm)
    return {"message": "Dorm created successfully!"}


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=3000, debug=True)
