##############################
# Cluster
##############################

output "cluster_name" {
    description = "The name of the EKS cluster."
    value = module.eks.cluster_name
}

output "cluster_id" {
    description = "The name/id of the EKS cluster."
    value = module.eks.cluster_id 
}

output "cluster_arn" {
  description = "the arn of the cluster"
  value = module.eks.cluster_arn
}

output "cluster_certificate_authority_data" {
    description = "Nested attribute containing certificate-authority-data for your cluster. This is the base64 encoded certificate data required to communicate with your cluster."
    value = module.eks.cluster_certificate_authority_data
}
  
output "cluster_endpoint" {
    description = "The endpoint for your EKS Kubernetes API."
    value = module.eks.cluster_endpoint
}

output "cluster_oidc_issuer_url" {
  description = "value of the OIDC issuer URL of the cluster"
  value = module.eks.cluster_oidc_issuer_url
}

output "cluster_platform_version" {
  description = "Platform version for the cluster"
  value       = module.eks.cluster_platform_version
}

output "cluster_status" {
  description = "Status of the EKS cluster. One of `CREATING`, `ACTIVE`, `DELETING`, `FAILED`"
  value       = module.eks.cluster_status
}

output "cluster_security_group_id" {
  description = "Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console"
  value       = module.eks.cluster_security_group_id
}


##############################
# IRSA
##############################
output "oidc_provider" {
  description = "The OpenID Connect identity provider (issuer URL without leading `https://`)"
  value       = module.eks.oidc_provider
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if `enable_irsa = true`"
  value       = module.eks.oidc_provider_arn
}

output "cluster_tls_certificate_sha1_fingerprint" {
  description = "The SHA1 fingerprint of the public key of the cluster's certificate"
  value       = module.eks.cluster_tls_certificate_sha1_fingerprint
}