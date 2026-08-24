# DAX Measures Reference — Power BI Dashboard

Add these in Power BI Desktop after importing the 3 CSVs from `/data`.
Right-click the relevant table in the Fields pane → **New Measure** → paste → Enter.

## On `employee_analytics`

```dax
Headcount = COUNTROWS(employee_analytics)

Avg Tenure = AVERAGE(employee_analytics[Tenure_Years])

Avg Salary = AVERAGE(employee_analytics[Basic_Salary])

Avg Performance Score = AVERAGE(employee_analytics[Avg_Performance_Score])

% Female = 
DIVIDE(
    CALCULATE(COUNTROWS(employee_analytics), employee_analytics[Gender]="Female"),
    [Headcount]
)

% Insurance Expired = 
DIVIDE(
    CALCULATE(COUNTROWS(employee_analytics), employee_analytics[Insurance_status]="Expired"),
    [Headcount]
)

% Not Leave Eligible = 
DIVIDE(
    CALCULATE(COUNTROWS(employee_analytics), employee_analytics[Medical_leave_eligible]="No"),
    [Headcount]
)

% Active = 
DIVIDE(
    CALCULATE(COUNTROWS(employee_analytics), employee_analytics[employee_status]="Active"),
    [Headcount]
)

% On Leave = 
DIVIDE(
    CALCULATE(COUNTROWS(employee_analytics), employee_analytics[employee_status]="On Leave"),
    [Headcount]
)

% Inactive = 
DIVIDE(
    CALCULATE(COUNTROWS(employee_analytics), employee_analytics[employee_status]="Inactive"),
    [Headcount]
)
```

## On `department_performance_yearly`

```dax
Total Revenue = SUM(department_performance_yearly[Total_Revenue_Generated])

Total Cost = SUM(department_performance_yearly[Total_Cost])

Revenue per Cost = DIVIDE([Total Revenue], [Total Cost])

Avg Dept Performance = AVERAGE(department_performance_yearly[Average_Performance_Score])

Avg Training Hours (Dept) = AVERAGE(department_performance_yearly[Training_Hours_Completed])
```

## Dashboard layout (single page)

| Visual | Type | Fields |
|---|---|---|
| KPI: Headcount | Card | `Headcount` |
| KPI: Avg Tenure | Card | `Avg Tenure` |
| KPI: Best Revenue/Cost | Card | `Revenue per Cost` (filtered to Human Resources) |
| KPI: Insurance Risk | Card | `% Insurance Expired` |
| Slicer | Slicer | `department_name` |
| 1. Headcount by Department | Clustered Column | Axis: `department_name`, Legend: `Position`, Values: `Headcount` |
| 2. Revenue per Cost by Department | Horizontal Bar (sort asc) | Axis: `department_name`, Values: `Revenue per Cost` |
| 3. Education vs. Salary & Performance | Clustered Bar | Axis: `Education_Level`, Values: `Avg Salary`, `Avg Performance Score` |
| 4. Health Risk by Department | Clustered Column | Axis: `department_name`, Values: `% Insurance Expired`, `% Not Leave Eligible` |
| 5. Employee Status Mix | Stacked Column | Axis: `department_name`, Values: `% Active`, `% On Leave`, `% Inactive` |
| 6. Performance Trend | Line Chart | Axis: `Year`, Values: `Avg Dept Performance` |
| 7. Training vs. Performance | Scatter | X: `Training_Hours_Completed`, Y: `Average_Performance_Score`, Details: `Department` |

## Relationships needed (Model view)

- `employee_analytics[EmployeeID]` → `employee_performance_yearly[EmployeeID]` (1:*)
- `employee_analytics[Department_Code]` → `department_performance_yearly[Department_Code]` (1:*)
