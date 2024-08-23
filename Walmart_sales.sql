CREATE TABLE IF NOT EXISTS sales (
    invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price NUMERIC(10, 2) NOT NULL,
    quantity INT NOT NULL,
    VAT NUMERIC(6, 4) NOT NULL,
    total NUMERIC(12, 4) NOT NULL,
    sales_date DATE NOT NULL,
    sales_time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs NUMERIC(10, 2) NOT NULL,
    gross_margin_percentage NUMERIC(11, 9) NOT NULL,
    gross_income DECIMAL(12, 4) NOT NULL,
    rating NUMERIC(2, 1) NOT NULL
);
-------------------------------------------------------------------------
-- time_of_day 
SELECT sales_time,
    CASE
        WHEN sales_time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN sales_time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        WHEN sales_time BETWEEN '16:01:00' AND '19:00:00' THEN 'Evening'
        ELSE 'Night'
    END AS time_of_day
FROM sales;
ALTER TABLE sales
ADD COLUMN time_of_day VARCHAR(20);
UPDATE sales
SET time_of_day = CASE
        WHEN sales_time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN sales_time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        WHEN sales_time BETWEEN '16:01:00' AND '19:00:00' THEN 'Evening'
        ELSE 'Night'
    END;
--day_name
SELECT sales_date,
    TO_CHAR(sales_date, 'Dy') AS day_name
FROM sales;
ALTER TABLE sales
ADD COLUMN day_name VARCHAR(10);
UPDATE sales
SET day_name = TO_CHAR(sales_date, 'Dy');
--month_name
SELECT sales_date,
    TO_CHAR(sales_date, 'Mon') AS month_name
FROM sales;
ALTER TABLE sales
ADD COLUMN month_name VARCHAR(10);
UPDATE sales
SET month_name = TO_CHAR(sales_date, 'Mon');
------------------------------GENERIC---------------------------------
--How many unique city does the data contain?
SELECT COUNT(DISTINCT city)
FROM sales;
--In which city is each branch?
SELECT DISTINCT branch,
    city
FROM sales
GROUP BY branch,
    city;
------------------------------PRODUCT---------------------------------
--How many unique product lines does the data have?
SELECT COUNT(DISTINCT product_line)
FROM sales;
--What is the most common payment method?
SELECT payment_method,
    COUNT(payment_method)
FROM sales
GROUP BY payment_method
ORDER BY COUNT(payment_method) DESC;
--What is the most selling product line?
SELECT product_line,
    count(*)
FROM sales
GROUP BY product_line
ORDER BY count(*) DESC;
--What is the total revenue by month?
SELECT month_name,
    SUM(total) AS total_revenue
FROM sales
GROUP BY month_name,
    EXTRACT(
        MONTH
        FROM sales_date
    )
ORDER BY EXTRACT(
        MONTH
        FROM sales_date
    );
--What month had the largest COGS?
SELECT month_name,
    SUM(cogs) AS total_cogs
FROM sales
GROUP BY month_name
ORDER BY month_name DESC;
--What product line had the largest revenue?
SELECT product_line,
    SUM(total) AS revenue_product
FROM sales
GROUP BY product_line
ORDER BY SUM(total) DESC;
--What is the city with the largest revenue?
SELECT city,
    SUM(total) AS revenue_city
FROM sales
GROUP BY city
ORDER BY SUM(total) DESC;
--What product line had the largest VAT?
SELECT product_line,
    AVG(VAT) AS average_VAT
FROM sales
GROUP BY product_line
ORDER BY AVG(VAT) DESC;
--Fetch each product line and add a column to those product line 
--showing "Good", "Bad". Good if its greater than average sales
SELECT product_line,
    (
        CASE
            WHEN AVG(total) > (
                SELECT AVG(total)
                FROM sales
            ) THEN 'Good'
            ELSE 'Bad'
        END
    ) AS remarks
FROM sales
GROUP BY product_line;
--Which branch sold more products than average product sold?
SELECT branch,
    SUM(quantity) AS quantity
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (
        SELECT AVG(quantity)
        FROM sales
    )
ORDER BY branch;
--What is the most common product line by gender?
SELECT gender,
    product_line,
    COUNT(*)
FROM sales
GROUP BY gender,
    product_line
ORDER BY gender,
    COUNT(*) DESC;
--What is the average rating of each product line?
SELECT product_line,
    AVG(rating) AS average_rating
FROM sales
GROUP BY product_line;
------------------------------SALES---------------------------------
--Number of sales made in each time of the day per weekday
SELECT day_name,
    time_of_day,
    COUNT(*) AS sales_count
FROM sales
GROUP BY day_name,
    time_of_day
ORDER BY day_name,
    time_of_day;
--Which of the customer types brings the most revenue?
SELECT customer_type,
    SUM(total) AS revenue_customer
FROM sales
GROUP BY customer_type
ORDER BY SUM(total) DESC;
--Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT city,
    AVG(VAT) AS average_vat
FROM sales
GROUP BY city
ORDER BY AVG(VAT) DESC;
--Which customer type pays the most in VAT?
SELECT customer_type,
    AVG(VAT) AS average_vat
FROM sales
GROUP BY customer_type
ORDER BY AVG(VAT) DESC;
------------------------------CUSTOMER---------------------------------
--How many unique customer types does the data have?
SELECT COUNT(DISTINCT customer_type)
FROM sales;
--How many unique payment methods does the data have?
SELECT COUNT(DISTINCT payment_method)
FROM sales;
--What is the most common customer type?
SELECT customer_type,
    COUNT(*)
FROM sales
GROUP BY customer_type
ORDER BY COUNT(*) DESC;
--Which customer type buys the most?
SELECT customer_type,
    SUM(total) sales_customer
FROM sales
GROUP BY customer_type
ORDER BY SUM(total);
--What is the gender breakdown of the customers?
SELECT gender,
    count(*)
FROM sales
GROUP BY gender;
--What is the gender distribution per branch?
SELECT branch,
    gender,
    count(*)
FROM sales
GROUP BY branch,
    gender
ORDER BY branch;
--Which time of the day do customers give most ratings?
SELECT time_of_day,
    ROUND(AVG(rating), 2) AS average_rating
FROM sales
GROUP BY time_of_day
ORDER BY average_rating DESC;
--Which time of the day do customers give most ratings per branch?
SELECT branch,
    time_of_day,
    ROUND(AVG(rating), 2) AS average_rating
FROM sales
GROUP BY branch,
    time_of_day
ORDER BY branch;
--Which day fo the week has the best avg ratings?
SELECT day_name,
    ROUND(AVG(rating), 2) AS average_rating
FROM sales
GROUP BY day_name
ORDER BY average_rating DESC;
--Which day of the week has the best average ratings per branch?
SELECT branch,
    day_name,
    ROUND(AVG(rating), 2) AS average_rating
FROM sales
GROUP BY branch,
    day_name
ORDER BY branch,
    average_rating DESC;