"""
DynamoDB Construct
Deploy:
    - DynamoDB Tables
"""

from constructs import Construct
from aws_cdk import aws_dynamodb as dynamodb, RemovalPolicy
import json
import os

class DynamoDBConstruct(Construct):
    """DynamoDB Constructs CDK definition"""

    def __init__(self, scope: Construct, stack_id: str, construct_helper, **kwargs) -> None:
        super().__init__(scope, stack_id, **kwargs)
        self.construct_helper = construct_helper
        config_path = os.path.join(os.path.dirname(__file__), 'config', 'dynamoDb.json')
        with open(config_path, 'r') as f:
            tables = json.load(f)
        for table in tables:
            self.create_dynamodb_table(table)

    def create_dynamodb_table(self, table_config: dict) -> None:
        partition_key = dynamodb.Attribute(
            name=table_config["partition_key"],
            type=dynamodb.AttributeType.STRING
        )
        sort_key = None
        if table_config.get("sort_key"):
            sort_key = dynamodb.Attribute(
                name=table_config["sort_key"],
                type=dynamodb.AttributeType.STRING
            )
        table = dynamodb.Table(
            self,
            self.construct_helper.get_resource_name(table_config["name"]),
            table_name=self.construct_helper.get_resource_name(table_config["name"]),
            partition_key=partition_key,
            sort_key=sort_key,
            read_capacity=table_config.get("read_capacity", 5),
            write_capacity=table_config.get("write_capacity", 5),
            removal_policy=RemovalPolicy.DESTROY,
        )
