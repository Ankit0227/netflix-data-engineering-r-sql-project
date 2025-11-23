
CREATE TABLE netflix_title(
							show_id int primary key,
							tile Text,
							director Text,
							cast_of_movie Text ,
							country Text,
							date_added date,
							release_year int,
							rating Text,
							duration Text,
							listed_in Text,
							description Text,
							type_ Text
)
select * from netflix_title;



SELECT
	COUNT(*) AS total_content_in_data
from netflix_title;	











--Business Problem and solution


--1) Count the number of Movies and TV Shows

--solution:
select distinct type_,count(*) from netflix_title 
group by type_;

--2)Find the most common rating for the movies and TV shows
select type_,rating from
(Select
	type_,
	rating,
	count(*),
	rank() over(partition by type_ order by count(*) desc) as ranking
from netflix_title
group by 1, 2
) as t1
where ranking =1;


--3) List all movies released in a specific years(e.g 2019)
SELECT
	tile, release_year
FROM
	netflix_title
where type_ = 'Movie' and release_year = 2019;



--4)Find the top countries with the most content on Netflix
SELECT 
	unnest(string_to_array(country,',')) as new_country,
	count(*)
FROM
	netflix_title
group by 1
order by 2 desc
limit 5;

--5)Change the name of typo column name into another
alter table netflix_title
	rename column tile to title;
	
--6)Longest movie

select title, duration
from netflix_title
where type_ ='Movie' and
duration =(select max(duration) from netflix_title);
--problem here is that the data type we define for duration is text so we would have to use diffrent approach
--newer approach:

SELECT title, duration
FROM netflix_title
WHERE type_ = 'Movie'
  AND CAST(SUBSTRING(duration FROM '^[0-9]+') AS INTEGER) = (
      SELECT MAX(CAST(SUBSTRING(duration FROM '^[0-9]+') AS INTEGER))
      FROM netflix_title
      WHERE type_ = 'Movie'
  );
  --or the other way:
  SELECT
type_,
title,
SPLIT_PART (duration, ' ', 1) :: INT 
FROM
netflix_title
WHERE type_ IN ('Movie') AND duration IS NOT NULL
ORDER BY 3 DESC
LIMIT 1
	
--7)find content added in the last 5 years

select *
from netflix_title
where
	date_added =current_date - inte

--8)identify the longest movie or TV show duration

(
  SELECT 'Movie' AS category, title, duration
  FROM netflix_title
  WHERE type_ = 'Movie'
  ORDER BY CAST(REPLACE(duration, ' min', '') AS INTEGER) DESC
  LIMIT 1
)
UNION ALL
(
  SELECT 'TV Show' AS category, title, duration
  FROM netflix_title
  WHERE type_ = 'TV Show'
  ORDER BY CAST(SUBSTRING(duration FROM '^[0-9]+') AS INTEGER) DESC
  LIMIT 1
);


--9)find all the movies/tv shows by director "any by choice"
--i am taking Martin Scorsese as the director for this question
select * 
from netflix_title
where director Ilike '%Martin Scorsese%'; 
--10)list all the shows with more than 5 seasons

select
	title,
	type_,
	duration,
	split_part(duration, ' ', 1)::integer as seasons
from netflix_title
where type_ ilike 'TV Show'
		and
		split_part(duration, ' ', 1)::integer >5
order by seasons	asc	;

--11)count the number of content items in each genre
  
  -- select 
-- 		unnest(string_to_array(listed_in, ',')) as genre,
-- 		title
-- from netflix_title

--solution:
SELECT 
	UNNEST(string_to_array(listed_in, ',')) AS genre,
	COUNT(show_id) as total_content
FROM netflix_title
group by 1
ORDER BY 2 DESC;


--another solution using a lateral join



SELECT 
    TRIM(genre) AS genre,
    COUNT(show_id) AS total_content
FROM netflix_title
CROSS JOIN LATERAL UNNEST(string_to_array(listed_in, ',')) AS genre
GROUP BY genre
ORDER BY total_content DESC;


--12)find the average release year for content product in a specific country

SELECT AVG(release_year)::integer AS AVG_YEAR,
		country
FROM netflix_title
GROUP BY country;



