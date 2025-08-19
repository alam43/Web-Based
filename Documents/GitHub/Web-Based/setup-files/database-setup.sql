-- Group Expense Manager Database Setup
-- This script safely creates the database and tables with error handling

-- Create database with character set
CREATE DATABASE IF NOT EXISTS group_expense_manager 
DEFAULT CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

-- Use the database
USE group_expense_manager;

-- Drop existing tables if they exist (for clean reinstall)
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS members;
DROP TABLE IF EXISTS events;
SET FOREIGN_KEY_CHECKS = 1;

-- Events table with comprehensive tracking
CREATE TABLE events (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    currency ENUM('USD', 'BDT', 'AED', 'GBP') NOT NULL DEFAULT 'USD',
    total_amount DECIMAL(12, 2) DEFAULT 0.00,
    average_amount DECIMAL(12, 2) DEFAULT 0.00,
    member_count INT DEFAULT 0,
    status ENUM('active', 'completed', 'cancelled') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_currency (currency),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Members table with balance tracking
CREATE TABLE members (
    id INT AUTO_INCREMENT PRIMARY KEY,
    event_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    contribution DECIMAL(12, 2) DEFAULT 0.00,
    balance DECIMAL(12, 2) DEFAULT 0.00, -- positive = should receive, negative = should pay
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
    UNIQUE KEY unique_member_per_event (event_id, name),
    INDEX idx_event_id (event_id),
    INDEX idx_balance (balance)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Transactions table for detailed audit trail
CREATE TABLE transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    event_id INT NOT NULL,
    member_id INT NOT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    transaction_type ENUM('contribution', 'payment', 'receipt', 'adjustment') NOT NULL,
    description TEXT,
    metadata JSON, -- For storing additional data like currency conversion rates
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE,
    INDEX idx_event_id (event_id),
    INDEX idx_member_id (member_id),
    INDEX idx_transaction_type (transaction_type),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create a view for easy expense summaries
CREATE VIEW event_summary AS
SELECT 
    e.id,
    e.name,
    e.currency,
    e.total_amount,
    e.average_amount,
    e.member_count,
    e.status,
    e.created_at,
    COUNT(m.id) as actual_member_count,
    SUM(m.contribution) as calculated_total,
    AVG(m.contribution) as calculated_average,
    SUM(CASE WHEN m.balance > 0 THEN m.balance ELSE 0 END) as total_to_receive,
    SUM(CASE WHEN m.balance < 0 THEN ABS(m.balance) ELSE 0 END) as total_to_pay
FROM events e
LEFT JOIN members m ON e.id = m.event_id
GROUP BY e.id, e.name, e.currency, e.total_amount, e.average_amount, e.member_count, e.status, e.created_at;

-- Insert sample data for testing
INSERT INTO events (name, currency, total_amount, average_amount, member_count, status) VALUES
('Weekend Getaway', 'USD', 480.00, 120.00, 4, 'completed'),
('Birthday Dinner', 'BDT', 1200.00, 300.00, 4, 'completed'),
('Movie Night', 'AED', 280.00, 56.00, 5, 'completed'),
('Conference Trip', 'GBP', 750.00, 150.00, 5, 'completed'),
('Team Lunch', 'USD', 180.00, 45.00, 4, 'active');

-- Sample members for Weekend Getaway (Event ID: 1)
INSERT INTO members (event_id, name, contribution, balance) VALUES
(1, 'Alice Johnson', 150.00, 30.00),
(1, 'Bob Smith', 100.00, -20.00),
(1, 'Charlie Brown', 110.00, -10.00),
(1, 'Diana Wilson', 120.00, 0.00);

-- Sample members for Birthday Dinner (Event ID: 2)
INSERT INTO members (event_id, name, contribution, balance) VALUES
(2, 'Emma Davis', 400.00, 100.00),
(2, 'Frank Miller', 300.00, 0.00),
(2, 'Grace Lee', 250.00, -50.00),
(2, 'Henry Kim', 250.00, -50.00);

-- Sample members for Movie Night (Event ID: 3)
INSERT INTO members (event_id, name, contribution, balance) VALUES
(3, 'Ivy Chen', 80.00, 24.00),
(3, 'Jack Taylor', 60.00, 4.00),
(3, 'Kate Anderson', 50.00, -6.00),
(3, 'Liam O\'Connor', 45.00, -11.00),
(3, 'Mia Rodriguez', 45.00, -11.00);

-- Sample members for Conference Trip (Event ID: 4)
INSERT INTO members (event_id, name, contribution, balance) VALUES
(4, 'Noah Thompson', 200.00, 50.00),
(4, 'Olivia Martinez', 150.00, 0.00),
(4, 'Peter Garcia', 140.00, -10.00),
(4, 'Quinn Lewis', 130.00, -20.00),
(4, 'Ruby Clark', 130.00, -20.00);

-- Sample members for Team Lunch (Event ID: 5) - Active event
INSERT INTO members (event_id, name, contribution, balance) VALUES
(5, 'Sam Wilson', 50.00, 5.00),
(5, 'Tina Brown', 45.00, 0.00),
(5, 'Uma Patel', 40.00, -5.00),
(5, 'Victor Chen', 45.00, 0.00);

-- Insert sample transactions for audit trail
INSERT INTO transactions (event_id, member_id, amount, transaction_type, description) VALUES
(1, 1, 150.00, 'contribution', 'Hotel booking payment'),
(1, 2, 100.00, 'contribution', 'Food and drinks'),
(1, 3, 110.00, 'contribution', 'Transportation'),
(1, 4, 120.00, 'contribution', 'Activities and miscellaneous'),
(2, 5, 400.00, 'contribution', 'Restaurant bill payment'),
(2, 6, 300.00, 'contribution', 'Drinks and dessert'),
(2, 7, 250.00, 'contribution', 'Decorations'),
(2, 8, 250.00, 'contribution', 'Birthday cake and gifts');

-- Create indexes for better performance
CREATE INDEX idx_events_currency_status ON events(currency, status);
CREATE INDEX idx_members_event_balance ON members(event_id, balance);
CREATE INDEX idx_transactions_event_type ON transactions(event_id, transaction_type);

-- Display success message
SELECT 'Database setup completed successfully!' as message,
       'Sample data inserted for testing' as note,
       (SELECT COUNT(*) FROM events) as total_events,
       (SELECT COUNT(*) FROM members) as total_members,
       (SELECT COUNT(*) FROM transactions) as total_transactions;