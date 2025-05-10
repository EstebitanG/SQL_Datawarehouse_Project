



CREATE DATABASE DataWarehouse;

USE DataWarehouse;

##DDL Querys

CREATE TABLE crm_cust_info (cst_id INT, cst_key VARCHAR(50),
							cst_firstname VARCHAR(50),
                            cst_lastname VARCHAR(50),
                            cst_marital_status VARCHAR(50),
                            cst_gndr VARCHAR(50),
                            cst_create_date DATE);

DROP TABLE crm_prd_info;

CREATE TABLE crm_prd_info (prd_inf INT, prd_key VARCHAR(50),
						prd_nm VARCHAR(50) NULL,
                        prd_cost VARCHAR(50) NULL,
                        prd_line VARCHAR(50) NULL,
                        prd_start_dt DATE NULL,
                        prd_end_dt DATE NULL);
										
CREATE TABLE CRM_sales_details (sls_ord_num VARCHAR(50), sls_prd_key VARCHAR(50),
							sls_cust_id INT NULL, 
                            sls_order_dt DATE NULL,
                            sls_ship_dt DATE NULL, 
                            sls_due_dt DATE NULL,
                            sls_sales INT NULL,
                            sls_quantity INT NULL,
                            sls_price VARCHAR(50) NULL);

CREATE TABLE erp_CUST_AZ12 (CID VARCHAR(50),
						BDATE DATE NULL, 
                        GEN VARCHAR(50) NULL);

CREATE TABLE erp_LOC_A101 (CID VARCHAR(50),
						CNTRY VARCHAR(50));
                        
CREATE TABLE erp_PX_CAT_G1V2 (ID VARCHAR(50), 
							CAT VARCHAR(50),
                            SUBCAT VARCHAR(50),
                            MAINTENANCE VARCHAR(50));
                            
SELECT @@sql_mode;

SET sql_mode = 'NO_ENGINE_SUBSTITUTION';

SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cust_info.csv' 
INTO TABLE crm_cust_info CHARACTER SET latin1 
COLUMNS TERMINATED BY ',' LINES TERMINATED BY '\n'
IGNORE 1 LINES;

SELECT * FROM crm_cust_info;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/prd_info.csv' 
INTO TABLE crm_prd_info CHARACTER SET latin1 
COLUMNS TERMINATED BY ',' LINES TERMINATED BY '\n'
IGNORE 1 LINES;

SELECT * FROM crm_prd_info;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sales_details.csv' 
INTO TABLE crm_sales_details CHARACTER SET latin1 
COLUMNS TERMINATED BY ',' LINES TERMINATED BY '\n'
IGNORE 1 LINES;

SELECT * FROM crm_sales_details;

SELECT COUNT(*) FROM crm_sales_details;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/CUST_AZ12.csv' 
INTO TABLE erp_cust_az12 CHARACTER SET latin1 
COLUMNS TERMINATED BY ',' LINES TERMINATED BY '\n'
IGNORE 1 LINES;

SELECT * FROM erp_cust_az12;

SELECT COUNT(*) FROM erp_cust_az12;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/LOC_A101.csv' 
INTO TABLE erp_loc_a101 CHARACTER SET latin1 
COLUMNS TERMINATED BY ',' LINES TERMINATED BY '\n'
IGNORE 1 LINES;

SELECT * FROM erp_loc_a101;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/PX_CAT_G1V2.csv' 
INTO TABLE erp_px_cat_g1v2 CHARACTER SET latin1 
COLUMNS TERMINATED BY ',' LINES TERMINATED BY '\n'
IGNORE 1 LINES;

SELECT * FROM erp_px_cat_g1v2;
