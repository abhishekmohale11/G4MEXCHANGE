-- Create Database if not exists
CREATE DATABASE IF NOT EXISTS g4mexchange;
USE g4mexchange;

-- Drop existing tables if they exist (to start fresh)
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS items;
DROP TABLE IF EXISTS users;

-- Users Table
CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50) DEFAULT 'India',
    gaming_platform VARCHAR(50),
    preferred_game VARCHAR(100),
    role ENUM('buyer', 'seller') DEFAULT 'buyer',
    trust_score INT DEFAULT 0,
    total_transactions INT DEFAULT 0,
    successful_transactions INT DEFAULT 0,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    INDEX idx_username (username),
    INDEX idx_email (email)
);

-- Items Table
CREATE TABLE IF NOT EXISTS items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    seller_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    category ENUM('Console', 'Game', 'Accessory', 'Other') NOT NULL,
    console_type ENUM('PS4', 'PS5', 'Xbox', 'Nintendo', 'PC', 'Other') NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    listing_type ENUM('sell', 'rent') NOT NULL,
    item_condition ENUM('new', 'like-new', 'good', 'fair') DEFAULT 'good',
    images TEXT,
    location VARCHAR(100),
    is_negotiable BOOLEAN DEFAULT FALSE,
    views INT DEFAULT 0,
    status ENUM('active', 'sold', 'rented', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (seller_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_status (status),
    INDEX idx_category (category)
);

-- Transactions Table
CREATE TABLE IF NOT EXISTS transactions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    transaction_id VARCHAR(50) UNIQUE,
    item_id INT NOT NULL,
    buyer_id INT NOT NULL,
    seller_id INT NOT NULL,
    transaction_type ENUM('buy', 'rent') NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    trans_status ENUM('pending', 'completed', 'cancelled', 'returned') DEFAULT 'pending',
    payment_status ENUM('pending', 'paid', 'failed') DEFAULT 'pending',
    rent_start_date DATE,
    rent_end_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (item_id) REFERENCES items(id),
    FOREIGN KEY (buyer_id) REFERENCES users(id),
    FOREIGN KEY (seller_id) REFERENCES users(id)
);

-- Reviews Table
CREATE TABLE IF NOT EXISTS reviews (
    id INT PRIMARY KEY AUTO_INCREMENT,
    transaction_id INT NOT NULL,
    reviewer_id INT NOT NULL,
    reviewee_id INT NOT NULL,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (transaction_id) REFERENCES transactions(id),
    FOREIGN KEY (reviewer_id) REFERENCES users(id),
    FOREIGN KEY (reviewee_id) REFERENCES users(id)
);

USE g4mexchange;

CREATE TABLE IF NOT EXISTS payments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    username VARCHAR(50) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_type ENUM('wallet_add', 'direct_purchase') NOT NULL,
    transaction_id VARCHAR(50) NULL,
    card_number_last4 VARCHAR(4) NOT NULL,
    card_type VARCHAR(20) NOT NULL,
    card_holder_name VARCHAR(100) NOT NULL,
    payment_status ENUM('success', 'failed') DEFAULT 'success',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Insert Sample Users (password: demo123)
INSERT INTO users (id, username, email, phone, password, full_name, city, gaming_platform, preferred_game, role, trust_score, is_verified) VALUES
(1, 'gamer_alex', 'alex@g4mexchange.com', '9876543210', '$2a$10$rVqZqZqZqZqZqZqZqZqZu', 'Alex Kumar', 'Mumbai', 'PlayStation', 'God of War', 'seller', 85, TRUE),
(2, 'retro_mike', 'mike@g4mexchange.com', '9876543211', '$2a$10$rVqZqZqZqZqZqZqZqZqZu', 'Mike Singh', 'Delhi', 'Xbox', 'Halo', 'seller', 92, TRUE),
(3, 'game_master', 'master@g4mexchange.com', '9876543212', '$2a$10$rVqZqZqZqZqZqZqZqZqZu', 'Sarah Chen', 'Bangalore', 'PC', 'Valorant', 'seller', 78, TRUE),
(4, 'retro_gamer', 'retro@g4mexchange.com', '9876543213', '$2a$10$rVqZqZqZqZqZqZqZqZqZu', 'John Doe', 'Chennai', 'Nintendo', 'Zelda', 'seller', 95, TRUE),
(5, 'xbox_fan', 'xbox@g4mexchange.com', '9876543214', '$2a$10$rVqZqZqZqZqZqZqZqZqZu', 'David Miller', 'Hyderabad', 'Xbox', 'Forza', 'seller', 88, TRUE);

