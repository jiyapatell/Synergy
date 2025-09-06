"""
API Construct

Deploy:
    - API Gateway
    - Lambda Integration
"""

from constructs import Construct
from aws_cdk import aws_apigateway as apigateway
from aws_cdk import aws_iam as iam
from aws_cdk import aws_lambda as _lambda
import uuid
import re

from cdk.config.api_templates import ERROR_MAPPING_TEMPLATE, OUTPUT_MAPPING_TEMPLATE, REQUEST_TEMPLATE


access_control_allow_origin = "method.response.header.Access-Control-Allow-Origin"
content_type = "application/json"
response_content_type = "method.response.header.Content-Type"


class ApiConstruct(Construct):
    """
    API Construct
    """

    def __init__(
        self,
        scope: Construct,
        stack_id: str,
        api_gateway_role: iam.Role,
        api_gateway_policy_document: iam.PolicyDocument,
        lambda_functions: list,
        construct_helper,
        **kwargs,
    ) -> None:
        """
        Following parameters are required to create an API Construct:
        - api_gateway_role
        - api_gateway_policy_document
        - lambda_functions
        Args:
            scope (Construct): CDK stack
            stack_id (str): Stack ID
            api_gateway_role (iam.Role): API Gateway Role
            api_gateway_policy_document (iam.PolicyDocument): API Gateway Policy Document
            lambda_functions (list): Lambda Functions
            construct_helper (ConstructHelper): Construct Helper
        Returns:
            None
        """

        super().__init__(scope, stack_id, **kwargs)

        self.api_gateway_role = api_gateway_role
        self.api_gateway_policy_document = api_gateway_policy_document
        self.lambda_functions = lambda_functions
        self.construct_helper = construct_helper

        api_resources_data = self.construct_helper.read_config_data(
            "api_resources.json"
        )

        self.backend_api_endpoints = api_resources_data["backend_api_endpoints"]

        self.create_api_gateway()

        self.integration_responses = self.create_integration_responses()

        self.apigw_add_endpoints()

    def create_integration_responses(self):
        """
        Create integration responses
        """
        integration_responses = [
            {
                "statusCode": "200",
                "responseParameters": {
                    access_control_allow_origin: "'*'",
                },
                "responseTemplates": {content_type: OUTPUT_MAPPING_TEMPLATE},
            }
        ]

        error_integration_responses = [
            {
                "statusCode": "400",
                "selectionPattern": '.*\\"statusCode\\":400.*,.*',
                "responseParameters": {
                    access_control_allow_origin: "'*'",
                },
                "responseTemplates": {content_type: ERROR_MAPPING_TEMPLATE},
            },
            {
                "statusCode": "403",
                "selectionPattern": '.*\\"statusCode\\":403.*,.*',
                "responseParameters": {
                    access_control_allow_origin: "'*'",
                },
                "responseTemplates": {content_type: ERROR_MAPPING_TEMPLATE},
            },
            {
                "statusCode": "404",
                "selectionPattern": '.*\\"statusCode\\":404.*,.*',
                "responseParameters": {
                    access_control_allow_origin: "'*'",
                },
                "responseTemplates": {content_type: ERROR_MAPPING_TEMPLATE},
            },
            {
                "statusCode": "500",
                "selectionPattern": '.*\\"statusCode\\":500.*,.*',
                "responseParameters": {
                    access_control_allow_origin: "'*'",
                },
                "responseTemplates": {content_type: ERROR_MAPPING_TEMPLATE},
            },
        ]

        return integration_responses + error_integration_responses

    def create_api_gateway(self) -> None:
        """
        Create API Gateway
        """
        api_name = self.construct_helper.get_resource_name("Odoo-api")
        self.api_gateway = apigateway.RestApi(
            self,
            api_name,
            rest_api_name=api_name,
            description="API Gateway for Odoo management Service",
            policy=self.api_gateway_policy_document,
            cloud_watch_role=True,
        )

        suffix = self.construct_helper.get_parameter_value("SUFFIX")

        deployment = apigateway.Deployment(
            self, id="deployment-api", api=self.api_gateway
        )

        stage_name = suffix

        stage = apigateway.Stage(
            self,
            id=f"{stage_name}-api",
            deployment=deployment,
            stage_name=stage_name,
            tracing_enabled=True,
            metrics_enabled=True,
            logging_level=apigateway.MethodLoggingLevel.INFO,
        )

        self.api_gateway.deployment_stage = stage

    def apigw_add_endpoints(self):
        """
        Generate integration and method response
        Create resource and integrate with lambda function
        Add CORS to the API Gateway
        """
        resources = {}
        for resource_name, methods in self.backend_api_endpoints.items():
            # Create the resource only once
            if resource_name not in resources:
                resources[resource_name] = self.api_gateway.root.add_resource(resource_name)
            api_resource = resources[resource_name]
            cors_added = False
            for method_config in methods:
                lambda_name = method_config["LAMBDA"]
                method_type = method_config["METHOD"]
                request_params = method_config.get("REQUEST_PARAMETER", {})
                # Generate a unique, alphanumeric suffix for model names
                raw_suffix = f"{resource_name}{method_type}"
                unique_suffix = re.sub(r'[^a-zA-Z0-9]', '', raw_suffix)
                method_responses = self.create_method_response(unique_suffix=unique_suffix)
                lambda_function = self._find_lambda_function(lambda_name)
                if not lambda_function:
                    raise ValueError(f"Lambda function {lambda_name} not found")
                integration = apigateway.LambdaIntegration(
                    lambda_function,
                    proxy=False,
                    integration_responses=self.integration_responses,
                    request_templates={content_type: REQUEST_TEMPLATE},
                )
                api_resource.add_method(
                    method_type,
                    integration,
                    authorization_type=apigateway.AuthorizationType.NONE,
                    request_parameters=request_params if request_params else None,
                    method_responses=method_responses,
                )
                # Add CORS only once per resource
                if not cors_added:
                    self._add_cors(api_resource, method_type)
                    cors_added = True

    def _find_lambda_function(self, lambda_name: str) -> _lambda.Function:
        """
        Finds the Lambda function from the list based on the function name.
        Args:
            lambda_name (str): The name of the Lambda function to find
        Returns:
            _lambda.Function: The Lambda function if found, else None
        """
        for function_name, function in self.lambda_functions.items():
            if function_name == lambda_name:
                return function
        return None

    def _add_cors(self, api_resource: apigateway.IResource, method_type: str):
        """
        Adds CORS configuration to a resource.
        Args:
            api_resource (apigateway.IResource): The API Gateway resource to add CORS to
            method_type (str): The HTTP method type (GET, POST, etc.)
        """
        if method_type in ["GET", "POST", "OPTIONS"]:
            api_resource.add_cors_preflight(
                allow_origins=["*"],  # Allow all origins, but restrict as needed
                allow_methods=["GET", "POST", "OPTIONS"],
                allow_headers=["*"],  # You can restrict this as needed
            )

    def create_method_response(self, unique_suffix=None):
        """
        Create method response
        Returns:
            dict: Method response
        """
        # Use a unique suffix for model names to avoid duplicate construct errors
        suffix = unique_suffix or str(uuid.uuid4())
        response_model = self.api_gateway.add_model(
            f"Responsemodel{suffix}",
            content_type="application/json",
            model_name=f"ResponseModel{suffix}",
            schema=apigateway.JsonSchema(
                schema=apigateway.JsonSchemaVersion.DRAFT4,
                title="pollResponse",
                type=apigateway.JsonSchemaType.OBJECT,
                properties={
                    "message": apigateway.JsonSchema(
                        type=apigateway.JsonSchemaType.STRING
                    ),
                    "data": apigateway.JsonSchema(type=apigateway.JsonSchemaType.ARRAY),
                },
            ),
        )

        error_response_model = self.api_gateway.add_model(
            f"ErrorResponseModel{suffix}",
            content_type="application/json",
            model_name=f"ErrorResponseModel{suffix}",
            schema=apigateway.JsonSchema(
                schema=apigateway.JsonSchemaVersion.DRAFT4,
                title="errorResponse",
                type=apigateway.JsonSchemaType.OBJECT,
                properties={
                    "message": apigateway.JsonSchema(
                        type=apigateway.JsonSchemaType.STRING
                    )
                },
            ),
        )

        method_responses = [
            {
                "statusCode": "200",
                "responseParameters": {
                    access_control_allow_origin: True,
                },
                "responseModels": {content_type: response_model},
            }
        ]

        error_method_responses = self.create_error_method_response(error_response_model)

        return method_responses + error_method_responses

    def create_error_method_response(self, error_response_model):
        """
        Create error method response
        Args:
            error_response_model: Error response model
        Returns:
            dict: Error method response
        """
        error_method_responses = [
            {
                "statusCode": "400",
                "responseParameters": {
                    access_control_allow_origin: True,
                },
                "responseModels": {content_type: error_response_model},
            },
            {
                "statusCode": "403",
                "responseParameters": {
                    access_control_allow_origin: True,
                },
                "responseModels": {content_type: error_response_model},
            },
            {
                "statusCode": "404",
                "responseParameters": {
                    access_control_allow_origin: True,
                },
                "responseModels": {content_type: error_response_model},
            },
            {
                "statusCode": "500",
                "responseParameters": {
                    access_control_allow_origin: True,
                },
                "responseModels": {content_type: error_response_model},
            },
        ]

        return error_method_responses
