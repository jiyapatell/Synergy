from aws_lambda_powertools import Logger
from http import HTTPStatus
import uuid

from exceptions.exceptions import ProjectException
from db.generic_repository import GenericRepository
from tasks import TaskCreateRequest, TaskUpdateRequest
from utils.utils import Utils
from db.task_model import TaskDynamoModel

logger = Logger(service="task_manager")
task_db = GenericRepository(TaskDynamoModel)

class TaskManager:
    def get_all_tasks(self):
        """
        Get all tasks
        Returns:
            list: List of all tasks
        """
        try:
            tasks = []
            for val_task in task_db.list_all():
                tasks.append(val_task.attribute_values)
            return {
                "status": HTTPStatus.OK.value,
                "data": tasks,
                "message": "Tasks fetched successfully",
            }
        except Exception as e:
            logger.error(f"Error fetching tasks: {e}")
            raise ProjectException("Failed to fetch all tasks") from e

    def get_task_by_id(self, id):
        """
        Get task by ID
        Args:
            id (str): Task ID
        Returns:
            dict: Task data
        """
        try:
            task = task_db.get(id)
            if task:
                return {
                    "status": HTTPStatus.OK.value,
                    "data": task.attribute_values,
                    "message": "Task fetched successfully",
                }
            else:
                return {
                    "status": HTTPStatus.NOT_FOUND.value,
                    "data": None,
                    "message": "Task not found",
                }
        except Exception as e:
            logger.error(f"Error fetching task by ID: {e}")
            raise ProjectException("Failed to fetch task by ID") from e

    def create_task(self, task_data):
        """
        Create a new task
        Args:
            task_data (dict): Data for the new task
        Returns:
            dict: Created task data
        """
        try:
            task = TaskCreateRequest(**task_data)
            task_dict = task.dict()
            task_dict["id"] = uuid.uuid4().hex
            task_dict["created_date"] = Utils.get_current_timestamp()
            task_dict["updated_date"] = "NA"
            task_dict["updated_by"] = "NA"
            created_task = task_db.create(task_dict)
            return {
                "status": HTTPStatus.OK.value,
                "data": created_task.attribute_values,
                "message": "Task created successfully",
            }
        except Exception as e:
            logger.error(f"Error creating task: {e}")
            raise ProjectException("Failed to create task") from e

    def update_task(self, task_data):
        """
        Update current task
        Args:
            task_data (dict): Data for the current task
        Returns:
            dict: Updated task data
        """
        try:
            task = TaskUpdateRequest(**task_data)
            task_details = task_db.get(task_data["id"])
            task_details.update(task)
            task_db.update(task_data["id"], task_details)
            return {
                "status": HTTPStatus.OK.value,
                "data": task_details.attribute_values,
                "message": "Task updated successfully",
            }
        except Exception as e:
            logger.error(f"Error updating task: {e}")
            raise ProjectException("Failed to update task") from e

    def delete_task(self, id):
        """
        Delete task by ID
        Args:
            id (str): Task ID
        Returns:
            dict: Deletion status
        """
        try:
            deleted = task_db.delete(id)
            if deleted:
                return {
                    "status": HTTPStatus.OK.value,
                    "data": None,
                    "message": "Task deleted successfully",
                }
            else:
                return {
                    "status": HTTPStatus.NOT_FOUND.value,
                    "data": None,
                    "message": "Task not found",
                }
        except Exception as e:
            logger.error(f"Error deleting task: {e}")
            raise ProjectException("Failed to delete task") from e