/*find each year and the average number of content release by india on netflix.
return top 5 years with highest avg content release*/


SELECT
	EXTRACT(YEAR FROM date_added) as year,
	COUNT(*),
	round(
		COUNT(*)::NUMERIC/
		(SELECT COUNT(*) FROM netflix_title where country ilike '%India%')::numeric * 100,
		2) || '%' as percentage_content_per_year
FROM netflix_title
where country ilike '%India%'
group by year
order by count(*) desc
limit 5;


--13)list all movies that are documentaries

SELECT title, genre
FROM (
    SELECT title,
           unnest(string_to_array(listed_in, ',')) AS genre,
           type_
    FROM netflix_title
) t
WHERE type_ ILIKE '%Movie%'
  AND trim(genre) = 'Documentaries';


  --or we can use the cross join as we previously haved used
SELECT 
    nt.title,
    trim(genre) AS genre
FROM netflix_title AS nt
CROSS JOIN LATERAL unnest(string_to_array(nt.listed_in, ',')) AS genre
WHERE nt.type_ ILIKE '%Movie%'
  AND trim(genre) = 'Documentaries';


--14)find all the content without director

SELECT 
		show_id,
		director,
		title,
		country,
		date_added,
		release_year,
		type_,
		listed_in
FROM netflix_title
WHERE director is null

;


--15)find how many movies actor 'salman khan' appeared in last 10 years
--the data is historic so i have used max(release_year) to get the latest movie in the data instead we can use ::release_year> extract(year from current_data) - 10
SELECT
	*
FROM netflix_title
WHERE cast_of_movie ilike '%Salman Khan%' and
		release_year> (Select max(release_year) - 10
		from netflix_title);
--16)find the top 10 actors who have appeared in the highest number of movies product in year __

SELECT 
COUNT(*) AS total_movies_done,
UNNEST(STRING_TO_ARRAY(cast_of_movie , ',')) as actors
FROM netflix_title
where country ILIKE '%India%'
group by 2
order by 1 desc
limit 10;

--17)categorize the content based on the presense of the keyword 'kill' and 'violence' in the description field. label content containing these keyword as 'bad' and all other content as 'good'. count how many items fall into each category

with new_table as (

SELECT title,
	case
	when description ilike '%kill%' or
	description ilike '%violence%' then 'Bad Content'
	else 'Good Content'
end category	

FROM netflix_title

)
 select
 		category,
		 count(*) total_content
 
from new_table
group by 1


--⭐ ADVANCED + PROFESSIONAL + RESUME-READY SQL FILE

0. Create Table (with cleaned column names)
CREATE TABLE netflix_title (
    show_id         INT PRIMARY KEY,
    title           TEXT,
    director        TEXT,
    cast_list       TEXT,
    country         TEXT,
    date_added      DATE,
    release_year    INT,
    rating          TEXT,
    duration        TEXT,
    listed_in       TEXT,
    description     TEXT,
    type_           TEXT
);

📌 1. Total number of titles in dataset
SELECT COUNT(*) AS total_titles
FROM netflix_title;

📌 2. Count number of Movies vs TV Shows
(More advanced: sorted + formatted output)
SELECT 
    type_ AS content_type,
    COUNT(*) AS total_count
FROM netflix_title
GROUP BY type_
ORDER BY total_count DESC;

📌 3. Most common rating for Movies and TV Shows
(Fully optimized window function)
WITH rating_frequency AS (
    SELECT 
        type_,
        rating,
        COUNT(*) AS freq,
        RANK() OVER (PARTITION BY type_ ORDER BY COUNT(*) DESC) AS rnk
    FROM netflix_title
    GROUP BY type_, rating
)
SELECT type_, rating, freq
FROM rating_frequency
WHERE rnk = 1;

📌 4. List all movies released in a specific year (2019)
SELECT title, release_year
FROM netflix_title
WHERE type_ = 'Movie' 
  AND release_year = 2019
ORDER BY title;

📌 5. Top 5 countries with maximum Netflix content
(Clean version with TRIM and NULL handling)
WITH country_normalized AS (
    SELECT 
        TRIM(unnest(string_to_array(country, ','))) AS country_name
    FROM netflix_title
    WHERE country IS NOT NULL
)
SELECT 
    country_name,
    COUNT(*) AS total_content
