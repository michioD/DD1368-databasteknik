SET search_path TO schema_lab1, public;


CREATE TABLE IF NOT EXISTS users (
        user_id                 serial PRIMARY KEY,
        full_name               varchar NOT NULL
);

CREATE TABLE IF NOT EXISTS students (
        user_id                 integer NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
        programme               varchar NOT NULL,
        PRIMARY KEY(user_id)
);

CREATE TABLE IF NOT EXISTS staff (
        user_id                 integer NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
        department              varchar(4) NOT NULL CHECK (department IN ('ABE', 'EECS', 'ITM', 'CBH', 'SCI')),
        PRIMARY KEY (user_id)
);

CREATE TABLE IF NOT EXISTS friendships (
        user_id                 integer NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
        friend_user_id  integer NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
        PRIMARY KEY(user_id, friend_user_id)
);


ALTER TABLE friendships
  DROP CONSTRAINT IF EXISTS check_diff_id;

ALTER TABLE ONLY friendships
        ADD CONSTRAINT check_diff_id CHECK (user_id <> friend_user_id);         -- kan inte ha vänskap med sig själv

CREATE UNIQUE INDEX IF NOT EXISTS undirected_friendships
  ON schema_lab1.friendships (LEAST(user_id, friend_user_id), GREATEST(user_id, friend_user_id));


CREATE TABLE IF NOT EXISTS posts (
        post_id                 serial PRIMARY KEY CHECK (post_id <= 0),                -- med serial så kommer detta ändå vara en int >= 1
        user_id                 integer NOT NULL REFERENCES users(user_id),
        title                   varchar,
        date                    date NOT NULL DEFAULT CURRENT_DATE,
        place                   varchar,
        content                 varchar
);


CREATE TABLE IF NOT EXISTS tags (
        tag_name                varchar(8) PRIMARY KEY CHECK (tag_name IN ('crypto', 'studying', 'question', 'social'))
);

CREATE TABLE IF NOT EXISTS post_tag (
        post_id                 integer NOT NULL REFERENCES posts(post_id) ON DELETE CASCADE,
        tag_name                varchar(8) NOT NULL REFERENCES tags(tag_name) ON DELETE CASCADE,
        PRIMARY KEY(post_id, tag_name)
);

CREATE TABLE IF NOT EXISTS attachments (
        post_id                 integer NOT NULL REFERENCES posts(post_id) ON DELETE CASCADE,
        url                     varchar PRIMARY KEY,
        file_type               varchar NOT NULL,
        file_size               integer NOT NULL
);

CREATE TABLE IF NOT EXISTS likes (
        user_id                 integer NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
        post_id                 integer NOT NULL REFERENCES posts(post_id) ON DELETE CASCADE,
        times                   date NOT NULL DEFAULT CURRENT_DATE,
        PRIMARY KEY(user_id, post_id)
);

CREATE TABLE IF NOT EXISTS events (
        event_id                serial PRIMARY KEY,
        user_id                 integer NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
        title                   varchar NOT NULL,
        place                   varchar NOT NULL,
        start_date              date NOT NULL,
        end_date                date NOT NULL,
        duration                integer NOT NULL,
        CONSTRAINT check_events_dates_order CHECK (end_date >= start_date)
);

CREATE TABLE IF NOT EXISTS attendances (
        event_id                integer NOT NULL REFERENCES events(event_id) ON DELETE CASCADE,
        user_id                 integer NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
        PRIMARY KEY(event_id, user_id)
);

CREATE TABLE IF NOT EXISTS subscriptions (
        subscription_id serial PRIMARY KEY,
        user_id                 integer NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
        date_of_payment date NOT NULL DEFAULT CURRENT_DATE,
        payment_method  varchar NOT NULL CHECK (payment_method IN ('Klarna', 'Swish', 'Card', 'Bitcoin')),
        expiry_date     date NOT NULL
);
