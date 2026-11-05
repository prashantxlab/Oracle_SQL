# Day 6: TO_CHAR & Window Frames (Cumulative Sum)

> **Database:** Oracle SQL. Examples use the class sales table (Sept 2026) and the employee salary table.

## 1. TO_CHAR

Converts a **date or number into text**, using a format you choose. Syntax: `TO_CHAR(value, 'format')`

### Date formats
| Format | Meaning | `DATE '2026-09-05'` gives |
|---|---|---|
| `YYYY` | 4-digit year | 2026 |
| `MM` | Month number | 09 |
| `MON` | Short month name | SEP |
| `MONTH` | Full month name | SEPTEMBER |
| `DD` | Day of month | 05 |
| `DY` | Short day name | SAT |
| `DAY` | Full day name | SATURDAY |
| `HH24:MI:SS` | 24-hour time | 14:30:00 |

```sql
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD')          FROM DUAL;   -- 2026-09-05
SELECT TO_CHAR(SYSDATE, 'DD-MON-YYYY')         FROM DUAL;   -- 05-SEP-2026
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') FROM DUAL; -- date + time
SELECT TO_CHAR(SYSDATE, 'FMDay')               FROM DUAL;   -- Saturday
```

### Number formats
| Format | Meaning | Example | Result |
|---|---|---|---|
| `9` | A digit (blank if no digit) | `TO_CHAR(24000, '99,999')` | ` 24,000` |
| `0` | A digit (shows leading zero) | `TO_CHAR(5, '000')` | ` 005` |
| `,` / `.` | Thousands separator / decimal point | `TO_CHAR(1234.5, '9,999.99')` | ` 1,234.50` |

