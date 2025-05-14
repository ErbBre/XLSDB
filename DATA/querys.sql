DROP TABLE IF EXISTS tmp_docs;
CREATE TEMP TABLE tmp_docs AS SELECT docser FROM  gvenpedh_24f;

SELECT  *  FROM gvenpedh_lts9may WHERE docser in (SELECT * FROM tmp_docs); 







-- ARTICULOS DE LA ORDEN QUE SE ENCUENTRAN EN LOS 3 LOTES ATENDIDOS ANTERIORMENTE 1,7 y 8
SELECT 
	*  
FROM gvenpedh_ord9may  head
	JOIN gvenpedl_ord9may line ON head.cabid = line.cabid WHERE docser in (SELECT * FROM tmp_docs);





-- CUENTAS DEL LOTE 055242025-000001 inventory
DROP TABLE IF EXISTS tmp_codart;
CREATE TEMP TABLE tmp_codart AS
SELECT codart FROM gvenpedl_24f WHERE cabid = 71896;

SELECT  
	inv_cuenta, COUNT(*)  cantidad 
FROM  wms_inventory_24f 
WHERE 
			inv_codart IN (SELECT * FROM tmp_codart) 
	AND	inv_stkact != 0 
GROUP BY inv_cuenta 
ORDER BY cantidad DESC;






-- CUENTAS DEL LOTE 055242025-000001 DESPUES DE AJUSTE
DROP TABLE IF EXISTS tmp_codart;
CREATE TEMP TABLE tmp_codart AS
SELECT codart FROM gvenpedl_24f WHERE cabid = 71896;

SELECT DISTINCT inv_cuenta FROM  wms_inventory_24f WHERE inv_codart IN (SELECT * FROM tmp_codart) AND inv_stkact != 0;
SELECT  inv_cuenta, COUNT(*)  cantidad FROM  wms_inventory_lts9may WHERE inv_codart IN (SELECT * FROM tmp_codart) AND inv_stkact != 0 GROUP BY inv_cuenta ORDER BY cantidad DESC;






-- DISPOSICION EN INVA DE 055242025-000001 DEL 24 FEBRERO
DROP TABLE IF EXISTS tmp_codart;
CREATE TEMP TABLE tmp_codart AS
SELECT codart FROM gvenpedl_24f WHERE cabid = 71896;

DROP TABLE IF EXISTS tmp_codart_inva;
CREATE TEMP TABLE tmp_codart_inva AS
SELECT inv_codart FROM wms_inventory_24f WHERE inv_codart in (SELECT * from tmp_codart) AND inv_cuenta  = 'INVA';

select codart from sun_ins_prelote_user_24f WHERE codart  IN (SELECT * from tmp_codart_inva)





-- ARTICULOS UPEN DE 055242025-000001
DROP TABLE IF EXISTS tmp_codart;
CREATE TEMP TABLE tmp_codart AS
SELECT codart FROM gvenpedl_24f WHERE cabid = 71896;

DROP TABLE IF EXISTS tmp_codart_upen;
CREATE TEMP TABLE tmp_codart_upen AS
SELECT * FROM wms_inventory_24f WHERE inv_codart in (SELECT * from tmp_codart) AND inv_cuenta  = 'UPEN';

SELECT * FROM tmp_codart_upen





-- VERIFICACION DE ACTAS PARA EL ARTICULO UPEN DEL LOTE 1
SELECT * FROM gcommovh_lts9may head JOIN gcommovl_lts9may line ON head.cabid = line.cabid WHERE line.codart = '9988013021967'