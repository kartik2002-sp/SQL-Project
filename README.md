# SQL-Project

A comprehensive collection of SQL scripts demonstrating advanced data analytics solutions using Microsoft SQL Server and MySQL. This repository contains case studies, practical projects, and hands-on exercises covering complex query patterns, optimization techniques, and real-world database challenges.

---

## 📁 Repository Structure

### **Case Studies (Advanced Analytics)**

#### **CASE STUDY 1.sql** - Customer Loyalty & Rewards Analysis
**Database:** Diner Analytics  
**Domain:** Customer behavior analysis and loyalty program optimization

**Key Functions & Techniques:**
- **Window Functions:**
  - `DENSE_RANK()` OVER (PARTITION BY customer_id) - Ranking products by frequency per customer
  - `DENSE_RANK()` OVER (PARTITION BY customer_id ORDER BY order_date) - Temporal ranking
- **Common Table Expressions (CTEs):** 5+ nested CTEs for multi-stage data transformation
- **Conditional Aggregation:**
  - `CASE WHEN` statements for conditional scoring (sushi multiplier logic)
  - Dynamic point calculation based on membership status and purchase date
- **Date Functions:**
  - `DATE_ADD()` for membership anniversary calculations
  - Date range filtering with `BETWEEN` operator
- **JOIN Operations:** Multiple INNER & LEFT JOINs across sales, menu, and members tables

**Queries Included (7 questions):**
1. Most popular item per customer using ranking
2. First post-membership purchase identification
3. Last pre-membership purchase detection
4. Pre-membership spending analysis
5. Point calculation with dynamic multipliers
6. First-week bonus points with complex CASE logic
7. Member ranking with NULL handling for non-members

**Business Value:** Optimizing customer retention and rewards allocation

---

#### **CASE STUDY 2.sql** - Pizza Delivery Operations Analytics
**Database:** pizza_runner  
**Domain:** Operational efficiency, supply chain optimization

**Key Functions & Techniques:**
- **String Manipulation:**
  - `SUBSTRING_INDEX()` for parsing comma-separated values
  - `TRIM()` and `REPLACE()` for data cleaning
  - `CAST()` for type conversion of string numbers
- **Recursive CTEs (RECURSIVE):**
  - Number generator for splitting delimited strings
  - Dynamic ingredient list generation (up to 15 toppings)
- **Window Functions:**
  - `ROW_NUMBER()` OVER (ORDER BY order_id, pizza_id) for unique row identification
  - `LEAD()` for finding next plan dates
- **Aggregate Functions:**
  - `GROUP_CONCAT()` for string aggregation
  - `CONCAT_WS()` for conditional string concatenation
- **Complex Logic:**
  - Ingredient pool management (base - exclusions + extras)
  - Date arithmetic for payment schedules
  - NULL handling for malformed data

**Sections:**
- **A. Ingredient Optimization:** Standard ingredients, most added extras, most excluded toppings, order descriptions
- **B. Pricing & Ratings:** Revenue calculation, extra charges, runner ratings, delivery metrics, net profit

**Key Queries:**
- Pizza recipe parsing and ingredient aggregation
- Exclusions/extras counting and description generation
- Revenue computation with extras and discounts
- Running averages and speed calculations

**Business Value:** Cost optimization, ingredient forecasting, runner performance analytics

---

#### **CASE STUDY 3.sql** - Subscription Analytics (Foodie-Fi)
**Database:** foodie_fi  
**Domain:** SaaS metrics, churn analysis, revenue recognition

**Key Functions & Techniques:**
- **Ranking & Sequencing:**
  - `ROW_NUMBER()` OVER (PARTITION BY customer_id ORDER BY start_date) - Sequential plan tracking
  - Identifying plan transitions and downgrades
- **Date Arithmetic:**
  - Date differences for upgrade timing analysis
  - `EXTRACT(YEAR FROM date)` for temporal filtering
  - Percentile calculations using date buckets
- **Recursive CTEs:**
  - Payment schedule generation (monthly recurrence)
  - `LEAD()` for identifying next plan dates
  - Complex transition logic for discount application
- **Aggregate Functions:**
  - `COUNT(DISTINCT)` for unique customer metrics
  - Percentage calculations with `100.0 * COUNT(*) / total`
- **Window Functions for Running Calculations**

**Queries Included (9 main questions):**
1. Churn count and percentage
2. Churn after free trial percentage
3. Post-trial plan distribution
4. Plan distribution at year-end 2020
5. Annual plan upgrades in 2020
6. Average days to upgrade from trial
7. 30-day period breakdown of upgrade timing
8. Downgrades from pro to basic
9. **Payment Table Creation:** Complex recursive generation with monthly schedule and transition discounts

