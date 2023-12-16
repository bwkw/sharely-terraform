output "cluster_arn" {
  description = "ARN of the Aurora Cluster"
  value       = aws_rds_cluster.aurora.arn
}

output "cluster_endpoint" {
  description = "Writer endpoint for the Aurora Cluster"
  value       = aws_rds_cluster.aurora.endpoint
}

output "cluster_reader_endpoint" {
  description = "Reader endpoint for the Aurora Cluster"
  value       = aws_rds_cluster.aurora.reader_endpoint
}
