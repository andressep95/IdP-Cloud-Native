# ============================================
# Secrets Manager Module - Variables
# ============================================

variable "secret_name" {
  description = "Name of the secret"
  type        = string
}

variable "description" {
  description = "Description of the secret"
  type        = string
  default     = ""
}

variable "secret_value" {
  description = "Secret value as a map (will be stored as JSON)"
  type        = map(string)
  sensitive   = true
}

variable "recovery_window_in_days" {
  description = "Number of days to retain secret after deletion (0 for immediate deletion)"
  type        = number
  default     = 0 # For dev, use 0. For prod, use 7 or 30
}

variable "tags" {
  description = "Tags to apply to the secret"
  type        = map(string)
  default     = {}
}
