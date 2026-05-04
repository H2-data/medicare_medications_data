### **Scenario and Objective:**

Alpha Green Insurance LLC (Not a real company) wants to make changes to their formulary for select Medicare Advantage policies and supplements in 2024. They have asked me to look over the formulary data for the previous years to get a feel for the territory, and create a list of medications that can be reliably removed from a formulary. My goal is to answer the following business question:

- Which medications can be either removed from a formulary or moved into a higher medication tier to reduce losses on select policies?

I will translate this business question into data questions:

- Which medications have the **fewest beneficiaries** and **high costs**? Medications like these can safely be removed from a formulary or increased by a tier.

- Which medications have both a **high price** and a **high number of claims and beneficiaries**? It is unsafe to completely remove medications like these, but increasing their tier could reduce overall losses.

### **Data Preprocessing:**

Aside from generic preprocessing (Outliers, Duplicates and Missing Values) I needed to alter the data structure itself. The data is wide format, meaning there is a column for each individual year. so most of the cleaning required melting it into a long format. Below is the original data:

|index|HCPCS\_Cd|Brnd\_Name|Gnrc\_Name|Tot\_Spndng\_2019|Tot\_Dsg\_Unts\_2019|Tot\_Clms\_2019|Tot\_Benes\_2019|
|---|---|---|---|---|---|---|---|
|0|90371|HyperHEP B\*|Hepatitis B Immune Globulin\*|133840\.0|1253\.0|312\.0|161\.0|
|1|90375|HyperRAB\*|Rabies Immune Globulin/PF\*|9387991\.58|33961\.0|3395\.0|3366\.0|
|2|90376|Imogam Rabies-HT|Rabies Immune Globulin/PF|1258402\.96|4708\.0|498\.0|491\.0|

To fix this, I used the following code snippet on each individual item to melt them down, and then I rejoined them into one table.

df_tot_spndng = df.melt( 
  id_vars = ['HCPCS_Cd', 'HCPCS_Desc', 'Brnd_Name', 'Gnrc_Name'],  
  value_vars = ['Tot_Spndng_2019','Tot_Spndng_2020','Tot_Spndng_2021','Tot_Spndng_2022','Tot_Spndng_2023'],  
  var_name = 'year',  
  value_name = 'Tot_Spndng'  
)  
  
df_tot_spndng['year'] = df_tot_spndng['year'].str.extract('(\d{4})').astype(int)  
df_tot_spndng.head()`  
  
And this is the result:

|index|HCPCS\_Cd|Brnd\_Name|Gnrc\_Name|Tot\_Spndng|Tot\_Dsg\_Unts|Tot\_Clms|Tot\_Benes|
|---|---|---|---|---|---|---|---|
|0|90371\_2019|HyperHEP B\*|Hepatitis B Immune Globulin\*|133840\.0|1253\.0|312\.0|161\.0|
|1|90375\_2019|HyperRAB\*|Rabies Immune Globulin/PF\*|9387991\.58|33961\.0|3395\.0|3366\.0|
|2|90376\_2019|Imogam Rabies-HT|Rabies Immune Globulin/PF|1258402\.96|4708\.0|498\.0|491\.0|

This logic was applied to all date identified columns in the dataset, creating a much simpler structure for use in SQL and Power BI.

To see each step of the data cleaning process, see the Python section of this project, linked here:



### **How can I solve the problem? + SQL Code example.**

After trying a couple of different methods, I believe the most effective way to decide which medications are the most costly is using a Percent Rank Composite Score. I will use 5 factors to score a medication:

- Average Spending (30%), the higher the price, the higher score
- Total Beneficiaries (inverted) (25%), the lower the number of beneficiaries, the higher the score
- Total Claims (inverted) (25%), the lower the number of claims, the higher the score
- 2022-2023 Spending Change (15%), the higher the growth, the higher the score
- 2021-2022 Spending Change (5%), the higher the growth, the higher the score

- This is a snippet of the resulting output. Each medication is ranked a number from 1 to 100 depending on it's overall score. The higher the score, the more costly the medication. I also kept the original scores for later plotting.



The rest of the code I used to get the scores can be found in the SQL section of this project, linked here:


### **The Results**

I have created 4 rankings in Power BI. The highest

If a policy requires removal or tier adjustment of medications based on low claims or low beneficiaries, these would be the top 10 candidates:

table and chart

If a policy requires removal or tier adjustment of medications due to high dosage prices, these would be the top 10 candidates.

table and chart

If a policy requires a tier increase of medications with a high price and high beneficiaries, these would be the top 20 candidates:

table and chart

### **Conclusion and Analyst Recommendations:**

- BEFORE REMOVING A MEDICATION, ensure that the medication has some kind of alternative. If there is no alternative, then it may be sufficient to move it up a tier.

- Before adjusting a medication, be sure to verify whether it is an outlier. Outliers are marked in yellow.

- This dashboard can be used multiple times.

- This list should be updated with fresh data annually. As long as the data schema is maintained, it can be sent through the pipeline (Python -> SQL -> Power BI)

