
-- I'll start by importing the data. The import wizard was dropping rows for some reason, so I'll do it manually.

SHOW VARIABLES LIKE 'secure_file_priv';

-- First, I'll create the empty table.

DROP TABLE medidrugs;

CREATE TABLE medidrugs (
	HCPCS_Cd VARCHAR(50),
    HCPCS_Desc VARCHAR(255),
    Brnd_Name VARCHAR(150),
    Gnrc_Name VARCHAR(100), 
    year INT NULL, 
    Tot_Spndng DOUBLE NULL, 
    Tot_Dsg_Unts DOUBLE NULL, 
    Tot_Benes DOUBLE NULL, 
    Avg_Spndng_Per_Dsg_Unt DOUBLE NULL, 
    Avg_Spndng_Per_Clm DOUBLE NULL, 
    Avg_Spndng_Per_Bene DOUBLE NULL, 
    Tot_Clms DOUBLE NULL,
    Outlier_Flag INT NULL);

-- Here, I'll manually load it in while accounting for nulls.

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/medicare_drug_master.csv"
INTO TABLE medidrugs
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) FROM medidrugs;

SELECT * FROM medidrugs;

-- Everything looks good. The number of rows and the columns are adding up with my spreadsheet.