resource "aws_iam_role" "as_ecs" {
  name               = join("-", [local.prefix_name, "pri", "iam", "rol"])
  description        = "[Terraform] IAM roles for ECS tracker (cpu & memory)"
  assume_role_policy = file("${path.module}/files/iam/as-ecs-role.json")
  tags    = merge(
    var.tags,
    map("Name", join("-", [local.prefix_name, "pri", "rol"])),
    map("Technical:ECSClusterName", var.ecs_cluster_name)
  )
}

resource "aws_iam_role_policy" "cwl" {
  name   = join("-", [local.prefix_name, "pri", "pol", "asg"])
  role   = aws_iam_role.as_ecs.name
  policy = data.template_file.as_ecs.rendered
}
