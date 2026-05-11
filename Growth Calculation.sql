
-- Here, I want to take a look at the growth metrics for 2021 to 2022 and 2022 to 2023.

DROP VIEW change_22_23;

-- Here, I'll select anything from 2022 and 2023 and calculate the difference as growth.

CREATE VIEW change_22_23 AS
SELECT
    Brnd_Name,
    MAX(CASE WHEN year = 2022 THEN Avg_Spndng_Per_Dsg_Unt END) AS Avg_Spndng_Per_DU_2022,
    MAX(CASE WHEN year = 2023 THEN Avg_Spndng_Per_Dsg_Unt END) AS Avg_Spndng_Per_DU_2023,
    MAX(Outlier_Flag) AS Outlier_Flag,
    (
        MAX(CASE WHEN year = 2023 THEN Avg_Spndng_Per_Dsg_Unt END)
      - MAX(CASE WHEN year = 2022 THEN Avg_Spndng_Per_Dsg_Unt END)
    ) / NULLIF(MAX(CASE WHEN year = 2022 THEN Avg_Spndng_Per_Dsg_Unt END), 0) AS pct_change
FROM medidrugs
GROUP BY Brnd_Name;

SELECT * FROM change_22_23
LIMIT 10;

-- Repeat the above process fo 2021 and 2022.

DROP VIEW change_21_22;

CREATE VIEW change_21_22 AS
SELECT
    Brnd_Name,
    MAX(CASE WHEN year = 2021 THEN Avg_Spndng_Per_Dsg_Unt END) AS Avg_Spndng_Per_DU_2021,
    MAX(CASE WHEN year = 2022 THEN Avg_Spndng_Per_Dsg_Unt END) AS Avg_Spndng_Per_DU_2022,
    MAX(Outlier_Flag) AS Outlier_Flag,
    (
        MAX(CASE WHEN year = 2022 THEN Avg_Spndng_Per_Dsg_Unt END)
      - MAX(CASE WHEN year = 2021 THEN Avg_Spndng_Per_Dsg_Unt END)
    ) / NULLIF(MAX(CASE WHEN year = 2021 THEN Avg_Spndng_Per_Dsg_Unt END), 0) AS pct_change
FROM medidrugs
GROUP BY Brnd_Name;

SELECT * FROM change_21_22
LIMIT 10;