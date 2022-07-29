output "ami_name" {
  description = "Name of the ami being used"
  value       = data.aws_ami.gpu.name
}
