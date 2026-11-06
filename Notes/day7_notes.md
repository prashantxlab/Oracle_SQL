# Day 7: NULL Functions, CASE & DECODE

> **Database:** Oracle SQL. Examples use the class tables (`employees`, `customers`, `products`).

## 1. Why NULL functions?

`NULL` means **unknown / missing**. Any arithmetic with NULL gives NULL, so `salary + NULL = NULL`. NULL functions replace or handle NULLs so calculations and reports work.

| Function | Purpose | Args |
|---|---|---|
| `NVL` | Replace NULL with a value | 2 |
| `NVL2` | Different result for NULL and NOT NULL | 3 |
| `COALESCE` | First non-NULL value in a list | 2 or more |
| `NULLIF` | Return NULL if two values are equal | 2 |

---

## 2. NVL(expression, replacement_value)

**Logic:** if `expression` is NULL, return `replacement_value`; otherwise return `expression` unchanged.

Class table:

| EMP_ID | NAME | SALARY | COMMISSION |
|---|---|---|---|
| 101 | Ravi | 50000 | 5000 |
| 102 | Priya | 60000 | NULL |
| 103 | Arun | 45000 | 3000 |
| 104 | Neha | 55000 | NULL |

```sql
SELECT name, commission, NVL(commission, 0) AS final_commission FROM employees;
```
| NAME | COMMISSION | FINAL_COMMISSION |
|---|---|---|
| Ravi | 5000 | 5000 |
| Priya | NULL | **0** |
| Arun | 3000 | 3000 |
| Neha | NULL | **0** |

NVL is mostly used **inside calculations**:
```sql
SELECT name, salary, commission,
       salary + NVL(commission, 0) AS total_income
FROM employees;
```
| NAME | SALARY | COMMISSION | TOTAL_INCOME |
|---|---|---|---|
| Ravi | 50000 | 5000 | 55000 |
| Priya | 60000 | NULL | 60000 |
| Arun | 45000 | 3000 | 48000 |
| Neha | 55000 | NULL | 55000 |

Without NVL, Priya's and Neha's total income would be **NULL**.

---

## 3. NVL2(expression, value_if_not_null, value_if_null)

| Argument | Meaning |
|---|---|
| 1 | Expression to test |
| 2 | Returned when it is **NOT NULL** |
| 3 | Returned when it is **NULL** |

```sql
SELECT name, commission,
       NVL2(commission, 'Commission Available', 'No Commission') AS commission_status
FROM employees;
```
| NAME | COMMISSION | COMMISSION_STATUS |
|---|---|---|
| Ravi | 5000 | Commission Available |
| Priya | NULL | No Commission |
| Arun | 3000 | Commission Available |
| Neha | NULL | No Commission |

**NVL vs NVL2:** NVL returns the **original value** when it isn't NULL; NVL2 returns a **different value** for each case.

> **Fix in your raw notes:** text values need **single quotes** (`'Commission Available'`). Double quotes in Oracle mean a column name/identifier and cause an error. Also check the spelling `commission` (the notes had `commion`).

---

## 4. COALESCE(value1, value2, ..., valueN)

Returns the **first non-NULL** value, checking left to right. If all are NULL, the result is NULL (so end with a default).

Class table (customers):

| customer_id | customer_name | mobile_number | email_id | city |
|---|---|---|---|---|
| 101 | Ravi | 9876543210 | NULL | Bangalore |
| 102 | Priya | NULL | priya@gmail.com | Hyderabad |
| 103 | Arun | NULL | NULL | Chennai |
| 104 | Sneha | 9988776655 | sneha@gmail.com | NULL |
| 105 | Kiran | NULL | NULL | NULL |

```sql
-- find the first available contact
SELECT customer_name,
       COALESCE(mobile_number, email_id, 'No Contact Available') AS contact
FROM customers;
```
| customer_name | contact |
|---|---|
| Ravi | 9876543210 |
| Priya | priya@gmail.com |
| Arun | No Contact Available |
| Sneha | 9988776655 *(mobile comes first)* |
| Kiran | No Contact Available |

Another class table, three phone columns (the query below is my example):
```sql
SELECT customer,
       COALESCE(mobile, home_phone, office_phone, 'No Phone') AS contact_number
FROM customers;
```
| CUSTOMER | MOBILE | HOME_PHONE | OFFICE_PHONE | → contact_number |
|---|---|---|---|---|
| Ravi | 9876543210 | NULL | NULL | 9876543210 |
| Priya | NULL | 08022334455 | NULL | 08022334455 |
| Arun | NULL | NULL | 08044556677 | 08044556677 |
| Neha | NULL | NULL | NULL | No Phone |

**Points to remember**
- All arguments must be the **same data type family**. Mixing a `NUMBER` mobile column with a text email causes an error, so store phone numbers as `VARCHAR2`.
- **COALESCE vs NVL:** COALESCE is ANSI standard and takes many arguments; NVL is Oracle-specific with exactly 2.

---

## 5. NULLIF(value1, value2)

If both values are **equal → returns NULL**; otherwise returns the **first value**.

```sql
SELECT NULLIF(10, 10) FROM DUAL;   -- NULL
SELECT NULLIF(10, 20) FROM DUAL;   -- 10
```

