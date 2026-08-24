# Workforce Intelligence & Organizational Performance Analysis
### Roblox Africa Operations — Ghana Hub

Integrated workforce analytics project combining employee, department, education,
finance, health, and performance data (2021–2025) into one analytical model, built
to answer 5 core objectives: workforce composition, education-to-placement alignment,
compensation & cost efficiency, health-related risk, and workforce sustainability
recommendations.

## Repo contents

| File | What it is |
|---|---|
| `schema.sql` | Creates the database, 3 tables, and indexes. Run this first. |
| `analysis_queries.sql` | One query block per objective — run after data is loaded. |
| `/data/*.csv` | The 3 cleaned, analysis-ready tables (employee-level, employee-yearly, department-yearly). |
| `dashboard.pbix` | Power BI dashboard — **add this yourself** (see note below). |
| `dashboard.html` | Standalone interactive dashboard — works in any browser, no install needed. |

## How to reproduce this in MySQL

1. Create the database and tables:
   ```
   mysql -u root -p < schema.sql
   ```
2. Load the 3 CSVs from `/data` using MySQL Workbench's **Table Data Import Wizard**
   (right-click the `roblox_workforce` schema → Table Data Import Wizard → "Use existing table"),
   matching each CSV to its table name as noted in the comments in `schema.sql`.
3. Run `analysis_queries.sql` to reproduce every number in the analysis report.

## Data model

Star schema — one dimension table, two fact tables at different grains:

```
employee_analytics (30,000 rows — one per employee)
        |
        +--- employee_performance_yearly (150,000 rows — employee x year, 2021-2025)
        |
department_performance_yearly (40 rows — department x year, 2021-2025)
```

`employee_analytics.Department_Code` joins to `department_performance_yearly.Department_Code`.
`employee_analytics.EmployeeID` joins to `employee_performance_yearly.EmployeeID`.

## Key findings (see full report for detail)

- Workforce composition is evenly distributed across all 8 departments — no staffing imbalance.
- Education level shows negligible correlation with salary or performance.
- Revenue-per-cost efficiency ranges from 1.46x (Product Management) to 1.80x (Human Resources).
- ~33% of employees company-wide have expired insurance status — systemic, not department-specific.
- Training hours completed correlate weakly with performance (r≈0.23) and revenue (r≈0.11).

## About the .pbix file

This repo is missing `dashboard.pbix` on purpose — that file is a proprietary binary format
that Power BI Desktop generates, and it can't be produced as a text/code file. To add it:

1. Open Power BI Desktop.
2. Import the 3 CSVs from `/data` (or connect directly to your MySQL database after running the steps above).
3. Build the dashboard following the DAX measures in `dax_measures.md`.
4. **File → Save As** → save as `dashboard.pbix` into this repo folder before committing.

## Tools used
Excel/Python (cleaning), MySQL (database, joins, querying), Power BI (visualization).