-- Insert Items
INSERT INTO items (seller_id, title, category, console_type, description, price, listing_type, item_condition, location, views, status) VALUES
-- PlayStation Items
(1, 'PS5 Digital Edition', 'Console', 'PS5', 'Brand new PS5 Digital Edition, never opened', 449.99, 'sell', 'new', 'Mumbai', 0, 'active'),
(1, 'Spider-Man 2', 'Game', 'PS5', 'Limited Edition, includes digital code', 59.99, 'sell', 'new', 'Mumbai', 0, 'active'),
(1, 'PS5 DualSense Controller', 'Accessory', 'PS5', 'Galactic Purple, barely used', 49.99, 'sell', 'like-new', 'Mumbai', 0, 'active'),
(3, 'The Last of Us Part 1', 'Game', 'PS5', 'Complete edition with steelbook', 54.99, 'sell', 'like-new', 'Bangalore', 0, 'active'),
(3, 'PS5 Charging Station', 'Accessory', 'PS5', 'Official Sony charging dock', 29.99, 'sell', 'new', 'Bangalore', 0, 'active'),
-- Xbox Items
(2, 'Xbox Series X', 'Console', 'Xbox', 'Excellent condition, 1TB storage', 499.99, 'sell', 'like-new', 'Delhi', 0, 'active'),
(2, 'Halo Infinite', 'Game', 'Xbox', 'Campaign edition, like new', 39.99, 'sell', 'like-new', 'Delhi', 0, 'active'),
(5, 'Xbox Game Pass Ultimate', 'Game', 'Xbox', '3 months subscription', 44.99, 'sell', 'new', 'Hyderabad', 0, 'active'),
(5, 'Xbox Wireless Controller', 'Accessory', 'Xbox', 'Carbon Black, like new', 54.99, 'sell', 'like-new', 'Hyderabad', 0, 'active'),
(5, 'Forza Horizon 5', 'Game', 'Xbox', 'Premium Edition', 49.99, 'rent', 'good', 'Hyderabad', 0, 'active'),
-- Nintendo Items
(4, 'Nintendo Switch OLED', 'Console', 'Nintendo', 'White edition, with screen protector', 349.99, 'sell', 'like-new', 'Chennai', 0, 'active'),
(4, 'The Legend of Zelda: Tears of the Kingdom', 'Game', 'Nintendo', 'Collectors edition', 64.99, 'sell', 'new', 'Chennai', 0, 'active'),
(4, 'Super Mario Odyssey', 'Game', 'Nintendo', 'Good condition, cartridge only', 39.99, 'sell', 'good', 'Chennai', 0, 'active'),
(4, 'Nintendo Switch Pro Controller', 'Accessory', 'Nintendo', 'Official controller, great condition', 59.99, 'sell', 'like-new', 'Chennai', 0, 'active'),
-- PC Items
(3, 'RTX 3060 Gaming PC', 'Console', 'PC', 'i5-12400F, 16GB RAM, 1TB SSD', 899.99, 'sell', 'good', 'Bangalore', 0, 'active'),
(3, 'Logitech G502 Hero', 'Accessory', 'PC', 'Gaming mouse, like new', 34.99, 'sell', 'like-new', 'Bangalore', 0, 'active'),
(3, 'Valorant Points 5000', 'Game', 'PC', 'Digital code for Valorant', 49.99, 'sell', 'new', 'Bangalore', 0, 'active'),
(1, 'Mechanical Keyboard', 'Accessory', 'PC', 'RGB Mechanical Keyboard', 79.99, 'sell', 'like-new', 'Mumbai', 0, 'active'),
-- PS4 Items
(1, 'PS4 Slim 500GB', 'Console', 'PS4', 'Good condition, one controller', 199.99, 'sell', 'good', 'Mumbai', 0, 'active'),
(1, 'God of War Ragnarok', 'Game', 'PS4', 'Complete edition, like new', 49.99, 'sell', 'like-new', 'Mumbai', 0, 'active'),
(1, 'DualShock 4 Controller', 'Accessory', 'PS4', 'Official Sony controller', 45.00, 'rent', 'good', 'Mumbai', 0, 'active'),
(1, 'Ghost of Tsushima', 'Game', 'PS4', 'Director\'s Cut', 39.99, 'sell', 'like-new', 'Mumbai', 0, 'active'),
-- More Accessories
(2, 'Gaming Headset', 'Accessory', 'Other', 'Surround sound, RGB lighting', 89.99, 'sell', 'like-new', 'Delhi', 0, 'active'),
(3, 'Elgato Stream Deck', 'Accessory', 'PC', '15 keys, barely used', 149.99, 'sell', 'like-new', 'Bangalore', 0, 'active'),
(4, 'Capture Card', 'Accessory', 'Other', '1080p 60fps recording', 129.99, 'sell', 'good', 'Chennai', 0, 'active');

