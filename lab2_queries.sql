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
