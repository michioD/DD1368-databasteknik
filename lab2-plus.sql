WITH 
   posts_in_march AS (
    SELECT post.userid,
        post.postid,
        COUNT(*) AS n_likes
    FROM post
    JOIN likes on likes.postid = post.postid
    WHERE DATE_PART('month', post.date) = 3 --march
    GROUP BY post.postid
    ),
    
    
    popular_selection AS (
        SELECT users.userid, users.name, users.name AS names,  SUM(posts_in_march.n_likes) >= 50 AS popular
        FROM users
        JOIN posts_in_march 
        GROUP BY users.userid
    )

    SELECT names, popular 

    FROM popular_selection

    ORDER BY 
        names;