SELECT '✅ Database setup complete!' AS Status;
SELECT COUNT(*) as total_users FROM users;
SELECT COUNT(*) as total_items FROM items;

-- Insert more items with all sellers
INSERT INTO items (seller_id, title, category, console_type, description, price, listing_type, item_condition, location, views, status) VALUES

-- ============ gamer_alex (ID: 1) - More PlayStation Items ============
(1, 'PS5 Spider-Man 2 Limited Edition', 'Console', 'PS5', 'Limited edition Spider-Man 2 console with matching controller', 699.99, 'sell', 'new', 'Mumbai', 0, 'active'),
(1, 'Final Fantasy XVI', 'Game', 'PS5', 'Deluxe Edition with steelbook', 54.99, 'sell', 'like-new', 'Mumbai', 0, 'active'),
(1, 'PS5 Console Cover - Volcanic Red', 'Accessory', 'PS5', 'Official Sony console cover', 54.99, 'sell', 'new', 'Mumbai', 0, 'active'),
(1, 'Demon\'s Souls', 'Game', 'PS5', 'Launch title, great condition', 39.99, 'sell', 'good', 'Mumbai', 0, 'active'),
(1, 'Ratchet & Clank: Rift Apart', 'Game', 'PS5', 'Like new, played once', 34.99, 'sell', 'like-new', 'Mumbai', 0, 'active'),
(1, 'PS5 Media Remote', 'Accessory', 'PS5', 'Official remote for streaming', 29.99, 'sell', 'new', 'Mumbai', 0, 'active'),
(1, 'Gran Turismo 7', 'Game', 'PS5', '25th Anniversary Edition', 49.99, 'rent', 'like-new', 'Mumbai', 0, 'active'),
(1, 'PS5 Cooling Fan Stand', 'Accessory', 'PS5', 'RGB cooling stand with charger', 39.99, 'sell', 'new', 'Mumbai', 0, 'active'),

-- ============ retro_mike (ID: 2) - More Xbox Items ============
(2, 'Xbox Series X Halo Infinite Edition', 'Console', 'Xbox', 'Limited edition Halo Infinite console', 749.99, 'sell', 'like-new', 'Delhi', 0, 'active'),
(2, 'Microsoft Flight Simulator', 'Game', 'Xbox', 'Premium Deluxe Edition', 89.99, 'sell', 'new', 'Delhi', 0, 'active'),
(2, 'Xbox Rechargeable Battery Pack', 'Accessory', 'Xbox', 'Official 2-pack', 24.99, 'sell', 'new', 'Delhi', 0, 'active'),
(2, 'Redfall', 'Game', 'Xbox', 'Bite Back Edition', 49.99, 'sell', 'new', 'Delhi', 0, 'active'),
(2, 'Xbox Storage Expansion Card 1TB', 'Accessory', 'Xbox', 'Seagate official', 149.99, 'sell', 'new', 'Delhi', 0, 'active'),
(2, 'Age of Empires IV', 'Game', 'Xbox', 'Anniversary Edition', 39.99, 'rent', 'like-new', 'Delhi', 0, 'active'),
(2, 'Xbox Controller - Electric Volt', 'Accessory', 'Xbox', 'Official controller', 64.99, 'sell', 'new', 'Delhi', 0, 'active'),
(2, 'Hi-Fi Rush', 'Game', 'Xbox', 'Digital code', 29.99, 'sell', 'like-new', 'Delhi', 0, 'active'),

