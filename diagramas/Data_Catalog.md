Diccionario de datos Datawarehouse

Descripción General

En el apartado final de Data Modeling, aparecen las tablas catalogadas como DIMENSIONES o FACTS. Cada una posee sus propios atributos
necesarios de detallar.

1. DIMENSION_CLIENTES

Propósito: almacena características sociodemográficas de los clientes 

Columnas:

| Columna | Tipo de Dato | Descripción |
| --- | --- | --- |
| customer_key | BIGINT | Contenido 3 |
| customer_id | INT | Contenido 6 |
| customer_number | VARCHAR(50) | Contenido 3 |
| first_name | VARCHAR(50) | Contenido 6 |
| last_name | VARCHAR(50) | Contenido 3 |
| country | VARCHAR(50) | Contenido 6 |
| marital_status | VARCHAR(7) | Contenido 3 |
| gender | VARCHAR(7) | Contenido 6 |
| birthdate | DATE | Contenido 3 |
| create_date | DATE | Contenido 6 |
