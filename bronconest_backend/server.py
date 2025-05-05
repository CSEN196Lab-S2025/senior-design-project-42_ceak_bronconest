import os
import requests
import json
import re
from groq import Groq
from flask import Flask, request
from flask_cors import CORS
from firebase_admin import credentials, firestore, initialize_app
from pinecone import Pinecone
from dotenv import load_dotenv



app = Flask(__name__)
CORS(app)
cred = credentials.Certificate("serviceAccountKey.json")
default_app = initialize_app(cred)
db = firestore.client()

load_dotenv()

#API Keys
GROQ_API_KEY = os.getenv("GROQ_API_KEY")
PINECONE_API_KEY = os.getenv("PINECONE_API_KEY")
JINA_API_KEY = os.getenv("JINA_API_KEY")


@app.route("/")
def hello_world():
    return {"message": "Hello, World!"}

#Initialize the Pinecone Vector DB
pc = Pinecone(api_key=PINECONE_API_KEY)
index = pc.Index("dormreviews")

#Initialize Groq
client = Groq(api_key=GROQ_API_KEY)

#Initialize Sentence Transformer (JINA)
API_URL = "https://api.jina.ai/v1/embeddings"
headers = {
    "Content-Type": "application/json",
    "Authorization": f"Bearer {JINA_API_KEY}"
}


#Json helper function to format LLM response
def extract_json(text):
    # Strip markdown code blocks if present
    text = re.sub(r"^```(?:json)?|```$", "", text.strip(), flags=re.MULTILINE)

    # Attempt to find the first valid JSON object
    json_match = re.search(r"\{[\s\S]*\}", text)

    if json_match:
        json_str = json_match.group()
        try:
            return json.loads(json_str)
        except json.JSONDecodeError as e:
            print("JSON decode failed:", e)
            return {"error": "Malformed JSON", "raw": json_str}

    return {"error": "No JSON found", "raw": text}



#Vectorize and index SCU dorms
def index_scu_dorms(school="scu"):
    dorms = db.collection("schools").document(school).collection("dorms").get()
    for dorm_doc in dorms:
        dorm = dorm_doc.to_dict()
        dorm_id = dorm_doc.id

        #Score summary to embed
        score_text = (
            f"Amenities: {dorm.get('amenities_avg', 0)}, "
            f"Cleanliness: {dorm.get('cleanliness_avg', 0)}, "
            f"Comfort: {dorm.get('comfort_avg', 0)}, "
            f"Community: {dorm.get('community_avg', 0)}, "
            f"Quietness: {dorm.get('quietness_avg', 0)}, "
            f"Safety: {dorm.get('safety_avg', 0)}, "
            f"Walkability: {dorm.get('walkability_avg', 0)}"
        )

        data = {
            "model": "jina-clip-v2",
            "dimensions": 1024,
            "input": [score_text]
        }
        res = requests.post(API_URL, json=data, headers=headers)
        embedding = res.json()["data"][0]["embedding"]

        index.upsert([
            {
                "id": dorm_id,
                "values": embedding,
                "metadata": {
                    "name": dorm.get("name", ""),
                    "score_summary": score_text
                }
            }
        ])


#Rank SCU dorms based on user query
def rank_scu_dorms(user_query, school, max_retries=2):
    # Embed the user query
    query_data = {
        "model": "jina-clip-v2",
        "dimensions": 1024,
        "input": [user_query]
    }
    response = requests.post(API_URL, json=query_data, headers=headers)
    query_embedding = response.json()["data"][0]["embedding"]

    # Query Pinecone
    results = index.query(
        vector=query_embedding,
        top_k=12,
        include_metadata=True
    )



    # Create context for LLM
    context_entries = []
    valid_ids = []
    for match in results.get("matches", []):
        meta = match["metadata"]
        dorm_id = match["id"]
        valid_ids.append(dorm_id)
        context_entries.append(json.dumps({
            "id": dorm_id,
            "name": meta.get("name", ""),
            "scores": meta.get("score_summary", "")
        }))

    context = "[\n" + ",\n".join(context_entries) + "\n]"

    print("==== CONTEXT SENT TO LLM ====")
    print(context)

    sys_prompt = f"""
You are an assistant ranking Santa Clara University dorms.
Given the dorms and their summaries below, return their IDs sorted from best to worst according to the user's query.

Context:
{context}

ONLY return a single line of raw JSON — no markdown, no explanation, no commentary.
Format:
{{ "sorted_ids": ["id1", "id2", ...] }}

Use the exact Firebase dorm IDs provided. Do not invent or rename them.
"""

    # Retry loop in case of malformed JSON
    for attempt in range(max_retries):
        chat_response = client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[
                {"role": "system", "content": sys_prompt},
                {"role": "user", "content": user_query}
            ],
            tools=[
                {
                    "type": "function",
                    "function": {
                        "name": "rank_dorms",
                        "description": "Sort dorm IDs from best to worst based on the user's query.",
                        "parameters": {
                            "type": "object",
                            "properties": {
                                "sorted_ids": {
                                    "type": "array",
                                    "items": {"type": "string"},
                                    "description": "Dorm IDs sorted from best to worst"
                                }
                            },
                            "required": ["sorted_ids"]
                        }
                    }
                }
            ],
            tool_choice={"type": "function", "function": {"name": "rank_dorms"}}
        )

        tool_args = json.loads(chat_response.choices[0].message.tool_calls[0].function.arguments)
        sorted_ids = tool_args.get("sorted_ids", [])
        filtered = [id for id in sorted_ids if id in valid_ids]
        return {"sorted_ids": filtered}



        response_content = chat_response.choices[0].message.content.strip()
        print("LLM RAW RESPONSE:\n", response_content)

        response_json = extract_json(response_content)

        # Validate returned IDs are all in our known Pinecone match results
        if "sorted_ids" in response_json:
            sorted_ids = response_json["sorted_ids"]
            filtered = [id for id in sorted_ids if id in valid_ids]
            return {"sorted_ids": filtered}

        print(f"[Retry {attempt+1}] Invalid JSON or IDs. Retrying...")

    # Return last raw response after all retries fail
    return {"error": "Failed to get valid sorted_ids"}






@app.route("/rank_dorms", methods=["GET"])
def rank_dorms_route():
    query = request.args.get("query")
    school = request.args.get("school")
    result = rank_scu_dorms(query, school)
    return result


if __name__ == "__main__":
    index_scu_dorms()
    app.run(host="0.0.0.0", port=3000, debug=True)