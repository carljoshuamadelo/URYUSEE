-- URYUSEE E-Commerce Database Seed
-- Run this in your MySQL database to create tables and seed data

CREATE TABLE IF NOT EXISTS categories (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  slug VARCHAR(100) UNIQUE NOT NULL,
  description TEXT,
  product_count INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS products (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  sku VARCHAR(100) UNIQUE NOT NULL,
  barcode VARCHAR(100),
  category_id INT,
  description TEXT,
  cost_price DECIMAL(10,2) NOT NULL DEFAULT 0,
  price DECIMAL(10,2) NOT NULL DEFAULT 0,
  stock_qty INT NOT NULL DEFAULT 0,
  reorder_level INT NOT NULL DEFAULT 10,
  status ENUM('active', 'inactive', 'discontinued') DEFAULT 'active',
  image_url VARCHAR(500),
  sizes JSON,
  colors JSON,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS sales (
  id INT PRIMARY KEY AUTO_INCREMENT,
  sale_id VARCHAR(50) UNIQUE NOT NULL,
  customer_name VARCHAR(255),
  cashier_name VARCHAR(255) NOT NULL,
  total_amount DECIMAL(10,2) NOT NULL,
  discount_amount DECIMAL(10,2) DEFAULT 0,
  tax_amount DECIMAL(10,2) DEFAULT 0,
  payment_method VARCHAR(50),
  status ENUM('completed', 'pending', 'cancelled') DEFAULT 'completed',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS sale_items (
  id INT PRIMARY KEY AUTO_INCREMENT,
  sale_id INT,
  product_id INT,
  product_name VARCHAR(255) NOT NULL,
  quantity INT NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  total_price DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS inventory_movements (
  id INT PRIMARY KEY AUTO_INCREMENT,
  product_id INT,
  type ENUM('in', 'out', 'adjustment') NOT NULL,
  quantity INT NOT NULL,
  reason VARCHAR(255),
  reference_type VARCHAR(50),
  reference_id VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS purchase_orders (
  id INT PRIMARY KEY AUTO_INCREMENT,
  po_number VARCHAR(50) UNIQUE NOT NULL,
  supplier_name VARCHAR(255) NOT NULL,
  cashier_name VARCHAR(255),
  order_date DATE NOT NULL,
  received_date DATE,
  total_cost DECIMAL(10,2) NOT NULL DEFAULT 0,
  status ENUM('pending', 'received', 'cancelled') DEFAULT 'pending',
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS po_items (
  id INT PRIMARY KEY AUTO_INCREMENT,
  po_id INT,
  product_name VARCHAR(255) NOT NULL,
  qty_ordered INT NOT NULL,
  qty_received INT DEFAULT 0,
  unit_cost DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (po_id) REFERENCES purchase_orders(id) ON DELETE CASCADE
);

-- Seed Categories
INSERT INTO categories (name, slug, description, product_count) VALUES
('TEES', 'tees', 'T-shirts, hoodies, and casual tops', 24),
('BOTTOMS', 'bottoms', 'Jeans, shorts, and casual bottoms', 18),
('ESSENTIALS', 'essentials', 'Underwear, socks, and basic accessories', 32),
('OUTERWEAR', 'outerwear', 'Jackets, coats, and seasonal outerwear', 15);

-- Seed Products
INSERT INTO products (name, sku, barcode, category_id, description, cost_price, price, stock_qty, reorder_level, status, image_url, sizes, colors) VALUES
('Classic White Tee', 'TEE001', '1234567890123', 1, 'Premium cotton white t-shirt', 150.00, 299.00, 45, 20, 'active', 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800&q=80', '["XS","S","M","L","XL","XXL"]', '["White","Black","Gray"]'),
('Black Denim Jeans', 'BOT001', '1234567890124', 2, 'Slim fit black denim jeans', 280.00, 599.00, 32, 15, 'active', 'https://images.unsplash.com/photo-1542272617-08f086302542?w=800&q=80', '["28","30","32","34","36"]', '["Black","Blue"]'),
('Essential Cotton Boxer', 'ESS001', '1234567890125', 3, 'Comfortable cotton boxer briefs', 80.00, 159.00, 67, 30, 'active', 'https://images.unsplash.com/photo-1584370848010-d7cc637611f7?w=800&q=80', '["S","M","L","XL"]', '["White","Black","Gray"]'),
('Urban Bomber Jacket', 'OUT001', '1234567890126', 4, 'Stylish urban bomber jacket', 450.00, 899.00, 18, 10, 'active', 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=800&q=80', '["S","M","L","XL"]', '["Black","Olive","Navy"]'),
('Graphic Street Tee', 'TEE002', '1234567890127', 1, 'Urban graphic print t-shirt', 120.00, 249.00, 38, 15, 'active', 'https://images.unsplash.com/photo-1503341504253-dff4815485f1?w=800&q=80', '["S","M","L","XL"]', '["Black","White","Red"]'),
('Chino Shorts', 'BOT002', '1234567890128', 2, 'Casual chino shorts', 180.00, 349.00, 25, 12, 'active', 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=800&q=80', '["28","30","32","34"]', '["Khaki","Navy","Olive"]');

-- Seed Sales
INSERT INTO sales (sale_id, customer_name, cashier_name, total_amount, discount_amount, tax_amount, payment_method, status, created_at) VALUES
('SALE001', 'John Doe', 'Juan Dela Cruz', 299.00, 0, 0, 'Cash', 'completed', '2025-04-20 10:30:00'),
('SALE002', 'Jane Smith', 'Juan Dela Cruz', 598.00, 50, 0, 'Card', 'completed', '2025-04-20 14:15:00'),
('SALE003', NULL, 'Ana Garcia', 159.00, 0, 0, 'Cash', 'completed', '2025-04-21 09:45:00'),
('SALE004', 'Mike Johnson', 'Juan Dela Cruz', 1198.00, 100, 0, 'Card', 'completed', '2025-04-21 16:20:00');

-- Seed Sale Items
INSERT INTO sale_items (sale_id, product_id, product_name, quantity, unit_price, total_price) VALUES
(1, 1, 'Classic White Tee', 1, 299.00, 299.00),
(2, 1, 'Classic White Tee', 2, 299.00, 598.00),
(3, 3, 'Essential Cotton Boxer', 1, 159.00, 159.00),
(4, 4, 'Urban Bomber Jacket', 1, 899.00, 899.00),
(4, 2, 'Black Denim Jeans', 1, 299.00, 299.00);

-- Seed Purchase Orders
INSERT INTO purchase_orders (po_number, supplier_name, cashier_name, order_date, received_date, total_cost, status, notes) VALUES
('PO001', 'Urban Fashion Supply Co.', 'John Doe', '2025-04-15', '2025-04-18', 12500.00, 'received', 'Regular restock'),
('PO002', 'Premium Textiles Ltd.', 'Jane Smith', '2025-04-16', NULL, 8750.00, 'pending', 'Urgent order'),
('PO003', 'Fashion Forward Inc.', 'Mike Johnson', '2025-04-14', '2025-04-14', 15600.00, 'cancelled', 'Cancelled due to quality issues');

-- Seed PO Items
INSERT INTO po_items (po_id, product_name, qty_ordered, qty_received, unit_cost) VALUES
(1, 'Classic White Tee', 100, 98, 125.00),
(1, 'Black Denim Jeans', 50, 50, 280.00),
(2, 'Essential Cotton Boxer', 75, 0, 117.00),
(3, 'Urban Bomber Jacket', 25, 0, 624.00);

-- Seed Inventory Movements
INSERT INTO inventory_movements (product_id, type, quantity, reason, reference_type, reference_id) VALUES
(1, 'in', 100, 'Purchase order received', 'po', 'PO001'),
(1, 'out', 3, 'Sales', 'sale', 'SALE001'),
(2, 'in', 50, 'Purchase order received', 'po', 'PO001'),
(2, 'out', 1, 'Sales', 'sale', 'SALE004'),
(3, 'in', 75, 'Purchase order', 'po', 'PO002'),
(3, 'out', 1, 'Sales', 'sale', 'SALE003'),
(4, 'in', 25, 'Initial stock', 'adjustment', NULL),
(4, 'out', 1, 'Sales', 'sale', 'SALE004');
