# Day 5: Date Functions, Ranking & LAG / LEAD

> **Database:** Oracle SQL, using `hr.EMPLOYEES`. Sample results assume today is **05-Nov-2026** (Thursday).

## 1. Date & time basics

| Type | Format | Stores |
|---|---|---|
| **DATE** | `YYYY-MM-DD` | Date + time down to seconds |
| **TIMESTAMP** | `YYYY-MM-DD HH:MM:SS.FF` | Date + time + fractional seconds (ms and finer) |

- Oracle **displays** dates in the session format (default looks like `05-NOV-26`), but the stored value is the same.
- Write a date literal as `DATE '2026-11-05'`, always with zero-padded month and day.
- `HH:MM:SS` = hours, minutes, seconds; the fractional part follows after a **dot** (`.123`).

## 2. Current date & time

| Function | Returns | Type |
|---|---|---|
| `SYSDATE` | Current date + time of the **database server** | DATE |
| `SYSTIMESTAMP` | Current date + time with fractional seconds and time zone | TIMESTAMP |

```sql
SELECT SYSDATE FROM DUAL;
SELECT SYSTIMESTAMP FROM DUAL;
SELECT employee_id, first_name, hire_date, SYSDATE FROM hr.employees;
```
"Server location" means the time comes from the database server's clock, not your laptop's.

## 3. Date functions

| Function | Purpose | Example | Result |
|---|---|---|---|
| `ADD_MONTHS(d, n)` | Add `n` months (negative `n` subtracts) | `ADD_MONTHS(SYSDATE, 3)` | 05-Feb-2027 |
| `MONTHS_BETWEEN(d1, d2)` | Months from d2 to d1 (can be fractional) | `MONTHS_BETWEEN(DATE '2026-11-05', DATE '2026-06-05')` | 5 |
| `LAST_DAY(d)` | Last day of that date's month | `LAST_DAY(SYSDATE)` | 30-Nov-2026 |
| `NEXT_DAY(d, 'day')` | First given weekday **after** d | `NEXT_DAY(SYSDATE, 'Monday')` | 09-Nov-2026 |
| `EXTRACT(part FROM d)` | Pull out YEAR, MONTH or DAY | `EXTRACT(YEAR FROM SYSDATE)` | 2026 |

### Examples from class
```sql
-- probation end date = hire date + 6 months
SELECT first_name, hire_date, ADD_MONTHS(hire_date, 6) AS probation_period
FROM hr.employees;

-- months worked (CEIL rounds a partial month up)
SELECT first_name, hire_date,
       CEIL(MONTHS_BETWEEN(SYSDATE, hire_date)) AS months_worked
FROM hr.employees;

-- last day of each hire month
SELECT first_name, hire_date, LAST_DAY(hire_date) FROM hr.employees;

-- next Monday / Friday after today
SELECT SYSDATE, NEXT_DAY(SYSDATE, 'Monday'), NEXT_DAY(SYSDATE, 'Friday') FROM DUAL;

-- split today into year, month, day
SELECT EXTRACT(YEAR  FROM SYSDATE) AS current_year,
       EXTRACT(MONTH FROM SYSDATE) AS current_month,
       EXTRACT(DAY   FROM SYSDATE) AS current_day
FROM DUAL;
```

### Points to remember
- `MONTHS_BETWEEN(later, earlier)` is **positive**; swap the order and it turns negative.
- `NEXT_DAY` is strictly *after* the date: if today is Monday, it returns the **next** Monday, not today.
- `EXTRACT` on a **DATE** supports only `YEAR`, `MONTH`, `DAY`. For `HOUR`/`MINUTE`/`SECOND`, the value must be a **TIMESTAMP**.
- `ADD_MONTHS` on a month-end date returns the month-end of the target month (e.g. 30-Nov + 3 months = 28-Feb in a non-leap year).

---

## 4. ROW_NUMBER vs RANK vs DENSE_RANK

These are **window (analytic) functions**: they calculate over a set of rows **without collapsing them** (unlike `GROUP BY`). `OVER (ORDER BY ...)` defines the ranking order.

```sql
SELECT first_name, salary,
       ROW_NUMBER() OVER (ORDER BY salary DESC) AS row_num,
       RANK()       OVER (ORDER BY salary DESC) AS rnk,
       DENSE_RANK() OVER (ORDER BY salary DESC) AS dense_rnk
FROM hr.employees;
```

Illustration with two employees tied at 17000:

