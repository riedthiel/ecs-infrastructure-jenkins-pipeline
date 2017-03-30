aws s3 sync ~/ancestry-sandbox/sde-ecs-cfn/ s3://jw-ia-dev/ --profile isengard --exclude ".*" 

aws cloudformation create-stack --stack-name IA-ECS-Stack-4 --template-url https://s3.amazonaws.com/jw-ia-dev/master.yaml --parameters file://~/ancestry-sandbox/sde-ecs-cfn/parameters/dev-parameters.json --capabilities CAPABILITY_NAMED_IAM --profile isengard --region us-east-1  --disable-rollback

c=1
while [[ $c -le 5 ]]; do
   aws cloudformation describe-stacks --stack-name IA-ECS-Stack-4 --profile isengard --region us-east-1
   sleep 10s
   (( c++ ))
done