-- ============ game_master (ID: 3) - More PC Items ============
(3, 'Custom Gaming PC - RTX 4080', 'Console', 'PC', 'i9-13900K, RTX 4080, 64GB DDR5', 3499.99, 'sell', 'new', 'Bangalore', 0, 'active'),
(3, 'Baldur\'s Gate 3', 'Game', 'PC', 'Digital Deluxe Edition', 59.99, 'sell', 'new', 'Bangalore', 0, 'active'),
(3, 'ASUS ROG Swift 32" 4K OLED', 'Accessory', 'PC', '240Hz OLED gaming monitor', 1299.99, 'sell', 'new', 'Bangalore', 0, 'active'),
(3, 'Cyberpunk 2077: Phantom Liberty', 'Game', 'PC', 'Ultimate Edition', 49.99, 'sell', 'like-new', 'Bangalore', 0, 'active'),
(3, 'Logitech G915 X Lightspeed', 'Accessory', 'PC', 'Wireless mechanical keyboard', 229.99, 'sell', 'like-new', 'Bangalore', 0, 'active'),
(3, 'Star Wars Jedi: Survivor', 'Game', 'PC', 'Deluxe Edition', 44.99, 'rent', 'like-new', 'Bangalore', 0, 'active'),
(3, 'Corsair 1000D Super Tower Case', 'Accessory', 'PC', 'Obsidian Series case', 499.99, 'sell', 'like-new', 'Bangalore', 0, 'active'),
(3, 'Hogwarts Legacy', 'Game', 'PC', 'Digital Deluxe Edition', 54.99, 'sell', 'like-new', 'Bangalore', 0, 'active'),

-- ============ retro_gamer (ID: 4) - More Nintendo Items ============
(4, 'Nintendo Switch Lite - Dialga & Palkia', 'Console', 'Nintendo', 'Limited edition Pokemon', 199.99, 'sell', 'like-new', 'Chennai', 0, 'active'),
(4, 'Zelda: Tears of Kingdom - Collectors', 'Game', 'Nintendo', 'Collector\'s edition', 129.99, 'sell', 'new', 'Chennai', 0, 'active'),
(4, 'Nintendo Switch Joy-Con - Pastel', 'Accessory', 'Nintendo', 'Pastel Pink/Green', 79.99, 'sell', 'new', 'Chennai', 0, 'active'),
(4, 'Metroid Prime Remastered', 'Game', 'Nintendo', 'Physical edition', 39.99, 'sell', 'like-new', 'Chennai', 0, 'active'),
(4, 'Hori Split Pad Pro', 'Accessory', 'Nintendo', 'Ergonomic controller', 49.99, 'sell', 'good', 'Chennai', 0, 'active'),
(4, 'Pikmin 4', 'Game', 'Nintendo', 'New sealed', 59.99, 'sell', 'new', 'Chennai', 0, 'active'),
(4, 'Nintendo Switch Dock Set', 'Accessory', 'Nintendo', 'Official dock', 69.99, 'rent', 'like-new', 'Chennai', 0, 'active'),
(4, 'Fire Emblem Engage', 'Game', 'Nintendo', 'Divine Edition', 79.99, 'sell', 'like-new', 'Chennai', 0, 'active'),

