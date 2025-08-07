## 1. 🔁 Column Renaming (Fix Encoding Issues and Standardize Names)
ALTER TABLE branch_monthly_revenuee CHANGE COLUMN Branch_iD Branch_id VARCHAR(100);

ALTER TABLE speciality

CHANGE COLUMN Avg_Consultation_Fee Consultation_Fee VARCHAR(100),

CHANGE COLUMN Avg_Treatment_Cost Treatment_Cost VARCHAR(100),

CHANGE COLUMN ï»¿Specialty_id speciality_id VARCHAR(100);

ALTER TABLE doctors

CHANGE COLUMN ï»¿doctor_ID Doctor_ID VARCHAR(100);

ALTER TABLE hospital_branches

CHANGE COLUMN ï»¿Branch_ID Branch_ID VARCHAR(100);

ALTER TABLE patients

CHANGE COLUMN ï»¿Patient_ID Patient_ID VARCHAR(100);

ALTER TABLE patients

DROP COLUMN contact;

## 2. 📋 Missing Values Summary – Textual and Numeric
-- Check for missing string fields
SELECT 

  SUM(CASE WHEN Full_Name IS NULL OR TRIM(Full_Name) = '' THEN 1 ELSE 0 END) AS Full_Name_Missing,

  SUM(CASE WHEN Gender IS NULL OR TRIM(Gender) = '' THEN 1 ELSE 0 END) AS Gender_Missing,

  SUM(CASE WHEN Admission_Date IS NULL OR TRIM(Admission_Date) = '' THEN 1 ELSE 0 END) AS Admission_Date_Missing,

  SUM(CASE WHEN Discharge_Date IS NULL OR TRIM(Discharge_Date) = '' THEN 1 ELSE 0 END) AS Discharge_Date_Missing

FROM Patients;

-- Check for missing numeric fields
SELECT 
  SUM(CASE WHEN Patient_ID IS NULL THEN 1 ELSE 0 END) AS Patient_ID_NULLs,

  SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END) AS Age_NULLs,

  SUM(CASE WHEN Branch_ID IS NULL THEN 1 ELSE 0 END) AS Branch_ID_NULLs,

  SUM(CASE WHEN Doctor_ID IS NULL THEN 1 ELSE 0 END) AS Doctor_ID_NULLs,

  SUM(CASE WHEN Specialty_ID IS NULL THEN 1 ELSE 0 END) AS Specialty_ID_NULLs,

  SUM(CASE WHEN Total_Cost IS NULL THEN 1 ELSE 0 END) AS Total_Cost_NULLs,

  SUM(CASE WHEN Insurance_Covered IS NULL THEN 1 ELSE 0 END) AS Insurance_Covered_NULLs,

  SUM(CASE WHEN Out_of_Pocket IS NULL THEN 1 ELSE 0 END) AS Out_of_Pocket_NULLs

FROM Patients;

## 3. 📆 Fill Missing Discharge_Date with Logic
-- Example: For August 2025

UPDATE branch_monthly_revenuee bmr

JOIN (

    SELECT AVG(NULLIF(`2025-08`, 0)) AS avg_val

    FROM branch_monthly_revenuee

) AS avg_table

SET bmr.`2025-08` = avg_table.avg_val

WHERE bmr.`2025-08` = 0;

## 4. 🧮 Fill Zero Revenue Values with Monthly Averages (2023–2025)

-- Example: For August 2025

UPDATE branch_monthly_revenuee bmr

JOIN (

    SELECT AVG(NULLIF(`2025-08`, 0)) AS avg_val
    FROM branch_monthly_revenuee
) AS avg_table

SET bmr.`2025-08` = avg_table.avg_val

WHERE bmr.`2025-08` = 0;

## ⚧ Clean Gender Values (Remove 'Other', Replace with Most Frequent)

-- Find most common gender

SELECT Gender, COUNT(*) AS count

FROM patients

WHERE Gender IS NOT NULL AND Gender != 'Other'

GROUP BY Gender

ORDER BY count DESC

LIMIT 2;

-- Replace 'Other' with 'Male'

UPDATE patients

SET Gender = 'Male'

WHERE Gender = 'Other';

## 💰 Fill Blank Out_of_Pocket Costs with Average Value

-- Check how many blank strings exist

SELECT COUNT(*) AS Blank_Count

FROM patients

WHERE Out_of_Pocket = '';

-- Replace blank values with average (excluding blanks)

UPDATE patients

JOIN (

    SELECT ROUND(AVG(CAST(Out_of_Pocket AS DECIMAL(10,2)))) AS avg_out_of_pocket
    FROM patients
    WHERE Out_of_Pocket != '' AND Out_of_Pocket IS NOT NULL

) AS avg_table

SET patients.Out_of_Pocket = avg_table.avg_out_of_pocket

WHERE patients.Out_of_Pocket = '';

