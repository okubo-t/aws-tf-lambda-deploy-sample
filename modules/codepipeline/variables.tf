data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

variable "event_rule_name" {}
variable "codepipeline_name" {}
variable "repository_name" {}
variable "branch_name" {}
variable "stack_name" {}
