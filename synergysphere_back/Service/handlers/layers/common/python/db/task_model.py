from pynamodb.models import Model
from pynamodb.attributes import UnicodeAttribute

# PynamoDB model for Task
class TaskDynamoModel(Model):
    class Meta:
        table_name = "tasks-int-427547500501"
        region = "ap-south-1"
    id = UnicodeAttribute(hash_key=True)
    project_id = UnicodeAttribute()
    title = UnicodeAttribute()
    description = UnicodeAttribute()
    creator = UnicodeAttribute()
    status = UnicodeAttribute()
    end_date = UnicodeAttribute()
    update_by = UnicodeAttribute()
    updated_date = UnicodeAttribute()
    created_by = UnicodeAttribute()
    created_date = UnicodeAttribute()
