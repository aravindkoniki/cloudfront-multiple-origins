# Upload Lambda@Edge function
resource "aws_lambda_function" "edge_router" {
  provider         = aws.us_east_1
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = filebase64sha256(data.archive_file.lambda_zip.output_path)
  function_name    = "edge-router"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "edge-redirect.handler"
  runtime          = "nodejs18.x"
  publish          = true
}

resource "aws_iam_role" "lambda_exec" {
  provider = aws.us_east_1
  name     = "lambda-edge-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = [
            "lambda.amazonaws.com",
            "edgelambda.amazonaws.com"
          ]
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  provider   = aws.us_east_1
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


data "archive_file" "lambda_zip" {
  provider    = aws.us_east_1
  type        = "zip"
  source_file = "${path.root}/lambda/edge-redirect.js"
  output_path = "${path.root}/edge-redirect.zip"
}