### Points to remember
- The result is a **string**, not a date or number, so you can't do date arithmetic on it.
- `FM` prefix removes the padding spaces (`DAY` pads to 9 characters; `FMDay` doesn't).
- **Useful for grouping by month:** `GROUP BY TO_CHAR(sale_date, 'YYYY-MM')`.

---

## 2. Window frames

A **window function** (like `SUM() OVER`) works on a set of rows around the current row. The **frame** says exactly *which* rows are included.

```sql
function() OVER (
  [PARTITION BY col]          -- restart for each group
  ORDER BY col                -- order of rows
  ROWS BETWEEN <start> AND <end>   -- the frame
)
```

### Frame keywords
| Keyword | Meaning |
|---|---|
| `UNBOUNDED PRECEDING` | From the **first** row of the partition |
| `n PRECEDING` | `n` rows **before** the current row |
| `CURRENT ROW` | The current row itself |
| `n FOLLOWING` | `n` rows **after** the current row |
| `UNBOUNDED FOLLOWING` | Up to the **last** row of the partition |

```
Rows:   1    2    3    4    5
                  ▲
             current row (row 3)

1 PRECEDING AND 1 FOLLOWING  →  rows 2, 3, 4
```

### Sample data (from class)
| Sale ID | Sale Date | Product | Sales Amount |
|---|---|---|---|
| 1 | 1-Sep-26 | Laptop | 50,000 |
| 2 | 2-Sep-26 | Mouse | 1,000 |
| 3 | 3-Sep-26 | Keyboard | 2,000 |
| 4 | 4-Sep-26 | Monitor | 12,000 |
| 5 | 5-Sep-26 | Headphones | 3,000 |

### All frames on `SUM(sales_amount)` ordered by `sale_date`
| Frame | Sale 1 | Sale 2 | Sale 3 | Sale 4 | Sale 5 |
|---|---|---|---|---|---|
| `UNBOUNDED PRECEDING AND CURRENT ROW` | 50,000 | 51,000 | 53,000 | 65,000 | 68,000 |
| `1 PRECEDING AND CURRENT ROW` | 50,000 | 51,000 | 3,000 | 14,000 | 15,000 |
| `2 PRECEDING AND CURRENT ROW` | 50,000 | 51,000 | 53,000 | 15,000 | 17,000 |
| `CURRENT ROW AND 1 FOLLOWING` | 51,000 | 3,000 | 14,000 | 15,000 | 3,000 |
| `1 PRECEDING AND 1 FOLLOWING` | 51,000 | 53,000 | 15,000 | 17,000 | 15,000 |
| `CURRENT ROW AND UNBOUNDED FOLLOWING` | 68,000 | 18,000 | 17,000 | 15,000 | 3,000 |
| `UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING` | 68,000 | 68,000 | 68,000 | 68,000 | 68,000 |
| `CURRENT ROW AND CURRENT ROW` | 50,000 | 1,000 | 2,000 | 12,000 | 3,000 |

Check one: at Sale 3 with `1 PRECEDING AND 1 FOLLOWING` → rows 2, 3, 4 → 1,000 + 2,000 + 12,000 = **15,000**.

```sql
SELECT sale_id, sale_date, sales_amount,
       SUM(sales_amount) OVER (
         ORDER BY sale_date
         ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
       ) AS moving_sum
FROM sales;
```

### Frames in plain words
| Frame | Used for |
|---|---|
| Unbounded preceding → current row | **Cumulative (running) total** |
| 1 or 2 preceding → current row | **Moving average / sum** of recent rows |
| Current row → 1 following | Look at today and tomorrow |
| 1 preceding → 1 following | **Centered moving average** |
| Current row → unbounded following | Running total from here to the end |
| Unbounded preceding → unbounded following | **Whole partition** (same value on every row) |
| Current row → current row | Just the row itself |

---

## 3. Cumulative sum

Add up values **from the start up to the current row**.

```sql
SELECT sale_id, sale_date, sales_amount,
       SUM(sales_amount) OVER (
         ORDER BY sale_date
         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS cumulative_sales
FROM sales;
```

| Sale ID | Sales Amount | Cumulative Sales |
|---|---|---|
| 1 | 50,000 | 50,000 |
| 2 | 1,000 | 51,000 |
| 3 | 2,000 | 53,000 |
| 4 | 12,000 | 65,000 |
| 5 | 3,000 | 68,000 |

Each row = the previous cumulative value + the current amount. Add `PARTITION BY` (for example by product or month) to restart the total for each group.

---

## 4. Unbounded preceding and unbounded following

The frame covers **every row** in the partition, so every row gets the same result. In the class example (employees 100 to 104):

| Employee ID | Salary | Frame sees |
|---|---|---|
| 100 | 24,000 | 100-104 |
| 101 | 17,000 | 100-104 |
| 102 | 17,000 | 100-104 |
| 103 | 9,000 | 100-104 |
| 104 | 6,000 | 100-104 |

```sql
SELECT employee_id, salary,
       SUM(salary) OVER (
         ORDER BY employee_id
         ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
       ) AS total_salary          -- 73,000 on every row
FROM hr.employees
WHERE employee_id BETWEEN 100 AND 104;
```
Total = 24,000 + 17,000 + 17,000 + 9,000 + 6,000 = **73,000**. Useful for "each salary as a share of the total" (`salary / total`).

### Points to remember
- If you write `ORDER BY` but **no frame**, Oracle's default is `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`. So `LAST_VALUE` seems to return the current row unless you use `UNBOUNDED FOLLOWING`.
- `ROWS` counts **physical rows**; `RANGE` treats rows with the **same ORDER BY value** (ties) as one unit. Use `ROWS` for predictable running totals.
- Rows near the edges have **smaller windows** (at Sale 1, `1 PRECEDING` has nothing to include).
- The `ROWS BETWEEN` frame needs `ORDER BY` so "preceding" and "following" mean something.

---

## 5. FIRST_VALUE with a frame (class example)

`FIRST_VALUE(col)` returns the value from the **first row of the frame**. `LAST_VALUE(col)` returns it from the **last row of the frame**.

```sql
SELECT employee_id, salary,
       FIRST_VALUE(salary) OVER (
         ORDER BY hire_date, employee_id
         ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
       ) AS first_hired_salary
FROM hr.employees
WHERE department_id = 50
ORDER BY hire_date, employee_id
FETCH FIRST 10 ROWS ONLY;
```
*(The class screenshot is cropped at the right edge; the alias `first_hired_salary` is added here to complete the query.)*

### Reading the query piece by piece
| Part | What it does |
|---|---|
| `WHERE department_id = 50` | Keeps only department 50 employees, **before** the window runs |
| `FIRST_VALUE(salary)` | Picks the salary of the first row in the frame |
| `ORDER BY hire_date, employee_id` (inside `OVER`) | Defines "first": the **earliest hired**; `employee_id` breaks ties on the same date |
| `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING` | Every row sees the **whole partition** |
| `ORDER BY ...` (outside) | Sorts the final output |
| `FETCH FIRST 10 ROWS ONLY` | Returns only 10 rows (Oracle 12c and later) |

**Result:** every row shows the **same** value, the salary of the earliest-hired employee in department 50, next to that employee's own salary. Illustrative output:

| employee_id | salary | first_hired_salary |
|---|---|---|
| 121 | 8,200 | 8,200 |
| 122 | 7,900 | 8,200 |
| 123 | 6,500 | 8,200 |
| 124 | 5,800 | 8,200 |

**Use cases:** compare each salary with the first (or starting) value, such as "how much more or less than the first hire?" → `salary - FIRST_VALUE(salary) OVER (...)`.

### Points to remember
- **Order of execution:** `WHERE` → window function → final `ORDER BY` → `FETCH FIRST`. So `FIRST_VALUE` is calculated over **all** department 50 rows, not just the 10 displayed.
- For `FIRST_VALUE`, the default frame (start to current row) gives the same answer, because the first row is always inside it. The explicit frame **matters for `LAST_VALUE`**:

```sql
LAST_VALUE(salary) OVER (
  ORDER BY hire_date, employee_id
  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
)   -- salary of the most recently hired employee in the dept
```
Without `UNBOUNDED FOLLOWING`, `LAST_VALUE` would just return the **current row's** salary.

---

## Quick revision
1. What does `TO_CHAR(SYSDATE, 'YYYY-MM-DD')` return, and what type is the result?
2. Which frame gives a cumulative sum, and what does "unbounded" mean?
3. For sales 50,000 / 1,000 / 2,000 / 12,000 / 3,000, what is `1 PRECEDING AND 1 FOLLOWING` at Sale 4?
4. What do you get from `UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING`?
5. `ROWS` vs `RANGE`: what is the difference when there are ties?
6. In the `FIRST_VALUE` example, why does every row show the same `first_hired_salary`, and why is `employee_id` in the `ORDER BY`?
7. Why does `LAST_VALUE` need `UNBOUNDED FOLLOWING` to work as expected?