**Business Value:** Customer lifecycle analysis, revenue prediction, churn prevention strategies

---

#### **CASE STUDY 4.sql** - Data Bank Operations Analytics
**Database:** databank  
**Domain:** Resource allocation, balance tracking, financial analytics

**Key Functions & Techniques:**
- **Running Calculations:**
  - `SUM() OVER (PARTITION BY customer_id ORDER BY txn_date)` - Running balance
  - Cumulative sums for closing balance tracking
- **Window Functions:**
  - `ROW_NUMBER()` for row numbering in percentile calculations
  - `LAG()` for previous balance comparisons
  - `AVG() OVER (... RANGE BETWEEN INTERVAL 30 DAY PRECEDING AND CURRENT ROW)` - Rolling averages
- **CASE Statements:**
  - Conditional deposit/withdrawal logic
  - Balance growth detection (>5% increase)
- **Percentile Calculations:**
  - Manual percentile logic using ROW_NUMBER and position calculations
  - Median, 80th, 95th percentile derivation
- **Monthly Aggregation:**
  - `LAST_DAY()` for month-end dates
  - `DATE_FORMAT()` for month grouping
  - Hierarchical month-over-month analysis

**Sections:**
- **A. Customer Node Allocation:** Unique nodes, regional distribution, reallocation analysis
- **B. Transaction Analytics:** Transaction counts, deposit averages, monthly transaction patterns
- **C. Data Allocation Challenge:**
  - Running customer balance with running sum
  - Month-end closing balances
  - Min/Max/Avg running balance per customer
  - Data allocation based on previous month balance
  - Data allocation based on 30-day rolling average

**Business Value:** Infrastructure planning, resource allocation optimization, financial forecasting

---

### **SQL Projects (Hands-On Implementation)**

#### **SQL Project 1.sql** - User-Defined Functions & Data Manipulation
**Database:** Jomato (Restaurant Analytics)

**Key Functions & Techniques:**
1. **User-Defined Scalar Functions:**
   - String concatenation function for data transformation
   - Function application in UPDATE statements with transactions
   - ROLLBACK to demonstrate reversibility

2. **Window Functions:**
   - `MAX()` with GROUP BY for ranking

3. **Mathematical Functions:**
   - `CEILING()` - Rounding up
   - `FLOOR()` - Rounding down
   - `ABS()` - Absolute values

4. **Date Functions:**
   - `GETDATE()` - Current timestamp
   - `DATEPART()` - Extract date components
   - `DATENAME()` - Return month/day names

5. **Aggregation with ROLLUP:**
   - Hierarchical grouping for total cost analysis
   - Grand total generation

**Queries:**
1. Custom function for menu name transformation
2. Restaurant with maximum ratings and cuisine type
3. Rating status classification (Excellent/Good/Average/Bad)
4. Math functions applied to ratings with current date details
5. Restaurant type cost aggregation with ROLLUP

**Business Value:** Restaurant performance analysis, quality assessment, cost tracking

---

#### **SQL Project 2.sql** - Stored Procedures, Transactions & Advanced Features
**Database:** Jomato (Restaurant Analytics)

**Key Functions & Techniques:**
1. **Stored Procedures:**
   - Parameterized queries for restaurant filtering
   - LIKE pattern matching within procedures
   - Encapsulation of business logic

2. **Transactions:**
   - `BEGIN TRANSACTION` and `ROLLBACK` for data integrity
   - Safe testing of destructive operations

3. **Window Functions:**
   - `ROW_NUMBER()` OVER (PARTITION BY area ORDER BY Rating DESC) - Top N per group
   - Filtering with `WHERE rn = 1` for ranking

4. **Control Flow:**
   - WHILE loop for iterative operations
   - Counter-based iteration

5. **Views:**
   - CREATE VIEW for data abstraction
   - Persistent query definitions

6. **Triggers:**
   - AFTER INSERT trigger definition
   - Email notification integration (sp_send_dbmail)

**Queries:**
1. Stored procedure for restaurant booking availability
2. Transaction with ROLLBACK (cuisine type update)
3. CTE + Window functions for top 5 rated areas
4. WHILE loop generating numbers 1-50
5. View creation for top 5 restaurants
6. Trigger for email notifications on new inserts

**Business Value:** Data quality assurance, automated notifications, performance optimization

---

#### **SQL Project 3.sql** - Analytics & Complex Joins (Product Sales Analysis)
**Database:** Multi-table sales data (Location, Product, Fact tables)

**Key Functions & Techniques:**
1. **Aggregate Functions:**
   - `COUNT(DISTINCT)` - Unique value counts
   - `SUM()` - Revenue aggregation
   - `AVG()` - Averaging metrics
   - `MIN()` / `MAX()` - Boundary detection
   - `TOP 1 ... ORDER BY` - Single extreme value selection

