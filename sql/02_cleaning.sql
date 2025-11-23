-- 02_cleaning.sql
-- Staging table import (assumes CSV loaded into netflix_title_stg via COPY)
CREATE TABLE IF NOT EXISTS netflix_title_stg (
    show_id_text TEXT,
    title TEXT,
    director TEXT,
    cast_list TEXT,
    country TEXT,
    date_added TEXT,
    release_year_text TEXT,
    rating TEXT,
    duration TEXT,
    listed_in TEXT,
    description TEXT,
    type_ TEXT
);

-- Clean and move to target table
INSERT INTO netflix_title (show_id, title, director, cast_list, country, date_added, release_year, rating, duration, listed_in, description, type_)
SELECT
  NULLIF(TRIM(show_id_text),'')::INT AS show_id,
  NULLIF(TRIM(title),'')::TEXT AS title,
  NULLIF(TRIM(director),'')::TEXT AS director,
  NULLIF(TRIM(cast_list),'')::TEXT AS cast_list,
  NULLIF(TRIM(country),'')::TEXT AS country,
  (CASE
     WHEN date_added ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN TO_DATE(date_added,'YYYY-MM-DD')
     WHEN date_added ~ '^[A-Za-z]{3} [0-9]{1,2}, [0-9]{4}$' THEN TO_DATE(date_added,'Mon DD, YYYY')
     ELSE NULL
   END) AS date_added,
  NULLIF(TRIM(release_year_text),'')::INT AS release_year,
  NULLIF(TRIM(rating),'') AS rating,
  NULLIF(TRIM(duration),'') AS duration,
  NULLIF(TRIM(listed_in),'') AS listed_in,
  NULLIF(TRIM(description),'') AS description,
  CASE WHEN TRIM(type_) IN ('Movie','TV Show') THEN TRIM(type_) ELSE NULL END
FROM netflix_title_stg
WHERE NULLIF(TRIM(title),'') IS NOT NULL;
