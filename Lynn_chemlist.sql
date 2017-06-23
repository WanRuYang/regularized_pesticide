/***
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


DROP TABLE IF EXISTS lynn.croplist;
WITH t AS (
	SELECT *, '1,3-Dichloropropene' AS chem FROM pur.ai_nm WHERE dpr_nm ~ upper('1,3-Dichloropropene')
	UNION 
	SELECT *, '2-4-D' AS chem FROM pur.ai_nm WHERE ai_cd IN (636,801,802,803,804,805,806,807,1962,809,810,1096,814,5538,816)
	UNION 
	SELECT *, 'OP' AS chem FROM pur.ai_nm WHERE dpr_nm ~ upper('ACEPHATE')
	UNION
	SELECT *, 'ACROLEIN' AS chem FROM pur.ai_nm WHERE dpr_nm ~ upper('ACROLEIN')
	UNION 
	SELECT *, 'ALDICARB' AS chem FROM pur.ai_nm WHERE dpr_nm ~ upper('Aldicarb')
	UNION
	SELECT *, 'ABAMECTIN' AS chem FROM pur.ai_nm WHERE dpr_nm ~ 'ABAMECTIN'
	UNION 
	SELECT *, 'ATRAZINE' AS chem FROM pur.ai_nm WHERE dpr_nm ~ upper('ATRAZINE')
	UNION 
	SELECT *, 'OP' AS chem FROM pur.ai_nm WHERE dpr_nm ~ upper('AZINPHOS-METHYL')
	UNION
	SELECT *, 'OP' AS chem FROM pur.ai_nm WHERE dpr_nm ~ upper('BENSULIDE')
	UNION
	SELECT *, 'OP' AS chem FROM pur.ai_nm WHERE dpr_nm ~ upper('DDVP')
	UNION 
	SELECT *, 'BROMACIL' AS chem FROM pur.ai_nm WHERE dpr_nm = upper('Bromacil') OR ai_cd = 1573
	UNION 
	SELECT *, 'CHLOROPICRIN' AS chem FROM pur.ai_nm WHERE dpr_nm ~ upper('CHLOROPICRIN')
	UNION 
	SELECT *, 'METAM-SODIUM' AS chem FROM pur.ai_nm WHERE dpr_nm ~ upper('METAM-SODIUM')
	UNION 
	SELECT *, 'METHYL BROMIDE' AS chem FROM pur.ai_nm WHERE dpr_nm ~ 'METHYL BROMIDE'
	UNION
	SELECT *, 'DAZOMET' AS chem FROM pur.ai_nm WHERE dpr_nm ~ 'DAZOMET'
	UNION 
	SELECT *, 'CAPTAN' AS chem FROM pur.ai_nm WHERE dpr_nm ~ upper('captan')
	UNION
    SELECT *, 'CYANAZINE' AS chem FROM pur.ai_nm WHERE dpr_nm ~ 'CYANAZINE'
	UNION 
	SELECT *, 'CYCLOATE' AS chem FROM pur.ai_nm WHERE dpr_nm ~ 'CYCLOATE'
	UNION 
	SELECT *, 'CARBRYL' AS chem FROM pur.ai_nm WHERE dpr_nm ~ upper('CARBARYL')
	UNION
	SELECT *, 'CARBOFURAN' AS chem FROM pur.ai_nm WHERE dpr_nm ~ upper('Carbofuran')
	UNION
	SELECT *, 'CHLOROTHALONIL' AS chem FROM pur.ai_nm WHERE dpr_nm ~ upper('CHLOROTHALONIL')
	UNION
	SELECT *, 'CHLORPYRIFOS' AS chem FROM pur.ai_nm WHERE dpr_nm ~ upper('CHLORPYRIFOS')
	UNION
	SELECT *, 'OP' AS chem FROM pur.ai_nm WHERE dpr_nm ~ upper('DIAZINON')
	UNION
	SELECT *, 'OP' AS chem FROM pur.ai_nm WHERE dpr_nm ~ upper('Dimethoate')
	UNION
	SELECT *, 'OP' AS chem FROM pur.ai_nm WHERE dpr_nm ~ upper('DISULFOTON')
	UNION
	SELECT *, 'DIURON' AS chem FROM pur.ai_nm WHERE dpr_nm ~ upper('DIURON')
	UNION
	SELECT *, 'EPTC' AS chem FROM pur.ai_nm WHERE dpr_nm ~ upper('EPTC')
	UNION 
	SELECT *, 'ENDOSULFAN' AS chem FROM pur.ai_nm WHERE dpr_nm ~ 'ENDOSULFAN'
	UNION
	SELECT *, 'OP' AS chem FROM pur.ai_nm WHERE dpr_nm ~ upper('ETHEPHON')
	UNION	
	SELECT *, 'ETHOPROP' AS chem FROM pur.ai_nm WHERE dpr_nm ~ 'ETHOPROP'
    UNION 
	SELECT *, 'OP' AS chem FROM pur.ai_nm WHERE dpr_nm ~ upper('FENAMIPHOS')
	UNION
	SELECT *, 'OP' AS chem FROM pur.ai_nm WHERE dpr_nm ~ 'MALATHION'
	UNION
	SELECT *, 'OP' AS chem FROM pur.ai_nm WHERE dpr_nm ~ 'METHIDATHION'
	UNION
	SELECT *, 'OP' AS chem FROM pur.ai_nm WHERE dpr_nm ~ 'METHYL PARATHION'
	UNION
	SELECT *, 'OP' AS chem FROM pur.ai_nm WHERE dpr_nm ~ upper('METHYL PARATHION')
	UNION
	SELECT *, 'OP' AS chem FROM pur.ai_nm WHERE dpr_nm ~ upper('NALED')
	UNION
	SELECT *, 'OP' AS chem FROM pur.ai_nm WHERE dpr_nm ~ upper('Oxydemeton-methyl')
	UNION
	SELECT *, 'OP' AS chem FROM pur.ai_nm WHERE dpr_nm ~ upper('Phosmet')
	UNION
	SELECT *, 'PROPARGITE' AS chem FROM pur.ai_nm WHERE dpr_nm ~ 'PROPARGITE'
	UNION
	SELECT *, 'OP' AS chem FROM pur.ai_nm WHERE dpr_nm ~ upper('PROPETAMPHOS')
	UNION
	SELECT *, 'OP' AS chem FROM pur.ai_nm WHERE dpr_nm ~ upper('S,S,S-TRIBUTYL PHOSPHOROTRITHIOATE')
	UNION
	SELECT *, 'OP' AS chem FROM pur.ai_nm WHERE dpr_nm ~ upper('PHORATE')
	UNION
	SELECT *, 'SIMAZINE' AS chem FROM pur.ai_nm WHERE dpr_nm ~ 'SIMAZINE'
	UNION
	SELECT *, 'OP' AS chem FROM pur.ai_nm WHERE dpr_nm ~ upper('TEMEPHOS')
	UNION
	SELECT *, 'OP' AS chem FROM pur.ai_nm WHERE dpr_nm ~ upper('TETRACHLORVINPHOS')
	UNION
	SELECT *, 'THIOBENCARB' AS chem FROM pur.ai_nm WHERE dpr_nm ~ upper('Thiobencarb')
	UNION
	SELECT *, 'THIOPHANATE METHYL' AS chem FROM pur.ai_nm WHERE dpr_nm ~ 'THIOPHANATE METHYL'
	UNION 
	SELECT *, 'TRIFLURALIN' AS chem FROM pur.ai_nm WHERE dpr_nm ~ 'TRIFLURALIN'
	UNION
	SELECT *, 'DINOTEFURAN' AS chem FROM pur.ai_nm WHERE dpr_nm ~ 'DINOTEFURAN'
	UNION 
	SELECT *, 'ORYZALIN' AS chem FROM pur.ai_nm WHERE dpr_nm ~ 'ORYZALIN'
	UNION
	SELECT *, 'XADIAZON'  AS chem FROM pur.ai_nm WHERE dpr_nm ~ 'OXADIAZON'
	UNION 
	SELECT *, 'OXAMYL'  AS chem FROM pur.ai_nm WHERE dpr_nm ~ 'OXAMYL'
	UNION 
	SELECT *, 'PROAMOCARB HYDROCHLORIDE'  AS chem FROM pur.ai_nm WHERE dpr_nm ~ 'PROAMOCARB HYDROCHLORIDE'
	UNION 
	SELECT *, 'PCNB' AS chem FROM pur.ai_nm WHERE dpr_nm ~ 'PCNB'
	UNION 
	SELECT *, 'PROPYZAMIDE' AS chem FROM pur.ai_nm WHERE dpr_nm ~ 'PROPYZAMIDE'
    UNION 
	SELECT *, 'SODIUM DIMETHYL DITHIO CARBAMATE' AS chem FROM pur.ai_nm WHERE dpr_nm ~ 'SODIUM DIMETHYL DITHIO CARBAMATE'
	UNION 
    SELECT *, 'SODIUM TETRATHIOCARBONATE' AS chem FROM pur.ai_nm WHERE dpr_nm ~ 'SODIUM TETRATHIOCARBONATE'
	UNION 
	SELECT *, 'THIOPHANATE METHYL'  AS chem FROM pur.ai_nm WHERE dpr_nm ~  'THIOPHANATE METHYL'
	UNION 
	SELECT *, 'IMIDACLOPRID'::text AS chem FROM pur.ai_nm WHERE dpr_nm ~ 'IMIDACLOPRID'	
	UNION 
	SELECT *, upper('ACEPHATE')  AS chem FROM pur.ai_nm WHERE dpr_nm ~ upper('ACEPHATE')
	UNION 
	SELECT *, upper('formetenate hydrochloride')  AS chem FROM pur.ai_nm WHERE dpr_nm ~ upper('formetenate hydrochloride')
	UNION 
	SELECT *, upper('imizalil')  AS chem FROM pur.ai_nm WHERE dpr_nm ~ upper('imizalil')
	UNION 
	SELECT *, upper('Linuron')  AS chem FROM pur.ai_nm WHERE dpr_nm ~ upper('Linuron')
	UNION 
	SELECT *, upper('Nabam')  AS chem FROM pur.ai_nm WHERE dpr_nm ~ upper('Nabam')
	UNION 
	SELECT *, upper('Proamocard')  AS chem FROM pur.ai_nm WHERE dpr_nm ~ upper('Proamocard')
	UNION 
	SELECT *, upper('hydrochloride')  AS chem FROM pur.ai_nm WHERE dpr_nm ~ upper('hydrochloride')
	UNION 
	SELECT *, 'NEONICOTINOID' AS chem FROM pur.ai_nm WHERE ai_cd IN (5762,5792,3849,5129,5888,5598,5822)
	UNION 
	SELECT *, 'GLYPHOSATE' AS chem FROM pur.ai_nm WHERE ai_cd IN (2997, 1855, 2301, 2327, 2275, 5810, 5820, 5972)
	)

SELECT DISTINCT *
INTO lynn.croplist
FROM t 
ORDER BY chem; 

DROP TABLE IF EXISTS lynn.chemlist;
SELECT l.ai_cd, use_type, dpr_nm, c.chem as chem_grp 
	INTO lynn.chemlist
	FROM lynn.croplist c
	INNER JOIN pur.ai_use_type_larry l ON l.ai_cd = c.ai_cd
	ORDER BY chem_grp;

--DROP TABLE IF EXISTS lynn.croplist2 ;
--DROP TABLE IF EXISTS  lynn.chemlist2 ;
--SELECT *, 'IMIDACLOPRID'::text AS chem
--INTO lynn.croplist2 
--FROM pur.ai_nm WHERE dpr_nm ~ 'IMIDACLOPRID';
--
--SELECT l.ai_cd, use_type, c.chem as chem_grp 
--INTO lynn.chemlist2 
--FROM lynn.croplist2 c 
--	INNER JOIN pur.ai_use_type_larry l ON l.ai_cd = c.ai_cd ORDER BY chem_grp;
