# Day 4: Operators & System Defined Functions

> **Database:** Oracle SQL, using the sample `hr.EMPLOYEES` table (employee_id, first_name, last_name, salary, department_id...).

## 1. Operators

An **operator** is a symbol or keyword that performs an operation on values. There are four groups.

### 1.1 Comparison operators
| Operator | Meaning | Example |
|---|---|---|
| `=` | Equal to | `department_id = 50` |
| `!=` or `<>` | Not equal to | `department_id <> 50` |
| `<` | Less than | `salary < 5000` |
| `>` | Greater than | `salary > 5000` |
| `<=` | Less than or equal to | `salary <= 5000` |
| `>=` | Greater than or equal to | `salary >= 5000` |

Use `IS NULL` for NULL checks, never `= NULL`.

### 1.2 Arithmetic operators
| Operator | Operation | Example | Result |
|---|---|---|---|
| `+` | Addition | `10 + 3` | 13 |
| `-` | Subtraction | `10 - 3` | 7 |
| `*` | Multiplication | `10 * 3` | 30 |
| `/` | Division | `10 / 3` | 3.3333... |

```sql
SELECT first_name, salary, salary + 500 AS new_salary FROM hr.employees;
SELECT 10 / 3 FROM DUAL;   -- Oracle needs FROM DUAL when no table is used
```
Oracle has no `%` operator; use `MOD(a, b)` for the remainder.

### 1.3 Set operators
Combine the results of two `SELECT`s **vertically** (rows stacked).

| Operator | Returns | Duplicates |
|---|---|---|
| `UNION` | All rows from both | Removed |
| `UNION ALL` | All rows from both | Kept (faster) |
| `INTERSECT` | Only rows common to both | Removed |
| `MINUS` (`EXCEPT`) | Rows in the 1st query not in the 2nd | Removed |

```
A = {1, 2, 3}     B = {3, 4}
UNION      → 1, 2, 3, 4          INTERSECT → 3
UNION ALL  → 1, 2, 3, 3, 4       MINUS     → 1, 2   (A - B)
```
**Rules:** same number of columns, compatible data types, same column order.
`MINUS` is Oracle's keyword; `EXCEPT` is the standard name (PostgreSQL, SQL Server). MySQL has no `MINUS` and supports `EXCEPT` only from 8.0.31.

**Example from class:** dept 50 employees, excluding those earning more than 5000
```sql
SELECT employee_id, first_name, salary FROM hr.employees WHERE department_id = 50
MINUS
SELECT employee_id, first_name, salary FROM hr.employees WHERE salary > 5000;
```
This returns salary **<= 5000** (exactly 5000 is kept). For strictly less than 5000, simply use `WHERE department_id = 50 AND salary < 5000`.

### 1.4 Logical operators
| Operator | Purpose |
|---|---|
| `BETWEEN` / `NOT BETWEEN` | Inside / outside a range (**inclusive**) |
| `IN` | Matches any value in a list |
| `AND` | **All** conditions true |
| `OR` | **At least one** true |
| `NOT` | Reverses a condition |
| `LIKE` / `NOT LIKE` | Pattern matches / does not match |

**Precedence:** `NOT` → `AND` → `OR`. Use parentheses when mixing.

**BETWEEN** (employees with salary 5000 to 10000, both ends included)
```sql
SELECT employee_id, first_name, last_name, salary
FROM hr.employees WHERE salary BETWEEN 5000 AND 10000;
```

**LIKE** wildcards: `%` = any number of characters, `_` = exactly one character.

| Requirement | Pattern |
|---|---|
| Last name **ends with** n | `WHERE last_name LIKE '%n'` |
| First name **contains** "an" | `WHERE first_name LIKE '%an%'` |
| First name, **2nd character** is a | `WHERE first_name LIKE '_a%'` |
| First name does **not start with** S | `WHERE first_name NOT LIKE 'S%'` |

> Note: the class comment says "last name containing letter n", but `'%n'` matches names that **end** with n. To match "contains n", use `'%n%'`. Also, `LIKE` is case-sensitive in Oracle (`'S%'` does not match "steven").

---

## 2. System Defined Functions (SDF)

**System Defined Functions** are **built-in functions** provided by the database. You call them directly instead of writing your own (the opposite is a *user-defined function*).

### Six types of functions
| # | Type | Works on |
|---|---|---|
| 1 | **Character** (string) | Text |
| 2 | **Numeric** | Numbers |
| 3 | Date | Dates and times |
| 4 | Conversion | Changing data types |
| 5 | General / NULL-handling | Any type, NULL handling |
| 6 | Group (aggregate) | Many rows → one value |

