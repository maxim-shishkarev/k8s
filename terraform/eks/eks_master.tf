resource "aws_security_group" "eks" {
  name        = "${var.name}-ingress-eks"
  description = "Ingress: EKS Security Group"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Ingress: EKS Security Group"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.anyip]
    self        = true
  }
}

resource "aws_iam_role" "eks_master" {
  name               = "${var.name}-eks_master_role"
  assume_role_policy = file("iam_eks_master_assume.json")
}

resource "aws_iam_role_policy_attachment" "eks_master" {
  role       = aws_iam_role.eks_master.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}


resource "aws_eks_cluster" "main" {
  name     = "${var.name}-eks"
  role_arn = aws_iam_role.eks_master.arn
  version = var.eks_version

  vpc_config {
    subnet_ids = "${aws_subnet.main[*].id}"
    endpoint_private_access = var.eks_private_endpoint
    endpoint_public_access = var.eks_public_endpoint
    security_group_ids = [
      aws_security_group.eks.id, 
      aws_security_group.any_to_any.id
    ]
    public_access_cidrs = [var.myip]
  }

  depends_on = [
    aws_subnet.main,
    aws_iam_role_policy_attachment.eks_master
  ]
}

data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "main" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

data "aws_iam_policy_document" "eks_cni" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.main.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.main.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "eks_cni" {
  name               = "${var.name}-eks_cni_role"
  assume_role_policy = data.aws_iam_policy_document.eks_cni.json
}

resource "aws_iam_role_policy_attachment" "eks_cni" {
  role       = aws_iam_role.eks_cni.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}


resource "aws_eks_addon" "main" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "vpc-cni"
  service_account_role_arn = aws_iam_role.eks_cni.arn
}

output "EKS_Endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "kubeconfig-ca-data" {
  value = aws_eks_cluster.main.certificate_authority[0].data
}