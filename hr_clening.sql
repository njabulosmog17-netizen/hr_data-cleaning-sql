-- PROJECT: HR Data Cleaning
-- GOAL: Make HR data trustworthy for headcount and attrition

-- 1. First table: messy_hr_dataset_detailed - original, NEVER touch it
-- 2. Second table: hr_work_table - fixed row_id 
-- 3. Third table: hr_work_table2 - created JUST to fix / rename columns

-- 1. Create new working table from original

CREATE TABLE hr_work_table AS
SELECT *
FROM messy_hr_dataset_detailed;

-- 2. Fix ONLY the ID column on the NEW table

ALTER TABLE hr_work_table 
RENAME COLUMN `Unnamed: 0` TO row_id;


-- STEP 2: Fix DUPLICATES second, before other columns

-- I saw duplicates on row_id, so I dealt with duplicates next
-- Method: CREATE TABLE hr_work_table2 AS SELECT DISTINCT *
-- SELECT DISTINCT * keeps only 1 copy of each exact duplicate row

CREATE TABLE hr_work_table2 AS
SELECT DISTINCT *
FROM hr_work_table;

-- STEP 3: Fix ALL other columns third, one by one

-- Now I deal with all other columns
-- Method: CREATE TABLE hr_work_table_clean AS SELECT ...
-- I select each column one by one and give it a new clean name

create table hr_work_table_clean2
select
  row_id,
  FirstName as first_name,
  LastName as last_name,
  StartDate as start_date,
  ExitDate as exit_date,
  title as title,
  Supervisor as supervisor,
  ADEmail as ade_mail,
  BusinessUnit as business_unit,
  EmployeeType as employee_type,
  PayZone as pay_zone,
  EmployeeClassificationType as employee_classification_type,
  TerminationDescription as termination_description,
  DepartmentType as department_type,
  Division as division,
  DOB as dob,
  State as state,
  JobFunctionDescription as job_function_description,
  GenderCode as gender_code,
  LocationCode as location_code,
  RaceDesc as race_desc,
  MaritalDesc as marital_desc,
  `Performance Score` as performance_score,
  `current Employee Rating` as current_employee_rating,
  `Employee ID` as employee_id,
  `Survey Date` as survey_date,
  `Engagement Score` as engagement_score,
  `Satisfaction Score` as satisfaction_score,
  `Work-Life Balance Score` as work_life_balance_score,
  `Training Date` as training_date,
  `Training Program Name` as training_program_name,
  `Training Type` as training_type,
  `Training Outcome` as training_outcome,
  Location as location,
  Trainer as trainer,
  `Training Duration(Days)` as training_days,
  `Training Cost` as training_cost
from hr_work_table2;

-- STEP 4: CHECK - duplicates are gone in hr_work_table_clean
-- Business key = first_name + last_name + start_date

SELECT first_name, last_name, start_date, COUNT(*) AS c
FROM hr_work_table_clean
GROUP BY first_name, last_name, start_date
HAVING c > 1;

-- RESULT: No data = 0 duplicates left

## NULLs and Spaces

I checked first_name and last_name for missing values and extra spaces
using SUM(CASE WHEN...).

### Query used
select 
      SUM(case when first_name is null or trim(first_name) = '' then 1 else
      0 end) as missing_fist_name,
      SUM(case when first_name is not null and first_name <> trim(first_name) then
      1 else 0 end) as spaces_first_name,

      sum(case when last_name is null or trim(last_name) = '' then 1 else 0 
      end) as missing_last_name,
      sum(case when last_name is not null and last_name <> trim(last_name) then 
      1 else 0 end) as spaces_last_name
 from hr_work_table_clean2;

### Result
- missing_first_name = 0
- spaces_first_name = 0
- missing_last_name = 0
- spaces_last_name = 0

### Conclusion
Both columns are clean. No NULLs, no extra spaces.
No UPDATE needed. TRIM was not needed.

Before cleaning, I checked the structure to see the column names and data types.

DESCRIBE hr_work_table_clean2;
SELECT * FROM hr_work_table_clean2 LIMIT 10;

What I found:
- dob was in DD-MM-YYYY format, e.g. 07-10-1969
- survey_date was in DD-MM-YYYY format, e.g. 09-09-2022
- MySQL did not recognise them as real dates

