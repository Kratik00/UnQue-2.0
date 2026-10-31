
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

## 5. Docker Image

Build the image:

    docker build -t unque-backend:1.0 .

Export:

    docker save unque-backend:1.0 -o unque-backend.tar

Load on deployment machine:

    docker load -i unque-backend.tar

## 6. Deployment

Make the deployment script executable:

    chmod +x deploy.sh

Export the required environment variables:

    export DB_TYPE=documentdb
    export MONGO_URL='mongodb://...'
    export JWT_SECRET='...'

Run:

    ./deploy.sh