-- ============ xbox_fan (ID: 5) - More Xbox Items ============
(5, 'Xbox Series X - Diablo IV Bundle', 'Console', 'Xbox', 'Includes Diablo IV', 559.99, 'sell', 'new', 'Hyderabad', 0, 'active'),
(5, 'Diablo IV', 'Game', 'Xbox', 'Ultimate Edition', 89.99, 'sell', 'new', 'Hyderabad', 0, 'active'),
(5, 'Turtle Beach Stealth 700 Gen 2', 'Accessory', 'Xbox', 'Wireless headset', 159.99, 'sell', 'like-new', 'Hyderabad', 0, 'active'),
(5, 'Lies of P', 'Game', 'Xbox', 'Deluxe Edition', 49.99, 'sell', 'like-new', 'Hyderabad', 0, 'active'),
(5, 'Razer Wolverine V2 Chroma', 'Accessory', 'Xbox', 'RGB controller', 99.99, 'sell', 'like-new', 'Hyderabad', 0, 'active'),
(5, 'Atomic Heart', 'Game', 'Xbox', 'Premium Edition', 44.99, 'rent', 'like-new', 'Hyderabad', 0, 'active'),
(5, 'Xbox Controller - Starfield Edition', 'Accessory', 'Xbox', 'Limited edition', 79.99, 'sell', 'new', 'Hyderabad', 0, 'active'),
(5, 'Dead Space Remake', 'Game', 'Xbox', 'Digital Deluxe Edition', 39.99, 'sell', 'like-new', 'Hyderabad', 0, 'active'),

-- ============ Cross-Platform Items ============
(1, 'SteelSeries Arctis Nova Pro Wireless', 'Accessory', 'Other', 'Premium wireless headset', 349.99, 'sell', 'new', 'Mumbai', 0, 'active'),
(2, 'Elgato Stream Deck XL', 'Accessory', 'PC', '32 macro keys', 249.99, 'sell', 'like-new', 'Delhi', 0, 'active'),
(3, 'Secretlab Titan Evo 2024', 'Accessory', 'Other', 'Gaming chair', 599.99, 'sell', 'like-new', 'Bangalore', 0, 'active'),
(4, '8BitDo Pro 2 Controller', 'Accessory', 'Other', 'Wireless controller', 49.99, 'sell', 'like-new', 'Chennai', 0, 'active'),
(5, 'Corsair HS80 RGB Wireless', 'Accessory', 'Other', 'Wireless headset', 149.99, 'sell', 'new', 'Hyderabad', 0, 'active'),

-- ============ More Rental Items ============
(1, 'PS5 Digital Edition Rental', 'Console', 'PS5', 'Monthly rental', 49.99, 'rent', 'good', 'Mumbai', 0, 'active'),
(2, 'Xbox Game Pass Ultimate 6 Months', 'Game', 'Xbox', '6 months subscription', 89.99, 'rent', 'new', 'Delhi', 0, 'active'),
(3, 'Razer Blade 15 Gaming Laptop', 'Console', 'PC', 'Weekly rental', 99.99, 'rent', 'like-new', 'Bangalore', 0, 'active'),
(4, 'Nintendo Switch Game Bundle', 'Game', 'Nintendo', '2 weeks rental', 24.99, 'rent', 'good', 'Chennai', 0, 'active'),
(5, 'Logitech G29 Racing Wheel', 'Accessory', 'PC', 'Weekly rental', 29.99, 'rent', 'good', 'Hyderabad', 0, 'active'),

-- ============ Budget Items ============
(2, 'Xbox One S 500GB', 'Console', 'Xbox', 'Good condition', 149.99, 'sell', 'good', 'Delhi', 0, 'active'),
(4, 'Nintendo Switch Lite - Turquoise', 'Console', 'Nintendo', 'Good condition', 159.99, 'sell', 'good', 'Chennai', 0, 'active'),
(1, 'PS4 Slim 500GB', 'Console', 'PS4', 'Good condition', 179.99, 'sell', 'good', 'Mumbai', 0, 'active'),
(5, 'Budget Gaming Mouse', 'Accessory', 'PC', 'RGB gaming mouse', 19.99, 'sell', 'new', 'Hyderabad', 0, 'active'),
(3, 'Gaming Mouse Pad XL', 'Accessory', 'PC', 'RGB mouse pad', 29.99, 'sell', 'new', 'Bangalore', 0, 'active'),

