resource "aws_codepipeline" "this" {
  name     = var.codepipeline_name
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.artifacts_store.id
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      provider = "CodeCommit"
      category = "Source"
      configuration = {
        BranchName           = var.branch_name
        PollForSourceChanges = "false"
        RepositoryName       = var.repository_name
      }
      name             = var.repository_name
      owner            = "AWS"
      version          = "1"
      output_artifacts = ["SourceArtifact"]
      role_arn         = aws_iam_role.codepipeline_codecommit.arn
    }
  }

  stage {
    name = "SAMPackaged"
    action {
      category = "Build"
      configuration = {
        ProjectName = aws_codebuild_project.this.name
      }
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]
      name             = aws_codebuild_project.this.name
      provider         = "CodeBuild"
      owner            = "AWS"
      version          = "1"
      role_arn         = aws_iam_role.codepipeline_codebuild.arn
    }
  }

  stage {
    name = "CreateChangeSet"

    action {
      name            = "CreateChangeSet"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CloudFormation"
      version         = "1"
      input_artifacts = ["BuildArtifact"]
      role_arn        = aws_iam_role.codepipeline_cfn.arn

      configuration = {
        ActionMode    = "CHANGE_SET_REPLACE"
        StackName     = var.stack_name
        ChangeSetName = var.stack_name
        RoleArn       = aws_iam_role.cfn_changeset.arn
        Capabilities  = "CAPABILITY_IAM"
        TemplatePath  = "BuildArtifact::packaged.yaml"
      }
      run_order = 1
    }
  }

  stage {
    name = "Approval"

    action {
      name      = "Approval"
      category  = "Approval"
      owner     = "AWS"
      provider  = "Manual"
      version   = "1"
      run_order = 1
    }
  }

  stage {
    name = "ExecuteChangeSet"

    action {
      name     = "ExecuteChangeSet"
      category = "Deploy"
      owner    = "AWS"
      provider = "CloudFormation"
      version  = "1"
      role_arn = aws_iam_role.codepipeline_cfn.arn

      configuration = {
        ActionMode    = "CHANGE_SET_EXECUTE"
        StackName     = var.stack_name
        ChangeSetName = var.stack_name
        RoleArn       = aws_iam_role.cfn_changeset.arn
        Capabilities  = "CAPABILITY_IAM"
      }
      run_order = 1
    }
  }
}
