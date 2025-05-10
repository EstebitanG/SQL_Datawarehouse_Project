Diccionario de datos Datawarehouse

Descripción General

En el apartado final de Data Modeling, aparecen las tablas catalogadas como DIMENSIONES o FACTS. Cada una posee sus propios atributos
necesarios de detallar.

1. DIMENSION_CLIENTES

Propósito: almacena características sociodemográficas de los clientes. 

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

2. DIMENSION_PRODUCTO

Propósito: almacena características de los productos. 

Columnas:


| Columna | Tipo de Dato | Descripción |
| --- | --- | --- |
| product_key | BIGINT | Clave sintética que identifica de manera única a cada producto |
| product_id | INT | Identificador único por producto para trazabilidad y referencia |
| category_id | VARCHAR(5) | Identificador único por categoría de producto, referencia a su categoría mayor |
| product_number | VARCHAR(44) | Código alfanumérico usado principalmente para inventario o categorización |
| category | VARCHAR(50) | La clasificación más amplia del producto (categoría mayor) |
| subcategory | VARCHAR(50) | Clasificación más detallada del producto, principalmente por tipo de producto |
| product_name | VARCHAR(50) | Nombre descriptivo del producto, incluyendo detalles principales como tamaño, color, etc. |
| cost | VARCHAR(50) | El costo base del producto, expresado en unidades monetarias |
| product_line | VARCHAR(11) | Línea de producto específica a la que pertence el producto (ej.'Road Mountain') |
| start_date | DATE | Fecha donde el producto estuvo disponible en inventario para la venta |
| MAINTENANCE | VARCHAR(50) | Indica si el producto requiere mantención (ej. 'Yes'/'No') |

3. FACT_VENTAS

Propósito: almacena transacciones históricas de venta para objetivos de análisis.

Columnas:


| Columna | Tipo de Dato | Descripción |
| --- | --- | --- |
| order_number | VARCHAR(50) | Identificador alfanumérico único para cada orden de venta (ej. 'SO43699') |
| product_key | BIGINT | Clave sintética que vincula la orden de venta con la DIMENSION_PRODUCTO (clave_foránea_1 FK1) |
| customer_key | BIGINT | Clave sintética que vincula la orden de venta con la DIMENSION_CLIENTES (clave_foránea_2 FK2) |
| order_date | DATE | Fecha donde la orden fue emitida |
| shipping_date | DATE | Fecha donde la orden fue transportada hacia el cliente |
| due_date | DATE | Fecha de vencimiento del pago del pedido |
| sales_amount | DOUBLE | Valor monetario total de la orden, expresado en unidades monetarias |
| price | VARCHAR(50) | Precio por unidad del producto |
| quantity | INT | Cantidad de unidades ordenadas del producto |
