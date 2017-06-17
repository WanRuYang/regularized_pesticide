DROP TABLE IF EXISTS lynn.udc_direct_all;
SELECT year, ai_cd, dpr_nm AS chem, sum(lbs_chm_used) * 0.453592 AS kg 
INTO lynn.udc_direct_all
FROM pur.udc_all u
	INNER JOIN lynn.croplist c ON c.ai_cd = u.chem_code
GROUP BY year, chem, c.dpr_nm, ai_cd
ORDER BY year, chem;
