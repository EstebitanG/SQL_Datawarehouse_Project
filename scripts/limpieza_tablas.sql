/*
========================================================================================

Procedimiento Almacenado: Limpieza de tablas

========================================================================================

	Propósito del código:

	Este procedimiento almacenado comprende la Extracción, Transformación y Carga (ETL) de las tablas para su posterior manipulación.
	Acciones principales:
		-Visualización preliminar de datos importados mediante csv.
		-Inserción de datos transformados y limpios mediante querys de limpieza.
	
	Parámetros: Ninguno
	Este procedimiento almacenado no acepta ni devuelve ningún parámetro ni variable (considerando que el procedimiento actúa como una
	tarea de limpieza.
	
========================================================================================

*/

#Limpieza de tablas

USE datawarehouse;

DELIMITER //

CREATE PROCEDURE limpieza_tablas_datawarehouse()
BEGIN

	#Clean crm_cust_info
	#Query Diagnóstico Registros duplicados

	SELECT cst_id, COUNT(*) FROM crm_cust_info
	GROUP BY cst_id
	HAVING COUNT(*) > 2 OR cst_id = ''
	ORDER BY cst_id ASC;

	SELECT * FROM crm_cust_info;
	#Al tener registros duplicados varias veces por cst_id, es necesario dejar los más recientes.

	#Estos son los registros que deberíamos dejar en nuestra base de datos --> Son los registros más recientes:

	SELECT DISTINCT * FROM crm_cust_info 
	WHERE cst_id IN('0','29433','29449','29466','29473','29483')
	ORDER BY cst_create_date DESC
	LIMIT 6;

	#Para ello, podemos usar ROW_NUMBER():

	SELECT *
	FROM (
	SELECT *, ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
	FROM crm_cust_info) AS T #hacemos una subconsulta para filtrar el ranking de flag_last
	WHERE flag_last = 1 AND cst_id <>0;

	#Query diagnóstico espacios innecesarios (usando TRIM)
	SELECT cst_firstname FROM crm_cust_info
	WHERE cst_firstname <> TRIM(cst_firstname);

	SELECT cst_lastname FROM crm_cust_info
	WHERE cst_lastname <> TRIM(cst_lastname);

	SELECT cst_gndr FROM crm_cust_info
	WHERE cst_gndr <> TRIM(cst_gndr);

	#Aplicamos una query para limpiar espacios indeseados 
	SELECT 
	cst_id,
	cst_key,
	TRIM(cst_firstname) AS cst_firstname,
	TRIM(cst_lastname) AS cst_lastname,
	cst_marital_status,
	cst_gndr,
	cst_create_date
	FROM (
			SELECT *, ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
			FROM crm_cust_info) AS t #reutilizamos la tabla limpia anterior mediante una subconsulta
			WHERE flag_last = 1 AND cst_id <>0;

	#Estandarización de datos y consistencia

	SELECT DISTINCT cst_gndr
	FROM crm_cust_info;

	#La columna gender y la columna marital_status tienen la misma abreviatura y pueden confudir. Usamos CASE para diferenciarlas:

	SELECT 
	cst_id,
	cst_key,
	TRIM(cst_firstname) AS cst_firstname,
	TRIM(cst_lastname) AS cst_lastname,
	CASE
		WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
		WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
		ELSE 'Unknown'
	END AS cst_marital_status,
	CASE
		WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
		WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
		ELSE 'Unknown'
	END AS cst_gndr,
	cst_create_date
	FROM (
			SELECT *, ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
			FROM crm_cust_info) AS t 
			WHERE flag_last = 1 AND cst_id <>0;
			
	#Creamos una tabla limpia a partir de Query anterior (fin limpieza crm_cust_info):

	CREATE TABLE crm_cust_info_clean AS
	SELECT 
	cst_id,
	cst_key,
	TRIM(cst_firstname) AS cst_firstname,
	TRIM(cst_lastname) AS cst_lastname,
	CASE
		WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
		WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
		ELSE 'Unknown'
	END AS cst_marital_status,
	CASE
		WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
		WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
		ELSE 'Unknown'
	END AS cst_gndr,
	cst_create_date
	FROM (
			SELECT *, ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
			FROM crm_cust_info) AS t
			WHERE flag_last = 1 AND cst_id <>0;
			
	SELECT * FROM crm_cust_info_clean;

	#Limpieza cmr_prd_info

	SELECT * FROM crm_prd_info;

	#Query comprobación duplicados

	SELECT prd_inf, COUNT(prd_inf) FROM crm_prd_info
	GROUP BY prd_inf
	HAVING COUNT(prd_inf) > 1 OR prd_inf = ''; #no hay duplicados en esta tabla

	#Explorando la tabla de productos, vemos que la columna prd_key contiene información de diversas fuentes en un mismo campo	
	#Se hace necesario separar esa columna medianet SUBSTRING()
	#En la misma query, asignamos nombres legibles a las categorías de producto, convertimos prd_start_dt a formato fecha y le damos orden cronológico
		
	SELECT 
	prd_inf,
	prd_key,
	REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_')  AS cat_id, #los primeros 5 caracteres corresponden a cat_id
	SUBSTRING(prd_key,7,LENGTH(prd_key)) AS prd_key, #los caracteres restantes coresponden a prd_key
	prd_nm,
	IF(prd_cost ='', 0, prd_cost) AS prd_cost,
	CASE
		WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
		WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
		WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
		WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
		ELSE 'Unknown'
	END AS prd_line,
	CAST(prd_start_dt AS DATE) AS prd_start_dt,
	CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) AS DATE) AS prd_end_dt_test
	FROM crm_prd_info;

	#Exploramos las claves naturales de las otras tablas para hacer JOINS posteriormente
	SELECT DISTINCT id from erp_px_cat_g1v2; 
	SELECT sls_prd_key FROM  crm_sales_details; 

	#Query para chequear espacios innecesarios
	SELECT prd_nm FROM crm_prd_info
	WHERE prd_nm <> TRIM(prd_nm); #no hay espacios innecesarios

	#Query para chequear nulos y números negativos
	SELECT prd_key, prd_cost FROM crm_prd_info
	WHERE prd_cost < 0 OR prd_cost = '';

	SELECT DISTINCT prd_line
	FROM crm_prd_info;

	SELECT * FROM crm_prd_info
	WHERE prd_end_dt < prd_start_dt; #Existen datos incoherentes en estas columnas, por lo que es necesario cambiar el orden cronológico

	#Para cambiar el orden cronológico de las fechas, usamos LEAD() y condicionamos con una subconsulta
	SELECT prd_inf, 
	prd_key, 
	prd_nm, 
	prd_start_dt, 
	prd_end_dt,
	LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) AS prd_end_dt_test
	FROM crm_prd_info
	WHERE prd_key IN (SELECT prd_key FROM crm_prd_info
					 WHERE prd_end_dt < prd_start_dt);
					 
	#Creamos la tabla limpia final (fin limpieza crm_prd_info)

	CREATE TABLE crm_prd_info_clean AS 
	SELECT 
	prd_inf,
	REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_')  AS cat_id,
	SUBSTRING(prd_key,7,LENGTH(prd_key)) AS prd_key,
	prd_nm,
	IF(prd_cost ='', 0, prd_cost) AS prd_cost,
	CASE
		WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
		WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
		WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
		WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
		ELSE 'Unknown'
	END AS prd_line,
	CAST(prd_start_dt AS DATE) AS prd_start_dt,
	CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) AS DATE) AS prd_end_dt_test
	FROM crm_prd_info;

	SELECT * FROM crm_prd_info_clean;

	SHOW COLUMNS FROM crm_prd_info_clean;

	#Limpieza crm_sales_details

	#Query de limpieza
	SELECT
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	CASE WHEN sls_order_dt = 0 OR LENGTH(sls_order_dt) <> 10 THEN NULL
		ELSE CAST(CAST(sls_order_dt AS CHAR) AS DATE)
	END AS sls_order_dt,
	CASE WHEN sls_ship_dt = 0 OR LENGTH(sls_ship_dt ) <> 10 THEN NULL
		ELSE CAST(CAST(sls_ship_dt AS CHAR) AS DATE)
	END AS sls_ship_dt,
	CASE WHEN sls_due_dt = 0 OR LENGTH(sls_due_dt) <> 10 THEN NULL
		ELSE CAST(CAST(sls_due_dt AS CHAR) AS DATE)
	END AS sls_due_dt,
	CASE
		WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales <>sls_quantity*ABS(sls_price) THEN sls_quantity*ABS(sls_price) #funcion ABSOLUTE, convierte de negativo a positivo
		ELSE sls_sales
	END AS sls_sales_clean,

	CASE 
		WHEN sls_price IS NULL OR sls_price <= 0 THEN sls_sales / NULLIF(sls_quantity,0)
		ELSE sls_price
	END AS sls_price_clean,
	sls_quantity
		
	FROM crm_sales_details;


	SHOW COLUMNS FROM crm_sales_details;

	#Espacios indeseados
	SELECT * FROM crm_sales_details
	WHERE sls_ord_num <> TRIM(sls_ord_num);

	#Limpieza de columnas para conectar con otras tablas
	SELECT * FROM crm_sales_details;

	SELECT 
	NULLIF(sls_order_dt , 0) AS sls_order_dt
	FROM crm_sales_details
	WHERE sls_order_dt <= 0;

	#Comprobar exactitud de la columna fecha
	SELECT 
	NULLIF(sls_order_dt , 0) AS sls_order_dt
	FROM crm_sales_details
	WHERE sls_order_dt <= 0 OR LENGTH(sls_order_dt) <> 10;

	#Corroborar coherencia entre fechas de pedido, envío y vencimiento
	SELECT * FROM crm_sales_details
	WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt; #todo OK

	#Corroborar coherencia entre las últimas 3 columnas de venta
	SELECT sls_ord_num, sls_sales,
	sls_quantity,
	sls_price
	FROM crm_sales_details
	WHERE sls_sales <> sls_quantity * sls_price 
	OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL 
	OR sls_sales ='' OR sls_quantity ='' OR sls_price =''
	OR sls_sales <=0 OR sls_quantity <=0 OR sls_price <=0
	ORDER BY sls_sales, sls_quantity, sls_price;

	#Reglas para arreglar las columnas de ventas
	#1 si las ventas son negativas, 0 o nulas, deducirlas de la multiplicación de la cantidad con precio
	#2 si el precio es 0, o nulo, calcularlo deduciéndolo de las ventas y cantidad
	#3si el precio es negativo, convertirlo a positivo

	SELECT sls_sales, sls_quantity, sls_price,
	CASE
		WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales <>sls_quantity*ABS(sls_price) THEN sls_quantity*ABS(sls_price) #funcion ABSOLUTE, convierte de negativo a positivo
		ELSE sls_sales
	END AS sls_sales_clean,

	CASE 
		WHEN sls_price IS NULL OR sls_price <= 0 THEN sls_sales / NULLIF(sls_quantity,0)
		ELSE sls_price
	END AS sls_price_clean
		
		
	FROM crm_sales_details
	ORDER BY sls_sales asc;

	#Creamos tabla limpia de crm_sales_details_clean

	CREATE TABLE crm_sales_details_clean AS
	SELECT
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	CASE WHEN sls_order_dt = 0 OR LENGTH(sls_order_dt) <> 10 THEN NULL
		ELSE CAST(CAST(sls_order_dt AS CHAR) AS DATE)
	END AS sls_order_dt,
	CASE WHEN sls_ship_dt = 0 OR LENGTH(sls_ship_dt ) <> 10 THEN NULL
		ELSE CAST(CAST(sls_ship_dt AS CHAR) AS DATE)
	END AS sls_ship_dt,
	CASE WHEN sls_due_dt = 0 OR LENGTH(sls_due_dt) <> 10 THEN NULL
		ELSE CAST(CAST(sls_due_dt AS CHAR) AS DATE)
	END AS sls_due_dt,
	CASE
		WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales <>sls_quantity*ABS(sls_price) THEN sls_quantity*ABS(sls_price) #funcion ABSOLUTE, convierte de negativo a positivo
		ELSE sls_sales
	END AS sls_sales_clean,

	CASE 
		WHEN sls_price IS NULL OR sls_price <= 0 THEN sls_sales / NULLIF(sls_quantity,0)
		ELSE sls_price
	END AS sls_price_clean,
	sls_quantity
		
	FROM crm_sales_details;

	SELECT * FROM crm_sales_details_clean;

	SHOW COLUMNS FROM crm_sales_details_clean;

	#Limpieza erp_cust_az12

	SELECT
	CASE
		WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
		ELSE cid
	END AS cid_clean,
	CASE WHEN bdate > CURDATE() THEN NULL
		ELSE bdate
	END AS bdate_clean,
	CASE 
		WHEN REGEXP_REPLACE(UPPER(gen), '[^A-Z]', '') = 'F' THEN 'Female'
		WHEN REGEXP_REPLACE(UPPER(gen), '[^A-Z]', '') = 'FEMALE' THEN 'Female'
		WHEN REGEXP_REPLACE(UPPER(gen), '[^A-Z]', '') = 'M' THEN 'Male'
		WHEN REGEXP_REPLACE(UPPER(gen), '[^A-Z]', '') = 'MALE' THEN 'Male'
		ELSE 'Unknown'
	END AS gen_clean
	FROM erp_cust_az12;

	#Limpieza codigo_id (cid)

	SELECT 
	CASE
		WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
		ELSE cid
	END AS cid_clean,
	bdate,
	gen
	FROM erp_cust_az12;

	#Chequear bdate
	SELECT distinct
	bdate
	FROM erp_cust_az12
	WHERE bdate < '1924-01-01' OR bdate > CURDATE(); #hay fechas que no tienen sentido, personas que tienen más de 100 años y personas que aún no nacen

	#Correción bdate
	SELECT
	CASE WHEN bdate > CURDATE() THEN NULL
		ELSE bdate
	END AS bdate_clean
	FROM erp_cust_az12;

	#Corrección gender
	SELECT DISTINCT gen FROM erp_cust_az12;

	SELECT DISTINCT gen, LENGTH(gen),
		CASE 
			WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
			WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
			ELSE 'Unknown'
		END AS gen_clean
	FROM erp_cust_az12;

	#Hay caracteres invisibles, por lo que hay que hacer pasos adicionales

	SELECT DISTINCT 
	  gen,
	  CASE 
		WHEN REGEXP_REPLACE(UPPER(gen), '[^A-Z]', '') = 'F' THEN 'Female'
		WHEN REGEXP_REPLACE(UPPER(gen), '[^A-Z]', '') = 'FEMALE' THEN 'Female'
		WHEN REGEXP_REPLACE(UPPER(gen), '[^A-Z]', '') = 'M' THEN 'Male'
		WHEN REGEXP_REPLACE(UPPER(gen), '[^A-Z]', '') = 'MALE' THEN 'Male'
		ELSE 'Unknown'
	  END AS gen_clean
	FROM erp_cust_az12;

	#Creación tabla limpia erp_cust_az12_clean

	CREATE TABLE erp_cust_az12_clean AS
	SELECT
	CASE
		WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
		ELSE cid
	END AS cid_clean,
	CASE WHEN bdate > CURDATE() THEN NULL
		ELSE bdate
	END AS bdate_clean,
	CASE 
		WHEN REGEXP_REPLACE(UPPER(gen), '[^A-Z]', '') = 'F' THEN 'Female'
		WHEN REGEXP_REPLACE(UPPER(gen), '[^A-Z]', '') = 'FEMALE' THEN 'Female'
		WHEN REGEXP_REPLACE(UPPER(gen), '[^A-Z]', '') = 'M' THEN 'Male'
		WHEN REGEXP_REPLACE(UPPER(gen), '[^A-Z]', '') = 'MALE' THEN 'Male'
		ELSE 'Unknown'
	END AS gen_clean
	FROM erp_cust_az12;

	SELECT * FROM erp_cust_az12_clean;

	SHOW COLUMNS FROM erp_cust_az12_clean;

	#Limpieza tabla erp_loc_a101

	SELECT 
	REPLACE(cid,'-','') cid, 
	cntry 
	FROM erp_loc_a101;

	#Limpieza guión cid

	SELECT  
	REPLACE(cid,'-','') cid,
	CASE
		WHEN REGEXP_REPLACE(UPPER(cntry), '[^A-Z]', '') = 'DE' THEN 'Germany'
		WHEN REGEXP_REPLACE(UPPER(cntry), '[^A-Z]', '') IN ('US', 'USA') THEN 'United States'
		WHEN REGEXP_REPLACE(cntry, '[[:space:]]', '') = '' OR cntry IS NULL THEN 'n/a'
		ELSE TRIM(cntry) 
	END AS cntry_clean
	FROM erp_loc_a101;

	#Estandarización y consistencia de cntry
	SELECT DISTINCT cntry
	FROM erp_loc_a101;

	SELECT DISTINCT cntry,
	CASE
		WHEN TRIM(cntry) = 'DE' THEN 'Germany'
		WHEN TRIM(cntry) IN('US','USA') THEN 'United States'
		WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
		ELSE TRIM(cntry) 
	END cntry_clean
	FROM erp_loc_a101;

	#Hay caracteres invisibles, por lo tanto debemos aplicar REGEX_REPLACE

	SELECT DISTINCT cntry,
	CASE
		WHEN REGEXP_REPLACE(UPPER(cntry), '[^A-Z]', '') = 'DE' THEN 'Germany'
		WHEN REGEXP_REPLACE(UPPER(cntry), '[^A-Z]', '') IN ('US', 'USA') THEN 'United States'
		WHEN REGEXP_REPLACE(cntry, '[[:space:]]', '') = '' OR cntry IS NULL THEN 'n/a'
		ELSE TRIM(cntry) 
	END AS cntry_clean
	FROM erp_loc_a101;

	#Creamos la tabla limpia erp_loc_a101_clean

	CREATE TABLE erp_loc_a101_clean AS
	SELECT 
	REPLACE(cid,'-','') cid,
	CASE
		WHEN REGEXP_REPLACE(UPPER(cntry), '[^A-Z]', '') = 'DE' THEN 'Germany'
		WHEN REGEXP_REPLACE(UPPER(cntry), '[^A-Z]', '') IN ('US', 'USA') THEN 'United States'
		WHEN REGEXP_REPLACE(cntry, '[[:space:]]', '') = '' OR cntry IS NULL THEN 'n/a'
		ELSE TRIM(cntry) 
	END AS cntry_clean
	FROM erp_loc_a101;

	SELECT * FROM erp_loc_a101_clean;

	SHOW COLUMNS FROM erp_loc_a101_clean;

	#Limpieza erp_px_cat_g1v2

	SELECT 
	ID,
	CAT,
	SUBCAT,
	MAINTENANCE
	FROM erp_px_cat_g1v2;

	#Comprobar espacios invisibles
	SELECT * FROM erp_px_cat_g1v2
	WHERE CAT <> TRIM(CAT) OR SUBCAT <> TRIM(SUBCAT) OR MAINTENANCE <> TRIM(MAINTENANCE);

	#Estandarización de la data y consistencia
	SELECT DISTINCT 
	maintenance
	FROM erp_px_cat_g1v2;

	#Maintenance está duplicado, aplicamos REGEX_REPLACE considerando que esta duplicación se debe a espacios invisibles
	#Primero diagnosticamos:

	SELECT DISTINCT
	  maintenance,
	  LENGTH(maintenance) AS len,
	  HEX(maintenance) AS hex_val
	FROM erp_px_cat_g1v2;

	#Existen caracteres hexadecimales invisibles pegados que no se han limpiado al importar la información

	SET SQL_SAFE_UPDATES = 0;

	#Luego limpiamos:

	UPDATE erp_px_cat_g1v2
	SET maintenance = TRIM(REPLACE(maintenance, CHAR(13), ''))
	WHERE maintenance LIKE '%Yes%';

	#Comprobamos maintenance
	SELECT DISTINCT 
	maintenance
	FROM erp_px_cat_g1v2;

	CREATE TABLE erp_px_cat_g1v2_clean AS
	SELECT 
	ID,
	CAT,
	SUBCAT,
	MAINTENANCE
	FROM erp_px_cat_g1v2;

	SELECT * FROM erp_px_cat_g1v2;
END //

DELIMITER ;
