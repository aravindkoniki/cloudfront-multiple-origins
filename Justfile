set shell := ["bash", "-cu"]

# Variables
LAMBDA_NAME := "edge-router"
DIST_ID := "E103J1BNQUMUYA"
REGION := "eu-west-1"
PROFILE := "MY_NETWORKING"

lambda-dir:
  cd lambda

clean:
  rm -f lambda/edge-redirect.zip

zip-lambda:
  cd lambda && zip edge-redirect.zip edge-redirect.js

update-lambda:
  aws lambda update-function-code \
    --function-name {{LAMBDA_NAME}} \
    --zip-file fileb://lambda/edge-redirect.zip \
    --region {{REGION}} \
    --profile {{PROFILE}}

publish-version:
  aws lambda publish-version \
    --function-name {{LAMBDA_NAME}} \
    --region {{REGION}} \
    --profile {{PROFILE}}

invalidate-cf:
  aws cloudfront create-invalidation \
    --distribution-id {{DIST_ID}} \
    --paths "/*" \
    --profile {{PROFILE}}

deploy:
  just clean
  just zip-lambda
  just update-lambda
  echo "Waiting 30 seconds for Lambda@Edge to propagate..."
  sleep 30
  just publish-version
  echo "Waiting 10 more seconds before invalidation..."
  sleep 10
  just invalidate-cf
  echo "✅ Lambda@Edge deployed and CloudFront invalidated"