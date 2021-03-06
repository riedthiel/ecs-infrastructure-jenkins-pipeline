node {
  stackname = "Nginx-ECS2"
  s3bucket = "jw-ia-dev"
  stage 'Checkout'
    checkout scm

  stage 'Create/Update Infrastructure'
    sh "aws s3 sync . s3://${s3bucket}/ --exclude '.*' "
    try {
      result = sh(returnStdout: true, script: "aws cloudformation describe-stacks --stack-name ${stackname} --region us-east-1 --query 'Stacks[*].StackStatus' --output text")
      sh "aws cloudformation update-stack --stack-name ${stackname} --template-url https://s3.amazonaws.com/${s3bucket}/master.yaml --parameters file://./parameters/dev-parameters.json --capabilities CAPABILITY_NAMED_IAM  --region us-east-1 "
    } catch (all) {
      sh 'sed -i "s/UsePreviousValue/ParameterValue/g" ./parameters/dev-parameters.json'
      sh 'sed -i "s/true/\\"latest\\"/g" ./parameters/dev-parameters.json'
      sh "aws cloudformation create-stack --stack-name ${stackname} --template-url https://s3.amazonaws.com/${s3bucket}/master.yaml --parameters file://./parameters/dev-parameters.json --capabilities CAPABILITY_NAMED_IAM  --region us-east-1 --disable-rollback"
    }

  stage 'Wait for Completion'
    result = sh(returnStdout: true, script: "aws cloudformation describe-stacks --stack-name ${stackname} --region us-east-1 --query 'Stacks[*].StackStatus' --output text")
    for (int i = 0; i < 10000; i++) {
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
