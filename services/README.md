# Services

This folder contains microservices of **mail-alias-platform**.

## Current Services
- **api/** — FastAPI service exposing REST API to clients
- **mail-storage/** — service for storing, retrieving, and forwarding emails
- **mcp/** — LLM-based processing and analysis service
- **auth/** (planned) — external authentication via Keycloak

## Service Guidelines
- Each service must have:
  - `README.md` with its purpose and setup
  - Independent dependencies (`pyproject.toml`)
  - Dockerfile for containerization
  - CI configuration if required

## Future Extensions
- **billing/** — manage subscriptions and payment plans
- **gateway/** — API Gateway for unified entry point
- **monitoring/** — observability services
