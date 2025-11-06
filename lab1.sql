SET search_path TO schema_lab1, public;

CREATE TABLE IF NOT EXISTS users (
        user_id                 serial PRIMARY KEY,
        full_name               varchar NOT NULL
);

CREATE TABLE IF NOT EXISTS students (
        user_id                 integer NOT NULL,
        programme               varchar NOT NULL,
        PRIMARY KEY(user_id),
        CONSTRAINT FK_students FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS staff (
        user_id                 integer NOT NULL,
        department              varchar(4) NOT NULL CHECK (department IN ('ABE', 'EECS', 'ITM', 'CBH', 'SCI')),
        PRIMARY KEY (user_id),
        CONSTRAINT FK_staff FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS friendships (
        user_id                 integer NOT NULL,
        friend_user_id  integer NOT NULL,
        PRIMARY KEY(user_id, friend_user_id),
        CONSTRAINT FK_friendship_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
        CONSTRAINT FK_friendship_friend FOREIGN KEY (friend_user_id) REFERENCES users(user_id) ON DELETE CASCADE
);


ALTER TABLE friendships
  DROP CONSTRAINT IF EXISTS check_diff_id;

ALTER TABLE ONLY friendships
        ADD CONSTRAINT check_diff_id CHECK (user_id <> friend_user_id);         -- kan inte ha vänskap med sig själv

CREATE UNIQUE INDEX IF NOT EXISTS undirected_friendships
  ON friendships (LEAST(user_id, friend_user_id), GREATEST(user_id, friend_user_id));


CREATE TABLE IF NOT EXISTS posts (
        post_id                 serial PRIMARY KEY CHECK (post_id >= 0),                -- med serial så kommer detta ändå vara en int >= 1
        user_id                 integer NOT NULL,
        title                   varchar,
        created_at              timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
        place                   varchar,
        content                 varchar,
        CONSTRAINT FK_post FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE IF NOT EXISTS post_tag (
        post_id                 integer NOT NULL,
        tag_name                varchar(8) NOT NULL CHECK (tag_name IN ('crypto', 'studying', 'question', 'social')),
        PRIMARY KEY(post_id, tag_name),
        CONSTRAINT FK_post_tag__post FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE
        -- CONSTRAINT FK_post_tag__tag FOREIGN KEY (tag_name) REFERENCES tags(tag_name)
);

CREATE TABLE IF NOT EXISTS attachments (
        post_id                 integer NOT NULL,
        url                     varchar NOT NULL,
        file_type               varchar NOT NULL CHECK (file_type IN ('video', 'image')),
        file_size               integer NOT NULL CHECK (file_size >= 0),
        PRIMARY KEY(post_id, url),
        CONSTRAINT FK_attachment FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS likes (
        user_id                 integer NOT NULL,
        post_id                 integer NOT NULL,
        liked_at                timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY(user_id, post_id),
        CONSTRAINT FK_like_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
        CONSTRAINT FK_like_post FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS events (
        event_id                serial PRIMARY KEY,
        user_id                 integer NOT NULL,
        title                   varchar NOT NULL,
        place                   varchar NOT NULL,
        start_date              timestamp NOT NULL,
        end_date                timestamp NOT NULL,
        duration                interval NOT NULL GENERATED ALWAYS AS (end_date - start_date) STORED,
        CONSTRAINT check_events_dates_order CHECK (end_date >= start_date),
        CONSTRAINT FK_events FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE IF NOT EXISTS attendances (
        event_id                integer NOT NULL,
        user_id                 integer NOT NULL,
        PRIMARY KEY(event_id, user_id),
        CONSTRAINT FK_attendance_event FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE CASCADE,
        CONSTRAINT FK_attendance_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS subscriptions (
        subscription_id serial PRIMARY KEY,
        user_id                 integer NOT NULL,
        date_of_payment date NOT NULL DEFAULT CURRENT_DATE,
        payment_method  varchar NOT NULL CHECK (payment_method IN ('Klarna', 'Swish', 'Card', 'Bitcoin')),
        expiry_date     date NOT NULL GENERATE ALWAYS AS (date_of_payment + INTERVAL '30 days') STORED,
        CONSTRAINT expiry_date_always_30days CHECK (expiry_date = date_of_payment + INTERVAL '30 days'),
        CONSTRAINT FK_subscriptions_user_id FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
        CONSTRAINT only_one_active_subcription_per_user UNIQUE (user_id) WHERE (expiry_date >= CURRENT_DATE)
);


-- CREATE TABLE IF NOT EXISTS tags (
--      tag_name                varchar PRIMARY KEY CHECK (tag_name IN ('crypto', 'studying', 'question', 'social'))
-- );
