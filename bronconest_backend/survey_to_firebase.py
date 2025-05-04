from firebase_admin import credentials, firestore, initialize_app
import pandas as pd
from datetime import datetime

cred = credentials.Certificate("serviceAccountKey.json")
default_app = initialize_app(cred)
db = firestore.client()
xlsx_file_path = "data.xlsx"

def clear_current_reviews():
    dorms = db.collection("schools").document("scu").collection("dorms").stream()
    for dorm in dorms:
        reviews = db.collection("schools").document("scu").collection("dorms").document(dorm.id).collection("reviews").stream()
        for review in reviews:
            db.collection("schools").document("scu").collection("dorms").document(dorm.id).collection("reviews").document(review.id).delete()


def fill_firebase():
    df = pd.read_excel(xlsx_file_path)
    for _, line in df.iterrows(): 
        formatted_timestamp = line["timestamp"].strftime("%Y-%m-%dT%H:%M:%S.%f")        
        dorm_data = {
            "timestamp": formatted_timestamp,
            "user_id": "",
            "user_name": "",
            "is_anonymous": True,
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

# clear_current_reviews()
fill_firebase()

