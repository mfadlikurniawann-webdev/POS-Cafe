-- POS Cafe Database Schema
-- Run this on your Neon.tech database

-- Categories
CREATE TABLE IF NOT EXISTS categories (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  icon VARCHAR(10) DEFAULT '☕',
  color VARCHAR(7) DEFAULT '#4A2C17',
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Products / Menu Items
CREATE TABLE IF NOT EXISTS products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  description TEXT,
  price DECIMAL(12, 0) NOT NULL,
  category_id INTEGER REFERENCES categories(id) ON DELETE SET NULL,
  image_url VARCHAR(500),
  is_available BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Orders
CREATE TABLE IF NOT EXISTS orders (
  id SERIAL PRIMARY KEY,
  order_number VARCHAR(30) UNIQUE NOT NULL,
  status VARCHAR(20) DEFAULT 'completed' CHECK (status IN ('pending', 'processing', 'completed', 'cancelled')),
  total_amount DECIMAL(12, 0) NOT NULL,
  tax_amount DECIMAL(12, 0) DEFAULT 0,
  discount_amount DECIMAL(12, 0) DEFAULT 0,
  payment_method VARCHAR(20) DEFAULT 'cash' CHECK (payment_method IN ('cash', 'card', 'qris', 'transfer')),
  payment_amount DECIMAL(12, 0),
  change_amount DECIMAL(12, 0) DEFAULT 0,
  customer_name VARCHAR(100),
  table_number VARCHAR(20),
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  completed_at TIMESTAMP WITH TIME ZONE
);

-- Order Items
CREATE TABLE IF NOT EXISTS order_items (
  id SERIAL PRIMARY KEY,
  order_id INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id INTEGER REFERENCES products(id) ON DELETE SET NULL,
  product_name VARCHAR(200) NOT NULL,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  unit_price DECIMAL(12, 0) NOT NULL,
  subtotal DECIMAL(12, 0) NOT NULL,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_available ON products(is_available);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at);
CREATE INDEX IF NOT EXISTS idx_order_items_order ON order_items(order_id);

-- Sample Categories
INSERT INTO categories (name, icon, color, sort_order) VALUES
  ('Kopi', '☕', '#4A2C17', 1),
  ('Non-Kopi', '🧋', '#1B5E20', 2),
  ('Makanan', '🍽️', '#E65100', 3),
  ('Snack', '🍪', '#F57F17', 4),
  ('Dessert', '🍰', '#880E4F', 5)
ON CONFLICT DO NOTHING;

-- Sample Products
INSERT INTO products (name, description, price, category_id, is_available) VALUES
  ('Espresso', 'Shot espresso murni yang kuat dan bold', 18000, 1, true),
  ('Americano', 'Espresso dengan tambahan air panas', 22000, 1, true),
  ('Cappuccino', 'Espresso dengan steamed milk dan thick foam', 28000, 1, true),
  ('Caffe Latte', 'Espresso dengan susu steamed yang lembut dan creamy', 30000, 1, true),
  ('Flat White', 'Double shot espresso dengan microfoam susu', 32000, 1, true),
  ('Cold Brew', 'Kopi cold brew 12 jam, smooth dan refreshing', 35000, 1, true),
  ('Matcha Latte', 'Matcha premium Jepang dengan susu pilihan', 35000, 2, true),
  ('Taro Latte', 'Taro creamy dengan susu segar', 35000, 2, true),
  ('Chocolate', 'Dark chocolate premium dengan susu panas', 30000, 2, true),
  ('Strawberry Tea', 'Teh segar dengan ekstrak strawberry', 28000, 2, true),
  ('Croissant', 'Croissant butter original, renyah dan lembut', 25000, 3, true),
  ('Club Sandwich', 'Sandwich dengan ayam panggang, telur, dan sayuran segar', 48000, 3, true),
  ('French Toast', 'Roti panggang dengan sirup maple dan buah', 35000, 3, true),
  ('Banana Bread', 'Roti pisang homemade yang lembut', 22000, 4, true),
  ('Cookies', 'Cookies chocolate chip double', 18000, 4, true),
  ('Brownie', 'Fudgy brownie dengan topping walnut', 25000, 4, true),
  ('Cheesecake', 'New York cheesecake premium dengan blueberry', 45000, 5, true),
  ('Tiramisu', 'Tiramisu klasik Italia dengan espresso dan mascarpone', 42000, 5, true),
  ('Panna Cotta', 'Panna cotta vanilla dengan saus strawberry', 38000, 5, true)
ON CONFLICT DO NOTHING;
