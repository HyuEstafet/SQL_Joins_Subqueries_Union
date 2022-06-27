-- Create suppliers and suppliers_addresses tables 
-- (same as customers and customers_addresses tables, reuse script with different names)

-- customers table (copied from previous tasks)
CREATE TABLE customers (
customer_id serial PRIMARY KEY,
customer_name varchar (255) NOT NULL,
customer_email varchar (255) UNIQUE NOT NULL,
customer_phone varchar (50) UNIQUE NOT NULL,
customer_age int DEFAULT 99,
gdpr_status boolean NOT NULL,
customer_profile_status boolean NOT NULL,
date_profile_created date DEFAULT CURRENT_TIMESTAMP,
date_profile_deactivated date DEFAULT NULL,
deactivation_reason varchar (1000) DEFAULT NULL,
customer_notes TEXT
);

-- Inserting values to the table
INSERT INTO customers (customer_id,customer_name,customer_email,customer_phone,customer_age,gdpr_status,customer_profile_status,date_profile_created,date_profile_deactivated,deactivation_reason,customer_notes)
VALUES (001,'Nick Clements','nick@email.com','+44765982735',34,TRUE,TRUE,CURRENT_TIMESTAMP,NULL,NULL,'Just an example text'),
       (005,'Abby Simons','abbys@email.com','+44775982735',40,TRUE,TRUE,CURRENT_TIMESTAMP,NULL,NULL,'Just an example text for Abby'),
       (007,'Sarah Pickering','sp@email.com','+44765333735',67,TRUE,TRUE,CURRENT_TIMESTAMP,NULL,NULL,'Just an example text for Sarah');

-- Dropping the table
DROP TABLE customers;

-------------------------------------------------------------------------------------------------------------------------------------
-- Practical task 1 -- Creating relationships between tables
-------------------------------------------------------------------------------------------------------------------------------------

-- 1) Create 1:1 relationship between customers and customers_addresses tables
CREATE TABLE customers_addresses (
customer_addresses_id SERIAL PRIMARY KEY,
customer_id INT NOT NULL,
address VARCHAR (1000),
city VARCHAR (255) NOT NULL,
province VARCHAR (255),
state VARCHAR (255) DEFAULT NULL,
postal_code INT CHECK (postal_code > 0),
country VARCHAR (255) NOT NULL,
CONSTRAINT fk_customer_id FOREIGN KEY (customer_id) REFERENCES customers (customer_id)
);

-- Inserting values
INSERT INTO customers_addresses (customer_id,address,city,province,state,postal_code,country)
VALUES (001,'25 Maritza blvd','Plovdiv','Plovdiv',NULL,4003,'Bulgaria'),
(005,'9 Vitosha blvd','Sofia','Sofia',NULL,1000,'Bulgaria');

-- Dropping the table
DROP TABLE customers_addresses;

-- 2) Create 1:1 relationship between suppliers and suppliers_addresses tables

-- First create suppliers table
CREATE TABLE suppliers (
supplier_id serial PRIMARY KEY,
supplier_name varchar (255) NOT NULL,
supplier_email varchar (255) UNIQUE NOT NULL,
supplier_phone varchar (50) UNIQUE NOT NULL,
supplier_age int DEFAULT 99,
supplier_gdpr_status boolean NOT NULL,
supplier_profile_status boolean NOT NULL,
date_supplier_profile_created date DEFAULT CURRENT_TIMESTAMP,
date_supplier_profile_deactivated date DEFAULT NULL,
supplier_deactivation_reason varchar (1000) DEFAULT NULL,
supplier_notes TEXT
);

-- Inserting values to the table
INSERT INTO suppliers (supplier_id,supplier_name,supplier_email,supplier_phone,supplier_age,supplier_gdpr_status,supplier_profile_status,date_supplier_profile_created,date_supplier_profile_deactivated,supplier_deactivation_reason,supplier_notes)
VALUES (007,'Emily Casavant','emily@test.com','+359889768696',46,TRUE,TRUE,CURRENT_TIMESTAMP,NULL,NULL,'Emilys notes'),
       (031,'Sarah Kennerly','s.k.@test.com','+359886660606',26,TRUE,TRUE,CURRENT_TIMESTAMP,NULL,NULL,'Sarahs notes');

-- Dropping the table
DROP TABLE suppliers;

