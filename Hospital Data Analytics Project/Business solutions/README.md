### 1. Rank Doctors Within Each Specialty by Salary (Top 3)
```sql
SELECT *
FROM (
    SELECT 
        Doctor_ID,
        Full_Name AS Doctor_Name,
        Specialty,
        Salary,
        RANK() OVER (PARTITION BY Specialty ORDER BY salary  DESC) AS rank_by_salary
    FROM 
        doctors
) AS ranked_doctors
WHERE rank_by_salary <= 3;
```

### 2. Find Doctors Whose Salary Is Above the Average of Their Specialty
```sql
SELECT 
    Doctor_ID,
    full_Name AS Doctor_Name,
    Specialty,
    Salary,
    ROUND(AVG(Salary) OVER (PARTITION BY Specialty), 2) AS Avg_Specialty_Salary
FROM 
    doctors
WHERE 
    Salary > (SELECT AVG(Salary) 
              FROM doctors d2 
              WHERE d2.Specialty = doctors.Specialty);
```

### 3. Which Specialties Have the Highest Avg Salary and Total Doctor Expense?
```sql
SELECT 
    sp.Specialty_Name AS Department,
    COUNT(d.Doctor_ID) AS Num_Doctors,
    ROUND(AVG(d.Salary), 2) AS Avg_Salary,
    SUM(d.Salary) AS Total_Department_Salary
FROM 
    doctors d
JOIN speciality sp ON d.Specialty = sp.Specialty_Name
GROUP BY 
    sp.Specialty_Name
ORDER BY 
    Total_Department_Salary DESC;
```

### 4. Which Departments Are Handling the Most Patients?
```sql
SELECT 
    sp.Specialty_Name AS Department,
    COUNT(d.Doctor_ID) AS Num_Doctors,
    SUM(d.no_of_Patients) AS Total_Patients_Handled,
    ROUND(AVG(d.no_of_Patients), 0) AS Avg_Patients_Per_Doctor
FROM 
    doctors d
JOIN speciality sp ON d.Specialty = sp.Specialty_name
GROUP BY 
    sp.Specialty_Name
ORDER BY 
    Total_Patients_Handled DESC;
```

### 5. Which Specialties Have the Most Experienced Doctors and Relation to Ratings?
```sql
SELECT 
    sp.Specialty_Name AS Department,
    ROUND(AVG(d.Experience_Years), 1) AS Avg_Experience,
    ROUND(AVG(d.rating), 2) AS Avg_Satisfaction,
    COUNT(d.Doctor_ID) AS Num_Doctors
FROM 
    doctors d
JOIN speciality sp ON d.Specialty = sp.Specialty_name
GROUP BY 
    sp.Specialty_Name
ORDER BY 
    Avg_Experience DESC;
```

### 6. Rank Patients by Total Spend (Out-of-Pocket + Insurance)
```sql
SELECT 
    Patient_ID,
    Full_Name,
    Branch_ID,
    Total_Cost,
    Out_of_Pocket,
    Insurance_Covered,
    (Out_of_Pocket + Insurance_Covered) AS Total_Spend,
    RANK() OVER (ORDER BY (Out_of_Pocket + Insurance_Covered) DESC) AS Spending_Rank
FROM 
    patients
LIMIT 10;
```

### 7. Which Specialty Has the Highest Total Cost from Patients?
```sql
SELECT 
    s.Specialty_Name,
    COUNT(p.Patient_ID) AS Total_Patients,
    ROUND(SUM(p.Total_Cost), 2) AS Total_Revenue
FROM 
    patients p
JOIN 
    speciality s ON p.Specialty_ID = s.Speciality_ID
GROUP BY 
    s.Specialty_Name
ORDER BY 
    Total_Revenue DESC;
```

### 8. Identify Patients With Long Hospital Stay But Low Spending
```sql
SELECT 
    Patient_ID,
    Full_Name,
    DATEDIFF(Discharge_Date, Admission_Date) AS Stay_Length,
    Total_Cost
FROM 
    patients
WHERE 
    Discharge_Date IS NOT NULL
    AND DATEDIFF(Discharge_Date, Admission_Date) > 7
    AND Total_Cost < 10000
ORDER BY 
    Stay_Length DESC;
```

