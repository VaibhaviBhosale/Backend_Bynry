-- Companies
CREATE TABLE companies (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
);

-- Warehouses
CREATE TABLE warehouses (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    company_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
);

-- Products
CREATE TABLE products (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    company_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    sku VARCHAR(100) NOT NULL,
    price DECIMAL(10,2),
    is_bundle BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    UNIQUE KEY uk_company_sku (company_id, sku)
);

-- Inventory (stock per product per warehouse)
CREATE TABLE inventory (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    product_id BIGINT NOT NULL,
    warehouse_id BIGINT NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id) ON DELETE CASCADE,
    UNIQUE KEY uk_product_warehouse (product_id, warehouse_id)
);

-- Inventory history (audit trail)
CREATE TABLE inventory_history (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    inventory_id BIGINT NOT NULL,
    old_quantity INT NOT NULL,
    new_quantity INT NOT NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (inventory_id) REFERENCES inventory(id) ON DELETE CASCADE
);

-- Suppliers
CREATE TABLE suppliers (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    company_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    contact_email VARCHAR(255),
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
);

-- Product–Supplier mapping (many-to-many)
CREATE TABLE product_suppliers (
    product_id BIGINT NOT NULL,
    supplier_id BIGINT NOT NULL,
    PRIMARY KEY (product_id, supplier_id),
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE CASCADE
);

-- Product bundles (parent–child relationship)
CREATE TABLE product_bundles (
    parent_product_id BIGINT NOT NULL,
    child_product_id BIGINT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    PRIMARY KEY (parent_product_id, child_product_id),
    FOREIGN KEY (parent_product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (child_product_id) REFERENCES products(id) ON DELETE CASCADE
);