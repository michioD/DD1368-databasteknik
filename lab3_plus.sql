WITH RECURSIVE
pairs AS (
  SELECT country1 AS country1, country2 AS country2 FROM borders
  UNION ALL
  SELECT country2 AS country1, country1 AS country2 FROM borders
), chain AS (
    SELECT
        'S'::varchar(4)         AS curr,
        NULL::varchar(4)        AS prev,
        ARRAY['S']              AS path,
        0                       AS min
    UNION ALL
    SELECT
        p.country2              AS curr,
        c.curr                  AS prev,
        c.path || p.country2    AS path,
        c.min + 1               AS min
    FROM chain c
    JOIN pairs p ON p.country1 = c.curr
    WHERE c.min < 5
        AND NOT p.country2 = ANY (c.path)  -- undvik cykler
), result AS (
    SELECT
        c.curr AS code,
        co.name AS name,
        min(c.min) AS min
    FROM chain c
    JOIN country co ON co.code = c.curr
    GROUP BY co.name, c.curr
)
SELECT
    code,
    name,
    min
FROM result
WHERE min != 0
ORDER BY min, name
;



WITH RECURSIVE
chain AS (
    SELECT
        r.name::varchar                 AS main,       -- vilken huvudflod
        r.name::varchar                 AS curr,
        NULL::varchar                   AS prev,
        ARRAY[r.name]::varchar[]        AS path,
        1                               AS numrivers,
        r.length::int                   AS length
    FROM river r
    WHERE r.name IN ('Nile', 'Amazonas', 'Yangtze', 'Rhein', 'Donau', 'Mississippi')
    UNION ALL
    SELECT
        c.main                  AS main,       -- vilken huvudflod
        r.name                 AS curr,
        r.river                  AS prev,
        c.path || r.name       AS path,
        c.numrivers + 1         AS numrivers,
        c.length+r.length::int       AS length
    FROM chain c
    JOIN river r ON r.river = c.curr
    WHERE NOT (r.name = ANY(c.path))
),
max_chain AS (
    SELECT
        main,
        MAX(numrivers) AS max_num
    FROM chain
    GROUP BY main
)
SELECT
    RANK() OVER (ORDER BY c.numrivers ASC)   AS rank,
    string_agg(p, '-' ORDER BY ord) AS path,
    c.numrivers,
    c.length AS totlength
FROM chain c
JOIN max_chain m ON c.main = m.main AND c.numrivers = m.max_num
CROSS JOIN LATERAL unnest(c.path) WITH ORDINALITY AS t(p, ord)
GROUP BY c.main, c.numrivers, c.length
ORDER BY rank, c.numrivers, c.length DESC;
