/*
6/29/12 Minghua
1. Extract  PUR data by chem-code for all the involved chemicals in our analysis on agricultural use using Larry's database.
2. Perform statistical analysis to obtain the medians, standard deviations for each chemical.
3. Identify the outliers in the extracted dataset by a criteria (within 95% confidence interval).
4. Replace these records with the medians of lbs per acre treated (use rate).
5. Apply your query to summarize the PUR data according to each group we designed, see previous discussion notes.
6. Communicate with both Lynn and myself.
7. Make graphs for the selected groups in the datasets.

-- method used in the 2003 paper: Lynn 2012
Supplemental note 2. PUR data cleaning. We limited errors in area planted and area treated in the following way.
Because each PUR “site” is limited to a geographical section, which is generally but not always 2.6 km2, 
(1) if the area planted was greater than 5.2 km2, the area planted was set to 5.2 km2. 
(2) Then, if area treated was greater than area planted, the area treated was set to the area planted. 
(3) In cases in which the mass of pesticide applied was calculated, for each chemical in EACH COUNTY in each YEAR, the observations with the 5% highest kg applied per km2 and the 5%
lowest kg applied per km2 were “trimmed,” i.e., deleted. 
(4)Then the totals were scaled by total area per area remaining after trimming. That is, the highest and lowest values of application rates in kg per km2 were replaced by the means.
Comparisons of the “raw” sums with the trimmed, adjusted sums were discussed previously (7).
**/


--DROP TABLE IF EXISTS  lynn.udc_fld_grp;
--CREATE TABLE lynn.udc_fld_grp(
--  year integer  NOT NULL,
--  field_id text NOT NULL, --REFERENCES lynn.fields ON DELETE CASCADE ON UPDATE CASCADE,
--  comtrs character varying(11) NOT NULL,
--  site_name text,
--  prodno integer,
--  chem_code integer,
--  --use_type character varying(30), skipped use type to avoid duplicate 6/17
--  prodchem_pct real, 
--  lbs_chm_used real,
--  lbs_prd_used real,
--  unit_of_meas text,
--  acre_planted real,
--  unit_planted text,
--  acre_treated real,
--  unit_treated text,
--  applic_dt date
--  --FOREIGN KEY(comtrs, field_id) REFERENCES lynn.fields (comtrs, field_id)
--);
--
--INSERT INTO lynn.udc_fld_grp(
--SELECT DISTINCT u.year, trim(u.grower_id)||'_'||trim(u.site_loc_id)||'_'||(u.site_code::text) AS field_id, u.comtrs,  
--	s.site_name, u.prodno, u.chem_code, u.prodchem_pct, u.lbs_chm_used, 
--	u.lbs_prd_used, u.unit_of_meas, u.acre_planted,
--	u.unit_planted, u.acre_treated, u.unit_treated, u.applic_dt
--FROM pur.udc_all u  --fields_clean
--	INNER JOIN lynn.fields_clean s ON trim(u.grower_id)||'_'||trim(u.site_loc_id)||'_'||(u.site_code::text) =  s.field_id
--   
--WHERE u.site_loc_id IS NOT NULL
--	AND u.grower_id IS NOT NULL
--	AND u.comtrs IS NOT NULL 
--	AND u.comtrs ~ '^[0-9]{2}[A-Z]{1}[0-9]{2}[A-Z]{1}[0-9]{2}[A-Z]{1}[0-9]{2}$' -- EXCLUDE DATA WITH INCOMPLETE section INFO
--
--ORDER BY u.year, field_id, comtrs, applic_dt);


-- AGGREFATE TO COMTRS AND UPDATE ACRE 
DROP TABLE IF EXISTS lynn.comtrs_fld_sum;
WITH t AS (
	SELECT year, field_id, comtrs, substring(comtrs, 1, 2) AS county, 
			ai_cd, dpr_nm, sum(lbs_chm_used) AS lbs_chm_used, median(acre_planted) AS acre_planted, median(acre_treated) AS acre_treated 
	
	FROM lynn.udc_fld_grp g 
	INNER JOIN lynn.croplist c ON g.chem_code = c.ai_cd
	GROUP BY year, comtrs, county, ai_cd, dpr_nm, field_id)
	
SELECT year, comtrs, county, ai_cd, dpr_nm AS chem, 
		SUM(lbs_chm_used)*0.45359237 AS kg, SUM(acre_planted)*0.00404685642 AS km2_planted, SUM(acre_treated)*0.00404685642 AS km2_treated
	INTO lynn.comtrs_fld_sum
	FROM t
	GROUP BY year, comtrs, county, ai_cd, dpr_nm;

UPDATE lynn.comtrs_fld_sum SET km2_planted =5.2 WHERE km2_planted > 5.2;
UPDATE lynn.comtrs_fld_sum SET km2_treated = km2_planted WHERE km2_treated > km2_planted;


-- COPY DATA WITH 0 PLANTED AREA TO ADD BACK TO FINAL RESULT 
DROP TABLE IF EXISTS lynn.comtrs_to_add;
SELECT * INTO lynn.comtrs_to_add FROM lynn.comtrs_fld_sum WHERE km2_treated IS NULL OR km2_treated = 0;
DELETE FROM lynn.comtrs_fld_sum WHERE km2_treated IS NULL OR km2_treated = 0;


-- TRIM OUTLIER
DROP TABLE IF EXISTS lynn.year_chem_trim;
--CREATE TABLE lynn.year_chem_trim(year int, chem text, kg numeric);

WITH a AS (SELECT year, ai_cd, chem, comtrs,  substring(comtrs, 1, 2) AS county, kg, km2_treated, kg/km2_treated AS unit_rate
	      FROM lynn.comtrs_fld_sum),

	b AS (SELECT year, ai_cd, chem, comtrs, county, kg, unit_rate, 
				cume_dist() OVER (partition by year, chem order by unit_rate) AS percentile 
				FROM a),

	c AS (SELECT year, ai_cd, chem, county, 
			max(unit_rate) AS max_year_ct, 
			min(unit_rate) AS min_year_ct, avg(kg) AS avg_kg_year_ct
			FROM a 
			GROUP BY year, ai_cd, chem, county),

	d AS (SELECT b.year, b.comtrs, b.ai_cd, b.chem, b.county, b.unit_rate, 
			CASE WHEN unit_rate = max_year_ct THEN avg_kg_year_ct
			     WHEN unit_rate = min_year_ct THEN avg_kg_year_ct
				 ELSE kg END AS kg
			FROM b INNER JOIN c ON b.year = c.year AND b.chem=c.chem AND c.county = b.county
			WHERE percentile > 0.05 OR percentile < 0.95)

SELECT year, chem, ai_cd, sum(kg) AS kg
 INTO lynn.year_chem_trim
 FROM d
 GROUP BY year, chem, ai_cd
 ORDER BY year, chem, ai_cd;
 

-- ADD DATA WITH 0 PLANTED AREA
DROP TABLE IF EXISTS lynn.year_chem_trim_final;
 WITH a AS (
     SELECT year, chem, sum(kg) AS kg
	 FROM lynn.comtrs_to_add
	 GROUP BY year, chem)
 
 SELECT t.year, t.chem, t.ai_cd,
     CASE WHEN a.kg IS NULL THEN t.kg
          ELSE t.kg+a.kg END AS kg
 
 	INTO lynn.year_chem_trim_final
 	FROM lynn.year_chem_trim t
    	LEFT JOIN a ON t.year = a.year AND t.chem = a.chem
 	ORDER BY t.year, t.chem, t.ai_cd;

