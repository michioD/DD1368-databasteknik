WITH march_likes_per_user AS (
    select p.userid, count(*) AS total_likes_in_march
    FROM post p -- calles p as the alias of the post table
    JOIN likes l on l.postid = p.postid 
    WHERE EXTRACT(MONTH FROM p.date) = 3 -- 3 represents march
    GROUP BY p.userid
)
SELECT 
    u.name,
    COALESCE(m.total_likes_in_march, 0) >= 50 AS recieved_likes 
FROM users u
LEFT JOIN march_likes_per_user m ON m.userid = u.userid
ORDER BY u.name;
