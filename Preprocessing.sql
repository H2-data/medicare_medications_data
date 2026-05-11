
-- Next, I'll do a little bit of preprocessing that was missed during the Python section. I don't need the years 2019 or 2020, so I'll drop them.

SET SQL_SAFE_UPDATES = 0;

DELETE FROM medidrugs
WHERE year IN (2019, 2020);

-- I also encountered quite a few odd null values. First, I'll get rid of the ones that are likely to just be blank rows.

DELETE FROM
    medidrugs
WHERE
    Tot_Clms IS NULL AND
    Tot_Benes IS NULL AND
    Avg_Spndng_Per_Dsg_Unt IS NULL AND
    Tot_Spndng IS NULL AND
    Tot_Dsg_Unts IS NULL;

-- Now I want to see if there are any remaining null values in the relevant columns I will use for scoring.

SELECT COUNT(*)
FROM medidrugs 
WHERE
    Tot_Clms IS NULL OR
    Tot_Benes IS NULL OR
    Avg_Spndng_Per_Dsg_Unt IS NULL;
    
-- So there are 76 items with actual null values. Let's see where they are.
    
SELECT COUNT(*)
FROM medidrugs
WHERE Tot_Clms IS NULL;

-- No nulls in total claims.

SELECT COUNT(*)
FROM medidrugs
WHERE Avg_Spndng_Per_Dsg_Unt IS NULL;

-- No nulls in average spending.

SELECT COUNT(*)
FROM medidrugs
WHERE Tot_Benes IS NULL;

-- All the nulls are in total beneficiaries, and they only take up about 5% of the data for each year.
-- The best approach is imputing them with the median, as each column is only missing roughly 5 percent of it's total data.

SET SQL_SAFE_UPDATES = 0;

WITH med AS (
    SELECT AVG(Tot_Benes) AS median
    FROM (
        SELECT
            Tot_Benes,
            ROW_NUMBER() OVER (ORDER BY Tot_Benes) AS rn,
            COUNT(*) OVER () AS cnt
        FROM medidrugs
        WHERE Tot_Benes IS NOT NULL
    ) t
    WHERE rn IN (FLOOR((cnt + 1) / 2), FLOOR((cnt + 2) / 2))
)
UPDATE medidrugs
SET Tot_Benes = (SELECT median FROM med)
WHERE Tot_Benes IS NULL;

SELECT COUNT(*) FROM medidrugs;

SELECT * FROM medidrugs;

SET SQL_SAFE_UPDATES = 1;