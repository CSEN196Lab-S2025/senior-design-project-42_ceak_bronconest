import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firebase Admin SDK
cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)

# Firestore database reference
db = firestore.client()

def calculate_and_update_dorm_averages():
    try:
        # Reference to the dorms collection
        dorms_ref = db.collection('schools').document('scu').collection('dorms')
        dorms = dorms_ref.stream()

        for dorm in dorms:
            dorm_data = dorm.to_dict()
            dorm_id = dorm.id

            # Reference to the reviews subcollection for the current dorm
            reviews_ref = dorms_ref.document(dorm_id).collection('reviews')
            reviews = reviews_ref.stream()

            # Initialize accumulators and counters
            walkability_total = 0
            cleanliness_total = 0
            quietness_total = 0
            comfort_total = 0
            safety_total = 0
            amenities_total = 0
            community_total = 0
            review_count = 0

            for review in reviews:
                review_data = review.to_dict()
                walkability_total += review_data.get('walkability', 0)
                cleanliness_total += review_data.get('cleanliness', 0)
                quietness_total += review_data.get('quietness', 0)
                comfort_total += review_data.get('comfort', 0)
                safety_total += review_data.get('safety', 0)
                amenities_total += review_data.get('amenities', 0)
                community_total += review_data.get('community', 0)
                review_count += 1

            if review_count > 0:
                # Calculate averages
                walkability_avg = walkability_total / review_count
                cleanliness_avg = cleanliness_total / review_count
                quietness_avg = quietness_total / review_count
                comfort_avg = comfort_total / review_count
                safety_avg = safety_total / review_count
                amenities_avg = amenities_total / review_count
                community_avg = community_total / review_count

                # Update the dorm document with the calculated averages
                dorms_ref.document(dorm_id).update({
                    'walkability_avg': walkability_avg,
                    'cleanliness_avg': cleanliness_avg,
                    'quietness_avg': quietness_avg,
                    'comfort_avg': comfort_avg,
                    'safety_avg': safety_avg,
                    'amenities_avg': amenities_avg,
                    'community_avg': community_avg,
                })

                print(f"Updated averages for dorm {dorm_id}")
            else:
                print(f"No reviews found for dorm {dorm_id}")

    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    calculate_and_update_dorm_averages()