2. **JOIN Operations:**
   - INNER JOIN for enforced relationships
   - LEFT JOIN for optional relationships
   - Multiple table joins (Fact, Product, Location)

3. **Window Functions:**
   - `DENSE_RANK()` OVER (ORDER BY Sales) - Ranking without gaps

4. **Stored Procedures:**
   - Parameterized SELECT with @variable inputs
   - Type-specific filtering

5. **Date Functions:**
   - `DATEADD(WEEK, DATEDIFF(WEEK, 0, [Date]), 0)` - Week grouping

6. **CASE Statements:**
   - Profit/loss determination based on expense thresholds

7. **Set Operations:**
   - UNION - Combining distinct values
   - INTERSECT - Finding common values

8. **User-Defined Functions (Table-Valued):**
   - Returning filtered table based on parameter
   - RETURN with WHERE clause filter

9. **String Functions:**
   - `ASCII()` - Character code extraction
   - `SUBSTRING()` - Character position access

10. **ROLLUP:**
    - Weekly hierarchical aggregation
    - Multi-level grouping for summaries

**Queries (29 total):**
1. Distinct state count
2. Regular product type count
3. Marketing spend for product ID 1
4. Minimum product sales
5. Maximum COGS (Cost of Goods Sold)
6. Coffee product details with joins
7. Expenses > 40 filtering
8. Area code 719 average sales
9. Colorado state total profit
10. Average inventory per product
11. Distinct state listing
12. Average budget with HAVING clause
13. Total sales on specific date
14. Average expenses by product and date
15. Complex multi-table join aggregation
16. Sales-wise ranking with DENSE_RANK
17. State-wise profit and sales
18. Product-wise state profit and sales
19. Sales projection with 5% increase
20. Maximum profit with product details
21. **Stored Procedure:** Fetch products by type
22. **CASE Logic:** Profit/Loss classification
23. **ROLLUP:** Weekly sales hierarchy
24. **UNION:** Area code consolidation
25. **INTERSECT:** Common area codes
26. **User-Defined Function (Table-Valued):** Product type filter
27. **Transactions:** Product type update with ROLLBACK
28. Delete regular type products
29. ASCII value of fifth character in product name

**Business Value:** Sales analysis, profitability insights, inventory management, trend analysis

---

## 🔧 Technologies & SQL Dialects

- **T-SQL (SQL Server):** CASE STUDY 1, SQL Projects 1-3
- **MySQL:** CASE STUDY 2, CASE STUDY 3, CASE STUDY 4
- **Advanced Features Used:**
  - Window Functions (PARTITION BY, ORDER BY, OVER clauses)
  - Common Table Expressions (CTEs and Recursive CTEs)
  - Stored Procedures & User-Defined Functions
  - Transactions & Triggers
  - Views & Joins
  - Complex Aggregations & Ranking

---

## 📊 Key Concepts Demonstrated

### **Data Transformation**
- String parsing and manipulation
- Type casting and conversion
- Date arithmetic and formatting
- Hierarchical data aggregation

### **Analytics Patterns**
- Customer behavioral analysis
- Time-series data analysis
- Cohort analysis
- Churn prediction
- Revenue recognition

### **Performance Techniques**
- Window functions for efficient ranking
- CTEs for readable complex queries
- Proper JOIN strategies
- Indexed column usage patterns

### **Data Quality**
- NULL handling strategies
- Data validation with CASE statements
- Transaction management
- ROLLBACK for safety

---

## 🚀 How to Use

1. **For Learning:** Study each file in order, starting with SQL Project files for fundamentals, then progress to Case Studies for advanced patterns
2. **For Reference:** Use specific queries as templates for your own SQL development
3. **For Practice:** Modify queries to work with your own databases and data structures
4. **For Interview Prep:** These represent common SQL interview questions and patterns

---

## 📝 Query Complexity Levels

- **Beginner:** SQL Project 1 (basic functions, CASE statements)
- **Intermediate:** SQL Project 2 & 3 (stored procedures, views, complex joins)
- **Advanced:** CASE STUDIES 1-4 (window functions, CTEs, recursive logic)

---

## 💡 Notable Techniques

- **Recursive CTEs** for string splitting and schedule generation
- **Window Functions** for ranking without loss of detail
- **Complex CASE Logic** for conditional aggregations
- **Rolling Averages** for trend analysis
- **Percentile Calculations** for distribution analysis
- **Hierarchical Aggregation** with ROLLUP
- **Transaction Safety** with ROLLBACK

---

## 📌 License

This repository contains educational SQL examples and case studies for learning and reference purposes.

---

*Last Updated: June 2026*
