# Data Engineering Notes

## Table of Contents

- [Data Storage Architectures](#data-storage-architectures)
- [Data Types in Engineering](#data-types-in-engineering)
- [Core Data Modeling Concepts](#core-data-modeling-concepts)
- [Schema Types & Use Cases](#schema-types--use-cases)
- [Querying Schemas and JOINs](#querying-schemas-and-joins)
- [GROUP BY Aggregation](#group-by-aggregation)
- [HAVING Clause](#having-clause)
- [Database Operations (CRUD & DQL)](#database-operations-crud--dql)
- [The WHERE Clause](#the-where-clause)

---

## Data Storage Architectures

| Architecture | Purpose | Key Characteristics |
|---|---|---|
| **Database** | Stores day-to-day operational data for specific applications | Handles current, frequently updated data for transactions (**OLTP**) |
| **Data Warehouse** | Centralized repository integrating data from multiple sources | Used for historical analysis and business intelligence |
| **Data Mart** | Smaller, department-specific subset of a data warehouse | Tailored for functions like Sales or Finance |

---

## Data Types in Engineering

| Data Type | Description | Typically Managed By |
|---|---|---|
| **Unstructured** | Raw formats like text, audio, images, or video | AWS S3, Azure Blob Storage |
| **Semi-Structured** | Loose frameworks like JSON or XML | NoSQL databases (e.g., MongoDB) |
| **Structured** | Highly organized, tabular data | RDBMS (e.g., Oracle, PostgreSQL) |

---

## Core Data Modeling Concepts

- **ER Diagram:** A visual map showing how database tables relate to one another.
- **Cardinality:** Defines numerical relationships between entities (`1:1`, `1:N`, or `M:N`).
- **Fact Table:** The central table in a schema, storing quantitative metrics and foreign keys.
- **Dimension Table:** Surrounding tables storing qualitative, descriptive attributes that provide context to the facts.
- **Quantitative vs. Qualitative:**
  - *Quantitative* data is numeric and measurable (e.g., revenue).
  - *Qualitative* data is descriptive (e.g., location) and groups the facts.

---

## Schema Types & Use Cases

### Star Schema

A central fact table directly connected to **denormalized** dimension tables.

- Requires fewer joins, so query performance is much faster.
- **Ideal for:** Pharmacy real-time sales/inventory reporting.

### Snowflake Schema

A central fact table connected to **normalized** dimension tables that branch out further.

- Saves storage space at the cost of query complexity.

**Car Manufacturer Snowflake Example:**

```text
Vehicle_Sales_Fact
        │
        ▼
Dealership_Dim   (Level 1)
        │
        ▼
City_Dim         (Level 2)
        │
        ▼
Region_Dim       (Level 3)
```

### Quick Comparison

| Feature | Star Schema | Snowflake Schema |
|---|---|---|
| Dimension tables | Denormalized | Normalized |
| Number of joins | Fewer | More |
| Query performance | Faster | Slower |
| Storage usage | Higher | Lower |
| Query complexity | Simple | Complex |

---

## Querying Schemas and JOINs

### Schema Notation

In enterprise environments, tables belong to a specific owner or schema. To query them, use `schema_name.table_name`:

```sql
FROM hr.employees
```

### JOIN Clause

Combines rows from two or more tables based on a related column between them (usually a **Primary Key** to **Foreign Key** relationship).

### Table Aliases

When joining tables, use short aliases (like `e` for `employees` and `d` for `departments`) to avoid typing the full schema and table name repeatedly.

### JOIN Example

```sql
-- Retrieves the employee's name from one table and their department name from another
SELECT e.first_name, d.department_name
FROM hr.employees e
JOIN hr.departments d
  ON e.department_id = d.department_id;
```

---

## GROUP BY Aggregation

`GROUP BY` collapses multiple rows sharing a common attribute into a single summary row using aggregate functions.

### Core Aggregate Functions

| Function | Description |
|---|---|
| `COUNT()` | Total number of rows |
| `SUM()` | Total of a numeric column |
| `AVG()` | Average of a numeric column |
| `MAX()` / `MIN()` | Highest / lowest value |

> **The Golden Rule:** Any column in the `SELECT` clause that is not wrapped in an aggregate function must explicitly appear in the `GROUP BY` clause.

```sql
-- Calculates total headcount and average salary per department
SELECT department_id,
       COUNT(employee_id) AS total_employees,
       ROUND(AVG(salary), 2) AS average_salary
FROM hr.employees
GROUP BY department_id;
```

---

## HAVING Clause

- Filters entire **groups** based on the results of an aggregate function.
- Used strictly **after** `GROUP BY` has organized the data into groups, because `WHERE` cannot evaluate aggregate functions.

```sql
-- Finds only departments that have more than 100 employees
SELECT department_id,
       COUNT(employee_id) AS total_employees
FROM hr.employees
GROUP BY department_id
HAVING COUNT(employee_id) > 100;
```

---

## Database Operations (CRUD & DQL)

- **CRUD:** The four foundational database operations: **C**reate, **R**ead, **U**pdate, and **D**elete.
- **DQL (Data Query Language):** The subset of SQL dedicated to the "Read" operation, letting you query and retrieve information without altering the underlying data.

### Anatomy of a Complete DQL Query

When combining clauses in a `SELECT` statement, they must be written in this order:

| Order | Clause | Purpose |
|---|---|---|
| 1 | `SELECT` | Chooses columns to display |
| 2 | `FROM schema_name.table_name` | Specifies the primary source table |
| 3 | `JOIN` | Connects additional tables based on related columns |
| 4 | `WHERE` | Filters individual rows **before** any grouping |
| 5 | `GROUP BY` | Collapses data into summary rows |
| 6 | `HAVING` | Filters the summarized groups |
| 7 | `ORDER BY` | Sorts the final result set |

---

## The WHERE Clause

- **Purpose:** Acts as a boolean gatekeeper that filters individual rows before any aggregations are applied.
- **Mechanism:** Checks a condition using operators (`=`, `>`, `<`, `AND`, `OR`). If the condition evaluates to `TRUE`, the row is included; if `FALSE` or `NULL`, the row is discarded.

```sql
-- Filters the table to only include employees earning over 10,000
SELECT employee_id, first_name, salary
FROM hr.employees
WHERE salary > 10000;
```

### WHERE vs. HAVING

| Feature | `WHERE` | `HAVING` |
|---|---|---|
| Filters | Individual rows | Groups |
| Runs | Before `GROUP BY` | After `GROUP BY` |
| Can use aggregate functions | No | Yes |