### Main use: avoid divide-by-zero
```sql
SELECT product_name, sales / quantity FROM products;
-- fails with a "divisor is equal to zero" error when quantity = 0

SELECT product_name,
       sales / NVL(NULLIF(quantity, 0), 10) AS price_per_unit
FROM products;
```
How the class query works, for `quantity = 0`:
1. `NULLIF(quantity, 0)` → quantity equals 0, so it returns **NULL**
2. `NVL(NULL, 10)` → replaces NULL with **10**
3. `sales / 10` → no error

For any other quantity, `NULLIF` returns it unchanged, and NVL passes it through.

> Note: swapping a zero quantity for **10** is a business choice and gives an invented price. Often it is better to leave the result NULL: `sales / NULLIF(quantity, 0)`.

---

## 6. CASE

Adds **IF / THEN / ELSE logic** inside SQL. Rows are checked **one at a time, top to bottom**, and the **first true condition wins** (only one branch runs per row).

### 6.1 Simple CASE (compares one expression with values)
```sql
CASE expression
  WHEN value1 THEN result1
  WHEN value2 THEN result2
  ELSE default_result
END
```
```sql
SELECT emp_id, name, dept,
       CASE dept
         WHEN 'IT'  THEN 'Information Technology'
         WHEN 'HR'  THEN 'Human Resources'
         WHEN 'FIN' THEN 'Finance'
         ELSE 'Other Department'
       END AS department_name
FROM employees;
```
| EMP_ID | NAME | DEPT | department_name |
|---|---|---|---|
| 101 | Ravi | IT | Information Technology |
| 102 | Priya | HR | Human Resources |
| 103 | Arun | FIN | Finance |
| 104 | Neha | SALES | Other Department |

> **Fix in your raw notes:** use single quotes, and match the **exact case** of the data (`'IT'`, not `'it'`), because text comparison is case-sensitive.

### 6.2 Searched CASE (conditions with operators)
```sql
CASE
  WHEN condition1 THEN result1
  WHEN condition2 THEN result2
  ELSE default_result
END
```
**Salary category:**
```sql
SELECT name, salary,
       CASE
         WHEN salary >= 100000 THEN 'High Salary'
         WHEN salary >= 50000  THEN 'Medium Salary'
         ELSE 'Low Salary'
       END AS salary_category
FROM employees;
```
Salary 120000 → High. 60000 → Medium (the first condition fails, the second passes). 30000 → Low.

**Multiple conditions with AND / OR (bonus):**
```sql
SELECT name, salary, experience,
       CASE
         WHEN salary >= 100000 AND experience >= 10 THEN '20% Bonus'
         WHEN salary >= 50000  AND experience >= 5  THEN '10% Bonus'
         ELSE '5% Bonus'
       END AS bonus
FROM employees;
```
Illustrative rows:

| salary | experience | bonus | Why |
|---|---|---|---|
| 120000 | 12 | 20% Bonus | Both conditions of the first WHEN are true |
| 60000 | 6 | 10% Bonus | First fails, second passes |
| 120000 | 3 | 5% Bonus | High salary but low experience, so both fail → ELSE |

**Order matters:** put the most specific or highest condition first. If `salary >= 50000` came first, 120000 would be caught there.

### 6.3 CASE in ORDER BY (custom sort order)
```sql
SELECT name, designation
FROM employees
ORDER BY
  CASE designation
    WHEN 'Manager' THEN 1
    WHEN 'Senior'  THEN 2
    WHEN 'Junior'  THEN 3
    ELSE 4
  END DESC;
```
`DESC` sorts the numbers high to low, so the order becomes **Others → Junior → Senior → Manager**. To show **Manager first**, use `ASC` (or leave it off).

---

## 7. DECODE (Oracle-specific)

An Oracle function that works like a simple CASE:
```sql
DECODE(expression, search1, result1, search2, result2, ..., default)
```
The last unpaired value is the **default**.

```sql
SELECT customer_name, rating,
       DECODE(rating,
              1, 'Very Poor',
              2, 'Poor',
              3, 'Average',
              4, 'Good',
              5, 'Excellent',
              'Unknown') AS rating_description
FROM customers;
```
```sql
SELECT name, status,
       DECODE(status,
              'A', 'Active',
              'I', 'Inactive',
              'L', 'On Leave',
              'T', 'Terminated',
              'Unknown') AS employee_status
FROM employees;
```
Status `'A'` → Active. A status not in the list (say `'X'`) → Unknown.

---

## 8. CASE vs DECODE

| | **CASE** | **DECODE** |
|---|---|---|
| Origin | SQL standard expression | Oracle-only function |
| Logical operators (`>`, `<`, `!=`) | Yes | **No** (equality only) |
| `BETWEEN`, `IN`, `NOT IN` | Yes | **No** |
| `AND` / `OR` (multiple conditions) | Yes | **No** |
| Readability | Clear | Harder to read when long |
| Recommendation | **Recommended** | Usually not recommended |

DECODE treats two NULLs as **equal** (`DECODE(NULL, NULL, 'x')` returns `'x'`), while CASE does not. Learn DECODE mainly to read old Oracle code.

---

## Quick revision
1. What do `NVL`, `NVL2`, `COALESCE` and `NULLIF` each return?
2. Why does `salary + commission` give NULL for some rows, and how do you fix it?
3. For `NULLIF(10, 10)` and `NULLIF(10, 20)`, what are the results?
4. How does `sales / NVL(NULLIF(quantity, 0), 10)` avoid an error?
5. Which COALESCE result do you get for Arun (mobile NULL, email NULL)?
6. Simple CASE vs searched CASE?
7. Why is the order of WHEN conditions important?
8. Why is CASE preferred over DECODE?
