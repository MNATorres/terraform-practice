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

# 1. Le decimos a Terraform que comprima nuestro código automáticamente
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/lambda.zip"
}

# 2. Creamos un Rol de IAM para la Lambda (Su "DNI" con permisos)
resource "aws_iam_role" "lambda_role" {
  name = "mi_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# 3. Le pegamos una política básica al Rol para que la Lambda pueda escribir logs en CloudWatch
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# 4. Definimos la Función Lambda real
resource "aws_lambda_function" "mi_lambda" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "mi-lambda-terraform"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"                                  # Apunta al archivo index.js y a la función exports.handler
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256 # Detecta si cambiás el código JS para actualizarlo

  runtime = "nodejs18.x" # El entorno de ejecución

  tags = {
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}
