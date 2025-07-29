/*
==========================================================================================================================================
Data Modeling
==========================================================================================================================================

Propósito del código:
	Este código tiene por objetivo llegar a la etapa final de la base de datos. Esto se logra mediante el uso de JOINS y creación de 
	Vistas, identificando las tablas que corresponden a Dimensiones (clave primaria PK) y FACTS (clave foránea FK).

	Cada Vista corresponde a las transformaciones finales de las tablas, listas para ser usadas para consultas empresariales.

Uso:
	Estas Vistas pueden ser usadas directamente para consultas de Data Analytics e informes.
==========================================================================================================================================
*/

#Para llegar al modelo dimensional depurado, unimos las tablas mediante JOINS, considerando la información que entregan las tablas (CLIENTES - PRODUCTOS - VENTAS)

#Tablas CLIENTES (3 tablas - crm_cust_info_clean, erp_cust_az12_clean, erp_loc_a101_clean)
SELECT 
		cc.cst_id,
		cc.cst_key,
		cc.cst_firstname,
		cc.cst_lastname,
		cc.cst_marital_status,
		cc.cst_create_date,
        	eca.bdate_clean,
        CASE WHEN cc.cst_gndr <>'Unknown' THEN cc.cst_gndr #le hacemos caso a la tabla customer CRM (cc.cst_gndr y eca_gen no coinciden siempre, lo cual no puede ser)
			ELSE COALESCE(eca.gen_clean, 'Unknown')
        END AS new_gen,
        ela.cntry_clean
FROM crm_cust_info_clean AS cc
LEFT JOIN erp_cust_az12_clean AS eca #usamos LEFT JOIN para no perder información (a diferencia de INNER)
ON cc.cst_key = eca.cid_clean

LEFT JOIN erp_loc_a101_clean AS ela
ON cc.cst_key = ela.cid;

#Renombramos las columnas a nombres amigables
SELECT 
		cc.cst_id AS customer_id,
		cc.cst_key AS customer_number,
		cc.cst_firstname AS first_name,
		cc.cst_lastname AS last_name,
		ela.cntry_clean AS country,
		cc.cst_marital_status AS marital_status,
        CASE WHEN cc.cst_gndr <>'Unknown' THEN cc.cst_gndr #le hacemos caso a la tabla customer CRM (cc.cst_gndr y eca_gen no coinciden siempre, lo cual no puede ser)
			ELSE COALESCE(eca.gen_clean, 'Unknown')
        END AS gender,
        eca.bdate_clean AS birthdate,
        cc.cst_create_date AS create_date
FROM crm_cust_info_clean AS cc
LEFT JOIN erp_cust_az12_clean AS eca #usamos LEFT JOIN para no perder información (a diferencia de INNER)
ON cc.cst_key = eca.cid_clean

LEFT JOIN erp_loc_a101_clean AS ela
ON cc.cst_key = ela.cid;

#Creamos una Vista con la Dimensión completa (Tabla Clientes) considerando crear una clave sintética (surrogate key) mediante ROW NUMBER

CREATE VIEW DIMENSION_CLIENTES AS
SELECT 
		ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key, 
		cc.cst_id AS customer_id,
		cc.cst_key AS customer_number,
		cc.cst_firstname AS first_name,
		cc.cst_lastname AS last_name,
		ela.cntry_clean AS country,
		cc.cst_marital_status AS marital_status,
        CASE WHEN cc.cst_gndr <>'Unknown' THEN cc.cst_gndr #le hacemos caso a la tabla customer CRM (cc.cst_gndr y eca_gen no coinciden siempre, lo cual no puede ser)
			ELSE COALESCE(eca.gen_clean, 'Unknown')
        END AS gender,
        eca.bdate_clean AS birthdate,
        cc.cst_create_date AS create_date
FROM crm_cust_info_clean AS cc
LEFT JOIN erp_cust_az12_clean AS eca #usamos LEFT JOIN para no perder información (a diferencia de INNER)
ON cc.cst_key = eca.cid_clean

LEFT JOIN erp_loc_a101_clean AS ela
ON cc.cst_key = ela.cid;

SELECT * FROM DIMENSION_CLIENTES;

#Tablas PRODUCTOS (2 tablas - erp_px_cat_g1v2, crm_prd_info)

#Creamos una Vista con la dimensión completa (Tabla Producto) considerando crear una clave sintética (surrogate key) mediante ROW NUMBER

CREATE VIEW DIMENSION_PRODUCTO AS
SELECT 
	ROW_NUMBER() OVER (ORDER BY cic.prd_start_dt, cic.prd_key) AS product_key,
	cic.prd_inf AS product_id,
	cic.cat_id AS category_id,
	cic.prd_key AS product_number,
	px.CAT AS category,
    	px.SUBCAT AS subcategory,
	cic.prd_nm AS product_name,
	cic.prd_cost AS cost,
	cic.prd_line AS product_line,
	cic.prd_start_dt AS start_date,
    	px.MAINTENANCE
FROM crm_prd_info_clean AS cic
LEFT JOIN erp_px_cat_g1v2_clean AS px
ON cic.cat_id = px.id #se hace el JOIN con cat_id

WHERE prd_end_dt_test IS NULL; #aplicamos este filtro para obtener solamente los productos actuales

SELECT * FROM DIMENSION_PRODUCTO;

#Tabla Ventas (1 tabla - crm_sales_details_clean)

#Creamos una Vista con el HECHO completo (Tabla Ventas), donde las claves sintéticas vienen de las tablas dimensiones (como claves foráneas)
#De esta forma conectamos las tablas Dimensiones con la tabla HECHO

CREATE VIEW FACT_VENTAS AS
SELECT 
	csd.sls_ord_num AS order_number,
	pr.product_key, #FK
    	cu.customer_key, #FK
	csd.sls_order_dt AS order_date,
	csd.sls_ship_dt AS shipping_date,
	csd.sls_due_dt AS due_date,
	csd.sls_sales_clean AS sales_amount,
	csd.sls_price_clean AS price,
	csd.sls_quantity AS quantity
FROM crm_sales_details_clean AS csd
LEFT JOIN dimension_producto AS pr
ON csd.sls_prd_key = pr.product_number

LEFT JOIN dimension_clientes AS cu
ON csd.sls_cust_id = cu.customer_id;  #tanto product_key como customer_key sirven de claves foráneas para conectar las tablas (FACTS - DIMENTIONS)

SELECT * FROM FACT_VENTAS;

#Tablas finales
SELECT * FROM DIMENSION_CLIENTES;

SELECT * FROM DIMENSION_PRODUCTO;

SELECT * FROM FACT_VENTAS;