STEP 2: Fix Date of Birth Column

Problem:
The dob column was stored as DD-MM-YYYY. Trying to convert it directly gave Error 1292.

Solution:
Create a new TEXT column, cut the date apart and re-arrange it to YYYY-MM-DD, then replace the old column.

-- 1. Create a new temporary column as TEXT to avoid Error 1292
ALTER TABLE hr_work_table_clean2
ADD COLUMN dob_new VARCHAR(50);

-- 2. Rearrange date from DD-MM-YYYY to YYYY-MM-DD
-- SUBSTRING(..., 7, 4) = Year
-- SUBSTRING(..., 4, 2) = Month
-- SUBSTRING(..., 1, 2) = Day
UPDATE hr_work_table_clean2
SET dob_new = CASE
  WHEN dob IS NULL OR CAST(dob AS CHAR) = '' THEN NULL
  WHEN CAST(dob AS CHAR) LIKE '__-__-____' THEN CONCAT(SUBSTRING(CAST(dob AS CHAR), 7, 4), '-', SUBSTRING(CAST(dob AS CHAR), 4, 2), '-', SUBSTRING(CAST(dob AS CHAR), 1, 2))
  ELSE CAST(dob AS CHAR)
END;

-- 3. Verify the conversion worked
SELECT dob, dob_new
FROM hr_work_table_clean2
LIMIT 10;

-- 4. Drop the old broken column
ALTER TABLE hr_work_table_clean2
DROP COLUMN dob;

-- 5. Rename the new column to a proper name
ALTER TABLE hr_work_table_clean2
RENAME COLUMN dob_new TO date_of_birth;

-- 6. Change the data type from VARCHAR to DATE
ALTER TABLE hr_work_table_clean2
MODIFY COLUMN date_of_birth DATE;

Result:
07-10-1969 became 1969-10-07
Data type is now DATE

STEP 3: Fix Survey Date Column

Problem:
The survey_date column had the exact same issue - stored as DD-MM-YYYY.

Solution:
Applied the same cleaning method as date_of_birth.

-- 1. Create a new temporary column
ALTER TABLE hr_work_table_clean2
ADD COLUMN survey_date_new VARCHAR(50);

-- 2. Rearrange date from DD-MM-YYYY to YYYY-MM-DD
UPDATE hr_work_table_clean2
SET survey_date_new = CASE
  WHEN survey_date IS NULL OR CAST(survey_date AS CHAR) = '' THEN NULL
  WHEN CAST(survey_date AS CHAR) LIKE '__-__-____' THEN CONCAT(SUBSTRING(CAST(survey_date AS CHAR), 7, 4), '-', SUBSTRING(CAST(survey_date AS CHAR), 4, 2), '-', SUBSTRING(CAST(survey_date AS CHAR), 1, 2))
  ELSE CAST(survey_date AS CHAR)
END;

-- 3. Verify the conversion worked
SELECT survey_date, survey_date_new
FROM hr_work_table_clean2
LIMIT 10;

-- 4. Drop the old column
ALTER TABLE hr_work_table_clean2
DROP COLUMN survey_date;

-- 5. Rename the new column back to survey_date
ALTER TABLE hr_work_table_clean2
RENAME COLUMN survey_date_new TO survey_date;

-- 6. Change the data type from VARCHAR to DATE
ALTER TABLE hr_work_table_clean2
MODIFY COLUMN survey_date DATE;

Result:
09-09-2022 became 2022-09-09
Data type is now DATE

STEP 4: Verify Final Data Types

DESCRIBE hr_work_table_clean2;

Final Check:
- training_days stays as INT - correct, because it is a number
- date_of_birth is now DATE
- survey_date is now DATE

Key Concepts I Learned

- CAST: Changes the data type of a value. Example: CAST(dob AS CHAR) treats a date as text so it can be cut.
- SUBSTRING: Cuts out part of a text value.
- CONCAT: Joins pieces of text back together.
- CASE WHEN: Checks a condition and decides what to do.
- ALTER TABLE: Used to ADD, DROP, RENAME and MODIFY columns.
- Why YYYY-MM-DD matters: MySQL only recognises dates in YYYY-MM-DD format for sorting, filtering and date calculations like age.

# My journey for data cleaning ends here.
