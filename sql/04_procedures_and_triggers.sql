-- 04_procedures_and_triggers.sql
CREATE OR REPLACE FUNCTION extract_first_int(txt TEXT) RETURNS INT AS $$
DECLARE v INT;
BEGIN
  IF txt IS NULL THEN RETURN NULL; END IF;
  BEGIN
    v := CAST(REGEXP_REPLACE(txt, '[^0-9]', '', 'g') AS INTEGER);
    RETURN v;
  EXCEPTION WHEN INVALID_TEXT_REPRESENTATION THEN
    RETURN NULL;
  END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION recompute_avg_rating_for_show(p_show_id INT) RETURNS VOID AS $$
BEGIN
  UPDATE netflix_title SET
    -- store avg_rating in a denormalized column if you add one
    -- avg_rating = sub.avg
    -- For demo, we will just perform a select; in production you'd update
    NULL = NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ratings_insert_trigger() RETURNS TRIGGER AS $$
BEGIN
  -- example: refresh materialized view or call recompute function
  PERFORM pg_notify('ratings_change', TG_ARGV[0]::text);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_ratings_insert AFTER INSERT ON ratings
FOR EACH ROW EXECUTE PROCEDURE ratings_insert_trigger();