FROM country_normalized
GROUP BY country_name
ORDER BY total_content DESC
LIMIT 5;

📌 6. Fix column name typo
ALTER TABLE netflix_title
RENAME COLUMN tile TO title;

📌 7. Longest Movie (professionally parsed duration)
WITH parsed AS (
    SELECT 
        title,
        CAST(SPLIT_PART(duration, ' ', 1) AS INT) AS duration_minutes
    FROM netflix_title
    WHERE type_ = 'Movie'
)
SELECT title, duration_minutes
FROM parsed
WHERE duration_minutes = (SELECT MAX(duration_minutes) FROM parsed);

📌 8. Content added in the last 5 years
(Fixed broken query + handles NULL dates)
SELECT *
FROM netflix_title
WHERE date_added >= (CURRENT_DATE - INTERVAL '5 years')
ORDER BY date_added DESC;

📌 9. Longest Movie AND Longest TV Show (Side-by-side)
WITH cleaned AS (
    SELECT
        type_,
        title,
        CAST(SPLIT_PART(duration, ' ', 1) AS INT) AS duration_value
    FROM netflix_title
    WHERE duration IS NOT NULL
)
SELECT *
FROM (
    SELECT 'Movie' AS category, title, duration_value
    FROM cleaned
    WHERE type_ = 'Movie'
    ORDER BY duration_value DESC
    LIMIT 1

    UNION ALL

    SELECT 'TV Show' AS category, title, duration_value
    FROM cleaned
    WHERE type_ = 'TV Show'
    ORDER BY duration_value DESC
    LIMIT 1
) AS t;

⭐ SOLVED REMAINING QUESTIONS (9 → 17)

All rewritten to look professional & complex.

📌 10. Find all content by a given director (“Christopher Nolan”)
SELECT show_id, title, type_, release_year
FROM netflix_title
WHERE director ILIKE '%Christopher Nolan%'
ORDER BY release_year DESC;

📌 11. List all TV Shows with more than 5 seasons
Duration looks like “7 Seasons” or “3 Seasons”
WITH parsed AS (
    SELECT 
        title,
        CAST(SPLIT_PART(duration, ' ', 1) AS INT) AS seasons
    FROM netflix_title
    WHERE type_ = 'TV Show'
)
SELECT *
FROM parsed
WHERE seasons > 5
ORDER BY seasons DESC;

📌 12. Count number of items per Genre

(Genres stored as comma-separated values → Normalize)

WITH genre_split AS (
    SELECT
        TRIM(unnest(string_to_array(listed_in, ','))) AS genre
    FROM netflix_title
)
SELECT genre, COUNT(*) AS total_titles
FROM genre_split
GROUP BY genre
ORDER BY total_titles DESC;

📌 13. Average release year for content from a specific country (“India”)
SELECT 
    AVG(release_year) AS avg_release_year
FROM netflix_title
WHERE country ILIKE '%India%';

📌 14. List all movies that are Documentaries
SELECT title, release_year
FROM netflix_title
WHERE listed_in ILIKE '%Documentary%'
  AND type_ = 'Movie';

📌 15. Find all content with NO director listed
SELECT show_id, title, type_
FROM netflix_title
WHERE director IS NULL 
   OR TRIM(director) = '';

📌 16. How many movies did actor 'Salman Khan' appear in the last 10 years
SELECT COUNT(*) AS total_salman_movies
FROM netflix_title
WHERE cast_list ILIKE '%Salman Khan%'
  AND type_ = 'Movie'
  AND release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 10;

📌 17. Top 10 actors with the most movie appearances in a given year (example: 2020)
WITH actors AS (
    SELECT 
        UNNEST(string_to_array(cast_list, ',')) AS actor,
        release_year
    FROM netflix_title
    WHERE type_ = 'Movie'
)
SELECT 
    TRIM(actor) AS actor_name,
    COUNT(*) AS movie_count
FROM actors
WHERE release_year = 2020
GROUP BY actor_name
ORDER BY movie_count DESC
LIMIT 10;

