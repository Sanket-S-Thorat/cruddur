#Install AWS CLI at root folder
cd /workspace
      curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
      unzip awscliv2.zip
      sudo ./aws/install
      cd $THEIA_WORKSPACE_ROOT

#export credentials
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
export AWS_DEFAULT_REGION=""
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --q Account --o text)

#Create monthly budget
## Costs $0.10 per budget if you have 2 or more existing actions budgets
aws budgets create-budget \
    --account-id $AWS_ACCOUNT_ID \
    --budget /workspace/cruddur/_docs/aws/budget.json \
    --notifications-with-subscribers /workspace/cruddur/_docs/aws/budget_subscribers.json

#SNS Notification for budget alerts create and assign ARN to an envar.
export TopicARN=aws sns create-topic --name billing-alarm --q TopicArn --o text

# Delete SNS topic
aws sns delete-topic --topic-arn ($TopicARN)

# Subscribe to the SNS topic
aws sns subscribe \
    --topic-arn $TopicARN \
    --protocol email \
    --notification-endpoint sanket201603116@gmail.com

# Create an Alarm for daily charges
aws cloudwatch put-metric-alarm --cli-input-json file://_docs/aws/billing-alarm.json


## User truffle-hog and bfg to look out for any secrets commited to remote repo either in present or history of the repo.

################################# WEEk - 1 ####################################

