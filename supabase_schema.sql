-- Supabase Database Schema for Admin Shahrayar Restaurant App
-- Run these SQL commands in your Supabase SQL Editor

-- Enable Row Level Security (RLS)
ALTER TABLE IF EXISTS customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS menu_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS staff ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS drivers ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS promotions ENABLE ROW LEVEL SECURITY;

-- Customers table
CREATE TABLE IF NOT EXISTS customers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  total_spent DECIMAL(10,2) DEFAULT 0.00,
  order_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Reviews table
CREATE TABLE IF NOT EXISTS reviews (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  customer_name VARCHAR(255) NOT NULL,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5) NOT NULL,
  comment TEXT,
  date VARCHAR(50) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Menu items table
CREATE TABLE IF NOT EXISTS menu_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE,
  price DECIMAL(8,2) NOT NULL,
  category VARCHAR(100) NOT NULL,
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Staff table
CREATE TABLE IF NOT EXISTS staff (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  role VARCHAR(50) NOT NULL CHECK (role IN ('Admin', 'Chef', 'Delivery', 'Cashier')),
  status VARCHAR(20) NOT NULL CHECK (status IN ('Active', 'Inactive')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Drivers table
CREATE TABLE IF NOT EXISTS drivers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  status VARCHAR(20) NOT NULL CHECK (status IN ('Available', 'OnDelivery', 'Offline')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Promotions table
CREATE TABLE IF NOT EXISTS promotions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  code VARCHAR(50) NOT NULL UNIQUE,
  description TEXT NOT NULL,
  discount_type VARCHAR(20) NOT NULL CHECK (discount_type IN ('Percentage', 'FixedAmount')),
  discount_value DECIMAL(10,2) NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Orders table
CREATE TABLE IF NOT EXISTS orders (
  id VARCHAR(50) PRIMARY KEY,
  customer VARCHAR(255) NOT NULL,
  status VARCHAR(20) NOT NULL CHECK (status IN ('Pending', 'Preparing', 'Completed', 'Cancelled')),
  type VARCHAR(20) NOT NULL CHECK (type IN ('Pickup', 'Delivery')),
  driver_id UUID REFERENCES drivers(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Order items table (for the items within each order)
CREATE TABLE IF NOT EXISTS order_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  order_id VARCHAR(50) REFERENCES orders(id) ON DELETE CASCADE,
  item_name VARCHAR(255) NOT NULL,
  quantity INTEGER NOT NULL,
  modifiers TEXT[] DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for better performance
CREATE INDEX IF NOT EXISTS idx_customers_total_spent ON customers(total_spent DESC);
CREATE INDEX IF NOT EXISTS idx_reviews_rating ON reviews(rating);
CREATE INDEX IF NOT EXISTS idx_menu_items_category ON menu_items(category);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_orders_customer ON orders(customer);
CREATE INDEX IF NOT EXISTS idx_staff_role ON staff(role);
CREATE INDEX IF NOT EXISTS idx_staff_status ON staff(status);
CREATE INDEX IF NOT EXISTS idx_drivers_status ON drivers(status);
CREATE INDEX IF NOT EXISTS idx_promotions_active ON promotions(is_active);

-- RLS Policies (allow all operations for authenticated users)
-- You may want to customize these based on your authentication requirements

-- Customers policies
CREATE POLICY "Allow all operations on customers" ON customers
  FOR ALL USING (true);

-- Reviews policies  
CREATE POLICY "Allow all operations on reviews" ON reviews
  FOR ALL USING (true);

-- Menu items policies
CREATE POLICY "Allow all operations on menu_items" ON menu_items
  FOR ALL USING (true);

-- Staff policies
CREATE POLICY "Allow all operations on staff" ON staff
  FOR ALL USING (true);

-- Drivers policies
CREATE POLICY "Allow all operations on drivers" ON drivers
  FOR ALL USING (true);

-- Promotions policies
CREATE POLICY "Allow all operations on promotions" ON promotions
  FOR ALL USING (true);

-- Orders policies
CREATE POLICY "Allow all operations on orders" ON orders
  FOR ALL USING (true);

-- Order items policies
CREATE POLICY "Allow all operations on order_items" ON order_items
  FOR ALL USING (true);

-- Insert some sample data
INSERT INTO customers (id, name, total_spent, order_count) VALUES
  ('c1', 'Jane Smith', 450.50, 12),
  ('c2', 'Mary Johnson', 380.00, 10),
  ('c3', 'John Doe', 250.75, 8),
  ('c4', 'Peter Jones', 180.25, 6)
ON CONFLICT (id) DO NOTHING;

INSERT INTO reviews (customer_name, rating, comment, date) VALUES
  ('Peter Jones', 5, 'The Classic Burger was amazing! Best in town. Fast pickup too.', '2 days ago'),
  ('Mike T.', 4, 'Delivery was quick and the food was still hot. The fries could have been a bit crispier though.', '3 days ago'),
  ('Guest User', 2, 'My pizza was cold when it arrived and the order took over an hour.', '4 days ago')
ON CONFLICT DO NOTHING;

INSERT INTO menu_items (name, price, category, image_url) VALUES
  ('Classic Burger', 12.99, 'Main Course', 'https://placehold.co/400x300/f87171/ffffff?text=Burger'),
  ('Margherita Pizza', 15.50, 'Main Course', 'https://placehold.co/400x300/fb923c/ffffff?text=Pizza'),
  ('Caesar Salad', 9.75, 'Appetizer', 'https://placehold.co/400x300/a3e635/ffffff?text=Salad'),
  ('Chocolate Lava Cake', 7.50, 'Dessert', 'https://placehold.co/400x300/7c3aed/ffffff?text=Cake'),
  ('Spaghetti Carbonara', 14.00, 'Main Course', 'https://placehold.co/400x300/38bdf8/ffffff?text=Pasta'),
  ('French Fries', 4.50, 'Sides', 'https://placehold.co/400x300/facc15/ffffff?text=Fries')
ON CONFLICT (name) DO NOTHING;

INSERT INTO staff (id, name, role, status) VALUES
  ('s1', 'Alex Morgan', 'Admin', 'Active'),
  ('s2', 'Ben Carter', 'Cashier', 'Active'),
  ('s3', 'David Chen', 'Delivery', 'Active'),
  ('s4', 'Sarah Kim', 'Chef', 'Inactive')
ON CONFLICT (id) DO NOTHING;

INSERT INTO drivers (id, name, status) VALUES
  ('d1', 'David Chen', 'Available'),
  ('d2', 'Sarah Kim', 'OnDelivery'),
  ('d3', 'Mike Ross', 'Offline')
ON CONFLICT (id) DO NOTHING;

INSERT INTO promotions (id, code, description, discount_type, discount_value, is_active) VALUES
  ('p1', 'SAVE20', '20% off entire order', 'Percentage', 20, true),
  ('p2', '5OFF', '$5 off orders over $50', 'FixedAmount', 5, true),
  ('p3', 'FREEDELIVERY', 'Free delivery on weekends', 'FixedAmount', 0, false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO orders (id, customer, status, type, driver_id, created_at) VALUES
  ('#84321', 'John Doe', 'Completed', 'Delivery', null, NOW() - INTERVAL '5 minutes'),
  ('#84320', 'Jane Smith', 'Pending', 'Pickup', null, NOW() - INTERVAL '3 days'),
  ('#84319', 'Peter Jones', 'Completed', 'Pickup', null, NOW() - INTERVAL '8 days'),
  ('#84318', 'Mary Johnson', 'Completed', 'Delivery', 'd2', NOW() - INTERVAL '40 days'),
  ('#84317', 'Chris Lee', 'Cancelled', 'Delivery', null, NOW() - INTERVAL '400 days')
ON CONFLICT (id) DO NOTHING;

INSERT INTO order_items (order_id, item_name, quantity, modifiers) VALUES
  ('#84321', 'Margherita Pizza', 1, '{}'),
  ('#84320', 'Classic Burger', 2, '{}'),
  ('#84319', 'Caesar Salad', 1, '{}'),
  ('#84318', 'Spaghetti Carbonara', 1, '{}'),
  ('#84317', 'Chocolate Lava Cake', 2, '{}')
ON CONFLICT DO NOTHING;
