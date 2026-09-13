# The security group (empty container) for EKS worker nodes.
# Rules are added as separate resources below, referencing this group's ID.
resource "aws_security_group" "eks_node_sg" {
  name        = "eks_node_sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  tags = {
    Name = "eks_node_sg"
  }
}

# Allows HTTPS (443) traffic IN from anywhere on the internet.
# Needed so real user traffic can reach your app's pods running on these nodes,
# via the load balancer -> Ingress Controller -> pod path.
resource "aws_vpc_security_group_ingress_rule" "node_allow_443" {
  security_group_id = aws_security_group.eks_node_sg.id
  cidr_ipv4          = "0.0.0.0/0"
  from_port          = 443
  to_port             = 443
  ip_protocol        = "tcp"
  description        = "Allow HTTPS inbound from internet to nodes"
}

# Allows the kubelet API (port 10250) to be reached, but ONLY from the
# control plane's security group - never from the open internet.
# The control plane uses this to manage pods/health on each node.
resource "aws_vpc_security_group_ingress_rule" "node_allow_kubelet" {
  security_group_id            = aws_security_group.eks_node_sg.id
  referenced_security_group_id = aws_security_group.eks_control_plane_sg.id
  from_port                    = 10250
  to_port                      = 10250
  ip_protocol                  = "tcp"
  description                  = "Allow kubelet port from control plane security group only"
}

# Allows nodes to send traffic OUT anywhere, unrestricted.
# Outbound is left open since nodes need to pull container images, call AWS
# APIs, etc. - the security risk is in what's allowed IN, not OUT.
resource "aws_vpc_security_group_egress_rule" "node_allow_all_outbound" {
  security_group_id = aws_security_group.eks_node_sg.id
  cidr_ipv4          = "0.0.0.0/0"
  ip_protocol        = "-1"
  description        = "Allow all outbound traffic from nodes"
}

# The security group (empty container) for the EKS control plane.
# Same pattern as the node SG - rules are separate resources referencing this ID.
resource "aws_security_group" "eks_control_plane_sg" {
  name        = "eks_control_plane_sg"
  description = "Security group for EKS control plane"
  vpc_id      = var.vpc_id

  tags = {
    Name = "eks_control_plane_sg"
  }
}

# Allows HTTPS (443) traffic IN to the control plane's API server.
# This is what lets kubectl (and anything else) talk to the cluster at all.
resource "aws_vpc_security_group_ingress_rule" "control_plane_allow_443" {
  security_group_id = aws_security_group.eks_control_plane_sg.id
  cidr_ipv4          = "0.0.0.0/0"
  from_port          = 443
  to_port             = 443
  ip_protocol        = "tcp"
  description        = "Allow HTTPS inbound to control plane API server"
}

# Allows the control plane to send traffic OUT to nodes on port 10250 (kubelet).
# This is the "other half" of node_allow_kubelet above - both sides need to
# explicitly permit this traffic for it to actually flow.
resource "aws_vpc_security_group_egress_rule" "control_plane_to_nodes" {
  security_group_id            = aws_security_group.eks_control_plane_sg.id
  referenced_security_group_id = aws_security_group.eks_node_sg.id
  from_port                    = 10250
  to_port                      = 10250
  ip_protocol                  = "tcp"
  description                  = "Allow control plane to reach kubelet on nodes only"
}

# Allows the control plane to send traffic OUT anywhere, unrestricted.
# Same reasoning as the node's outbound rule - outbound isn't the security risk here.
resource "aws_vpc_security_group_egress_rule" "control_plane_allow_outbound" {
  security_group_id = aws_security_group.eks_control_plane_sg.id
  cidr_ipv4          = "0.0.0.0/0"
  ip_protocol        = "-1"
  description        = "Allow all outbound traffic from control plane"
}