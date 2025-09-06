"""
App file to deploy the stack
"""

from aws_cdk import App, Environment

from cdk.constructs.service_stack import ServiceStack


def launch(app, env, environment):
    """
    Launch function to deploy the stack
    Args:
        app(App): CDK App
        env(dict): Environment
        environment(str): Environment name
    """
    app.node.set_context("env", environment)

    ServiceStack(app, f"OdooProjectStack-{environment}", env=env)


if __name__ == "__main__":
    app = App()

    environment = "int"
    env = Environment(region="ap-south-1", account="427547500501")
    launch(app, env, environment)

    app.synth()
