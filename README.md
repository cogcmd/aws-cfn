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

## Configuration

CFN_TEMPLATE_URL="s3://bucket/path"
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
AWS_REGION="us-east-1"
