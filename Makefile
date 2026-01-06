.PHONY: help localstack-start localstack-stop init plan apply destroy test-table

help:
	@echo "IdP Cloud - Development Commands"
	@echo ""
	@echo "LocalStack:"
	@echo "  make localstack-start  - Start LocalStack"
	@echo "  make localstack-stop   - Stop LocalStack"
	@echo ""
	@echo "Terraform:"
	@echo "  make init           - Initialize Terraform"
	@echo "  make plan           - Show Terraform plan"
	@echo "  make apply          - Apply Terraform changes"
	@echo "  make destroy        - Destroy infrastructure"
	@echo ""
	@echo "Testing:"
	@echo "  make test-table        - Test DynamoDB table"

localstack-start:
	@echo "🚀 Starting LocalStack..."
	docker-compose up -d localstack
	@echo "⏳ Waiting for LocalStack..."
	@sleep 5
	@echo "✅ LocalStack ready!"

localstack-stop:
	@echo "🛑 Stopping LocalStack..."
	docker-compose down

init:
	@echo "🔧 Initializing Terraform..."
	cd infra/terraform/environments/dev && terraform init

plan:
	@echo "📋 Planning Terraform changes..."
	cd infra/terraform/environments/dev && terraform plan

apply:
	@echo "🚀 Applying Terraform changes..."
	cd infra/terraform/environments/dev && terraform apply -auto-approve

destroy:
	@echo "💣 Destroying infrastructure..."
	cd infra/terraform/environments/dev && terraform destroy -auto-approve

test-table:
	@echo "🧪 Testing DynamoDB table..."
	@echo "Listing tables..."
	aws dynamodb list-tables --endpoint-url http://localhost:4566 --region us-east-1
	@echo ""
	@echo "Describing users table..."
	aws dynamodb describe-table --table-name idp-cloud-dev-users --endpoint-url http://localhost:4566 --region us-east-1 --query 'Table.TableName'