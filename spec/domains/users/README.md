## Technology Stack

- **API Gateway**: REST API
- **Compute**: AWS Lambda (Go 1.x)
- **Storage**: DynamoDB (single table)
- **Observability**: CloudWatch Logs + X-Ray

## Key Metrics

- **API Latency P95**: < 200ms
- **Throughput**: 100 req/s
- **Error Rate**: < 0.1%

## Use Cases

| ID           | Name        | Actor           | Status     |
| ------------ | ----------- | --------------- | ---------- |
| UC-USERS-001 | create-user | customer, admin | 📝 Planned |
| UC-USERS-002 | get-user    | customer, admin | 📝 Planned |
| UC-USERS-003 | list-users  | admin           | 📝 Planned |
| UC-USERS-004 | update-user | customer, admin | 📝 Planned |
| UC-USERS-005 | delete-user | customer, admin | 📝 Planned |

## Data Model

### Users Table (DynamoDB)

| Attribute    | Type   | Key                | Description                      |
| ------------ | ------ | ------------------ | -------------------------------- |
| userId       | String | PK                 | UUID v4                          |
| email        | String | GSI-1 PK           | Unique email address             |
| passwordHash | String | -                  | Bcrypt hash                      |
| firstName    | String | -                  | User's first name                |
| lastName     | String | -                  | User's last name                 |
| status       | String | GSI-2 PK           | active/suspended/pending/deleted |
| entityType   | String | GSI-3 PK           | Fixed value: "USER"              |
| phoneNumber  | String | -                  | Optional phone number            |
| metadata     | Map    | -                  | Custom key-value pairs           |
| createdAt    | String | GSI-2 SK, GSI-3 SK | ISO 8601 timestamp               |
| updatedAt    | String | -                  | ISO 8601 timestamp               |
| lastLoginAt  | String | -                  | ISO 8601 timestamp (optional)    |

### Indexes

#### Primary Key

- **PK**: `userId` (Partition Key)
- **Use Case**: Get user by ID
- **Query**: `GetItem` with userId

#### GSI-1: email-index

- **PK**: `email`
- **Projection**: ALL
- **Use Cases**:
  - Login by email
  - Check if email exists (duplicate validation)
- **Query Pattern**: `email = "user@example.com"`

#### GSI-2: status-created-index

- **PK**: `status`
- **SK**: `createdAt`
- **Projection**: ALL
- **Use Cases**:
  - List users by status with sorting
  - Get recently created active users
  - Filter suspended users from last month
- **Query Patterns**:
  - `status = "active" AND createdAt > "2026-01-01"`
  - `status = "suspended" ORDER BY createdAt DESC`

#### GSI-3: all-users-index

- **PK**: `entityType` (Fixed value: "USER")
- **SK**: `createdAt`
- **Projection**: ALL
- **Use Cases**:
  - List ALL users with pagination
  - Admin dashboard: show all users
- **Query Pattern**: `entityType = "USER" ORDER BY createdAt DESC`
- **Cost**: Efficient for up to ~100K users

## API Endpoints

- `POST /v1/users` - Create user
- `GET /v1/users/{userId}` - Get user by ID
- `GET /v1/users` - List users (paginated)
- `PATCH /v1/users/{userId}` - Update user
- `DELETE /v1/users/{userId}` - Delete user (soft delete)

## Security

- **Authentication**: JWT tokens
- **Authorization**: Role-based (customer, admin)
- **Encryption**:
  - At rest: DynamoDB encryption
  - In transit: TLS 1.3
- **Rate Limiting**: 100 req/min per IP

## Compliance

- **Data Classification**: PII (Personally Identifiable Information)
- **Retention**: 7 years for audit purposes
- **GDPR**: Right to deletion implemented via soft delete

## Development

### Local Setup

```bash

```
