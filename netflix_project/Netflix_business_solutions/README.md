### 1. Count the Number of Movies vs TV Shows

```sql
SELECT 
    type,
    COUNT(*)
FROM netflix
GROUP BY 1;
```

### 2. Find the Most Common Rating for Movies and TV Shows
```sql
WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;
```

### 3. trend of Movie Releases Over the Years (with Running Total)
```sql
WITH MovieCounts AS (
    SELECT 
        release_year,
        COUNT(*) AS movies_released
    FROM netflix
    WHERE type = 'Movie'
    GROUP BY release_year
)
SELECT 
    release_year,
    movies_released,
    SUM(movies_released) OVER (ORDER BY release_year) AS running_total
FROM MovieCounts
ORDER BY release_year;
```

### 4. Find the Top 5 Countries with the Most Content on Netflix
```sql
SELECT * 
FROM
(
    SELECT 
        UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
        COUNT(*) AS total_content
    FROM netflix
    GROUP BY 1
) AS t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;
```
### 5. Find Top 3 Longest Movies per Rating Category
```sql
WITH MovieDurations AS (
    SELECT *,
        SPLIT_PART(duration, ' ', 1)::INT AS minutes
    FROM netflix
    WHERE type = 'Movie'
)
SELECT *
FROM (
    SELECT *,
        RANK() OVER (PARTITION BY rating ORDER BY minutes DESC) AS rank
    FROM MovieDurations
) AS ranked
WHERE rank <= 3
ORDER BY  rank;
```

### 6.  Monthly Trend of Content Added in the Last 5 Years 
```sql
WITH cleaned_data AS (
    SELECT *,
        TO_DATE(date_added, 'Month DD, YYYY') AS added_date
    FROM netflix
    WHERE date_added IS NOT NULL
),
filtered_data AS (
    SELECT *
    FROM cleaned_data
    WHERE added_date >= CURRENT_DATE - INTERVAL '5 years'
)
SELECT 
    DATE_TRUNC('month', added_date) AS month,
    COUNT(*) AS content_added
FROM filtered_data
GROUP BY month
ORDER BY month;
```

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'.
```sql
SELECT *
FROM (
    SELECT 
        *,
        UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
    FROM netflix
) AS t
WHERE director_name = 'Rajiv Chilaka';
```

### 8. List All TV Shows with More Than 5 Seasons
```sql
SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::INT > 5;
```

### 9. Count the Number of Content Items in Each Genre.
```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(*) AS total_content
FROM netflix
GROUP BY 1;
```
### 10.Find each year and the average numbers of content release in India on netflix.
```sql
SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;
```
### 11. List All Movies that are Documentaries.
```sql
SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries';

### 12.  Find Shows with the Same Director
```sql
SELECT 
    A.title AS show_1,
    B.title AS show_2,
    A.director
FROM netflix A
JOIN netflix B
  ON A.director = B.director
  AND A.show_id <> B.show_id
WHERE A.director IS NOT NULL;
```

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
```sql
SELECT * 
FROM netflix
WHERE casts LIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
```

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India.
```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 10;
```
### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
```sql
SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;
```