### 9. Distribution of Patients by Gender and Age Group Across Specialties
```sql
SELECT 
    s.Specialty_Name,
    p.Gender,
    CASE 
        WHEN p.Age < 18 THEN 'Child (<18)'
        WHEN p.Age BETWEEN 18 AND 35 THEN 'Young Adult (18-35)'
        WHEN p.Age BETWEEN 36 AND 50 THEN 'Adult (36-50)'
        ELSE 'Senior (51+)'
    END AS Age_Group,
    COUNT(p.Patient_ID) AS Total_Patients
FROM 
    patients p
JOIN 
    speciality s ON p.Specialty_ID = s.Speciality_ID
GROUP BY 
    s.Specialty_Name, p.Gender, Age_Group
ORDER BY 
   Total_Patients DESC , s.Specialty_Name, Age_Group;
```

### 10. Top Longest-Staying Patients per Specialty
```sql
SELECT 
  p.Full_Name,
  s.Speciality_ID,
  s.Specialty_Name,
  p.Admission_Date,
  p.Discharge_Date,
  DATEDIFF(p.Discharge_Date, p.Admission_Date) AS No_of_Days
FROM (
    SELECT *,
           RANK() OVER (PARTITION BY Specialty_ID ORDER BY DATEDIFF(Discharge_Date, Admission_Date) DESC) AS rnk
    FROM patients
    WHERE Discharge_Date IS NOT NULL AND Admission_Date IS NOT NULL
) p
JOIN speciality s ON p.Specialty_ID = s.Speciality_ID
WHERE p.rnk <= 2
ORDER BY No_of_Days DESC;
```

### 11. Rank Branches by Average Monthly Revenue (Last 12 Months)
```sql
SELECT 
    bm.Branch_ID,
    b.branch_name,
    ROUND((
        `2024-09` + `2024-10` + `2024-11` + `2024-12` +
        `2025-01` + `2025-02` + `2025-03` + `2025-04` +
        `2025-05` + `2025-06` + `2025-07` + `2025-08`
    ) / 12, 2) AS Avg_12_Month_Revenue,
    RANK() OVER (ORDER BY (
        `2024-09` + `2024-10` + `2024-11` + `2024-12` +
        `2025-01` + `2025-02` + `2025-03` + `2025-04` +
        `2025-05` + `2025-06` + `2025-07` + `2025-08`
    ) DESC) AS Revenue_Rank
FROM 
    branch_monthly_revenuee BM
JOIN hospital_branches b ON bm.branch_id = b.branch_id;
```
### Question 12: (using view) Which hospital branches have the highest average patient spending in the past 6 months, 
   and which specialties are contributing most to that revenue
```sql
   CREATE OR REPLACE VIEW branch_specialty_avg_revenue AS
SELECT
    hb.branch_name,
    s.specialty_name,
    COUNT(p.Patient_ID) AS total_patients,
    ROUND(AVG(CAST(p.Out_of_Pocket AS DECIMAL(10,2))), 2) AS avg_patient_spending,
    SUM(CAST(p.Out_of_Pocket AS DECIMAL(10,2))) AS total_specialty_revenue
FROM
    patients p
    JOIN hospital_branches hb ON p.Branch_ID = hb.Branch_ID
    JOIN speciality s ON p.Specialty_ID = s.Speciality_ID
WHERE
    p.admission_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
    AND p.Out_of_Pocket IS NOT NULL AND p.Out_of_Pocket != ''
GROUP BY
    hb.branch_name, s.specialty_name
ORDER BY
    total_specialty_revenue DESC;

SELECT * FROM branch_specialty_avg_revenue
WHERE avg_patient_spending > 10000;
```
###  Question 13 : Which branch has the highest average patient spending (Out_of_Pocket) per doctor in the last 6 months of data, and what is the specialty
 with the most contribution in each branch?
