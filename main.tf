# 1. Bloque de configuración: Le decimos a Terraform qué proveedor necesitamos
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Usa la versión 5 o superior de la librería de AWS
    }
  }
}

# 2. Configuración del proveedor: Le indicamos la región de trabajo
provider "aws" {
  region = "us-east-1"
}

# 3. Nuestro Recurso: El Bucket de S3
resource "aws_s3_bucket" "mi_bucket" {
  # IMPORTANTE 🚨: El nombre del bucket debe ser único en TODO EL PLANETA.
  # Si otra persona en el mundo ya usó este nombre, AWS te va a tirar error.
  # Cambiá el "matias" por tu apellido o unos números locos para asegurarte.
  bucket = "practica-arquitectura-s3-matias-2026"

  tags = {
    Name        = "Mi Bucket de Práctica"
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}