-- Then create the relation by creating the suppliers_addresses table with a FK supplier_id for suppliers_addresses and PK supplier_id for suppliers
CREATE TABLE suppliers_addresses (
suppliers_addresses_id SERIAL PRIMARY KEY,
supplier_id INT NOT NULL,
suppliers_address VARCHAR (1000),
suppliers_city VARCHAR (255) NOT NULL,
suppliers_province VARCHAR (255),
suppliers_state VARCHAR (255) DEFAULT NULL,
suppliers_postal_code INT CHECK (suppliers_postal_code > 0),
suppliers_country VARCHAR (255) NOT NULL,
CONSTRAINT fk_supplier_id FOREIGN KEY (supplier_id) REFERENCES suppliers (supplier_id)
);

-- Inserting values to the table
INSERT INTO suppliers_addresses (supplier_id,suppliers_address,suppliers_city,suppliers_province,suppliers_state,suppliers_postal_code,suppliers_country)
VALUES (007,'16 Ruski blvd','Plovdiv','Plovdiv',NULL,4012,'Bulgaria'),
       (031,'11 6-ti Septemvri blvd','Plovdiv','Plovdiv',NULL,4022,'Bulgaria');

-- Dropping the table
DROP TABLE suppliers_addresses;

-- 3) Create 1: many  relationship between customers and orders

-- First we create the orders table
CREATE TABLE orders (
order_id SERIAL PRIMARY KEY,
customer_id INT NOT NULL,
is_order_completed BOOLEAN NOT NULL,
is_order_paid BOOLEAN NOT NULL,
date_of_order DATE DEFAULT CURRENT_TIMESTAMP NOT NULL,
date_order_completed DATE,
CONSTRAINT fk_customer_id FOREIGN KEY (customer_id) REFERENCES customers (customer_id)
);

-- Inserting data into the table
INSERT INTO orders (order_id,customer_id,is_order_completed,is_order_paid,date_of_order)
VALUES (001,007,TRUE,FALSE,CURRENT_timestamp),
       (002,001,TRUE,TRUE,CURRENT_timestamp);
      
-- Dropping the table
DROP TABLE orders;

-- 4) Create 1: many relationship between suppliers and products_inventory

-- First we create product_inventory table
CREATE TABLE products_inventory (
product_id SERIAL PRIMARY KEY,
supplier_id INT NOT NULL,
product_name VARCHAR (255) NOT NULL,
available_quantity INT NOT NULL,
product_type VARCHAR (255) NOT NULL,
price_no_VAT DECIMAL NOT NULL,
price_VAT_added DECIMAL NOT NULL,
is_product_in_stock BOOLEAN NOT NULL,
warehouse_name VARCHAR NOT NULL,
CONSTRAINT fk_supplier_id FOREIGN KEY (supplier_id) REFERENCES suppliers (supplier_id)
);

-- Inserting data into the table
INSERT INTO 
 	products_inventory 	 	
 VALUES 
	(001, 007, 'bread', 50, 'food', 1.5,  1.8, true, 'Sofia'),
	(002, 031, 'chocolate', 150, 'food', 2,  2.12, true, 'Sliven');

-- 5) Create many:many relationship between orders and products_inventory table with the ordered quantity

-- We need to create another table that will hold the primary keys of the two tables: orders and products_inventory
CREATE TABLE 
	orders_and_products (
		order_id INT REFERENCES orders (order_id) ON UPDATE CASCADE ON DELETE CASCADE,
		product_id INT REFERENCES products_inventory (product_id) ON UPDATE CASCADE,
		ordered_quantity INT NOT NULL,
		CONSTRAINT order_product_pkey PRIMARY KEY (order_id, product_id)
		);
	
-- Inserting data into the table
INSERT INTO orders_and_products	 	
VALUES 
 	(001, 002, 5),
 	(002, 001, 15);

-------------------------------------------------------------------------------------------------------------------------------------
-- Practical task 2 -- Creating views and saving as scripts
-------------------------------------------------------------------------------------------------------------------------------------

-- 1) Create view customers_contact_info: all customers contact information - phone, address and etc.
 CREATE VIEW customers_contact_information AS
 SELECT customer_name ,customer_phone, ca.address
 FROM customers c
 FULL OUTER JOIN customers_addresses ca
 ON c.customer_id = ca.customer_id;

-- Dropping the view
DROP VIEW customers_contact_information;
 
-- 2) Create view customers_active_orders: customer id, name and phone with order id, status and date of ordering
CREATE VIEW customers_active_orders AS
SELECT c.customer_id, customer_name, customer_phone, order_id, is_order_completed, date_of_order
FROM customers c
FULL OUTER JOIN orders o
ON c.customer_id = o.customer_id 
WHERE is_order_completed = FALSE;

-- Dropping the view
DROP VIEW customers_active_orders;

