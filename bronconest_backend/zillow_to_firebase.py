import json
from firebase_admin import credentials, firestore, initialize_app
from math import radians, cos, sin, sqrt, atan2

cred = credentials.Certificate("serviceAccountKey.json")
initialize_app(cred)
db = firestore.client()

def create_zillow_sorted():
    with open('zillow_sjsu.json', 'r') as infile:
        data = json.load(infile)
    
    sorted_data = []
    for property in data['props']:
        # Check if the property has multiple units
        if 'units' in property and isinstance(property['units'], list):
            for unit in property['units']:
                sorted_property = {
                    'address': property.get('address', None),
                    'price': unit.get('price', None),
                    'type': property.get('propertyType', 'Apartment'),
                    'bedrooms': int(unit.get('beds', None)),
                    'bathrooms': None,
                    'sqft': None,
                    'image': property.get('imgSrc', None),
                    'listing': "https://www.zillow.com" + property.get('detailUrl', None),
                    'lat': property.get('latitude', None),
                    'long': property.get('longitude', None),
                }
                sorted_data.append(sorted_property)
        else:
            # Handle single-unit properties
            property_type = property.get('propertyType', None)
            if property_type == "SINGLE_FAMILY":
                property_type = "House"
            elif property_type == "TOWNHOUSE":
                property_type = "Townhouse"
            elif property_type == "APARTMENT":
                property_type = "Apartment"

            sorted_property = {
                'address': property.get('address', None),
                'price': str(property.get('price', None)),
                'type': property_type,
                'bedrooms': property.get('bedrooms', None),
                'bathrooms': property.get('bathrooms', None),
                'sqft': property.get('livingArea', None),
                'image': property.get('imgSrc', None),
                'listing': "https://www.zillow.com" + property.get('detailUrl', None),
                'lat': property.get('latitude', None),
                'long': property.get('longitude', None),
            }
            sorted_data.append(sorted_property)

    with open('zillow_sorted.json', 'w') as outfile:
        json.dump(sorted_data, outfile, indent=2)

def zillow_to_firebase():
    with open('zillow_sorted.json', 'r') as infile:
        data = json.load(infile)

    school_ref = db.collection("schools").document("sjsu")
    school_data = school_ref.get().to_dict()
    school_lat = school_data.get('lat')
    school_long = school_data.get('long')

    for property in data:
        distanceFromSchool = calculate_distance_from_school(property.get('lat', None), property.get('long', None), school_lat, school_long)
        house_data = {
            'address': property.get('address', None),
            'price': property.get('price', None),
            'type': property.get('type', None),
            'bedrooms': property.get('bedrooms', None),
            'bathrooms': property.get('bathrooms', None),
            'sqft': property.get('sqft', None),
            'image': property.get('image', None),
            'listing': property.get('listing', None),
            'distance_from_school': distanceFromSchool,
        }
        doc_ref = db.collection("schools").document("sjsu").collection("houses").add(house_data)
        house_data["id"] = doc_ref[1].id
        db.collection("schools").document("sjsu").collection("houses").document(doc_ref[1].id).set(house_data)

        print(f"Added property {property.get('address', None)} to Firestore with ID: {doc_ref[1].id}")

def calculate_distance_from_school(lat, long, school_lat, school_long):
    if lat is None or long is None:
        return None

    # Convert latitude and longitude from degrees to radians
    lat1, lon1 = radians(school_lat), radians(school_long)
    lat2, lon2 = radians(lat), radians(long)

    # Haversine formula to calculate the distance
    dlat = lat2 - lat1
    dlon = lon2 - lon1
    a = sin(dlat / 2)**2 + cos(lat1) * cos(lat2) * sin(dlon / 2)**2
    c = 2 * atan2(sqrt(a), sqrt(1 - a))
    radius_of_earth_km = 3963  # Earth's radius in miles
    distance = radius_of_earth_km * c

    return distance

if __name__ == "__main__":
    create_zillow_sorted()
    zillow_to_firebase()