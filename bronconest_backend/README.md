# BroncoNest Backend

## Endpoints

### GET /
- Arguments: None
- Returns a welcome message

### GET /get_schools
- Arguments: None
- Returns a list of all schools

### GET /get_all_dorms
- Arguments: None
- Returns a list of all dorms for all schools

### GET /get_dorms
- Arguments: school_id
- Returns a list of all dorms for a specific school

### GET /get_dorm
- Arguments: school_id, dorm_id
- Returns a specific dorm for a specific school

### POST /add_dorm
- Arguments: school_id, dorm.json
- JSON Example:
```json
{
    "id": "Dorm ID",
    "name": "Dorm Name",
}
```
- Adds a dorm to a specific school
