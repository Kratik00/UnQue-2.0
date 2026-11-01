
# UnQue Backend — Amazon DocumentDB Migration

## 1. Introduction

This project demonstrates migration of the UnQue Node.js backend
from MongoDB to Amazon DocumentDB using Mongoose.

The application is containerized using Docker and can be deployed
in an AWS EC2 environment connected privately to DocumentDB.

## 2. Architecture

- Application: Node.js and Express
- ODM: Mongoose
- Containerization: Docker
- Deployment target: AWS EC2
- Database: Amazon DocumentDB
- Database protocol: MongoDB-compatible API
- Database port: 27017
- Database encryption: TLS

## 3. Configuration

Application uses these environment variables.

| Variable | Description |
|---|---|
| PORT | Application port |
| DB_TYPE | mongodb or documentdb |
| MONGO_URL | Database connection URI |
| JWT_SECRET | JWT signing secret |
| DOCDB_CA_FILE | DocumentDB CA certificate path |

## 4. DocumentDB Connection

For DocumentDB deployments, configure Mongoose with:

- TLS enabled
- AWS DocumentDB CA certificate
- retryWrites disabled
- Private DocumentDB cluster endpoint
- Port 27017

## 5. Network Configuration

For deployment in AWS, the EC2 instance and Amazon DocumentDB cluster should be deployed inside the same VPC or connected VPCs.

Required network configuration:

- DocumentDB should be deployed under private subnets.
- EC2 should have network connectivity to the DocumentDB cluster.
- The DocumentDB security group should allow inbound TCP traffic on port `27017` from the EC2 security group.
- The EC2 security group should allow outbound traffic to the DocumentDB endpoint.
- The DocumentDB endpoint should not be exposed publicly for security purposes.

## 6. DocumentDB Connection Setup

The application uses Mongoose to establish a connection with Amazon DocumentDB.

When `DB_TYPE=documentdb` is configured, the application enables TLS and uses the AWS-provided CA certificate to verify the database connection.

The following settings are used:

- `tls: true` enables encrypted communication.
- `tlsCAFile` specifies the AWS DocumentDB CA certificate.
- `retryWrites: false` disables retryable writes, which are not supported by DocumentDB.
- `MONGO_URL` contains the DocumentDB cluster connection URI.

The database connection is established before the Express server starts accepting requests. If the database connection fails, the application exits instead of starting without a working database.

## 7. Docker Image

Build the image:

    docker build -t unque-backend:1.0 .

Export:

    docker save unque-backend:1.0 -o unque-backend.tar

Load on deployment machine:

    docker load -i unque-backend.tar

## 8. Deployment

Make the deployment script executable:

    chmod +x deploy.sh

Export the required environment variables:

    export DB_TYPE=documentdb
    export MONGO_URL='mongodb://...'
    export JWT_SECRET='...'

Run:

    ./deploy.sh
## 8. Testing and Deployment Limitations

The backend application was containerized and tested locally using Docker and MongoDB because Amazon documentDB cluster did not support any free tier however i attached Dockerfile and bash script for running the appication in same repo incudiing Docker-compose file i already edited index.js file based on project requirements and following API endpoints are tested:

- Creating professor availability.
- Updating an existing free availability slot.
- Booking an appointment as a student.
- Preventing duplicate appointment bookings.
- Cancelling an appointment.
- Verifying that a student has no pending appointments after cancellation.
