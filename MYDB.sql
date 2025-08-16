-- Users (Admin, Manager, Staff)
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    role ENUM('Admin', 'Manager', 'Staff') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Suppliers
CREATE TABLE Suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    contact_email VARCHAR(100),
    contact_phone VARCHAR(20),
    address VARCHAR(255)
);

-- Products
CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    supplier_id INT,
    stock INT DEFAULT 0,
    price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id)
);

-- Customers
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    address VARCHAR(255)
);

-- Orders
CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Pending', 'Shipped', 'Delivered', 'Cancelled') DEFAULT 'Pending',
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- Order Items
CREATE TABLE OrderItems (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- Payments
CREATE TABLE Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    amount DECIMAL(10,2) NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    method ENUM('Cash', 'Card', 'UPI'),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

-- Inventory Log
CREATE TABLE InventoryLog (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    change_type ENUM('IN', 'OUT') NOT NULL,
    quantity INT NOT NULL,
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);
DELIMITER $$
CREATE TRIGGER deduct_stock_after_order
AFTER INSERT ON OrderItems
FOR EACH ROW
BEGIN
    UPDATE Products
    SET stock = stock - NEW.quantity
    WHERE product_id = NEW.product_id;
END$$

DELIMITER ;
CREATE VIEW LowStockProducts AS
SELECT product_id, product_name, stock
FROM Products
WHERE stock < 10;
DELIMITER //
CREATE PROCEDURE MonthlySalesReport(IN report_month INT, IN report_year INT)
BEGIN
    SELECT p.product_name, SUM(oi.quantity) AS total_sold, SUM(oi.price * oi.quantity) AS total_revenue
    FROM OrderItems oi
    JOIN Orders o ON oi.order_id = o.order_id
    JOIN Products p ON oi.product_id = p.product_id
    WHERE MONTH(o.order_date) = report_month AND YEAR(o.order_date) = report_year
    GROUP BY p.product_name
    ORDER BY total_revenue DESC;
END //
DELIMITER ;



SELECT TRIGGER_SCHEMA, TRIGGER_NAME
FROM information_schema.TRIGGERS
WHERE TRIGGER_NAME = 'deduct_stock_after_order';

USE smart_inventory;
DROP TRIGGER IF EXISTS deduct_stock_after_order;





-- ------------------------
-- 1) Suppliers (8 rows)
-- ------------------------
INSERT INTO Suppliers (supplier_name, contact_email, contact_phone, address) VALUES
('TechWorld Gadgets','contact@techworld.com','9001002001','Mumbai, Maharashtra'),
('Home Essentials Co.','info@homeessentials.com','9001002002','Bengaluru, Karnataka'),
('SportsGear Ltd.','hello@sportsgear.com','9001002003','Pune, Maharashtra'),
('BeautyCare Pvt Ltd','sales@beautycare.com','9001002004','Delhi, NCR'),
('ToyPlanet','support@toyplanet.com','9001002005','Chennai, Tamil Nadu'),
('FreshGrocers','contact@freshgrocers.com','9001002006','Hyderabad, Telangana'),
('OfficeSupplies Inc.','orders@officesupplies.com','9001002007','Ahmedabad, Gujarat'),
('CameraWorld','sales@cameraworld.com','9001002008','Kolkata, West Bengal');

-- ------------------------
-- 2) Users (Admin/Manager/Staff) — 10 rows
-- ------------------------
INSERT INTO Users (full_name, email, phone, role) VALUES
('Aarav Sharma','aarav.sharma@example.com','9876543210','Admin'),
('Priya Verma','priya.verma@example.com','9123456780','Manager'),
('Rohan Gupta','rohan.gupta@example.com','9988776655','Staff'),
('Sneha Iyer','sneha.iyer@example.com','9786543210','Staff'),
('Karan Mehta','karan.mehta@example.com','9876123450','Manager'),
('Ananya Singh','ananya.singh@example.com','9876001234','Admin'),
('Vikram Nair','vikram.nair@example.com','9765432109','Staff'),
('Pooja Kulkarni','pooja.kulkarni@example.com','9654321098','Manager'),
('Rahul Choudhary','rahul.choudhary@example.com','9543210987','Staff'),
('Divya Patel','divya.patel@example.com','9432109876','Admin');
select * from users;
-- ------------------------
-- 3) Products (50 rows) — generated via recursive CTE
-- ------------------------
INSERT INTO Products (product_name, category, supplier_id, stock, price)
VALUES
('Wireless Mouse', 'Electronics', 1, 150, 499.00),
('Mechanical Keyboard', 'Electronics', 1, 80, 2499.00),
('Smartphone X', 'Mobiles', 2, 50, 29999.00),
('USB-C Charger', 'Accessories', 2, 200, 999.00),
('Bluetooth Speaker', 'Electronics', 3, 100, 1999.00),
('Gaming Laptop', 'Computers', 3, 20, 79999.00),
('External Hard Drive', 'Storage', 4, 75, 5499.00),
('LED Monitor 24"', 'Computers', 4, 40, 10999.00),
('Smartwatch Pro', 'Wearables', 5, 60, 14999.00),
('Noise Cancelling Headphones', 'Audio', 5, 35, 8999.00);

