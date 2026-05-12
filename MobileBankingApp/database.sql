-- ============================================================
-- Mobile Banking Application - Database Setup
-- MySQL 8.0+
-- ============================================================

CREATE DATABASE IF NOT EXISTS mobile_banking_db;
USE mobile_banking_db;

-- ---------------------------------------------------------------
-- Table: users
-- ---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(15),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ---------------------------------------------------------------
-- Table: accounts
-- ---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS accounts (
    account_no VARCHAR(20) PRIMARY KEY,
    user_id INT NOT NULL,
    balance DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    account_type VARCHAR(20) DEFAULT 'SAVINGS',
    status VARCHAR(10) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- ---------------------------------------------------------------
-- Table: transactions
-- ---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    from_acc VARCHAR(20),
    to_acc VARCHAR(20),
    amount DECIMAL(15,2) NOT NULL,
    type VARCHAR(20) NOT NULL,
    description VARCHAR(255),
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ---------------------------------------------------------------
-- Sample Data
-- ---------------------------------------------------------------

-- Users (password = "password123" stored as plain text for demo)
-- In production, use BCrypt hashing
INSERT INTO users (username, password, full_name, email, phone) VALUES
('alice', 'password123', 'Alice Johnson', 'alice@email.com', '9876543210'),
('bob', 'password123', 'Bob Smith', 'bob@email.com', '9123456780'),
('charlie', 'password123', 'Charlie Brown', 'charlie@email.com', '9988776655');

-- Accounts
INSERT INTO accounts (account_no, user_id, balance, account_type) VALUES
('ACC1001001', 1, 75000.00, 'SAVINGS'),
('ACC1001002', 2, 42500.50, 'SAVINGS'),
('ACC1001003', 3, 120000.00, 'CURRENT');

-- Sample Transactions
INSERT INTO transactions (from_acc, to_acc, amount, type, description) VALUES
('ACC1001001', 'ACC1001002', 5000.00, 'TRANSFER', 'Fund Transfer to Bob'),
('ACC1001002', 'ACC1001001', 2000.00, 'TRANSFER', 'Fund Transfer to Alice'),
('ACC1001001', NULL, 1500.00, 'BILL_PAYMENT', 'Electricity Bill - EB Board'),
('ACC1001002', NULL, 800.00, 'BILL_PAYMENT', 'Mobile Recharge - Airtel'),
('ACC1001003', 'ACC1001001', 10000.00, 'TRANSFER', 'Fund Transfer to Alice'),
('ACC1001001', NULL, 500.00, 'BILL_PAYMENT', 'Water Bill - BWSSB');
