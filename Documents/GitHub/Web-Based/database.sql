-- Group Expense Manager Database Schema
CREATE DATABASE IF NOT EXISTS group_expense_manager;
USE group_expense_manager;

-- Events table
CREATE TABLE events (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    currency ENUM('USD', 'BDT', 'AED', 'GBP') NOT NULL,
    total_amount DECIMAL(10, 2) DEFAULT 0,
    average_amount DECIMAL(10, 2) DEFAULT 0,
    member_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Members table
CREATE TABLE members (
    id INT AUTO_INCREMENT PRIMARY KEY,
    event_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    contribution DECIMAL(10, 2) DEFAULT 0,
    balance DECIMAL(10, 2) DEFAULT 0, -- positive means they should receive, negative means they should pay
    payment_status ENUM('pending', 'paid') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
    UNIQUE KEY unique_member_per_event (event_id, name)
);

-- Transactions table (for detailed tracking)
CREATE TABLE transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    event_id INT NOT NULL,
    member_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    transaction_type ENUM('contribution', 'payment', 'receipt') NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE
);

-- Sample data for testing
INSERT INTO events (name, currency, total_amount, average_amount, member_count) VALUES
('Dinner Party', 'USD', 120.00, 30.00, 4),
('Movie Night', 'BDT', 800.00, 200.00, 4),
('Weekend Trip', 'AED', 500.00, 100.00, 5);

INSERT INTO members (event_id, name, contribution, balance, payment_status) VALUES
(1, 'Alice', 40.00, 10.00, 'pending'),
(1, 'Bob', 20.00, -10.00, 'pending'),
(1, 'Charlie', 30.00, 0.00, 'paid'),
(1, 'David', 30.00, 0.00, 'paid'),
(2, 'Emma', 300.00, 100.00, 'pending'),
(2, 'Frank', 200.00, 0.00, 'paid'),
(2, 'Grace', 150.00, -50.00, 'pending'),
(2, 'Henry', 150.00, -50.00, 'paid'),
(3, 'Ivy', 150.00, 50.00, 'pending'),
(3, 'Jack', 100.00, 0.00, 'paid'),
(3, 'Kate', 80.00, -20.00, 'pending'),
(3, 'Liam', 90.00, -10.00, 'pending'),
(3, 'Mia', 80.00, -20.00, 'paid');