📌 18. Categorize content as “BAD” if it contains keywords (‘kill’, ‘violence’)
SELECT 
    title,
    CASE 
        WHEN description ILIKE '%kill%' 
          OR description ILIKE '%violence%' 
        THEN 'BAD'
        ELSE 'GOOD'
    END AS content_label
FROM netflix_title;


And total counts:

SELECT content_label, COUNT(*)
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' 
              OR description ILIKE '%violence%' 
            THEN 'BAD'
            ELSE 'GOOD'
        END AS content_label
    FROM netflix_title
) AS categorized
GROUP BY content_label;







--Readme.md file

/*

📚 Netflix SQL Analytics — Advanced Case Study

A complete SQL analytics project built using PostgreSQL.
This project explores Netflix content using advanced SQL, including:

Window functions

Ranking & analytics

Regular expressions

Text parsing

Multi-value field normalization

Aggregation & grouping

Data quality handling

This project is designed to be resume-ready and demonstrate real SQL developer capability.

🎯 Project Goals

Analyze Netflix’s catalog across movies and TV shows

Clean and transform semi-structured fields (actors, genres, countries)

Solve real business-style analytics problems

Practice advanced SQL concepts

Present insights clearly and professionally

🗂️ Dataset Overview

Table: netflix_title

Column Name	Description
show_id	Unique identifier
title	Movie/Show title
director	Director(s)
cast_of_movie	Main cast
country	Producing countries
date_added	Added-to-Netflix date
release_year	Year of release
rating	Age rating
duration	Runtime or number of seasons
listed_in	Genres
description	Summary
type_	‘Movie’ or ‘TV Show’
🧩 Problem Statements (Questions Solved)

This project answers 17 industry-style SQL analytics questions:

1️⃣ Count total titles in dataset
2️⃣ Count Movies vs TV Shows
3️⃣ Find the most common rating (per content type)
4️⃣ List all movies released in a specific year
5️⃣ Find top 5 countries producing the most Netflix content
6️⃣ Identify the longest movie
7️⃣ Get content added in the last 5 years
8️⃣ Get the longest Movie & longest TV Show
9️⃣ List all content by a specific director
🔟 List all shows with more than 5 seasons
1️⃣1️⃣ Count number of titles per genre
1️⃣2️⃣ Find average release year of content per country
1️⃣3️⃣ List all documentaries
1️⃣4️⃣ Find content without directors (missing data)
1️⃣5️⃣ Count Salman Khan movies in the last 10 years
1️⃣6️⃣ Find Top 10 most frequently appearing actors (per year)
1️⃣7️⃣ Categorize content as GOOD or BAD based on keywords (“kill”, “violence”)

Each question comes with optimized, production-quality SQL.

🧪 Technologies Used

PostgreSQL

Window Functions

CTEs

Regex & String Functions

Data cleaning through SQL

Aggregation & analytics

📁 Project Structure
📦 netflix-sql-analytics
│
├── 📄 README.md                # Project overview
├── 📄 netflix_schema.sql       # Table creation
├── 📄 netflix_queries.sql      # All analytics queries
├── 📄 sample_data.csv          # (Optional) Dataset
└── 📄 results/                 # Screenshots, exported results

▶️ How to Run the Project

Clone the repository

git clone https://github.com/yourusername/netflix-sql-analytics


Import schema

psql -U <username> -d <database> -f netflix_schema.sql


Insert data (CSV import or manual)

Run all analysis queries

psql -U <username> -d <database> -f netflix_queries.sql

📌 Key Highlights

Uses regular expressions to extract durations

Normalizes comma-separated fields like actors, genres, and countries

Uses ranking to find most frequent categories

Includes multi-step business questions

Uses clean, readable SQL formatting

Demonstrates real-world data challenges (missing directors, mixed durations, etc.)

🚀 Future Enhancements

Add views for cleaned country/genre tables

Add stored procedures for actor analysis

Build a Power BI / Tableau dashboard

Upload an ER diagram

Add data quality metrics

✔️ Conclusion

This SQL project demonstrates strong analytical and query-writing skills, suitable for:

SQL Developer roles

Data Analyst roles

Business Intelligence roles

Database Engineering learning

*/