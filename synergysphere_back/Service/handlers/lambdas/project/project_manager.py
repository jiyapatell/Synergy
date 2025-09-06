from aws_lambda_powertools import Logger
from exceptions.exceptions import ProjectException
from db.generic_repository import GenericRepository
from projects import ProjectListResponse, ProjectCreateRequest, ProjectUpdateRequest
from utils.utils import Utils
from db.project_model import ProjectDynamoModel
from db.task_model import TaskDynamoModel

import uuid
from http import HTTPStatus

logger = Logger(service="project_manager")
project_db = GenericRepository(ProjectDynamoModel)
tasks_db = GenericRepository(TaskDynamoModel)

class ProjectManager:

    def get_all_projects(self):
        """
        Get all projects
        Returns:
            list: List of all projects
        """
        try:
            projects = []
            for val_project in project_db.list_all():
                project = ProjectListResponse(**val_project.attribute_values)
                projects.append(project.dict())
            
            return {
                "status": HTTPStatus.OK.value,
                "data": projects,
                "message": "Projects fetched successfully",
            }

        except Exception as e:
            logger.error(f"Error fetching projects: {e}")
            raise ProjectException("Failed to fetch all projects") from e

    def get_project_by_id(self, id):
        """
        Get project by ID
        Args:
            id (str): Project ID
        Returns:
            dict: Project data
        """
        try:
            project = project_db.get(id)
            filter_condition = (tasks_db.model_class.project_id == id)
            filtered_tasks = tasks_db.list_all(filter_condition=filter_condition)
            tasks_list = [task.attribute_values.get("id") for task in filtered_tasks]
            if project:
                data = project.attribute_values.copy()
                data["tasks"] = tasks_list
                return {
                    "status": HTTPStatus.OK.value,
                    "data": data,
                    "message": "Project fetched successfully",
                }
            else:
                return {
                    "status": HTTPStatus.NOT_FOUND.value,
                    "data": None,
                    "message": "Project not found",
                }
        except Exception as e:
            logger.error(f"Error fetching project by ID: {e}")
            raise ProjectException("Failed to fetch project by ID") from e


    def create_project(self, project_data):
        """
        Create a new project
        Args:
            project_data (dict): Data for the new project
        Returns:
            dict: Created project data
        """
        try:
            project = ProjectCreateRequest(**project_data)
            project_dict = project.dict()
            project_dict["id"] = uuid.uuid4().hex
            project_dict["created_date"] = Utils.get_current_timestamp()
            project_dict["updated_date"] = "NA"
            project_dict["updated_by"] = "NA"
            created_project = project_db.create(project_dict)
            return {
                "status": HTTPStatus.OK.value,
                "data": created_project.attribute_values,
                "message": "Project created successfully",
            }
        except Exception as e:
            logger.error(f"Error creating project: {e}")
            raise ProjectException("Failed to create project") from e

    def update_project(self,  project_data):
        """
        Update current project
        Args:
            project_data (dict): Data for the current project
        Returns:
            dict: Updated project data
        """
        try:
            project = ProjectUpdateRequest(**project_data)
            project_details = project_db.get(project_data["id"])
            project_details.update(project)
            project_db.update(project_data["id"], project_details)
        except Exception as e:
            logger.error(f"Error updating project: {e}")
            raise ProjectException("Failed to update project") from e

    def delete_project(self, id):
        """
        Delete project by ID
        Args:
            id (str): Project ID
        Returns:
            dict: Deletion status
        """
        try:
            deleted = project_db.delete(id)
            if deleted:
                return {
                    "status": HTTPStatus.OK.value,
                    "data": None,
                    "message": "Project deleted successfully",
                }
            else:
                return {
                    "status": HTTPStatus.NOT_FOUND.value,
                    "data": None,
                    "message": "Project not found",
                }
        except Exception as e:
            logger.error(f"Error deleting project: {e}")
            raise ProjectException("Failed to delete project") from e
