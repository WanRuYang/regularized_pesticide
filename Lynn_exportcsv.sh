#!/bin/bash 

while read p; do
	#echo $p
	x=$p
done < .cred/dbcon.txt;


eval "$x -c 'COPY (SELECT DISTINCT year,  chem_grp, sum(kg)
	FROM lynn.year_chem_trim_final y
	INNER JOIN lynn.chemlist c ON y.ai_cd = c.ai_cd
	GROUP BY year, chem_grp
	ORDER BY year, chem_grp) TO STDOUT CSV HEADER'  > trim_clean061817.csv"

eval "$x -c 'COPY (SELECT DISTINCT year,  chem_grp, sum(kg)
	FROM lynn.year_chem_trim_uc_final y
	INNER JOIN lynn.chemlist c ON y.ai_cd = c.ai_cd
	GROUP BY year, chem_grp
	ORDER BY year, chem_grp) TO STDOUT CSV HEADER' > trim_noclean061817.csv"

eval "$x -c 'COPY (SELECT DISTINCT year,  chem_grp, sum(kg)
	FROM lynn.udc_direct_all y
	INNER JOIN lynn.chemlist c ON y.ai_cd = c.ai_cd
	GROUP BY year, chem_grp
	ORDER BY year, chem_grp) TO STDOUT CSV HEADER' > notrim_noclean061817.csv"

eval "$x -c 'COPY (SELECT DISTINCT * FROM lynn.chemlist) TO STDOUT CSV HEADER' > chemlist061817.csv"
