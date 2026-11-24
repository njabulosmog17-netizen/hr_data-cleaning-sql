## hr_data-cleaning-in-excel
Cleaned messy HR data in MySQL so headcount and attrition reports can be trusted

## BEFORE - 5 Rows of Messy Table

<img width="1245" height="288" alt="image" src="https://github.com/user-attachments/assets/93cfadaf-b9a4-4f0d-9640-0cb93e027e29" />

## What I Fixed
- Removed duplicate rows - Abbott appeared 3 times, Acosta appeared 2 times, kept only 1 of each
- Removed unnecessary rows - deleted rows with no name / no employee ID
- Fixed StartDate format - changed all dates to one format YYYY-MM-DD, e.g. 20-Sep-19 -> 2020-09-20
- Fixed ExitDate format - changed all dates to one format YYYY-MM-DD
- Fixed missing values - filled blank emails / blank dates where possible
- Standardized EmployeeStatus - made Active / Inactive consistent
- 
## AFTER - 5 Rows of Clean Table

<img width="1241" height="325" alt="image" src="https://github.com/user-attachments/assets/d72bc83e-3b3c-441f-835b-d2bd83578efd" />



