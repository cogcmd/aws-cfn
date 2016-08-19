# Cog Bundle: cfn

Cog commands for interacting with Amazon Web Services CloudFormation.

## Commands

### `cfn:template`

**Usage:**

```
cfn:template <action> [<args>]

Actions:
  list - list available templates
  describe <name> - show details for named template
```

**Examples:**

```
> cfn:template list
+---------------+---------------------+
| Template      | Modified            |
+---------------+---------------------+
| base_vpc      | 2015-12-08 14:17:02 |
| elb/basic_tcp | 2016-01-31 11:19:01 |
| elb/https     | 2016-02-03 11:12:04 |
| ecs/cluster   | 2016-02-22 11:14:03 |
| postgres_rds  | 2016-08-03 09:21:40 |
+---------------+---------------------+
```
```
> cfn:template list | raw
{
  "templates": [
    {
      "name": "base_vpc",
      "last_modified": "2015-12-08 14:17:02"
    },
    {
      "name": "elb/basic_tcp",
      "last_modified": "2016-01-31 11:19:01"
    },
    {
      "name": "elb/https",
      "last_modified": "2016-02-03 11:12:04"
    },
    {
      "name": "ecs/cluster",
      "last_modified": "2016-02-22 11:14:03"
    },
    {
      "name": "postgres_rds",
      "last_modified": "2016-08-03 09:21:40"
    }
  ]
}
```
```
> cfn:template describe base_vpc
{ ... GetTemplateSummary struct ... }
```

### `cfn:create`

**Usage**

```
cfn:create <name> <s3_template_name>

Options:
  --param, -p "Key1=Value1"
  --param, -p "Key2=Value2"
  --tag, -t "Name1=Value1"
  --tag, -t "Name2=Value2"
  --policy, -o <s3_policy_name>
  --notify, -n "sns_topic_arn1"
  --notify, -n "sns_topic_arn2"
  --on-failure, -f <rollback *|delete|keep>
  --timeout, -e <minutes>
  --capabilities, -c <iam|named_iam>
```

## Configuration

### General Configuration

The `cfn` bundle makes use of CloudFormation stack templates and stack policies that are defined in JSON documents and stored in pre-defined S3 locations. These locations are defined in the configuration variables below:

* CFN_TEMPLATE_URL="s3://bucket/templates"
* CFN_POLICY_URL="s3://bucket/policies"

### AWS Credential Configuration

* `AWS_REGION="us-east-1"`

Basic AWS credentials can be configured via environment variables, an AWS CLI profile, or an IAM instance profile.

* First, the bundle will look for the following environment variables:
  * `AWS_ACCESS_KEY_ID=...`
  * `AWS_SECRET_ACCESS_KEY=...`
* If those environment variables are not found, the shared AWS configuration files (`~/.aws/credentials` and `~/.aws/config`) will be used, if configured.
* Finally, the IAM instance profile will be used if the bundle is running on an AWS instance or ECS container with a profile assigned.

You can also define an STS role ARN that should be assumed:

* `AWS_STS_ROLE_ARN: "arn:aws:iam::<account_number>:role/<role_name>"`
