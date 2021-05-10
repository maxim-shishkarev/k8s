resource "aws_iam_role" "eks_worker" {
  name               = "${var.name}-eks_worker_role"
  assume_role_policy = file("iam_eks_worker_assume.json")
}

resource "aws_iam_role_policy_attachment" "eks_worker_node" {
  role       = aws_iam_role.eks_worker.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_worker_cni" {
  role       = aws_iam_role.eks_worker.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  
}

resource "aws_iam_role_policy_attachment" "eks_worker_ecr" {
  role       = aws_iam_role.eks_worker.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}


resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.name}-eks-workers"
  node_role_arn   = aws_iam_role.eks_worker.arn
  subnet_ids      = aws_subnet.main[*].id

  ami_type = var.eks_worker_ami_type
  capacity_type = var.eks_worker_capacity_type
  instance_types = var.eks_workers_instance_types
  disk_size = var.eks_workers_disk
  
  remote_access {
      ec2_ssh_key = var.ec2_key_name
      source_security_group_ids = [ aws_security_group.any_from_myip.id ]
  }

  scaling_config {
    desired_size = var.eks_workers_desired
    max_size     = var.eks_workers_max
    min_size     = var.eks_workers_min
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node,
    aws_iam_role_policy_attachment.eks_worker_cni,
    aws_iam_role_policy_attachment.eks_worker_ecr
  ]
}
