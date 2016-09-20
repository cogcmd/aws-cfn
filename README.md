# Cog Bundle: cfn

Cog commands for interacting with Amazon Web Services CloudFormation.

## Commands

The following commands are included with the bundle. For usage info about each command see the `help` builtin command: `help ecs:<command_name>`.

### Template Commands

Templates are stored as JSON documents in a predefined S3 bucket. See configuration for details on configuring the S3 bucket.

* `cfn:template-list`

> Lists available CloudFormation templates.

* `cfn:template-show`

> Shows summary information for a CloudFormation template.

### Stack Commands

* `cfn:stack-create`

> Creates a new stack based on an existing template and returns the newly created stack.

* `cfn:stack-list`

> Lists stack summaries.

* `cfn:stack-show`

> Shows details for a stack.

* `cfn:stack-delete`

> Deletes a stack.

* `cfn:stack-events`

> Lists events for a stack. Returns all stack related events for a specified stack in reverse chronological order.

* `cfn:stack-resources`

> Lists stack resources.

### Changeset Commands

* `cfn:changeset-create`

> Creates a changeset for a stack.

* `cfn:changeset-list`

> Lists cloudformation changesets.

* `cfn:changeset-show`

> Shows a cloudformation changeset.

* `cfn:changeset-delete`

> Deletes cloudformation changesets.

* `cfn:changeset-apply`

> Applies a cloudformation changeset.

## Configuration

### General Configuration

The preferred way of configuring `cfn` is via Cog's dynamic config. To learn more about dynamic config check out Cog's [documentation](https://cog.readme.io/docs/dynamic-command-configuration).

The `cfn` bundle makes use of CloudFormation stack templates and stack policies that are defined in JSON documents and stored in pre-defined S3 locations. These locations are defined in the configuration variables below:

* `CFN_TEMPLATE_URL="s3://bucket/templates"`
* `CFN_POLICY_URL="s3://bucket/policies"`

### AWS Configuration

The easiest way to configure your AWS credentials is with the following variables set in your dynamic config:

* `AWS_REGION="us-east-1"`
* `AWS_ACCESS_KEY_ID=...`
* `AWS_SECRET_ACCESS_KEY=...`

You can also define an STS role ARN that should be assumed:

* `AWS_STS_ROLE_ARN: "arn:aws:iam::<account_number>:role/<role_name>"`

#### Alternative Credential Configuration

If you prefer, you can configure your AWS credentials via an AWS CLI profile or an IAM instance profile.

Note: If you choose to configure your AWS credentials in this manner you will still need to configure your region via dynamic config.

* First, the bundle will look for the following environment variables:
  * `AWS_ACCESS_KEY_ID=...`
  * `AWS_SECRET_ACCESS_KEY=...`
* If those environment variables are not found, the shared AWS configuration files (`~/.aws/credentials` and `~/.aws/config`) will be used, if configured.
* Finally, the IAM instance profile will be used if the bundle is running on an AWS instance or ECS container with a profile assigned.

