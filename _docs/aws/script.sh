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

#SNS Notification for budget alerts
aws sns create-topic --name billing-alarm
aws sns subscribe \
    --topic-arn TopicARN \
    --protocol email \
    --notification-endpoint sanket201603116@gmail.com
