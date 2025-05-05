# Cloud Test Environment

This project provides a complete cloud test environment with a React TypeScript frontend, Python Flask backend, and MySQL database. The infrastructure is defined using Terraform for deployment to AWS.

## Project Structure

```
cloud-test-environment/
├── frontend/             # React TypeScript frontend
├── server/               # Python Flask backend
└── terraform/            # Terraform infrastructure code
```

## Getting Started

### Prerequisites

- Node.js 14+ and npm
- Python 3.8+
- MySQL Server or access to an RDS instance
- Terraform 1.0+
- AWS CLI configured with appropriate credentials

### Local Development Setup

#### Frontend Setup

1. Navigate to the frontend directory:
   ```
   cd frontend
   ```

2. Install dependencies:
   ```
   npm install
   ```

3. Create a `.env` file with environment configuration:
   ```
   REACT_APP_API_URL=http://localhost:5000/api
   ```

4. Start the development server:
   ```
   npm start
   ```

#### Backend Setup

1. Navigate to the server directory:
   ```
   cd server
   ```

2. Create a virtual environment:
   ```
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. Install dependencies:
   ```
   pip install -r requirements.txt
   ```

4. Create a `.env` file with environment configuration:
   ```
   FLASK_ENV=development
   FLASK_DEBUG=1
   DB_USER=root
   DB_PASSWORD=password
   DB_HOST=localhost
   DB_PORT=3306
   DB_NAME=cloud_test_db
   ```

5. Start the Flask server:
   ```
   python app.py
   ```

### Setting Up the Database

For local development, you can use MySQL:

1. Create a MySQL database:
   ```sql
   CREATE DATABASE cloud_test_db;
   ```

2. The application will automatically create the necessary tables on startup.

### Deploying with Terraform

1. Navigate to the terraform directory:
   ```
   cd terraform
   ```

2. Initialize Terraform:
   ```
   terraform init
   ```

3. Create a `terraform.tfvars` file with your specific configuration:
   ```hcl
   environment      = "development"
   aws_region       = "us-west-2"
   db_password      = "yourSecurePassword"
   ssh_key_name     = "your-ssh-key"
   ```

4. Preview the changes:
   ```
   terraform plan
   ```

5. Apply the changes:
   ```
   terraform apply
   ```

6. After deployment, Terraform will output important information like the load balancer DNS name.

## Features

- React TypeScript frontend with Tailwind CSS for styling
- Python Flask backend with RESTful API endpoints
- MySQL database integration
- Health status monitoring for all components
- Infrastructure as Code with Terraform
- Multi-environment support (development, staging, production)

## Testing

### Frontend Tests

```
cd frontend
npm test
```

### Backend Tests

```
cd server
python -m pytest
```

## Infrastructure Architecture

The infrastructure consists of:

- VPC with public and private subnets across multiple availability zones
- RDS MySQL database in private subnets
- EC2 instances for backend servers in private subnets
- EC2 instances for frontend servers in public subnets
- Application Load Balancer for frontend traffic
- Security groups for controlled access
- CloudWatch monitoring and alerts

## Contributing

Please follow standard Git workflow:

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## License

This project is licensed under the MIT License.