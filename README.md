# Lambda Bulk Tagger
Based heavily on https://github.com/rom1spi/aws-bulk-tagger this is a "Terraform" port of the same
idea. The original project relies heavily on Serverless framework, but modularising the project
into a terraform project made it easier for us to deploy, use, and maintain at Release.

# How to Use
1. Clone this repository into a directory
2. Create a `repo` directory peered with `config`
3. Create a `prod-us-west-2` or similar directory under `repo`
4. Create a module to import the project like this

```hcl
provider "aws" {
  region  = "us-west-2"
  profile = "production"
}

module "lambda_bulk_tagger_us_west_2" {
  source = "../../lambda-bulk-tagger/config"
}
```

(If you are using https://releasehub.com, follow instructions for setting up a terraform runner with
repository attached to an application).

#How it works
Follow the excellent README from the original project https://github.com/rom1spi/aws-bulk-tagger#use-case

We have adapted the Lambda to use a cloudwatch event cycle of 1 hour (57 minutes actually) to feed
events into the bulk tagger so that new objects are continuously tagged. For example, in the file
[cloudwatch_event.tf](config/cloudwatch_event.tf)
to add VantaOwners to every type of object in AWS that Vanta might want to monitor, we use:

```hcl
  namespace = "owners"
  lambda_input = jsonencode({
    "TagKeyExclusion" = "VantaOwner",
    "TagFilters" = [],
    "TagsToApply" = {
      "VantaOwner"            = "owner@example.com"
    },
    "ResourceTypeFilters" = [
      "elasticloadbalancing",
      "ec2:instance",
      "s3",
      "rds",
      "redshift",
      "dynamodb",
      "sqs",
    ]
  })
```

Which basically says, `For resource types "elb, ec2, s3, rds...." apply "VantaOwner" tag with value
"owner@example.com"`

Then, since we use RDS snapshots quite a bit in Release ephmeral Instant Datasets, we also tag those
with more values like:

```hcl
  namespace = "RDS"
  lambda_input = jsonencode({
    "TagFilters" = [
      {
        "Key" = "releasehub.com/rds-pool",
        "Values" = [
          "true"
        ]
      }
    ],
    "TagsToApply" = {
      "VantaNonProd"          = "true",
      "VantaDescription"      = "RDS Pool Dev Instance",
      "VantaContainsUserData" = "false",
      "VantaNoAlert"          = "Pool instances for development work: no backups required and no user data stored."
    },
    "ResourceTypeFilters" = [
      "rds"
    ]
  })
```

Which basically says, `For resource type rds with existing tag "releasehub.com/rds-pool" == "true" apply
various tags with various values`

# Feedback
Feel free to open a pull request or github issue on this repository! We also have some very minor set
of contributions to the original Python source code we have not submitted upstream. If you would like
to help us or contribute back, let us know!
# terraform-aws-bulk-tagger
