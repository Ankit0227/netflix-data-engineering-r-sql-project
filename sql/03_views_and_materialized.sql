-- 03_views_and_materialized.sql
CREATE VIEW vw_top_genres AS
SELECT TRIM(UNNEST(string_to_array(listed_in,','))) AS genre, COUNT(*) AS cnt
FROM netflix_title
GROUP BY 1
ORDER BY cnt DESC;

CREATE MATERIALIZED VIEW mv_avg_rating AS
SELECT show_id, ROUND(AVG(r.rating)::numeric,2) AS avg_rating
FROM ratings r
GROUP BY show_id;
