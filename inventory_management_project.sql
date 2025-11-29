CREATE DATABASE inventory_db;
USE inventory_db;

CREATE TABLE Products (
	product_id INT auto_increment PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10,2),
    stock_quantity INT DEFAULT 0
    );
DESCRIBE Products;
CREATE TABLE Suppliers (
	supplier_id INT auto_increment PRIMARY KEY,
	name VARCHAR(100) NOT NULL,
	contact VARCHAR(20),
	address VARCHAR(200)
	);
DESCRIBE Suppliers;
        
CREATE TABLE Customers (
	customer_id INT auto_increment PRIMARY KEY,
	name VARCHAR(100) NOT NULL,
	email VARCHAR(100),
	phone VARCHAR(20)
	);
DESCRIBE Customers;

CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);
DESCRIBE Orders;

CREATE TABLE Order_Details (
    order_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id  INT,
    product_id INT,
    quantity INT,
    price DECIMAL(10, 2),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);
DESCRIBE Order_Details;

CREATE TABLE Inventory_Transactions (
	transaction_id INT auto_increment PRIMARY KEY,
    product_id INT,
    transaction_type ENUM('IN','OUT'),
    quantity INT,
    transaction_date DATE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);
DESCRIBE Inventory_Transactions;
        
INSERT INTO Products (name, category, price, stock_quantity) VALUES
('Laptop','Electronics',55000,10),
('Mouse','Electronics',500,100),
('Keyboard','Electronics',1500,500),
('Notebook','Stationary',50,100),
('Pen','Stationary',10,500);
SELECT * FROM Products;

INSERT INTO Suppliers (name, contact, address)
VALUES
('TechSupplier Pvt Ltd','9876543210','Pune'),
('Stationary Co','9123456789','Mumbai');
SELECT * FROM Suppliers;

INSERT INTO Customers(name, email, phone)
VALUES
('Sakshi Rane','sakshi@gmail.com','9876543218'),
('Arnav Sharma','arnav@gmail.com','9876543217');
SELECT * FROM Customers;
    
INSERT INTO Orders (customer_id, order_date, total_amount)
VALUES
(1, '2025-09-25', 55500),
(2, '2025-08-25', 510);
SELECT * FROM Orders;

INSERT INTO Order_Details (order_id, product_id, quantity, price)
VALUES
(1, 1, 1, 55000),
(1, 2, 1, 500),
(2, 2, 1, 500);
SELECT * FROM Order_Details;
 
 INSERT INTO Inventory_Transactions (product_id, transaction_type, quantity, transaction_date)
 VALUES
 (1, 'IN', 10, '2025-09-20'),
 (1, 'OUT', 1, '2025-09-25'),
 (2, 'OUT', 2, '2025-09-25');
 SELECT * FROM Inventory_Transactions;
 
 -- decrease stock when sold
 UPDATE Products
 SET stock_quantity = stock_quantity - 1
 WHERE product_id = 1;
 
 UPDATE Products
 SET stock_quantity = stock_quantity - 2
 WHERE product_id = 2;
 
 -- increase stock when purchased
 UPDATE Products
 SET stock_quantity = stock_quantity + 10
 WHERE product_id = 1;
 
SELECT * FROM Products;
 
-- 1) List all customer orders with details
SELECT o.order_id, c.name AS customer_name, o.order_date, od.product_id, od.quantity, od.price
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Order_Details od ON o.order_id = od.order_id;

-- 2) Check current stock of all products
SELECT name, stock_quantity
FROM Products;

-- 3) Total sales per customer
SELECT c.name, SUM(o.total_amount) AS total_spent
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
GROUP BY c.name;

-- Trigger to reduce stock when an order is inserted. This will auto-update stock whenever order is inserted
DELIMITER //
CREATE TRIGGER reduce_stock_after_order
AFTER INSERT ON Order_Details
FOR EACH ROW
BEGIN
	UPDATE Products
	SET stock_quantity = stock_quantity - NEW.quantity
	WHERE product_id = NEW.product_id ;
END//
DELIMITER ;

SHOW TRIGGERS;
SELECT VERSION();
 
 -- view 1
CREATE VIEW customer_order_summary AS
SELECT 
    c.customer_id,
    c.name AS customer_name,
    o.order_id,
    o.order_date,
    o.total_amount
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id;

SELECT * FROM customer_order_summary;

-- view 2
CREATE VIEW low_stock_products AS
SELECT 
    product_id, 
    name,
    stock_quantity
FROM Products
WHERE stock_quantity < 10;

SELECT * FROM low_stock_products;

-- view 3
CREATE VIEW product_sales_summary AS
SELECT 
    p.product_id,
    p.name AS product_name,
    SUM(od.quantity) AS total_units_sold,
    SUM(od.quantity * od.price) AS total_revenue
FROM Order_Details od
JOIN Products p ON od.product_id = p.product_id
GROUP BY p.product_id;

SELECT * FROM product_sales_summary;

-- basic queries
-- 1. Show all products
SELECT * FROM Products;

-- 2.Show low-stock products
SELECT * FROM Products
WHERE stock_quantity < 20;

-- 3.Show all orders with customer names
SELECT o.order_id, c.name, o.order_date, o.total_amount
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id;


-- 4.Show order details with product names
SELECT od.order_id, p.name, od.quantity, od.price
FROM Order_Details od
JOIN Products p ON od.product_id = p.product_id;

-- 5.Total revenue
SELECT SUM(total_amount) AS total_revenue
FROM Orders;

-- 6.Count total customers
SELECT COUNT(*) AS total_customers
FROM Customers;

-- 7.Best selling product
SELECT p.name, SUM(od.quantity) AS total_sold
FROM Order_Details od
JOIN Products p ON od.product_id = p.product_id
GROUP BY p.product_id
ORDER BY total_sold DESC
LIMIT 1;

-- 8.List all orders made in September
SELECT * FROM Orders
WHERE MONTH(order_date) = 9;

-- 9. Customer-wise total purchase
SELECT c.name, SUM(o.total_amount) AS total_spent
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id;

-- 10. Products costing above ₹1000
SELECT * FROM Products
WHERE price > 1000;

-- 11. Show all inventory IN and OUT entries
SELECT * FROM Inventory_Transactions;

-- 12. Total number of orders per customer
SELECT c.name, COUNT(o.order_id) AS orders_count
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id;

-- 13. Monthly sales report
SELECT MONTH(order_date) AS Month, SUM(total_amount) AS Monthly_Sales
FROM Orders
GROUP BY MONTH(order_date)
ORDER BY Month;

-- 14. Find customers who ordered more than once
SELECT c.name, COUNT(o.order_id) AS order_count
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id
HAVING order_count > 1;

