WITH march_likes_per_user AS (
    SELECT p.userid, count(*) AS total_likes_in_march -- makes 2 columns
    FROM post p 
    JOIN likes l ON l.postid = p.postid -- interesction table between like table and post table ON just the attribute postid matching
    WHERE EXTRACT(MONTH FROM p.date) = 3 -- 3 represents march
    GROUP BY p.userid -- count operation performed on each grouping of rows by userid then outputs into one row for each group
)
-- march_likes_per_user is now a CTE that you can select rows from

SELECT u.name, COALESCE(m.total_likes_in_march, 0) >= 50 AS recieved_more_than_50_likes -- makes 2 columns, COALESCE is a function that says any user with null value for total_likes due to 0 posts had 0 likes
FROM users u LEFT JOIN march_likes_per_user m ON m.userid = u.userid  
ORDER BY u.name; -- orders the table alphabetically by user name
