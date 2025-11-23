-- 01_schema.sql
CREATE TABLE netflix_title(
    show_id        INT PRIMARY KEY,
    title          TEXT NOT NULL,
    director       TEXT,
    cast_list      TEXT,
    country        TEXT,
    date_added     DATE,
    release_year   INT CHECK (release_year >= 1800 AND release_year <= EXTRACT(YEAR FROM CURRENT_DATE)),
    rating         TEXT,
    duration       TEXT,
    listed_in      TEXT,
    description    TEXT,
    type_          TEXT CHECK (type_ IN ('Movie', 'TV Show'))
);

CREATE TABLE users(
    user_id SERIAL PRIMARY KEY,
    name TEXT,
    email TEXT UNIQUE
);

CREATE TABLE ratings(
    rating_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    show_id INT REFERENCES netflix_title(show_id),
    rating SMALLINT CHECK (rating >=1 AND rating <=5),
    rating_date DATE DEFAULT CURRENT_DATE
);

CREATE TABLE genres(
    genre_id SERIAL PRIMARY KEY,
    genre_name TEXT UNIQUE
);

CREATE TABLE book_tags(
    show_id INT REFERENCES netflix_title(show_id),
    tag TEXT
);

CREATE TABLE activity_log(
    log_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    show_id INT REFERENCES netflix_title(show_id),
    activity_type TEXT,
    activity_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
