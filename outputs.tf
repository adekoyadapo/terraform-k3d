output "password" {
  description = "Passwords"
  value       = random_password.password.result
  sensitive   = true
}

output "endpoints" {
  description = "Endpoints"
  value       = { for i, j in data.template_file.helm_release : i => "${i}.${j.vars.domain}" }
}