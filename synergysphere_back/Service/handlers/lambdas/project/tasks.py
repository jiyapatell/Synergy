from pydantic import BaseModel

class TaskCreateRequest(BaseModel):
    title: str
    description: str
    creator: str
    end_date: str
    created_by: str

class TaskUpdateRequest(BaseModel):
    id: str
    title: str
    description: str
    status: str
    end_date: str
    update_by: str
