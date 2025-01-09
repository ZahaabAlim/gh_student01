
# AWS Student Management API

## Description
This project provides a solution to manage student records using Terraform and Python-based AWS Lambda functions. The project includes setting up AWS resources (DynamoDB tables, Lambda functions, API Gateway) and IAM roles. Lambda functions handle adding and listing student records in DynamoDB, with API Gateway providing RESTful endpoints. The deployment process is automated using GitHub Actions.

## Technologies Used
- Terraform
- Python
- Boto3
- AWS Lambda
- AWS DynamoDB
- AWS API Gateway
- AWS IAM
- GitHub Actions

## Key Features
- Automated AWS resource setup with Terraform.
- Lambda functions for adding and listing student records.
- RESTful API endpoints via API Gateway.
- Secure access control with IAM roles and policies.
- Continuous deployment with GitHub Actions.

## Setup Instructions

### Prerequisites
- AWS account
- Terraform installed
- AWS CLI configured
- GitHub account

### Steps

1. **Clone the Repository**
   ```sh
   git clone <repository-url>
   cd <repository-directory>
   ```

2. **Configure AWS Credentials**
   - Ensure your AWS credentials are configured in your environment or use the AWS CLI to configure them.

3. **Initialize Terraform**
   ```sh
   terraform init
   ```

4. **Generate Terraform Plan**
   ```sh
   terraform plan
   ```

5. **Apply Terraform Configuration**
   ```sh
   terraform apply -auto-approve
   ```

6. **Deploy Using GitHub Actions**
   - Push your changes to the `main` branch to trigger the GitHub Actions workflow for deployment.

## Lambda Functions

### Add Student
- **File**: `add_student.py`
- **Description**: Adds a student record to the DynamoDB table.
- **Handler**: `add_student.lambda_handler`

### List Students
- **File**: `list_students.py`
- **Description**: Lists all student records from the DynamoDB table.
- **Handler**: `list_students.lambda_handler`

## API Endpoints

### Add Student
- **Method**: POST
- **Endpoint**: `/add_student`
- **Description**: Adds a student record to the DynamoDB table.

### List Students
- **Method**: GET
- **Endpoint**: `/list_students`
- **Description**: Lists all student records from the DynamoDB table.

## IAM Roles and Policies
- **Lambda Execution Role**: Allows Lambda functions to interact with DynamoDB.
- **Inline Policy**: Grants necessary permissions for DynamoDB operations.

## GitHub Actions Workflow
- **File**: `.github/workflows/deploy.yml`
- **Description**: Automates the deployment process using GitHub Actions.

## Outputs
- **API Gateway URL**: The URL of the deployed API Gateway.
