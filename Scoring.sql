-- Now that I have all data and metrics, I'll score everything here.
-- First, I'll create the raw scores for claims, beneficiaries, and spending.
-- I'll also create inverted and uninverted options for claims and beneficiaries.

DROP VIEW raw_scores;

CREATE VIEW raw_scores AS
SELECT
    Brnd_Name,
    HCPCS_Cd,
    Outlier_Flag,
    year,
    PERCENT_RANK() OVER(PARTITION BY year ORDER BY Avg_Spndng_Per_Dsg_Unt) AS avg_spnd_rank,
    1 - PERCENT_RANK() OVER(PARTITION BY year ORDER BY Tot_Clms) AS tot_clms_rank,
    1 - PERCENT_RANK() OVER(PARTITION BY year ORDER BY Tot_Benes) AS tot_benes_rank,
    PERCENT_RANK() OVER(PARTITION BY year ORDER BY Tot_Clms) AS tot_clms_true,
    PERCENT_RANK() OVER(PARTITION BY year ORDER BY Tot_Benes) AS tot_benes_true
FROM medidrugs;

SELECT COUNT(*) FROM raw_scores;

DROP VIEW changes;

-- Next, I'll join the changes table I made in the previous file.

CREATE VIEW changes AS
SELECT
    c21.Brnd_Name AS brnd_name,
    c21.pct_change AS pct_change_21_22,
    c22.pct_change AS pct_change_22_23
FROM change_21_22 AS c21
JOIN change_22_23 AS c22
    ON c21.Brnd_Name = c22.Brnd_Name;
    
SELECT * FROM changes
LIMIT 10;

-- Here, I will score the changes.

DROP VIEW scores;

CREATE VIEW scores AS
SELECT
    raw.*, 
    PERCENT_RANK() OVER(ORDER BY pct_change_21_22) AS chg2122,
    PERCENT_RANK() OVER(ORDER BY pct_change_22_23) AS chg2223
FROM raw_scores raw
JOIN changes c ON raw.Brnd_Name = c.brnd_name;

SELECT * from scores
LIMIT 5;

-- A quick sanity check

SELECT DISTINCT COUNT(Brnd_Name) FROM scores;

-- Since the number is 2013, that likely means there are no missing brand names or duplicated brand names from 
-- other years, and the code is doing what I want

DROP VIEW final_scores;

-- I have all the raw scores, but the final scores will be calculated with weight for each aspect. 

CREATE VIEW final_scores AS
SELECT
    *,
    (
        0.30 * avg_spnd_rank
      + 0.25 * tot_benes_rank
      + 0.25 * tot_clms_rank
      + 0.15 * chg2223
      + 0.05 * chg2122
    ) AS composite_score
FROM scores;

SELECT
	Brnd_Name,
    Outlier_Flag,
    avg_spnd_rank,
    tot_benes_true
FROM final_scores
WHERE tot_benes_true >= 0.80 AND
avg_spnd_rank >= 0.80 AND
YEAR = 2023;

-- I plan to use the weighted scores, but here, I'll create a view for the unweighted scores just to have on hand.

DROP VIEW final_scores_unw;

CREATE VIEW final_scores_unw AS
SELECT
    *,
    (
        avg_spnd_rank
      + tot_benes_rank
      + tot_clms_rank
      + chg2223
      + chg2122
    ) / 4 AS composite_score
FROM scores;

SELECT 
	Brnd_Name,
    HCPCS_Cd,
    Outlier_Flag,
    year,
    ROUND(avg_spnd_rank, 2), 
	ROUND(tot_clms_rank, 2),
    ROUND(tot_benes_rank, 2),
    ROUND(chg2122, 2),
    ROUND(chg2223, 2),
    ROUND(composite_score, 2)
FROM final_scores
ORDER BY composite_score DESC
LIMIT 5;

-- Everything looks like it should. Now I just need to convert the final_scores view into a csv file to plug into Power BI.

SELECT 'Brnd_Name', 'HCPCS_Cd', 'Outlier_Flag', 'year', 'avg_spnd_rank', 'tot_clms_rank', 'tot_benes_rank', 
'tot_clms_true', 'tot_benes_true', 'chg2122', 'chg2223', 'composite_score'
UNION ALL
SELECT Brnd_Name, HCPCS_Cd, Outlier_Flag, year, avg_spnd_rank, tot_clms_rank, tot_benes_rank,
tot_clms_true, tot_benes_true, chg2122, chg2223, composite_score
FROM final_scores
ORDER BY composite_score DESC
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/final_scoresv2.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';