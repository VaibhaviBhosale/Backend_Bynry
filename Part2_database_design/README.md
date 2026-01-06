# Part 2: Database Design

## 1. Design Approach

The database schema is designed with the following considerations:

- A company can operate multiple warehouses.
- A product may exist in multiple warehouses with different stock levels.
- Inventory changes must be auditable over time.
- Suppliers can provide products to companies.
- Some products can be bundles composed of other products.

---

## 2. Key Design Decisions & Constraints

- **Company-level SKU uniqueness**  
  The combination of `(company_id, sku)` is unique, allowing different companies to reuse the same SKU format.

- **One inventory record per product per warehouse**  
  Enforced using a composite unique key on `(product_id, warehouse_id)`.

- **Auditability of stock changes**  
  Inventory changes are tracked in a separate `inventory_history` table to preserve historical data.

- **Cascade deletes for ownership hierarchy**  
  Deleting a company automatically removes its warehouses, products, inventory, and suppliers.

- **Bundle support using self-referencing table**  
  The `product_bundles` table allows flexible definition of bundled products.

---

## 3. Missing Requirements (Questions for Product Team)

The given requirements leave several open questions that should be clarified:

- Should SKUs be unique globally or only within a company?
- Can a supplier provide products to multiple companies?
- What events should trigger inventory history entries (sales, restocks, manual adjustments)?
- Are nested bundles (bundles inside bundles) allowed?
- Should inventory changes track who performed the action (user vs system)?
- How is “low stock” defined for alerts (absolute value, percentage, or recent sales)?
- Are warehouses shared across companies or strictly isolated?

---