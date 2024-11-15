-- ASSIGNMENT 2
-- Display the list of products (Id, Title, Count of Categories) which fall in more than one Category.
SELECT p.product_id, p.product_name, COUNT(pc.category_id) AS CategoryCount
FROM product p
JOIN category pc ON p.product_category_id = pc.product_id
GROUP BY p.product_id ,p.product_name
HAVING COUNT(pc.category_id) > 1;

-- Display Count of products as per below price range  
SELECT 
    CASE 
        WHEN product_price BETWEEN 0 AND 100 THEN '0 - 100'
        WHEN product_price BETWEEN 101 AND 500 THEN '101 - 500'
        ELSE 'Above 500'
    END AS PriceRange,
    COUNT(*) AS ProductCount
FROM product
GROUP BY PriceRange;

-- Display the Categories along with number of products under each category.
SELECT c.category_id, c.category_name, COUNT(p.product_id) AS Number_Of_Product
FROM category c
LEFT JOIN product p ON c.category_id = p.product_category_id
GROUP BY c.category_name, c.category_id
ORDER BY c.category_name ASC;

-- Assignment 3
-- Display Shopper’s information along with number of orders he/she placed during last 30 days.
SELECT u.first_name AS First_Name , u.last_name AS Last_Name, u.mobile_number AS Mobile_number, COUNT(o.order_id) AS Order_Count
FROM user u
LEFT JOIN orders o ON o.user_id = u.user_id
WHERE u.user_type ="shopper"
GROUP BY u.user_id;

-- Display the top 10 Shoppers who generated maximum number of revenue in last 30 days.
SELECT u.first_name AS First_Name, u.last_name AS Last_Name , SUM(o.order_amount) AS Total_Order_Amount
FROM user u
LEFT JOIN orders o ON o.user_id = u.user_id
WHERE u.user_type = "shopper" AND o.orderDate >= NOW() - INTERVAL 30 DAY
GROUP BY u.user_id
ORDER BY Total_Order_Amount DESC
LIMIT 10;

-- Display top 20 Products which are ordered most in last 60 days along with numbers.
SELECT p.product_name , SUM(ot.product_quantity) AS quantity_ordered
FROM product p
JOIN order_item AS ot ON ot.product_id = p.product_id 
JOIN orders AS o on ot.order_id = o.order_id
WHERE o.OrderDate >= NOW() -INTERVAL 60 DAY
GROUP BY p.product_id
LIMIT 20;

-- Display Monthly sales revenue of the StoreFront for last 6 months. It should display each month’s sale.
SELECT DATE_FORMAT(o.OrderDate, '%Y-%m') AS month_year, SUM(order_amount) AS MonthlyRevenue
FROM orders o
WHERE o.OrderDate >= DATE_SUB(curdate(), INTERVAL 6 MONTH)
GROUP BY month_year
ORDER BY month_year;

ALTER TABLE product 
ADD COLUMN product_status VARCHAR(20) NOT NULL DEFAULT "active";

-- Mark the products as Inactive which are not ordered in last 90 days.
UPDATE product p
SET p.product_status = 'inactive'
WHERE p.product_id NOT IN (
    SELECT DISTINCT ot.product_id
    FROM orders o
    JOIN order_item ot ON o.order_id = ot.order_id
    WHERE o.OrderDate >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)
);

-- Display top 10 Items which were cancelled most.
SELECT p.product_name , COUNT(o.product_id) AS cancelled_count
FROM product p 
JOIN order_item o ON p.product_id = o.product_id
WHERE o.order_status = "canceled"
GROUP BY o.product_id
ORDER BY cancelled_count DESC
LIMIT 10;


-- Assignment 4 

CREATE TABLE state (
    state_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    state_name VARCHAR(50) NOT NULL UNIQUE
);

-- Create City Table
CREATE TABLE city (
    city_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    city_name VARCHAR(50) NOT NULL,
    state_id INT NOT NULL,
    FOREIGN KEY (state_id) REFERENCES state(state_id)
);

-- Create Zip Code Table
CREATE TABLE zipcode (
    zip_code VARCHAR(10) NOT NULL PRIMARY KEY,
    city_id INT NOT NULL,
    FOREIGN KEY (city_id) REFERENCES city(city_id)
);

--  write a SQL
--          query for that returns a Resultset containing Zip Code, City Names and
--          States ordered by State Name and City Name.
-- 	(Create 3 tables to store State, District/City & Zip code separately)
SELECT z.zip_code, c.city_name, s.state_name
FROM zipcode z
JOIN city c ON z.city_id = c.city_id
JOIN state s ON c.state_id = s.state_id
ORDER BY s.state_name, c.city_name;


-- Assignment 5

-- Create a view displaying the order information (Id, Title, Price, Shopper’s name, Email, Orderdate, Status) with latest ordered items should be displayed first for last 60 days.
CREATE VIEW RecentOrders AS
SELECT o.order_id AS OrderId, p.product_name AS ProductTitle, p.product_id AS ProductId, p.product_price AS ProductPrice, u.first_name AS ShopperFirstName,
    u.last_name AS ShopperLastName, u.mobile_number AS ShopperMobile, o.OrderDate, oi.order_status
FROM orders o
JOIN order_item oi ON o.order_id = oi.order_id
JOIN product p ON oi.product_id = p.product_id
JOIN user u ON o.user_id = u.user_id
WHERE o.OrderDate >= DATE_SUB(CURDATE(), INTERVAL 60 DAY)
ORDER BY o.OrderDate DESC;

-- Use the above view to display the Products(Items) which are in ‘shipped’ state.
SELECT * FROM RecentOrders WHERE order_status = "shipped";

-- Use the above view to display the top 5 most selling products.
SELECT ro.ProductId, ro.ProductTitle, COUNT(ro.ProductId) AS ProductCount
FROM RecentOrders AS ro
GROUP BY ro.ProductId
ORDER BY ProductCount desc
LIMIT 5;
