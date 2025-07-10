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

PostgreSQL

pgAdmin (or any SQL editor)

Excel (for initial inspection)
