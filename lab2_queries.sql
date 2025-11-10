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
