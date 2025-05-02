import os
import requests
import json
from groq import Groq
from flask import Flask, request
from flask_cors import CORS
from firebase_admin import credentials, firestore, initialize_app
from pinecone import Pinecone
from sentence_transformers import SentenceTransformer


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

#Initialize the Pinecone Vector DB
pinecone_api_key = os.getenv("PINECONE_API_KEY")
pc = Pinecone(api_key=pinecone_api_key)
#index = pc.Index("reviews")

#Initialize Sentence Transformer
jina_api_key = os.getenv("JINA_API_KEY")

# Generate embeddings
user_query = "What is the best dorm at Santa Clara University?"

API_URL = "https://api.jina.ai/v1/embeddings"

headers = {
    "Content-Type": "application/json",
    "Authorization": f"Bearer {jina_api_key}"
}

data = {
    "model": "jina-clip-v2",  
    "dimensions" : 1024,
    "input": [user_query]
}

response = requests.post(API_URL, json=data, headers=headers)

# Print the embeddings
print(response.json())
query_embeddings = response.json()["data"][0]["embedding"]

context = ""

sys_prompt = f"""
Instructions:
- You are a helpful assistant trying to help a student find a dorm that suits them
Context: {context}
"""

# Initialize Groq
GROQ_API_KEY = os.getenv("GROQ_API_KEY")
client = Groq(api_key=GROQ_API_KEY)

# Generate response with Groq
response = client.chat.completions.create(
    model="llama-3.3-70b-versatile",
    messages=[
        {"role": "system", "content": sys_prompt},
        {"role": "user", "content": user_query},
    ]
)

# Print response
print(response.choices[0].message.content)