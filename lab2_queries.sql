SELECT p.title, string_agg(t.tag, ', ' ORDER BY t.tag) AS tags
FROM post p
JOIN posttag t ON t.postid = p.postid
GROUP BY p.postid, p.title
ORDER BY p.title;


SELECT postid,
       title,
       rank
FROM (
    SELECT p.postid,
           p.title,
           DENSE_RANK() OVER (ORDER BY COUNT(l.postid) DESC) as rank
    FROM post p
    JOIN likes l ON l.postid = p.postid
    JOIN posttag t ON t.postid = p.postid
    WHERE t.tag = '#leadership'
    GROUP BY p.postid
     ) x
WHERE rank <= 5
ORDER BY rank, title;


WITH weeks AS (
    SELECT generate_series(1, 52) AS week
    ),
    subs AS (
        SELECT userid,
               date,
               DATE_PART('week', date) AS week,
               MIN(date) OVER (PARTITION BY userid) AS first_date
        FROM subscription
    ),
    subs_per_week AS (
        SELECT week,
               SUM(CASE WHEN s.date = s.first_date THEN 1 ELSE 0 END) AS new_customers,
               SUM(CASE WHEN s.date > s.first_date THEN 1 ELSE 0 END) AS kept_customers
        FROM subs s
        GROUP BY week
    ),
    posts_per_week AS (
        SELECT DATE_PART('week', p.date) AS week,
               COUNT(p.postid) AS activity
        FROM post p
        GROUP BY week
    )
SELECT w.week,
       COALESCE(sw.new_customers, 0)  AS new_customers,
       COALESCE(sw.kept_customers, 0) AS kept_customers,
       COALESCE(pw.activity, 0)       AS activity
FROM weeks w
LEFT JOIN subs_per_week sw
    ON sw.week = w.week
LEFT JOIN posts_per_week pw
    ON pw.week = w.week
WHERE w.week <= 30
ORDER BY w.week;



WITH edges AS (
    SELECT userid AS u, friendid AS v FROM friend
    UNION ALL
    SELECT friendid AS u, userid AS v FROM friend
),
    friends AS (
    SELECT
        u AS userid,
        COUNT(DISTINCT v)::int AS n_friends
    FROM edges
    WHERE u <> v
    GROUP BY u
)
SELECT u.userid AS id,
       u.name AS name,
       (f.userid != 0) AS has_friends,
       s.date AS registration_date
FROM subscription s
LEFT JOIN friends f ON f.userid = s.userid
LEFT JOIN users u ON u.userid = s.userid
WHERE DATE_PART('month', date) = 1
ORDER BY u.name;


SELECT
  u.userid AS id,
  u.name   AS name,
  EXISTS (
    SELECT 1
    FROM friend f
    WHERE
      -- vänskap kan ligga på vilken sida som helst
      (f.userid = s.userid OR f.friendid = s.userid)
      -- ev. självkanter
      AND f.userid <> f.friendid
    LIMIT 1
  ) AS has_friends,
  s."date" AS registration_date
FROM subscription s
LEFT JOIN users u ON u.userid = s.userid
WHERE EXTRACT(MONTH FROM s."date") = 1
ORDER BY u.name NULLS LAST;



WITH RECURSIVE
edges AS (
  SELECT userid AS u, friendid AS v FROM friend
  UNION ALL
  SELECT friendid AS u, userid AS v FROM friend
),
chain AS (
  -- bassteg: starta på Anas med id 20
  SELECT
    20::int          AS current,
    NULL::int        AS prev,
    ARRAY[20]        AS path,
    1                AS position
  UNION ALL
  -- rekursivt steg: nästa granne som inte skapar triangel eller cykel
  SELECT
    e.v              AS current,
    c.current        AS prev,
    c.path || e.v    AS path,
    c.position + 1   AS position
  FROM chain c
  JOIN edges e ON e.u = c.current
  WHERE NOT (e.v = ANY(c.path))                 -- inte redan i listan
    AND NOT EXISTS (                            -- ingen länk till tidigare än grannen
      SELECT 1
      FROM edges x
      JOIN unnest(c.path) AS p ON true
      WHERE x.u = e.v
        AND x.v = p
        AND p <> c.current
    )
),
names AS (
  SELECT c.position, u.userid, u.name
  FROM chain c
  JOIN users u ON u.userid = c.current
)
SELECT
  name AS name,
  userid AS user_id,
  LEAD(userid) OVER (ORDER BY position) AS friend_id
FROM names
ORDER BY position;


