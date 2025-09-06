"""
Lambda for uploading files to s3
"""

from typing import Any
from response.response_handler import generate_response
from project_manager import ProjectManager
from task_manager import TaskManager

project_manager = ProjectManager()
task_manager = TaskManager()

@generate_response
def lambda_handler(event: dict[str, Any], _) -> dict[str, Any]:
    """
    Lambda handler function to upload files to s3
    Args:
        event (dict): Event data
    Returns:
        dict: Response
    """
    
    queryparam = event["params"]["querystring"]
    body = event["body"]
    method_type = event["context"]["http-method"]

    if method_type == "GET":
        action = queryparam.get("action")
        if action == "project":
            sub_action = queryparam.get("sub_action")
            if sub_action == "all":
                response = project_manager.get_all_projects()
            else:
                response = project_manager.get_project_by_id(body)
        else:
            response = task_manager.get_task_details()

    elif method_type == "POST":
        action = queryparam.get("action")
        if action == "project":
            response = project_manager.create_project(body)
        else:
            response = task_manager.create_task(body)
    
    elif method_type == "PUT":
        action = queryparam.get("action")
        if action == "project":
            response = project_manager.update_project(body)
        else:
            response = task_manager.update_task(body)
    
    else: # DELETE
        action = queryparam.get("action")
        if action == "project":
            response =  project_manager.delete_project(body)
        else:
            response = task_manager.delete_task(body)
    
    return response
