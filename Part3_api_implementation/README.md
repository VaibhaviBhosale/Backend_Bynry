# Part 3: Low-Stock Alerts API

## Overview
- Implements an API to identify low-stock products for a company.
- Designed to support multi-warehouse inventory systems.
- Focuses on production-ready logic and clean API responses.

## Assumptions
- Database schema follows the design from Part 2.
- Low-stock threshold is defined per product.
- Only products with sales in the last 30 days are considered.
- A company can operate multiple warehouses.
- Supplier information is optional.
- Authentication is handled externally.

## Business Rules Implemented
- Alerts are generated only when current stock falls below the defined threshold.
- Products without recent sales activity are excluded.
- Stock calculations are done per warehouse.
- Supplier details are included to support reordering.

## Edge Cases Handled
- Invalid company ID → returns 400 Bad Request.
- No recent sales → product excluded from alerts.
- Zero sales rate → days_until_stockout set to null.
- Missing supplier → supplier returned as null.
- Database failures → safe 500 response with logging.

## Approach
- REST API implemented using Node.js and Express.
- Single optimized SQL query to fetch all required data.
- Average daily sales used to estimate days until stockout.
- Simple and readable logic for easier maintenance.