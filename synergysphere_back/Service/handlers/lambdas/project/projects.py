from pydantic import BaseModel

class ProjectCreateRequest(BaseModel):
    title: str
    description: str
    created_by: str

class ProjectUpdateRequest(BaseModel):
    id: str
    title: str
    description: str
    updated_by: str

class ProjectListResponse(BaseModel):
    id: str
    title: str
    description: str


class ProjectIdResponse(BaseModel):
    id: str
    title: str
    description: str
    task: list[str]
    created_by: str
    created_date: str
    updated_by: str
    updated_date: str
