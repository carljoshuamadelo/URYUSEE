-- Add required categories for URYUSEE
-- Run this in your MySQL database

INSERT IGNORE INTO categories (name, slug, description) VALUES
('TEES', 'tees', 'T-Shirts and tops collection'),
('BOTTOMS', 'bottoms', 'Pants, shorts and bottoms collection'),
('ESSENTIALS', 'essentials', 'Basic essentials and everyday wear'),
('ACCESSORIES', 'accessories', 'Accessories and complementary items'),
('OUTERWEAR', 'outerwear', 'Jackets, hoodies and outerwear collection');