-- ============ Limited Edition Items ============
(1, 'PS5 30th Anniversary Edition', 'Console', 'PS5', 'Limited edition gray', 999.99, 'sell', 'new', 'Mumbai', 0, 'active'),
(2, 'Xbox 360 Elite', 'Console', 'Xbox', 'Classic with 20 games', 199.99, 'sell', 'good', 'Delhi', 0, 'active'),
(4, 'GameBoy Advance SP - Zelda', 'Console', 'Nintendo', 'Limited edition', 249.99, 'sell', 'good', 'Chennai', 0, 'active'),
(5, 'Halo 3 Legendary Helmet', 'Accessory', 'Xbox', 'Collector\'s helmet', 299.99, 'sell', 'like-new', 'Hyderabad', 0, 'active'),
(3, 'Counter-Strike 2 Beta Key', 'Game', 'PC', 'Rare beta key', 149.99, 'sell', 'new', 'Bangalore', 0, 'active');

USE g4mexchange;

-- Insert completed purchases
INSERT INTO transactions (transaction_id, item_id, buyer_id, seller_id, transaction_type, amount, trans_status, payment_status, created_at) VALUES
('TXN001', 1, 2, 1, 'buy', 449.99, 'completed', 'paid', '2026-04-01 10:30:00'),
('TXN002', 2, 3, 1, 'buy', 59.99, 'completed', 'paid', '2026-04-02 14:15:00'),
('TXN003', 6, 1, 2, 'buy', 499.99, 'completed', 'paid', '2026-04-03 09:45:00'),
('TXN004', 11, 4, 4, 'buy', 349.99, 'completed', 'paid', '2026-04-05 16:20:00'),
('TXN005', 15, 5, 3, 'buy', 899.99, 'completed', 'paid', '2026-04-07 11:00:00'),
('TXN006', 3, 2, 1, 'buy', 49.99, 'completed', 'paid', '2026-04-08 13:30:00'),
('TXN007', 7, 3, 2, 'buy', 39.99, 'completed', 'paid', '2026-04-10 10:15:00'),
('TXN008', 12, 1, 4, 'buy', 64.99, 'completed', 'paid', '2026-04-12 15:45:00'),
('TXN009', 16, 4, 3, 'buy', 34.99, 'completed', 'paid', '2026-04-14 12:00:00'),
('TXN010', 8, 2, 5, 'buy', 44.99, 'completed', 'paid', '2026-04-15 09:30:00');

-- Insert rental transactions
INSERT INTO transactions (transaction_id, item_id, buyer_id, seller_id, transaction_type, amount, trans_status, payment_status, rent_start_date, rent_end_date, created_at) VALUES
('TXN011', 10, 3, 5, 'rent', 49.99, 'completed', 'paid', '2026-04-01', '2026-04-08', '2026-04-01 08:00:00'),
('TXN012', 21, 1, 1, 'rent', 45.00, 'completed', 'paid', '2026-04-05', '2026-04-12', '2026-04-05 10:00:00'),
('TXN013', 32, 4, 1, 'rent', 49.99, 'completed', 'paid', '2026-04-10', '2026-04-17', '2026-04-10 14:30:00'),
('TXN014', 39, 2, 2, 'rent', 39.99, 'returned', 'paid', '2026-04-03', '2026-04-10', '2026-04-03 11:15:00'),
('TXN015', 47, 5, 3, 'rent', 44.99, 'completed', 'paid', '2026-04-08', '2026-04-15', '2026-04-08 09:45:00');

-- Insert pending/cancelled transactions
INSERT INTO transactions (transaction_id, item_id, buyer_id, seller_id, transaction_type, amount, trans_status, payment_status, created_at) VALUES
('TXN016', 4, 3, 3, 'buy', 54.99, 'pending', 'pending', '2026-04-16 08:30:00'),
('TXN017', 9, 1, 5, 'buy', 54.99, 'cancelled', 'failed', '2026-04-14 16:00:00'),
('TXN018', 14, 5, 4, 'buy', 59.99, 'pending', 'pending', '2026-04-15 13:20:00');

