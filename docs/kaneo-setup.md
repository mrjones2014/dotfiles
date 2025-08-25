# Kaneo Setup Instructions

This configuration sets up Kaneo (https://kaneo.app) using NixOS oci-containers with the following components:

## Services
- **PostgreSQL 16**: Database backend with persistent storage
- **Kaneo API**: Backend service (ghcr.io/usekaneo/api:latest)
- **Kaneo Web**: Frontend application (ghcr.io/usekaneo/web:latest)

## Network Setup
- Internal podman network: `kaneo`
- PostgreSQL: Only accessible within the kaneo network
- Backend API: Accessible on localhost:1337 and within the kaneo network
- Frontend: Accessible on localhost:5173 and exposed via nginx reverse proxy

## External Access
- The frontend will be available at: `https://kaneo.mjones.network`
- All traffic is routed through nginx with SSL termination

## Required Secrets
You need to generate and encrypt the following secrets in `secrets/kaneo_env.age`:

```bash
# Generate a secure PostgreSQL password
POSTGRES_PASSWORD=<your_secure_postgres_password>

# Generate a secure JWT token for backend authentication  
JWT_ACCESS=<your_secure_jwt_token>
```

To generate secure values:
```bash
# PostgreSQL password (32 character random string)
openssl rand -base64 32

# JWT access token (64 character random string)
openssl rand -base64 64
```

## Encrypting Secrets
1. Create a temporary file with the environment variables:
```bash
cat > /tmp/kaneo_env << EOF
POSTGRES_PASSWORD=your_generated_password_here
JWT_ACCESS=your_generated_jwt_token_here
EOF
```

2. Encrypt with agenix:
```bash
agenix -e secrets/kaneo_env.age < /tmp/kaneo_env
rm /tmp/kaneo_env  # Clean up temporary file
```

## Data Storage
- PostgreSQL data is stored in: `/var/lib/kaneo/postgres-data`
- This directory is created automatically with proper permissions

## Service Dependencies
- `kaneo-backend` depends on `kaneo-postgres`
- `kaneo-frontend` depends on `kaneo-backend`
- Services will start in the correct order automatically