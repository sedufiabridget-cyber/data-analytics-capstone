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
| `dashboard.pbix` | Power BI dashboard — single page, 11 visuals (4 KPI cards, 1 department slicer, 6 charts covering all 5 objectives). Open directly in Power BI Desktop. |
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

## About the dashboard

`dashboard.pbix` is a single-page Power BI report with 11 visuals:

- **4 KPI cards** — total headcount, average tenure, best revenue-per-cost department, and insurance-expiry risk
- **1 department slicer** — filters every visual on the page
- **6 charts** covering all five objectives:
  1. Headcount by department (clustered column)
  2. Revenue-per-cost by department (bar chart, sorted ascending)
  3. Education level vs. salary/performance (clustered bar)
  4. Health & wellbeing risk by department (column chart)
  5. Employee status mix by department (column chart)
  6. Company-wide performance trend, 2021–2025 (line chart)

To open it: install Power BI Desktop (free from Microsoft) if you don't already have it, then just double-click `dashboard.pbix`. All DAX measures used are documented in `dax_measures.md` if you want to inspect or rebuild any of them.

## Tools used
Excel/Python (cleaning), MySQL (database, joins, querying), Power BI (visualization).
