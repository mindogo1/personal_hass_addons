# Tracktor add-on

## 0.4.4

**Highlights:** 🚀 VIN display fix, vehicle images in cards, stronger backend logging & validation, tests added, and a breaking auth route rename.

**What's new**
- 🖼️ Frontend: Vehicle images are now supported and displayed in the vehicle card — richer UI.
- 🧾 Backend: Added structured logging using Winston for clearer, searchable logs.
- ✅ Common: Multi-environment configuration added (dev/staging/prod) for safer deployments.

**Improvements**
- 🔍 Frontend: Fixed VIN number display so VINs render correctly in the UI.
- 🔁 Frontend: Added a fetch wrapper to standardize API calls (consistent error handling, headers, etc.).
- 🏬 Frontend: Migrated to class-based stores for more consistent data fetching and state usage.
- 🧰 Backend: Added data validation via a common wrapper at the route level (improves request validation & reduces duplicate code).
- ↕️ Backend: Added secondary sort for fuel logs filled on the same day (stable, predictable ordering).

**Testing**
- 🧪 Frontend: Added frontend helper tests.
- 🔬 Backend: Added backend API tests.

**Breaking changes / Migration notes**
- ⚠️ Backend: Auth route renamed from /api/pin to /api/auth — update any clients, integrations, or documentation to use /api/auth. This is a breaking change for consumers calling the old endpoint.

**Developer / Ops notes**
- 🔧 Logging: Winston configuration is in place — ensure log aggregation/forwarding is updated if you rely on a specific log format or transport.
- ♻️ Validation: Route-level validation wrapper centralizes schema checks — review any custom per-route validation that may now be redundant.
- 🌐 Environments: Multi-environment config requires environment-specific variables; verify CI/CD and deployment configs contain the new keys.

**Recommended actions**
- Update all clients/integrations to use /api/auth instead of /api/pin.
- Verify logging/monitoring dashboards post-deploy (Winston format).
- Run full regression focusing on vehicle cards (VIN and images) and fuel log ordering.
- Confirm environment variables for each environment are present before deploying.

[View on GitHub](https://github.com/javedh-dev/tracktor/releases/tag/0.4.4)
