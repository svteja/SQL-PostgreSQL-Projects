# SQL Projects

This repository contains multiple SQL projects with structured queries, schema designs, and data solutions. Click on a project folder to explore its files and query logic.

## 📊 Projects
### 1️⃣ [Netflix Platform Analysis ](netflix_project/)

## 📌 Project Details
### Problem Statement:

Netflix is constantly adding new titles and expanding its global content library. To improve content recommendation, user engagement, and catalog management, it's essential to analyze patterns in the type, genre, release, and availability of content across countries and time. This project aims to extract meaningful insights from Netflix’s title database using advanced SQL techniques.

### 🔹 Solution:
Cleaned and transformed the dataset using string functions, date conversions, and CTEs to handle fields like duration, listed_in, and date_added.

Used window functions, self joins, and subqueries to derive advanced insights such as:

Most frequent genres and ratings

Longest movies by rating category

Top actors/directors based on country and frequency

Monthly trends in new content additions

Handled multi-valued fields (like genres, countries, cast) using UNNEST + STRING_TO_ARRAY, enabling accurate aggregation and ranking.

Designed 15+ diverse SQL queries covering content classification, trend analysis, and performance benchmarking.

🧠 Key Highlights:
Applied analytical SQL functions (e.g., RANK(), SUM() OVER(), CASE) for deeper business insights.

Created dynamic and reusable queries that could be integrated into Power BI or dashboards.

Addressed common real-world challenges like:

Inconsistent date formats

Null/missing director values

Overlapping genre and country fields

🧰 Tools Used:

PostgreSQL,pgAdmin (or any SQL editor),Excel (for initial inspection)

### 🏥[Hospital Data Analytics Project ](Hospital_Data_Analytics_Project/)

## 📌 Overview
This project simulates a real-world hospital environment using structured data from multiple tables such as doctors, patients, hospital branches, specialities, and monthly branch revenues. It helps uncover meaningful business insights using intermediate to advanced SQL techniques, useful for analysts and healthcare decision-makers.

## 🧩 Problem Statement
Hospitals deal with vast data daily — from patient admissions and medical specialties to financial metrics like consultation fees and revenue. Stakeholders need clear, data-driven answers to questions
 
## ✅ Solution
Using  MY SQL , this project:

Cleans and transforms raw data (e.g., filling missing discharge dates, converting blanks to NULLs, formatting costs).

Applies advanced SQL techniques like:

CTEs, window functions, joins, and date operations

Triggers for audit trails (e.g., patient insertions)

Stored procedures to encapsulate common business logic (e.g., get monthly revenue)

Indexes to improve query performance on patient visits and admissions

Solves 15+ business questions such as:

Rank doctors based on salary by department

Identify patients with the highest out-of-pocket spending

Analyze revenue trends by branch and specialty

Detect which specialties have longer patient stays

## 🧰 Tools Used
 MySQL Workbench – for SQL scripting and execution

Excel – initial data inspection and formatting
