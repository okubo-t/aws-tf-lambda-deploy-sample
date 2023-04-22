module "codepipeline" {
  source = "./modules/codepipeline"

  repository_name   = "sam-deploy-repo"
  branch_name       = "main"
  event_rule_name   = "sam-deploy-event"
  codepipeline_name = "sam-deploy-codepipeline"
  stack_name        = "sam-deploy-stack"
}