USE g4mexchange;

INSERT INTO reviews (transaction_id, reviewer_id, reviewee_id, rating, comment, created_at) VALUES
-- 5-star reviews
(1, 2, 1, 5, 'Excellent condition! PS5 works perfectly. Highly recommend this seller!', '2026-04-02 10:00:00'),
(2, 3, 1, 5, 'Game arrived quickly, great condition. Would buy again!', '2026-04-03 09:00:00'),
(3, 1, 2, 5, 'Xbox Series X is amazing! Fast shipping, thank you!', '2026-04-04 14:30:00'),
(6, 2, 1, 5, 'Controller looks brand new, very happy with purchase', '2026-04-09 11:00:00'),
(7, 3, 2, 5, 'Halo game is perfect, great seller!', '2026-04-11 10:15:00'),

-- 4-star reviews
(4, 4, 4, 4, 'Switch OLED is great, shipping was a bit slow but product is perfect', '2026-04-06 16:00:00'),
(5, 5, 3, 4, 'PC runs great, would recommend. Minor delay in shipping', '2026-04-08 13:00:00'),
(8, 1, 4, 4, 'Good game, seller was responsive', '2026-04-13 09:00:00'),

-- Rental reviews
(11, 3, 5, 5, 'Great rental experience, game was in perfect condition', '2026-04-09 12:00:00'),
(12, 1, 1, 4, 'Controller worked well, returned on time', '2026-04-13 15:00:00'),
(13, 4, 1, 5, 'PS5 rental was awesome! Will rent again', '2026-04-18 10:00:00');

USE g4mexchange;

INSERT INTO payments (user_id, username, amount, payment_type, transaction_id, card_number_last4, card_type, card_holder_name, payment_status, created_at) VALUES
-- Wallet additions
(1, 'gamer_alex', 100.00, 'wallet_add', NULL, '1234', 'Visa', 'Alex Kumar', 'success', '2026-04-01 09:00:00'),
(1, 'gamer_alex', 50.00, 'wallet_add', NULL, '5678', 'Mastercard', 'Alex Kumar', 'success', '2026-04-05 14:30:00'),
(2, 'retro_mike', 200.00, 'wallet_add', NULL, '9012', 'Visa', 'Mike Singh', 'success', '2026-04-02 11:00:00'),
(3, 'game_master', 150.00, 'wallet_add', NULL, '3456', 'Mastercard', 'Sarah Chen', 'success', '2026-04-03 10:15:00'),
(4, 'retro_gamer', 100.00, 'wallet_add', NULL, '7890', 'Visa', 'John Doe', 'success', '2026-04-04 16:45:00'),
(5, 'xbox_fan', 75.00, 'wallet_add', NULL, '2468', 'Mastercard', 'David Miller', 'success', '2026-04-06 09:30:00'),

-- Direct purchase payments
(2, 'retro_mike', 449.99, 'direct_purchase', 'TXN001', '4321', 'Visa', 'Mike Singh', 'success', '2026-04-01 10:35:00'),
(3, 'game_master', 59.99, 'direct_purchase', 'TXN002', '8765', 'Mastercard', 'Sarah Chen', 'success', '2026-04-02 14:20:00'),
(1, 'gamer_alex', 499.99, 'direct_purchase', 'TXN003', '1357', 'Visa', 'Alex Kumar', 'success', '2026-04-03 09:50:00'),
(5, 'xbox_fan', 44.99, 'direct_purchase', 'TXN010', '9876', 'Mastercard', 'David Miller', 'success', '2026-04-15 09:35:00');

-- Check results
SELECT '✅ More items added!' AS Status;
SELECT COUNT(*) as total_items FROM items;
SELECT 
    u.username,
    COUNT(i.id) as items_listed
FROM items i
JOIN users u ON i.seller_id = u.id
GROUP BY u.username
ORDER BY items_listed DESC;

select * from users;
select * from items;
select * from payments;
select * from transactions;
select * from reviews;

show tables;
