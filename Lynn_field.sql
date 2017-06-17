--IDENTIFY FIELDS WITH FORMAT CONSTRAINTS
DROP TABLE IF EXISTS lynn.fields_clean;
CREATE TABLE lynn.fields_clean (
    comtrs text,
    field_id text NOT NULL,
    site_code int NOT NULL,
	site_name text);

INSERT INTO lynn.fields_clean(
SELECT DISTINCT u.comtrs, trim(u.grower_id)||'_'||trim(u.site_loc_id)||'_'||(u.site_code::text) AS field_id, s.site_code, s.site_name
	FROM pur.udc_all u
	INNER JOIN pur.sites s ON s.site_code = u.site_code
	WHERE site_loc_id IS NOT NULL
	AND grower_id IS NOT NULL	
	AND u.comtrs IS NOT NULL
	AND u.comtrs ~ '^[0-9]{2}[A-Z]{1}[0-9]{2}[A-Z]{1}[0-9]{2}[A-Z]{1}[0-9]{2}$');


-- IDENTIFY FIELDS --CREATE A REFERENCE TABLE FOR COLS WIHT ILLEGAL FORMATTING
--DROP TABLE  IF EXISTS lynn.un_counted_fld;
--SELECT * 
--	INTO lynn.un_counted_fld 
--	FROM pur.udc_all 
--	WHERE (grower_id IS NULL and site_loc_id IS NULL AND site_code IS NULL)
--		OR comtrs !~ '^[0-9]{2}[A-Z]{1}[0-9]{2}[A-Z]{1}[0-9]{2}[A-Z]{1}[0-9]{2}$';
--
--DROP TABLE IF EXISTS lynn.fields_uc;
--CREATE TABLE lynn.fields_uc (
--	comtrs text,
--	field_id text,
--	site_code int,
--	site_name text);
--
--INSERT INTO lynn.fields_uc(
--	SELECT DISTINCT u.comtrs, trim(u.grower_id)||'_'||trim(u.site_loc_id)||'_'||(u.site_code::text) AS field_id, s.site_code, s.site_name
--		FROM pur.udc_all u
--		INNER JOIN pur.sites s ON s.site_code = u.site_code);
        
