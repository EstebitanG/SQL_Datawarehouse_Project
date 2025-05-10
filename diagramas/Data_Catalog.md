Diccionario de datos Datawarehouse

Descripción General

En el apartado final de Data Modeling, aparecen las tablas catalogadas como DIMENSIONES o FACTS. Cada una posee sus propios atributos
necesarios de detallar.

1. DIMENSION_CLIENTES

Propósito: almacena características sociodemográficas de los clientes 

Columnas:

| Columna | Tipo de Dato | Descripción |
| --- | --- | --- |
| customer_key | BIGINT | Clave sintética que identifica de manera única a cada cliente |
| customer_id | INT | Identificador único para cada cliente |
| customer_number | VARCHAR(50) | Identificador alfanumérico representante del cliente, usado para trazabilidad y referencia |
| first_name | VARCHAR(50) | Primer nombre del cliente |
| last_name | VARCHAR(50) | Apellido del cliente |
| country | VARCHAR(50) | Nacionalidad del cliente (ej. 'Australia') |
| marital_status | VARCHAR(7) | Estado civil del cliente (ej. 'Married') |
| gender | VARCHAR(7) | Género del cliente (ej. 'Single') |
| birthdate | DATE | Fecha de nacimiento del cliente, en formato YYYY-MMM-DD (ej. '1980-08-12') |
| create_date | DATE | Fecha de registro del cliente en el sistema |