| salary | ROW_NUMBER | RANK | DENSE_RANK |
|---|---|---|---|
| 24000 | 1 | 1 | 1 |
| 17000 | 2 | 2 | 2 |
| 17000 | 3 | **2** | **2** |
| 14000 | 4 | **4** (gap) | **3** (no gap) |

| Function | Ties | Gaps after ties |
|---|---|---|
| `ROW_NUMBER` | Different numbers (always unique) | n/a |
| `RANK` | Same rank | **Yes** (2, 2, 4) |
| `DENSE_RANK` | Same rank | **No** (2, 2, 3) |

- **Top N per group:** add `PARTITION BY department_id` before `ORDER BY`.
- **Nth highest salary:** use `DENSE_RANK() = N` (no gaps, so the Nth value always exists).
- With ties, `ROW_NUMBER` picks an arbitrary order; add a second column in `ORDER BY` to make it predictable.

---

## 5. LAG and LEAD

Access a value from **another row** without a self join.

| Function | Looks at | Idea |
|---|---|---|
| `LAG(col, n, default)` | The **previous** row (n rows back) | Today depends on **yesterday** |
| `LEAD(col, n, default)` | The **next** row (n rows ahead) | Today depends on **tomorrow** |

- `n` defaults to **1**; `default` (value when no such row exists) defaults to **NULL**.
- `ORDER BY` inside `OVER` is **required** (it decides what "previous" and "next" mean).

```sql
SELECT first_name, hire_date, salary,
       LAG(salary)  OVER (ORDER BY hire_date) AS prev_salary,
       LEAD(salary) OVER (ORDER BY hire_date) AS next_salary,
       salary - LAG(salary, 1, 0) OVER (ORDER BY hire_date) AS change_from_prev
FROM hr.employees;
```

| hire_date | salary | prev_salary (LAG) | next_salary (LEAD) |
|---|---|---|---|
| Jan | 5000 | **NULL** | 6000 |
| Feb | 6000 | 5000 | 7000 |
| Mar | 7000 | 6000 | **NULL** |

The first row has no previous row, and the last row has no next row, so both get NULL (or your `default`).

**Use cases:** day-over-day or month-over-month change, comparing with the previous record, finding gaps between events.

### Worked example (from class): daily sales
The idea is to **shift the Sales column down (LAG) or up (LEAD)** so each row can see a neighbouring day's value beside it.

| Day | Sales | LAG(sales, 1) | LAG(sales, 2) | LEAD(sales, 1) |
|---|---|---|---|---|
| Day 1 | 13 | NULL | NULL | 55 |
| Day 2 | 55 | 13 | NULL | 49 |
| Day 3 | 49 | 55 | 13 | 16 |
| Day 4 | 16 | 49 | 55 | 28 |
| Day 5 | 28 | 16 | 49 | 38 |
| Day 6 | 38 | 28 | 16 | 10 |
| Day 7 | 10 | 38 | 28 | 74 |
| Day 8 | 74 | 10 | 38 | 52 |
| Day 9 | 52 | 74 | 10 | 92 |
| Day 10 | 92 | 52 | 74 | NULL |

- **LAG 1:** the previous day's sales. Day 1 has no earlier day, so it is NULL.
- **LAG 2:** sales from **two** days back, so the first **two** rows are NULL. The offset `n` = how many rows to look back.
- **LEAD 1:** the next day's sales, so the **last** row is NULL.

```sql
SELECT day_no, sales,
       LAG(sales, 1)  OVER (ORDER BY day_no) AS lag_1,
       LAG(sales, 2)  OVER (ORDER BY day_no) AS lag_2,
       LEAD(sales, 1) OVER (ORDER BY day_no) AS lead_1,
       sales - LAG(sales, 1) OVER (ORDER BY day_no) AS day_over_day_change
FROM daily_sales;
```
Day-over-day change here: NULL, +42, -6, -33, +12, +10, -28, +64, -22, +40.

**Rule of thumb:** a shift by *n* creates *n* NULLs (at the top for LAG, at the bottom for LEAD), unless you pass a default value.

---

## Quick revision
1. `SYSDATE` vs `SYSTIMESTAMP`?
2. What does `MONTHS_BETWEEN(DATE '2026-11-05', DATE '2026-06-05')` return, and what if you swap the dates?
3. `ROW_NUMBER` vs `RANK` vs `DENSE_RANK` for salaries 90, 80, 80, 70?
4. Which function finds the 2nd highest salary safely, and why?
5. `LAG` vs `LEAD`, and why does the first row show NULL for `LAG`?
6. For `LAG(sales, 2)`, how many NULL rows appear and where?
