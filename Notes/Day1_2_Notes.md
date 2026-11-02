# Data Engineering Notes

## Table of Contents

- [Data Storage Architectures](#data-storage-architectures)
- [Data Types in Engineering](#data-types-in-engineering)
- [Core Data Modeling Concepts](#core-data-modeling-concepts)
- [Schema Types & Use Cases](#schema-types--use-cases)
- [Querying Schemas and JOINs](#querying-schemas-and-joins)

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
