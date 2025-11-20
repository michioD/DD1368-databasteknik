


SELECT p.title, string_agg(t.tag, ', ' ORDER BY t.tag) AS tags       -- Hämtar titeln för varje inlägg och samlar taggarna i en kommaseparerad lista
FROM post p
JOIN posttag t ON t.postid = p.postid       -- Kopplar inlägg med taggar via postid.
GROUP BY p.postid, p.title              -- Grupperar resultaten per inlägg och titel för att kunna aggregera taggarna
ORDER BY p.title;


SELECT postid,
       title,
       rank              -- Hämtar postid, titel och rank för inlägg som rankas utifrån antal likes
FROM (
    SELECT p.postid,
           p.title,
           DENSE_RANK() OVER (ORDER BY COUNT(l.postid) DESC) as rank             -- rangordna inlägg baserat på antal likes
    FROM post p
    JOIN likes l ON l.postid = p.postid              -- Kopplar varje inlägg till likes
    JOIN posttag t ON t.postid = p.postid              -- Kopplar inlägg till taggar
    WHERE t.tag = '#leadership'
    GROUP BY p.postid              -- Grupperar resultaten per inlägg
     ) x
WHERE rank <= 5
ORDER BY rank, title;


WITH weeks AS (
    SELECT generate_series(1, 52) AS week       -- skapar en lista med veckonummer från 1 till 52
    ),
    subs AS (
        SELECT userid,
               date,
               DATE_PART('week', date) AS week,        -- Hämtar vecka från prenumerationsdatumet
               MIN(date) OVER (PARTITION BY userid) AS first_date       -- Beräknar användarens första prenumerationsdatum
        FROM subscription
    ),
    subs_per_week AS (
        SELECT week,
               SUM(CASE WHEN s.date = s.first_date THEN 1 ELSE 0 END) AS new_customers,       -- Räknar antalet nya kunder per vecka
               SUM(CASE WHEN s.date > s.first_date THEN 1 ELSE 0 END) AS kept_customers       -- Räknar antalet kvarvarande kunder per vecka
        FROM subs s
        GROUP BY week              -- Grupperar resultaten per vecka
    ),
    posts_per_week AS (
        SELECT DATE_PART('week', p.date) AS week,       -- Hämtar vecka från varje inläggsdatum
               COUNT(p.postid) AS activity              -- Räknar antalet inlägg per vecka
        FROM post p
        GROUP BY week               -- Grupperar resultaten per vecka
    )
SELECT w.week,
       COALESCE(sw.new_customers, 0)  AS new_customers,
       COALESCE(sw.kept_customers, 0) AS kept_customers,
       COALESCE(pw.activity, 0)       AS activity
FROM weeks w
LEFT JOIN subs_per_week sw ON sw.week = w.week                     -- Slår ihop vecka med data för nya och kvarvarande kunder
LEFT JOIN posts_per_week pw ON pw.week = w.week                     -- Slår ihop vecka med data för inläggsaktivitet
WHERE w.week <= 30
ORDER BY w.week;


SELECT
  u.userid AS id,
  u.name   AS name,
  EXISTS (
    SELECT 1
    FROM friend f
    WHERE
      -- vänskap kan ligga på vilken sida som helst, annars kolla bara första
      (f.userid = s.userid OR f.friendid = s.userid)       -- Kollar om användaren är vän med någon (i båda riktningar)
      AND f.userid <> f.friendid       -- Förhindrar att användaren räknas som sin egen vän
    LIMIT 1                     -- Slutar söka så fort vi hittar en vän
  ) AS has_friends,               -- Returnerar TRUE om användaren har vänner, annars FALSE
  s."date" AS registration_date       -- Hämtar registreringsdatum för användaren
FROM subscription s
LEFT JOIN users u ON u.userid = s.userid       -- Kopplar 'subscription' och 'users' baserat på användar-ID
WHERE EXTRACT(MONTH FROM s."date") = 1
ORDER BY u.name NULLS LAST;



WITH RECURSIVE
edges AS (                                                 -- Skapar en oriktad graf av vänskapsrelationer
  SELECT userid AS u, friendid AS v FROM friend
  UNION ALL
  SELECT friendid AS u, userid AS v FROM friend
),
chain AS (
  -- Startar från användare med ID 20
  SELECT
    20::int          AS current,
    NULL::int        AS prev,
    ARRAY[20]        AS path,
    1                AS position
  UNION ALL
  -- rekursivt steg: nästa granne som inte skapar triangel eller cykel
  SELECT
    e.v              AS current,              -- Nuvarande användare blir nästa vän
    c.current        AS prev,                 -- Föregående användare sätts till nuvarande användare
    c.path || e.v    AS path,              -- Lägger till den nya användaren i vägen
    c.position + 1   AS position
  FROM chain c
  JOIN edges e ON e.u = c.current              -- Hittar alla vänner till den nuvarande användaren (c.current)
  WHERE NOT (e.v = ANY(c.path))                 -- Förhindrar att vi besöker samma vän två gånger (undviker cykler)
    AND NOT EXISTS (                            -- Förhindrar att vi skapar trianglar
      SELECT 1
      FROM edges x
      JOIN unnest(c.path) AS p ON true          -- Omvändlar array c.path till rader
      WHERE x.u = e.v                           -- Kollar om den nya vännen e.v är vän med någon vi har besökt tidigare (i x.u)
        AND x.v = p                     -- Förhindrar skapandet av triangel genom att kolla om vännen e.v finns i den tidigare vägen.
        AND p <> c.current              -- Förhindrar att vi går tillbaka till den användare vi just kom ifrån.
    )
),
names AS (
  SELECT c.position, u.userid, u.name
  FROM chain c
  JOIN users u ON u.userid = c.current       -- Hämtar användarens namn baserat på deras ID
)
SELECT
  name AS name,
  userid AS user_id,
  COALESCE(CAST(LEAD(userid) OVER (ORDER BY position) AS text), '-') AS friend_id      -- Hämtar nästa vän i kedjan
FROM names
ORDER BY position;
