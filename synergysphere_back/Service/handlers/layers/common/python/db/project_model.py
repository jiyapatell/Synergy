from pynamodb.models import Model
from pynamodb.attributes import UnicodeAttribute

# PynamoDB model for Project
class ProjectDynamoModel(Model):
    class Meta:
        table_name = "projects-int-427547500501"
        region = "ap-south-1"
    id = UnicodeAttribute(hash_key=True)
    title = UnicodeAttribute()
    description = UnicodeAttribute()
    created_by = UnicodeAttribute()
    created_date = UnicodeAttribute()
    updated_by = UnicodeAttribute()
    updated_date = UnicodeAttribute()