INSERT INTO Customers (full_name, email, phone, address)
VALUES
('Ravi Kumar', 'ravi.kumar@example.com', '9876543210', 'Hyderabad, Telangana'),
('Anjali Mehta', 'anjali.mehta@example.com', '9123456789', 'Mumbai, Maharashtra'),
('Vikram Singh', 'vikram.singh@example.com', '9988776655', 'Delhi, NCR'),
('Priya Sharma', 'priya.sharma@example.com', '9001122334', 'Pune, Maharashtra'),
('Arjun Reddy', 'arjun.reddy@example.com', '9898989898', 'Bengaluru, Karnataka'),
('Neha Gupta', 'neha.gupta@example.com', '9111223344', 'Kolkata, West Bengal'),
('Suresh Patel', 'suresh.patel@example.com', '9223344556', 'Ahmedabad, Gujarat'),
('Kiran Das', 'kiran.das@example.com', '9334455667', 'Guwahati, Assam'),
('Divya Nair', 'divya.nair@example.com', '9445566778', 'Kochi, Kerala'),
('Amit Joshi', 'amit.joshi@example.com', '9556677889', 'Jaipur, Rajasthan'),
('Pooja Yadav', 'pooja.yadav@example.com', '9667788990', 'Lucknow, Uttar Pradesh'),
('Rahul Verma', 'rahul.verma@example.com', '9778899001', 'Chandigarh, Punjab'),
('Sneha Rao', 'sneha.rao@example.com', '9889900012', 'Visakhapatnam, Andhra Pradesh'),
('Manoj Kumar', 'manoj.kumar@example.com', '9990001123', 'Patna, Bihar'),
('Swati Chawla', 'swati.chawla@example.com', '9000012345', 'Bhopal, Madhya Pradesh');

-- Generate 300 random orders
-- Insert 300 random orders into Orders table
INSERT INTO Orders (customer_id, order_date, status)
SELECT
    FLOOR(1 + RAND() * (SELECT MAX(customer_id) FROM Customers)), -- Random customer_id
    TIMESTAMP(DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 365) DAY)), -- Random date in past year
    ELT(FLOOR(1 + (RAND() * 4)), 'Pending', 'Shipped', 'Delivered', 'Cancelled') -- Random status
FROM
    (SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5) t1,
    (SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5) t2,
    (SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5) t3,
    (SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5) t4
LIMIT 300;


-- ------------------------
-- 6) OrderItems: use a stored procedure to loop each order and insert 1-4 items
--    (this ensures we pull correct product price and triggers fire)
-- ------------------------
DROP PROCEDURE IF EXISTS SeedOrderItems;
DELIMITER $$

CREATE PROCEDURE SeedOrderItems()
BEGIN
  DECLARE oid INT DEFAULT 1;
  DECLARE max_oid INT;
  DECLARE items INT;
  DECLARE pid INT;
  DECLARE qty INT;
  DECLARE pr DECIMAL(10,2);

  SELECT COALESCE(MAX(order_id), 0) INTO max_oid FROM Orders;

  WHILE oid <= max_oid DO
    SET items = FLOOR(1 + RAND()*4);
    WHILE items > 0 DO
      -- Pick a random existing product
      SELECT product_id, price INTO pid, pr
      FROM Products
      ORDER BY RAND()
      LIMIT 1;

      IF pr IS NOT NULL THEN
        SET qty = FLOOR(1 + RAND()*3);
        INSERT INTO OrderItems (order_id, product_id, quantity, price)
        VALUES (oid, pid, qty, pr);
      END IF;

      SET items = items - 1;
    END WHILE;
    SET oid = oid + 1;
  END WHILE;
END$$

DELIMITER ;

CALL SeedOrderItems();






SELECT p.product_name, SUM(oi.quantity) AS total_sold
FROM OrderItems oi
JOIN Products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_sold DESC
LIMIT 5;



SELECT p.product_name, SUM(oi.price * oi.quantity) AS total_revenue
FROM OrderItems oi
JOIN Products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_revenue DESC;



SELECT c.full_name, COUNT(o.order_id) AS total_orders
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_id
ORDER BY total_orders DESC
LIMIT 5;


SELECT o.order_id, c.full_name, o.order_date, o.status
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
WHERE o.status = 'Pending'
ORDER BY o.order_date DESC;
