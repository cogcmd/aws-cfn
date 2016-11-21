# cfn - AWS CloudFormation (0.0.17)

This bundle provides an opinioned interface to CloudFormation's raw
capabilities, not just to make it easier to use but, easier to use well.
Commands to perform all basic CloudFormation actions, such as creating and
listing stacks, are available, as you would expect. But, we've also built a
set of commands for managing a new concept, stack definitions.

Stack definitions are a layer on top of CloudFormation templates aimed at
making them more reusable and easier to work with as a team. They're
comprised of a defaults file, which is a named set of CloudFormation
paramters and tags, a named CloudFormation template, and a set of overrides.
All of these layers are merged together to make up all the inputs required to
create a stack.

Because most engineering and operations teams require a canonical version of
their infrastructure definitions to be stored in a VCS repository, templates,
defaults files, and stack definitions will be stored in a git repository.
Doing so supports several common use cases such as debugging and auditing.

Putting this all together results in a reusable, repeatable workflow that can
easily be executed from chat, while still allowing basic CloudFormation
actions when necessary.


## Installation

In chat:

```
@cog bundle install cfn
```

Via cogctl:

```
cogctl bundle install cfn
```

For more details about how to install and configure bundles see:

* [Installing Bundles](https://cog-book.operable.io/#_installing_bundles)
* [Dynamic Command Configuration](https://cog-book.operable.io/#_dynamic_command_configuration)

## Commands

The following commands are included with the bundle. For usage info
about each command see the `help` builtin command: `help cfn:<command_name>`.

* `template-show`
  > Shows contents of a template.

* `template-ls`
  > Lists all templates, filtered by an optional glob pattern.

* `stack-create`
  > Creates a new stack based on an existing template and returns the newly created stack.

* `stack-delete`
  > Deletes a stack.

* `stack-events`
  > Lists events for a stack. Returns all stack related events for a specified stack in reverse chronological order.

* `stack-list`
  > Lists stack summaries.

* `stack-resources`
  > Lists stack resources.

* `stack-show`
  > Shows details for a stack.

* `changeset-create`
  > Creates a changeset for a stack.

* `changeset-list`
  > Lists cloudformation changesets.

* `changeset-delete`
  > Deletes cloudformation changesets.

* `changeset-show`
  > Shows a cloudformation changeset.

* `changeset-apply`
  > Applies a cloudformation changeset.

* `definition-create`
  > Creates a stack definition.

* `definition-ls`
  > Lists all definitions, filtered by an optional glob pattern.

* `definition-show`
  > Shows contents of a definition.

* `defaults-create`
  > Creates a new defaults file.

* `defaults-ls`
  > Lists all defaults files, filtered by an optional glob pattern.

* `defaults-show`
  > Shows contents of a defaults file.

* `check-setup`
  > Checks that all configuration is set correctly

## Configuration

The commands in this bundle support a number of ways to authenticate with
Amazon Web Services. If you're not hosting a relay on EC2, you can provide
basic credentials with the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
environment variables. Or, if you are hosting Relay on EC2, you can keep
those environment variables blank and allow the commands to request
credentials from instance metadata. We also support an `AWS_STS_ROLE_ARN`
environment variable if you'd like to assume a role for all AWS requests.
You can read more about how IAM instance metadata and STS role ARNs work at
the following documentation page:

http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html

For access to the git repository, you'll need to provide a key that has
read and write access to all branches to be used by the command. If you're
having trouble providing the key in your dynamic config file, make sure
that row like the following:

```
- |
    GIT_SSH_KEY=-----BEGIN RSA PRIVATE KEY-----
    66HcO6zqknSn5b+kbn5TKiU/TUxjE1wUYZqiEBI+9t7kZWT5H3aTi5zhhHti0xGF
    vhI8N1p1ZRP8EeVcRASGeCjVt58llQhNpWP9bArz0B1vU5QvFZJ0gnnk5LI3uFYr
    ...
```

Once you've set all of your environment variables with dynamic config, you
can check to make sure all of them are set correctly and have the necessary
permissions by running `check setup`.


* `AWS_ACCESS_KEY_ID`
  > ID of the access key used to authenticate with the AWS API. Required if IAM instance metadata not used.

* `AWS_SECRET_ACCESS_KEY`
  > Secret of the access key used to authenticate with the AWS API. Required if IAM instance metadata not used.

* `AWS_REGION`
  > Optional region used for all commands

* `AWS_STS_ROLE_ARN`
  > Optional STS role ARN of which to assume when making requests to the AWS API.

* `S3_STACK_DEFINITON_BUCKET`
  > Required bucket name where created definitions will be written and read from when used to create stacks.

* `S3_STACK_DEFINITON_PREFIX`
  > Optional bucket key prefix to use when storing definitions in a shared bucket.

* `GIT_REMOTE_URL`
  > Url of git repository used to read and write defaults files, templates, and definitions.

* `GIT_SSH_KEY`
  > SSH key used to authenticate with the above git repository. Must have read and write access.