```sql
WITH recent_patients AS (
    SELECT 
        p.Patient_ID,
        p.Branch_ID,
        p.Specialty_ID,
        CAST(p.Out_of_Pocket AS DECIMAL(10,2)) AS Out_of_Pocket
    FROM patients p
    WHERE 
        p.admission_date BETWEEN '2025-03-01' AND '2025-08-31'
        AND p.Out_of_Pocket IS NOT NULL
        AND p.Out_of_Pocket != ''
),
doctor_count_per_branch AS (
    SELECT 
        Branch_ID,
        COUNT(DISTINCT Doctor_ID) AS num_doctors
    FROM doctors
    GROUP BY Branch_ID
),
branch_specialty_revenue AS (
    SELECT
        rp.Branch_ID,
        rp.Specialty_ID,
        SUM(rp.Out_of_Pocket) AS total_revenue,
        COUNT(rp.Patient_ID) AS patient_count
    FROM recent_patients rp
    GROUP BY rp.Branch_ID, rp.Specialty_ID
),
avg_revenue_per_doctor AS (
    SELECT 
        bsr.Branch_ID,
        bsr.Specialty_ID,
        bsr.total_revenue,
        bsr.patient_count,
        dcpb.num_doctors,
        ROUND(bsr.total_revenue / dcpb.num_doctors, 2) AS avg_revenue_per_doctor
    FROM branch_specialty_revenue bsr
    JOIN doctor_count_per_branch dcpb 
      ON bsr.Branch_ID = dcpb.Branch_ID
),
final_output AS (
    SELECT 
        hb.branch_name,
        s.specialty_name,
        ard.avg_revenue_per_doctor,
        ard.total_revenue,
        RANK() OVER (PARTITION BY ard.Branch_ID ORDER BY total_revenue DESC) AS specialty_rank
    FROM avg_revenue_per_doctor ard
    JOIN hospital_branches hb ON ard.Branch_ID = hb.Branch_ID
    JOIN speciality s ON ard.Specialty_ID = s.Speciality_ID
)
SELECT *
FROM final_output
WHERE specialty_rank <= 2
ORDER BY avg_revenue_per_doctor DESC;
```
###  Question 14: How can we ensure that any time a new patient is added with Out_of_Pocket expenses over ₹15,000, it is automatically 
  logged into a separate audit table for high-spending cases

```sql
CREATE TABLE high_spender_log (
    Log_ID INT AUTO_INCREMENT PRIMARY KEY,
    Patient_ID INT,
    Full_Name VARCHAR(100),
    Out_of_Pocket DECIMAL(10,2),
    Logged_On DATETIME DEFAULT CURRENT_TIMESTAMP
);

DELIMITER $$

CREATE TRIGGER trg_high_spender_insert
AFTER INSERT ON patients
FOR EACH ROW
BEGIN
    IF NEW.Out_of_Pocket > 15000 THEN
        INSERT INTO high_spender_log (Patient_ID, Full_Name, Out_of_Pocket)
        VALUES (NEW.Patient_ID, NEW.Full_Name, NEW.Out_of_Pocket);
    END IF;
END$$

DELIMITER ;

INSERT INTO patients (
  Patient_ID, Full_Name, Age, Gender, Branch_ID, Doctor_ID,
  Specialty_ID, Admission_Date, Discharge_Date, Total_Cost,
  Insurance_Covered, Out_of_Pocket
)
VALUES
  (1001, 'Ravi Kumar', 45, 'Male', 1, 10, 3, '2025-07-10', '2025-07-18', 20000, 5000, 17000),
  (1002, 'Anita Sharma', 38, 'Female', 2, 11, 2, '2025-07-12', '2025-07-20', 18000, 6000, 12000),
  (1003, 'John Deo', 29, 'Male',  3, 12, 1, '2025-07-15', '2025-07-23', 16000, 4000, 18000),
  (1004, 'Meena Patel', 33, 'Female',  1, 13, 4, '2025-07-16', '2025-07-25', 17000, 3000, 14000),
  (1005, 'Aarav Singh', 41, 'Male',  2, 14, 3, '2025-07-17', '2025-07-26', 22000, 8000, 15500);
  
SELECT * FROM high_spender_log;
```