-- 3) Create view customers_pending_payments: customer id and name with list of pending orders that are not payed, order date and total sum expected to be payed.
CREATE VIEW customers_pending_payments AS
SELECT customer_id, customer_name, ARRAY_AGG (AL.order_id) as orders_list, is_order_paid, date_of_order, sum(total_sum)
FROM 
		(SELECT DISTINCT
			c.customer_id, 
			c.customer_name, 
			o.order_id, 
			o.is_order_paid, 
			o.date_of_order, 
			products_inventory.price_VAT_added * o_p.ordered_quantity as total_sum
		FROM customers as c
		INNER JOIN orders as o
		ON 
		c.customer_id = o.customer_id
		LEFT JOIN orders_and_products as o_p
		ON 
			o.order_id = o_p.order_id
		LEFT JOIN 
			products_inventory
		ON
			o_p.product_id = products_inventory.product_id
		 
		WHERE 
			o.is_order_paid = FALSE) AS AL	
GROUP BY 
	customer_id,
	customer_name,
	is_order_paid, 
	date_of_order;

-- Dropping the view
DROP VIEW customers_pending_payments;

-- 4) Create view supplier_inventory: supplier id, name and phone with available products (qty > 0), quantity, price with and without VAT and the warehouse the item is located
CREATE VIEW supplier_inventory AS
SELECT 
	suppliers.supplier_id, supplier_name, supplier_phone, available_quantity, 
	price_no_VAT, price_VAT_added, warehouse_name
FROM suppliers
FULL OUTER JOIN products_inventory as products
ON 
	suppliers.supplier_id = products.supplier_id
WHERE available_quantity > 0
ORDER BY supplier_id;

-- Dropping the view:
DROP VIEW supplier_inventory;

-- 5) Create view customer_ordered_items: customer id and name with ordered product and product type
CREATE VIEW customer_ordered_items AS
SELECT 
	customer_id, customer_name, product_name, product_type
FROM
		(SELECT 
			c_orders.customer_id, c_orders.customer_name, o_p.order_id, o_p.product_id 
		FROM 
				(SELECT 
					c.customer_id, c.customer_name, o.order_id
				FROM 
					customers c
				RIGHT OUTER JOIN 
					orders o
				ON
					c.customer_id=o.customer_id
				ORDER BY
					customer_id) AS c_orders
		LEFT OUTER JOIN orders_and_products AS o_p
		ON 	
			c_orders.order_id = o_p.order_id) AS orders_and_products_ids
LEFT OUTER JOIN products_inventory
ON 
	orders_and_products_ids.product_id = products_inventory.product_id
ORDER BY customer_id;

-- Dropping the view:
DROP VIEW customer_ordered_items;

-- 6) Create view phones: a union of all suppliers and customers ids, names and phone numbers
CREATE VIEW phones AS
	SELECT 
		customer_id, customer_name, customer_phone
	FROM customers
UNION
	SELECT 
		supplier_id, supplier_name, supplier_phone
	FROM
		suppliers;
	
-- Dropping the view
DROP VIEW phones;

-------------------------------------------------------------------------------------------------------------------------------------
-- Practical task 3 -- Creating scripts
-------------------------------------------------------------------------------------------------------------------------------------

-- 1) Script: list of customers whos phone number is listed as phone number of another customer
SELECT 
	ARRAY_AGG(customer_id) AS customer_ids_duplicate_phones,
	ARRAY_AGG(customer_name) AS customer_names_duplicate_phones,
	customer_phone
FROM customers c
WHERE customer_phone IS NOT NULL
GROUP BY customer_phone;

-- 2) Script: using left and right joins, find customers without orders and orders without active customers

-- Finding customers without orders:
SELECT c.customer_id, customer_name
FROM customers c
LEFT OUTER JOIN orders o
ON
	c.customer_id = o.customer_id
WHERE order_id IS NULL
ORDER BY c.customer_id;

-- Finding orders without active customers:
SELECT o.order_id, c.customer_profile_status
FROM customers c
RIGHT OUTER JOIN orders o
ON
	c.customer_id = o.customer_id
WHERE c.customer_profile_status = FALSE;

-- 3) Script: using full join, find customers without orders and orders without active customers

-- Finding customers without orders
SELECT c.customer_id, customer_name, o.order_id
FROM customers c
FULL OUTER JOIN orders o
ON
	c.customer_id = o.customer_id
ORDER BY c.customer_id;
	
-- Finding orders without active customers
SELECT o.order_id, c.customer_profile_status
FROM orders o
FULL OUTER JOIN customers c
ON
	c.customer_id = o.customer_id
WHERE c.customer_profile_status = FALSE;

