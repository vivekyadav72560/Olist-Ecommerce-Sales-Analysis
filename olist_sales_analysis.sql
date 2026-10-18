
-- =====================================================
-- PROJECT: Olist E-commerce Sales Analysis
-- DATABASE: olist_ecommerce
-- TOOL: MySQL 8.0
--
-- OBJECTIVE:
-- Analyze e-commerce sales, product performance,
-- customer behavior, payment methods, order statuses,
-- and customer satisfaction.
--
-- SQL CONCEPTS:
-- SELECT, JOIN, GROUP BY, ORDER BY, subqueries,
-- aggregate functions, and date functions.
-- =====================================================

USE olist_ecommerce;

SELECT 'orders' AS dataset, COUNT(*) AS total_rows
FROM olist_orders_dataset

UNION ALL
SELECT 'order_items', COUNT(*)
FROM olist_order_items_dataset

UNION ALL
SELECT 'customers', COUNT(*)
FROM olist_customers_dataset

UNION ALL
SELECT 'products', COUNT(*)
FROM olist_products_dataset

UNION ALL
SELECT 'payments', COUNT(*)
FROM olist_order_payments_dataset

UNION ALL
SELECT 'sellers', COUNT(*)
FROM olist_sellers_dataset

UNION ALL
SELECT 'reviews', COUNT(*)
FROM olist_order_reviews_dataset

UNION ALL
SELECT 'geolocation', COUNT(*)
FROM olist_geolocation_dataset

UNION ALL
SELECT 'category_translations', COUNT(*)
FROM product_category_name_translation;

-- =========================================
-- OLIST E-COMMERCE SALES ANALYSIS
-- SECTION 1: KEY BUSINESS METRICS
-- =========================================

USE olist_ecommerce;

SELECT
    (SELECT COUNT(DISTINCT order_id)
     FROM olist_orders_dataset) AS total_orders,

    (SELECT COUNT(DISTINCT customer_unique_id)
     FROM olist_customers_dataset) AS total_customers,

    (SELECT ROUND(SUM(price), 2)
     FROM olist_order_items_dataset) AS total_product_revenue,

    (SELECT ROUND(SUM(freight_value), 2)
     FROM olist_order_items_dataset) AS total_freight;


-- =========================================
-- SECTION 2: TOP 10 PRODUCT CATEGORIES
-- =========================================

SELECT
    COALESCE(
        t.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS category,
    ROUND(SUM(oi.price), 2) AS revenue
FROM olist_order_items_dataset AS oi
JOIN olist_products_dataset AS p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation AS t
    ON p.product_category_name = t.product_category_name
GROUP BY category
ORDER BY revenue DESC
LIMIT 10;


-- =========================================
-- SECTION 3: MONTHLY DELIVERED-ORDER REVENUE
-- =========================================

SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
        AS order_month,
    ROUND(SUM(oi.price), 2) AS delivered_product_revenue,
    COUNT(DISTINCT o.order_id) AS delivered_orders
FROM olist_orders_dataset AS o
JOIN olist_order_items_dataset AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
ORDER BY order_month;


-- =========================================
-- SECTION 4: PAYMENT METHOD ANALYSIS
-- =========================================

SELECT
    payment_type,
    COUNT(*) AS total_payment_records,
    ROUND(SUM(payment_value), 2) AS total_payment_value,
    ROUND(AVG(payment_value), 2) AS average_payment_value
FROM olist_order_payments_dataset
GROUP BY payment_type
ORDER BY total_payment_value DESC;


-- =========================================
-- SECTION 5: ORDER STATUS ANALYSIS
-- =========================================

SELECT
    order_status,
    COUNT(*) AS total_orders,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*)
         FROM olist_orders_dataset),
        2
    ) AS percentage_of_orders
FROM olist_orders_dataset
GROUP BY order_status
ORDER BY total_orders DESC;


-- =========================================
-- SECTION 6: TOP 10 CUSTOMER STATES BY REVENUE
-- =========================================

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM olist_customers_dataset AS c
JOIN olist_orders_dataset AS o
    ON c.customer_id = o.customer_id
JOIN olist_order_items_dataset AS oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC
LIMIT 10;


-- =========================================
-- SECTION 7: TOP 10 BEST-SELLING PRODUCTS
-- =========================================

SELECT
    oi.product_id,
    COUNT(*) AS units_sold,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM olist_order_items_dataset AS oi
GROUP BY oi.product_id
ORDER BY units_sold DESC
LIMIT 10;


-- =========================================
-- SECTION 8: CUSTOMER REVIEW ANALYSIS
-- =========================================

SELECT
    review_score,
    COUNT(*) AS total_reviews,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*)
         FROM olist_order_reviews_dataset),
        2
    ) AS percentage_of_reviews
FROM olist_order_reviews_dataset
GROUP BY review_score
ORDER BY review_score DESC;

