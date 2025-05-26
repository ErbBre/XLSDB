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




-- TABLAS CON CAMPOS CODART
select 
	tabname,syscolumns.colname, 'SELECT * FROM '||tabname||';' query,  systables.nrows
from systables 
	join syscolumns 
		on systables.tabid = syscolumns.tabid  
WHERE 
		systables.nrows > 0 
	AND syscolumns.colname like '%codart%' 
	AND systables.tabname NOT LIKE '%\_v%' ESCAPE '\'
	AND systables.tabname NOT IN (
		't_result_07648',
		'sun_migra_ubicado_ilo',
		'sun_migra_ubicado_lalibertad',
		'usr_retro_mollendo',
		'sun_sitleg_tumbes',
		'sun_garticul_imei',
		'sun_datos_cambio_sitleg',
		'sun_gcompedl_desagr',
		
		'galmtipc'
	)
	
ORDER by systables.nrows DESC;


===============================================================================
--ATTACH DATABASE '/Users/christianruizovalle/desktop/project/xlsx/xlsdb/data/data_main.db' AS system;

-- TABLAS CON CAMPOS CODART

select 
	head.tabname,line.colname, 'SELECT * FROM '||head.tabname||';' query,  head.nrows
from system.systables head 
	join system.syscolumns line
		on head.tabid = line.tabid  
WHERE 
		head.nrows > 0 
	AND line.colname like '%codart%' 
	AND head.tabname NOT LIKE '%\_v%' ESCAPE '\'
	AND head.tabname NOT IN (
		't_result_07648',
		'sun_migra_ubicado_ilo',
		'sun_migra_ubicado_lalibertad',
		'usr_retro_mollendo',
		'sun_sitleg_tumbes',
		'sun_garticul_imei',
		'sun_datos_cambio_sitleg',
		'sun_gcompedl_desagr',
		'galmtipc',
		'wms_inventory2'
	)
ORDER by head.nrows DESC;









1	wms_count_adjusts	AJUSTES RECUENTOS
2	wms_count_cycle_gen_orders	GENERAR ÓRDENES DE RECUENTOS CÍCLICOS
3	wms_count_diff_justify	JUSTIFICACIÓN AJUSTES RECUENTOS
4	wms_count_diff_justify_rep	JUSTIFICACIÓN AJUSTES RECUENTOS
5	wms_count_order_2	PETICIONES POR ALMACEN - RESUMEN
6	wms_count_order_codalm	PETICIONES POR ALMACEN
7	wms_count_order_codart	RECUENTOS POR ARTÍCULO
8	wms_count_order_codfam	RECUENTOS POR FAMÍLIA DE ARTÍCULO
9	wms_count_order_overlapping	RECUENTOS DE STOCKS SOLAPADOS
10	wms_stkcount	MOVIMIENTOS DE RECUENTO DE STOCK



wms_count_request_head			Peticiones de recuento
wms_count_order_head_sqltsel	Entrada rápida de recuentos
wms_tasks						Tareas
wms_count_order_line			Líneas
wms_count_order_hu_line			Líneas UM
wms_count_order_wkf_status		Estados workflow
wms_workflow_log				Logs workflow
wms_stkcount					Ajustes de stock
sun_count_order_aux	
sun_count_order_stage_sel