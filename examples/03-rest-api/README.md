# REST API Example

**Example Level**: 3 (Moderate)
**Language**: Python/Flask or Node/Express
**Purpose**: Multi-tier system with persistence and API design

---

## Overview

This example builds a REST API for a todo list application with SQLite persistence.

**Why this example?**
- ✅ Real-world patterns (API, database, authentication)
- ✅ Multiple layers (routes, services, data)
- ✅ API design best practices
- ✅ Testing strategies for APIs
- ✅ Still manageable to study completely

---

## What You'll Learn

1. **API design**: RESTful endpoints, HTTP methods, status codes
2. **Layered architecture**: Routes → Services → Data access
3. **Persistence**: Database schema, migrations, queries
4. **Authentication**: Basic auth or JWT tokens
5. **Testing APIs**: Unit tests, integration tests, API tests
6. **Documentation**: API documentation (OpenAPI/Swagger)

---

## Features

- **CRUD operations**: Create, read, update, delete todos
- **SQLite database**: Simple persistence layer
- **Authentication**: User authentication and authorization
- **Input validation**: Request validation, error handling
- **API documentation**: OpenAPI/Swagger spec
- **Comprehensive tests**: Unit, integration, and API tests

---

## Structure

```
03-rest-api/
├── README.md                          # This file
├── specs/                             # What to build
│   ├── api-spec.md                    # API requirements
│   └── contracts/
│       └── openapi.yaml               # API contract
├── steps/                             # How to build (20 steps)
│   ├── api-step_000000000000.md       # Step 0: Build config
│   ├── api-step_478a8c4b0cef.md       # Step 1: Project structure
│   ├── api-step_c5404152680d.md       # Step 2: Database schema
│   ├── api-step_89b9e6233da5.md       # Step 3: Data models
│   ├── api-step_a1b2c3d4e5f6.md       # Step 4: Database layer
│   ├── ...                            # Steps 5-16: Implementation
│   ├── api-step_f6a1b2c3d4e5.md       # Step 17: Unit tests
│   ├── api-step_a2b3c4d5e6f7.md       # Step 18: Integration tests
│   ├── api-step_b3c4d5e6f7a8.md       # Step 19: API tests
│   └── api-step_c4d5e6f7a8b9.md       # Step 20: Verification + docs
└── builds/
    └── demo/                          # Example build output
        ├── src/
        │   ├── routes/
        │   ├── services/
        │   ├── models/
        │   └── db/
        ├── tests/
        ├── README.md
        └── openapi.yaml
```

---

## API Endpoints

```
POST   /api/auth/register      # Create new user
POST   /api/auth/login         # Login (get token)

GET    /api/todos              # List all todos
POST   /api/todos              # Create todo
GET    /api/todos/:id          # Get specific todo
PUT    /api/todos/:id          # Update todo
DELETE /api/todos/:id          # Delete todo
```

---

## Example Usage

```bash
# Register user
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username": "user1", "password": "pass123"}'

# Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "user1", "password": "pass123"}'
# Returns: {"token": "eyJhbGc..."}

# Create todo
curl -X POST http://localhost:3000/api/todos \
  -H "Authorization: Bearer eyJhbGc..." \
  -H "Content-Type: application/json" \
  -d '{"title": "Buy milk", "completed": false}'

# List todos
curl -X GET http://localhost:3000/api/todos \
  -H "Authorization: Bearer eyJhbGc..."
```

---

## Status

🚧 **Coming Soon**

This example is a placeholder in the YBS v2.0.0 restructure. Content will be added in a future update.

---

## Next Steps

After completing this example:
1. **Study**: [04-claude-chat](../04-claude-chat/) - Production complexity
2. **Apply**: Build your own API-based system
3. **Extend**: Add features (pagination, filtering, sorting)

---

## References

- **Examples Overview**: [../README.md](../README.md)
- **Previous**: [02-calculator](../02-calculator/) - Learn multi-module first
- **API Design**: See industry best practices (REST, OpenAPI)
- **Contract-Driven Development**: [../../scratch/ybs-practical-modular-approach.md](../../scratch/ybs-practical-modular-approach.md)
