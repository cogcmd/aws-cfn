# Cog Bundle: cfn

Cog commands for interacting with Amazon Web Services CloudFormation.

## Commands

### `cfn:stack`

```
Usage: cfn:stack <subcommand> [options]

Subcommands:
  create <stack name> <template name>
  list
  show <stack name>
  delete <stack name>
  event <stack name>
  resource <stack name>
  template <stack name>

Options:
  --help, -h     Show usage
```

#### `cfn:stack create`

```
Usage: cfn:stack create <stack name> <template name> [options]

Creates a new stack based on an existing template

Options:
  --param, -p "Key1=Value1"                   (Can be specified multiple times)
  --tag, -t "Name1=Value1"                    (Can be specified multiple times)
  --policy, -o "s3_policy_name"
  --notify, -n "NotifyArn"                    (Can be specified multiple times)
  --on-failure, -f <rollback | delete | keep>
  --timeout, -e <minutes>
  --capabilities, -c <iam | named_iam>
```

#### `cfn:stack list`

```
Usage: cfn:stack list [options]

List stack summaries

Options:
  --filter "status filter"    (Can be specified multiple times) (Defaults to 'ACTIVE')
  --limit <int>

Notes:
  The filter string can be one or more cloudformation stack status strings which include:
  CREATE_IN_PROGRESS, CREATE_FAILED, CREATE_COMPLETE, ROLLBACK_IN_PROGRESS, ROLLBACK_FAILED, ROLLBACK_COMPLETE, DELETE_IN_PROGRESS, DELETE_FAILED, DELETE_COMPLETE, UPDATE_IN_PROGRESS, UPDATE_COMPLETE_CLEANUP_IN_PROGRESS, UPDATE_COMPLETE, UPDATE_ROLLBACK_IN_PROGRESS, UPDATE_ROLLBACK_FAILED, UPDATE_ROLLBACK_COMPLETE_CLEANUP_IN_PROGRESS, UPDATE_ROLLBACK_COMPLETE

  Additionally a few special filter strings that correspond to a subset of the standard filter strings may be used:
  ACTIVE, COMPLETE, FAILED, DELETED, IN_PROGRESS
```

#### `cfn:stack show`

```
Usage: cfn:stack show <stack name>

Returns the specified stack
```

#### `cfn:stack delete`

```
Usage: cfn:stack delete <stack name>

Deletes a stack. Returns a map with the stack name and status.

Note: This command returns the same regardless of success or failure. Use the cfn:event command to view the results of the delete.
```

#### `cfn:stack event`

```
Usage: cfn:stack event <stack name>

Returns all stack related events for a specified stack in reverse chronological order.

Options:
  --limit <int>
```

#### `cfn:stack resource`

```
Usage: cfn:stack resource <stack name>

Returns the list of stack resources.
```

#### `cfn:stack template`

```
Usage: cfn:stack template <stack name>

Returns the template body for the specified stack.
```


### `cfn:template`

```
Usage: cfn:template <subcommand> [options]

Subcommands:
  list
  show <template name> | -s <stack name>

Options:
  --help, -h     Show Usage
```

#### `cfn:template list`

```
Usage: cfn:template list

Returns the list of templates in the configured s3 bucket.
```

#### `cfn:template show`

```
Usage: cfn:template show <template name> | -s <stack name>

Options:
  --stack, -s    "Specify a stack name instead of a template name"

Example:
  cfn:template show mytemplate
  ...<template summary>...

  cfn:template show -s mystack
  ...<template summary>...
```

### `cfn:changeset`

```
Usage: cfn:changeset <subcommand> [options]

Subcommands:
  create <stack name>
  delete <change set id> | <change set name> <stack name>
  list <stack name>
  show <change set id> | <change set name> <stack name>
  apply <change set id> | <change set name> <stack name>

Options:
  --help, -h    Show usage
```

#### `cfn:changeset create`

```
Usage: cfn:changeset create <stack name> [options]

Create a changeset for a stack. Returns the changeset

Options:
  --param, -p "Key1=Value1"               (Can be specified multiple times)
  --tag, -t "Name1=Value1"                (Can be specified multiple times)
  --template, -m "TemplateName"           (defaults to UsePreviousTemplate)
  --notify, -n "NotifyArn"                (Can be specified multiple times)
  --capabilities, -c <iam | named_iam>
  --description, -d "Description"
  --change-set-name "ChangeSetName"        (Defaults to 'changeset<num>')

Examples:
  cfn:changeset create mystack --param "Key1=Value1" --param "Key2=Value2"
```

#### `cfn:changeset delete`

```
Usage: cfn:changeset delete <change set id> | <change set name> <stack name>

Delete a changeset. Returns a map with containing the change set name AND stack name OR the change set id, depending on which was provided to apply.

Note: This command returns the same regardless of success or failure. Use the 'cfn:stack event' command to view the results of the delete.
```

#### `cfn:changeset list`

```
Usage: cfn:changeset list <stack name>

List changesets for a stack. Returns a list of changeset summaries equivalent to resp.summaries documented here, http://docs.aws.amazon.com/sdkforruby/api/Aws/CloudFormation/Client.html#list_change_sets-instance_method
```

#### `cfn:changeset show`

```
Usage: cfn:changeset show <change set id> | <change set name> <stack name>

Show changeset details. Returns a map equivalent to the response object documented here, http://docs.aws.amazon.com/sdkforruby/api/Aws/CloudFormation/Client.html#describe_change_set-instance_method
```

#### `cfn:changeset apply`

```
Usage: cfn:changeset apply <change set id> | <change set name> <stack name>

Apply a changeset to a stack. Returns a map containing the change set name AND stack name OR the change set id, depending on which was provided to apply.

Note: This command returns the same regardless of success or failure. Use the 'cfn:stack event' command to view the results of the apply.
```

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

