# Part 1: Code Review & Debugging

## 1. Issues Identified

- No input validation (crashes on missing fields).
- SKU uniqueness not enforced (duplicates allowed).
- Product tied to one warehouse, but business requires multi-warehouse support.
- Two separate commits risk inconsistent state (product saved, inventory lost).
- No error handling or rollback on failure.

## 2. Production Impact

- Server crashes on bad requests.
- Duplicate SKUs cause inventory and fulfillment errors.
- Can't track the same product across multiple warehouses.
- Orphaned product records if inventory creation fails.
- Users see generic 500 errors instead of helpful messages.

## 3. Fixes Applied

- Removed `warehouse_id` from `Product` — products are now warehouse-agnostic.
- Used one transaction with `flush()` and a single `commit()` to ensure atomicity.
- Validated required and optional fields, returning clear `400 Bad Request` responses.
- Caught `IntegrityError` for duplicate SKUs and returned `409 Conflict`.
- Created `Inventory` only when `warehouse_id` is provided to support flexible onboarding.
