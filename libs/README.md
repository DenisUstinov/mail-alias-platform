# Shared Libraries

This folder contains internal Python libraries and reusable code for **mail-alias-platform**.

## Purpose
- Provide common utilities across services
- Ensure consistent domain models
- Reduce duplication of API clients and helpers

## Typical Contents
- **Clients** — wrappers for external APIs (e.g., mail provider)
- **Models** — Pydantic and ORM models shared between services
- **Utils** — common functions (logging, validation, etc.)
- **Auth** — JWT/OIDC helpers for authentication

Each library should be:
- Self-contained
- Versioned properly
- Tested before being used by services
