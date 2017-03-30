node {
  stackname = "Nginx-ECS2"
  s3bucket = "jw-ia-dev"
  stage 'Checkout'
    checkout scm

  stage 'Create/Update Infrastructure'
    sh "aws s3 sync . s3://${s3bucket}/ --exclude '.*' "
    try {
      result = sh(returnStdout: true, script: "aws cloudformation describe-stacks --stack-name ${stackname} --region us-east-1 --query 'Stacks[*].StackStatus' --output text")
      sh "aws cloudformation update-stack --stack-name ${stackname} --template-url https://s3.amazonaws.com/jw-ia-dev/master.yaml --parameters file://./parameters/dev-parameters.json --capabilities CAPABILITY_NAMED_IAM  --region us-east-1 "
    } catch (all) {
      sh "aws cloudformation create-stack --stack-name ${stackname} --template-url https://s3.amazonaws.com/jw-ia-dev/master.yaml --parameters file://./parameters/dev-parameters.json --capabilities CAPABILITY_NAMED_IAM  --region us-east-1 --disable-rollback"
    }

  stage 'Wait for Completion'
    result = sh(returnStdout: true, script: "aws cloudformation describe-stacks --stack-name ${stackname} --region us-east-1 --query 'Stacks[*].StackStatus' --output text")
    for (int i = 0; i < 1000; i++) {
      result = sh(returnStdout: true, script: "aws cloudformation describe-stacks --stack-name ${stackname} --region us-east-1 --query 'Stacks[*].StackStatus' --output text")
      if (result.contains("ERROR") || result.contains("ROLLBACK")) {
         error: "Error in Stack Build"
      } else if (result.contains('COMPLETE')) {
        break;
      }
      echo "Status ${result}"
      sleep: 50000
    }
}