> Types 3 to 6 are the usual classification, so match them to your trainer's list.

### 2.1 Character functions
Examples use `first_name = 'Alexander'` unless stated.

| Function | Purpose | Example | Result |
|---|---|---|---|
| `UPPER(s)` | All capitals | `UPPER('Steven')` | STEVEN |
| `LOWER(s)` | All small letters | `LOWER('Steven')` | steven |
| `INITCAP(s)` | First letter of each word capital | `INITCAP('steven king')` | Steven King |
| `LENGTH(s)` | Number of characters | `LENGTH('Steven')` | 6 |
| `SUBSTR(s, start, len)` | Extract part of a string | `SUBSTR('Steven', 1, 3)` | Ste |
| `INSTR(s, ch)` | Position of first match (0 if none) | `INSTR('Alexander', 'a')` | 5 |
| `CONCAT(a, b)` | Join **two** strings | `CONCAT('Steven', 'King')` | StevenKing |
| `a \|\| b` | Join any number of strings | `'Steven' \|\| ' ' \|\| 'King'` | Steven King |
| `TRIM(s)` | Remove spaces from **both** ends | `TRIM('   Oracle SQL  ')` | Oracle SQL |
| `LTRIM(s)` | Remove spaces from the **left** | `LTRIM('  Oracle SQL  Test')` | Oracle SQL  Test |
| `RTRIM(s)` | Remove spaces from the **right** | `RTRIM('Oracle  ')` | Oracle |
| `LPAD(s, n, ch)` | Pad on the left up to total length n | `LPAD('Steven', 15, '*')` | \*\*\*\*\*\*\*\*\*Steven |
| `RPAD(s, n, ch)` | Pad on the right up to total length n | `RPAD('Steven', 15, '$')` | Steven\$\$\$\$\$\$\$\$\$ |
| `REPLACE(s, old, new)` | Replace characters | `REPLACE('Alexander', 'a', '@')` | Alex@nder |

```sql
SELECT first_name, UPPER(first_name) AS upper_name FROM hr.employees;
SELECT first_name, SUBSTR(first_name, 1, 3) AS first_three_name FROM hr.employees;
SELECT first_name || ' ' || last_name AS full_name FROM hr.employees;
SELECT TRIM('   Oracle SQL  ') AS result FROM DUAL;
SELECT first_name, LPAD(first_name, 15, '*') AS padded_name FROM hr.employees;
```

**Points to remember**
- **`DUAL`** is Oracle's dummy table; use it to test a function without a real table.
- `INSTR` and `REPLACE` are **case-sensitive**: `'Alexander'` has its first lowercase `a` at position 5, and the capital `A` is not replaced.
- `CONCAT` takes only **2** arguments; use `||` to join more (and to add a space).
- In the class example `RTRIM('  Oracle SQL  Test')` changes nothing, since the string has no trailing spaces; only leading spaces exist there.
- `LPAD`/`RPAD`: the number is the **final length**, not the number of padding characters.

### 2.2 Numeric functions
| Function | Purpose | Example | Result |
|---|---|---|---|
| `CEIL(n)` | Round **up** to next integer | `CEIL(4.2)` | 5 |
| `FLOOR(n)` | Round **down** to integer | `FLOOR(4.8)` | 4 |
| `ROUND(n, d)` | Round to `d` decimal places | `ROUND(4.567, 2)` | 4.57 |
| `ABS(n)` | Absolute value | `ABS(-7)` | 7 |
| `MOD(a, b)` | Remainder of a ÷ b | `MOD(10, 3)` | 1 |
| `POWER(a, b)` | a raised to the power b | `POWER(2, 3)` | 8 |
| `SQRT(n)` | Square root | `SQRT(16)` | 4 |
| `LN(n)` | Natural logarithm (base e) | `LN(1)` | 0 |

```sql
SELECT CEIL(4.2), FLOOR(4.8), ROUND(4.567, 2), ABS(-7), MOD(10, 3), POWER(2, 3), SQRT(16)
FROM DUAL;
```
`MOD(n, 2) = 0` means even, `= 1` means odd.

---

## Quick revision
1. `UNION` vs `UNION ALL` vs `INTERSECT` vs `MINUS`?
2. Write a query for names that do not start with S.
3. What does `LIKE '_a%'` match?
4. `CONCAT` vs `||`?
5. What does `LPAD(first_name, 15, '*')` return for "Steven"?
6. Why does `RTRIM('  Oracle SQL  Test')` look unchanged?
