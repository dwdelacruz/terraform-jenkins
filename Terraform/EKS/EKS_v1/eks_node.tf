resource "aws_iam_role" "eks_node_group" {
  name = "SNET-terraform-poc-eks-cluster-node"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "aws_eks_woker_node_policy_general" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    role = aws_iam_role.eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "aws_eks_cni_policy_general" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    role = aws_iam_role.eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "aws_eks_containerRegistry_policy_general" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    role = aws_iam_role.eks_node_group.name
}

resource "aws_eks_node_group" "node" {
    cluster_name = aws_eks_cluster.eks.name
    node_group_name = "node_general"
    node_role_arn = aws_iam_role.eks_node_group.arn
    subnet_ids = [
        data.aws_subnet.sub1.id
    ]
    scaling_config {
      desired_size = 1
      max_size = 1
      min_size = 1
    }
    ami_type = "AL2_x86_64"
    capacity_type = "ON_DEMAND"
    disk_size = 10
    force_update_version = false
    instance_types = ["t2.small"]
    version = "1.18"
    labels = {
      role = "node-general"

    }
    depends_on = [
      aws_iam_role_policy_attachment.aws_eks_woker_node_policy_general,
      aws_iam_role_policy_attachment.aws_eks_cni_policy_general,
      aws_iam_role_policy_attachment.aws_eks_containerRegistry_policy_general
    ]
}