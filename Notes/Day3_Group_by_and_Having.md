
- [GROUP BY Aggregation](#group-by-aggregation)
- [HAVING Clause](#having-clause)
- [Database Operations (CRUD & DQL)](#database-operations-crud--dql)
- [The WHERE Clause](#the-where-clause)

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
