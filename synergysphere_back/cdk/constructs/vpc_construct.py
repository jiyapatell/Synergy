"""
VPC Construct
"""

from aws_cdk import aws_ec2 as ec2
from constructs import Construct

class VpcConstruct(Construct):
    """
    VPC Construct CDK definition
    """

    def __init__(
        self, scope: Construct, stack_id: str, construct_helper, **kwargs
    ) -> None:
        """
        Following aws resources are created and initialized:
        - VPC

        """
        super().__init__(scope, stack_id, **kwargs)

        vpc_name = construct_helper.get_parameter_value("VPC_NAME")

        self.vpc = ec2.Vpc(
            self,
            construct_helper.get_resource_name(vpc_name),
            max_azs=2,
            subnet_configuration=[
                ec2.SubnetConfiguration(
                    name="Public",
                    subnet_type=ec2.SubnetType.PUBLIC,
                    cidr_mask=24
                ),
                ec2.SubnetConfiguration(
                    name="Private",
                    subnet_type=ec2.SubnetType.PRIVATE_WITH_EGRESS,
                    cidr_mask=24
                ),
            ],
            nat_gateways=1,
        )

        self.security_group = ec2.SecurityGroup(
            self, construct_helper.get_resource_name("ECSOdooSecurityGroup"),
            security_group_name= construct_helper.get_resource_name("ECSOdooSecurityGroup"),
            vpc=self.vpc,
            description="Security group for ECS Odoo management",
            allow_all_outbound=True
        )

        self.public_subnets = self.vpc.select_subnets(subnet_type=ec2.SubnetType.PUBLIC).subnets
        self.private_subnets = self.vpc.select_subnets(subnet_type=ec2.SubnetType.PRIVATE_WITH_EGRESS).subnets
