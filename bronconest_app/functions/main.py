from firebase_functions import https_fn, options
from firebase_functions.firestore_fn import on_document_written, Event, Change, DocumentSnapshot
from firebase_admin import initialize_app
import os
import requests
import json
import re
from pinecone import Pinecone
from groq import Groq
from dotenv import load_dotenv

# Initialize Firebase Admin
initialize_app()

load_dotenv()

# API Keys
GROQ_API_KEY = os.environ.get("GROQ_API_KEY")
PINECONE_API_KEY = os.environ.get("PINECONE_API_KEY")
JINA_API_KEY = os.environ.get("JINA_API_KEY")

# Initialize the Pinecone Vector DB
pc = Pinecone(api_key=PINECONE_API_KEY)
index = pc.Index("scu")

# Initialize Groq
client = Groq(api_key=GROQ_API_KEY)

# Initialize Sentence Transformer (JINA)
API_URL = "https://api.jina.ai/v1/embeddings"
headers = {
    "Content-Type": "application/json",
    "Authorization": f"Bearer {JINA_API_KEY}"
}

# Json helper function to format LLM response
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

# Helper function to upsert dorm data to Pinecone
def upsert_dorm_to_index(dorm_id, dorm, school):
    index = pc.Index(school)

    # Score summary to embed
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

    print(f"Upserted dorm {dorm_id} to Pinecone index.")

# Firestore trigger to update Pinecone index when a dorm is added, updated, or deleted
@on_document_written(document="schools/{school}/dorms/{dorm_id}")
def index_dorms(event: Event[Change[DocumentSnapshot | None]]) -> None:
    # Document snapshot
    old_data = event.data.before.to_dict() if event.data.before else None 
    new_data = event.data.after.to_dict() if event.data.after else None

    dorm_id = event.params["dorm_id"]

    # Check if the dorm was deleted
    if not new_data:
        print(f"Dorm {dorm_id} deleted. Removing from index.")
        index.delete([dorm_id])
        return
    
    # Check if the dorm was created or updated
    if not old_data:
        print(f"Dorm {dorm_id} created. Adding to index.")
        dorm = new_data.to_dict()
        upsert_dorm_to_index(dorm_id, dorm)
        return

    relevant_fields = [
        "amenities_avg", "cleanliness_avg", "comfort_avg",
        "community_avg", "quietness_avg", "safety_avg", "walkability_avg"
    ]

    if any(old_data.get(field) != new_data.get(field) for field in relevant_fields):
        print(f"Dorm {dorm_id} updated. Updating index.")
        upsert_dorm_to_index(dorm_id, new_data, event.params["school"])
    else:
        print(f"Dorm {dorm_id} updated but no relevant fields changed. No action taken.")


#Rank dorms based on user query
def rank_dorms_helper(user_query, school, max_retries=2):
    index = pc.Index(school)
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

    # Ctreate context for the LLM
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

    return {"error": "Failed to get valid sorted_ids"}

# Firebase Function to rank dorms
@https_fn.on_request(cors=options.CorsOptions(cors_origins="*", cors_methods=["get"]))
def rank_dorms(req: https_fn.Request) -> https_fn.Response:
    print(req.args["query"])
    query = req.args["query"]
    school = req.args["school"]
    if not query or not school:
        return https_fn.Response(
            json.dumps({"error": "Missing 'query' or 'school' parameter"}),
            status=400,
            mimetype="application/json"
        )

    result = rank_dorms_helper(query, school)
    return https_fn.Response(
        json.dumps(result),
        status=200,
        mimetype="application/json"
    )