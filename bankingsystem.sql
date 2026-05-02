-- Create Database
CREATE DATABASE BankingSystem;
USE BankingSystem;

-- Tables
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE Accounts (
    account_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    balance DECIMAL(10,2) DEFAULT 0,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE Transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    account_id INT,
    type VARCHAR(10),
    amount DECIMAL(10,2),
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES Accounts(account_id)
);

-- Sample Data
INSERT INTO Customers (name, email) VALUES
('Rahul', 'rahul@gmail.com'),
('Priya', 'priya@gmail.com');

INSERT INTO Accounts (customer_id, balance) VALUES
(1, 5000),
(2, 10000);

-- Trigger (auto update balance)
DELIMITER $$
CREATE TRIGGER update_balance
AFTER INSERT ON Transactions
FOR EACH ROW
BEGIN
    IF NEW.type = 'Deposit' THEN
        UPDATE Accounts SET balance = balance + NEW.amount
        WHERE account_id = NEW.account_id;
    ELSEIF NEW.type = 'Withdraw' THEN
        UPDATE Accounts SET balance = balance - NEW.amount
        WHERE account_id = NEW.account_id;
    END IF;
END $$
DELIMITER ;

-- Stored Procedure (transfer money)
DELIMITER $$
CREATE PROCEDURE TransferMoney(IN from_acc INT, IN to_acc INT, IN amt DECIMAL(10,2))
BEGIN
    INSERT INTO Transactions(account_id, type, amount) VALUES (from_acc, 'Withdraw', amt);
    INSERT INTO Transactions(account_id, type, amount) VALUES (to_acc, 'Deposit', amt);
END $$
DELIMITER ;

-- Test Transactions
INSERT INTO Transactions (account_id, type, amount) VALUES (1, 'Deposit', 2000);
INSERT INTO Transactions (account_id, type, amount) VALUES (1, 'Withdraw', 1000);

CALL TransferMoney(1, 2, 500);

-- Queries
-- Check balances
SELECT c.name, a.balance
FROM Customers c JOIN Accounts a
ON c.customer_id = a.customer_id;

-- Transaction history
SELECT * FROM Transactions;

-- Top customer
SELECT c.name, SUM(a.balance) AS total_balance
FROM Customers c JOIN Accounts a
ON c.customer_id = a.customer_id
GROUP BY c.name
ORDER BY total_balance DESC;