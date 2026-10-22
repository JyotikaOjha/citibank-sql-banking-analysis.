Citibank Banking Database: SQL Analysis

Author: Jyotika Ojha | Tools: MySQL 8 | Skills: joins, CTEs, window functions (RANK, LAG, running totals), conditional aggregation, data cleaning

[![SQL](https://img.shields.io/badge/SQL-MySQL%208-blue?style=for-the-badge&logo=mysql&logoColor=white)](https://www.mysql.com/)
[![Analysis](https://img.shields.io/badge/Focus-Business%20Analytics-0A7EA4?style=for-the-badge)](#project-overview)
[![Data](https://img.shields.io/badge/Skills-Data%20Cleaning%20%7C%20SQL%20Analysis-397A57?style=for-the-badge)](#technical-skills)

## 📌 Project Overview

How can banking data reveal operational trends and potential financial risks?

In this project, I used **MySQL 8** to explore a relational banking dataset, analyze transaction activity, compare branch performance, investigate loan repayment patterns, and examine data quality.

The project demonstrates how SQL can transform raw records into structured findings that support further business investigation and data-driven decision-making.

## 🎯 Project Objectives

- Analyze transaction values and branch-level performance.
- Investigate loan repayment patterns and potentially overdue accounts.
- Compare branch workforce and operational indicators.
- Identify data quality issues in customer records.
- Communicate findings through clear, business-oriented conclusions.

## ⭐ The STAR Approach

### 🟦 S — Situation

Banking datasets contain interconnected information about customers, accounts, transactions, cards, branches, employees, and loans. Understanding the relationships between these records is essential for identifying trends and areas that may need closer investigation.

### 🟨 T — Task

My objective was to use SQL to answer practical banking questions, validate data quality, examine transaction and repayment patterns, and derive meaningful findings from the available dataset.

### 🟩 A — Action

I approached the analysis through four key activities:

**1. Data exploration and quality checks**
- Inspected table structures and examined missing or blank values.
- Investigated customer date-of-birth values stored as text.
- Applied date-conversion techniques to support date-based analysis.

**2. SQL querying and relational analysis**
- Combined related tables using SQL joins.
- Used aggregate functions, `GROUP BY`, and `HAVING`.
- Applied Common Table Expressions (CTEs), subqueries, conditional aggregation, and date functions where appropriate.

**3. Business performance and risk analysis**
- Compared transaction values across branches.
- Examined employee distribution across branches.
- Identified active loans with no recorded payment for more than 180 days for further review.

**4. Insight generation**
- Interpreted query outputs in a business context.
- Documented findings and prepared a supporting case-study report.

### 🟪 R — Results & Key Findings

The analysis generated the following findings from the project dataset:

| Key finding | Business implication |
|---|---|
| Downtown Miami recorded the highest transaction value among the branches analyzed. | Provides a starting point for investigating branch-level transaction activity. |
| 49 active loans had no recorded payment for more than 180 days. | Highlights records that may require repayment-status and risk review. |
| Fort Lauderdale emerged as a location of concern for business-loan defaults. | Provides a basis for further investigation of loan records and default patterns. |
| South Beach had 21 employees and ranked sixth in the branch comparison. | Illustrates why workforce size and transaction performance should be assessed together. |

*These findings relate only to the project dataset and are not verified current Citibank performance figures.*

## 🧰 Technical Skills Demonstrated

| Skill area | Techniques used |
|---|---|
| SQL querying | Joins, filtering, aggregation |
| Advanced querying | CTEs, subqueries, conditional aggregation |
| Data quality | Blank-value checks and date conversion |
| Business analysis | Branch comparisons, transaction analysis, repayment-risk investigation |
| Communication | Interpreting query outputs and documenting business findings |

## 📂 Project Files

- **SQL queries:** Explore the SQL files in this repository to review the analysis.
- **Case-study report:** [View the Citibank SQL Charts PDF](https://github.com/JyotikaOjha/citibank-sql-banking-analysis./blob/main/Citibank_SQL_Charts.pdf)
- **README:** Start here for the project overview, methodology, and key findings.

## 💡 What This Project Demonstrates

This project showcases my ability to:

- Break down business questions into SQL queries.
- Work with related tables in a relational database.
- Investigate data quality before interpreting results.
- Analyze operational patterns and identify records requiring further review.
- Explain technical results in business-friendly language.

## 👩‍💻 About Me

**Jyotika Ojha**  
Aspiring Data Analyst | SQL | Power BI | Advanced Excel

I am building my analytical skills through practical projects that combine data exploration, SQL problem-solving, and business-focused insights.

🔗 [Connect with me on LinkedIn](https://www.linkedin.com/in/jyotika-ojha-807654213)

---

*This is an independent portfolio case study using a banking dataset for learning and analytical practice. It does not represent an official Citibank project.*

