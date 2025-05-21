GCOMPEDH:
    SELECT * FROM gcompedd;
    SELECT * FROM gproveed;
    SELECT * FROM cempresa;
    SELECT * FROM gdelegac;
    SELECT * FROM gdeparta;
    SELECT * FROM cterdire;
    SELECT * FROM galmacen;
    SELECT * FROM ctiponac;
    SELECT * FROM cpar_parpreh;
    SELECT * FROM cper_empleado;
    SELECT * FROM cterdire;
    SELECT * FROM cprovinc;

GCOMPEDL:
    SELECT * FROM gcompedh;
    SELECT * FROM gcomconl;
    SELECT * FROM cterdire;
    SELECT * FROM gartvarl; --Verificar


SELECT * FROM wms_tasks;
SELECT * FROM wic_wms:wic_jdic_tabdata WHERE tab_name = 'wms_stkcount';

SELECT 
    table_tbnames.tab_memo, wms_stkmovs.* 
FROM wms_stkmovs 
    JOIN wic_wms:wic_jdic_tabdata table_tbnames
        ON table_tbnames.tab_name = wms_stkmovs.stkm_tabori
WHERE 
        table_tbnames.locale = 'es'
    AND wms_stkmovs.stkm_codart = '0000000106773'
ORDER BY wms_stkmovs.date_created DESC


DOC ORIGEN DE PRUEBA:
BRE-2025-TEST-XXXXXX
BRE-BH25-0002-XXXXXX



gcommovh	Acta observacion
gcommovh	Acta recepción
gcommovh	Acta verificación
gcommovh	Acta separación
sun_seg_recepcion_sga	Seguimiento SGA
sun_sel_autoriza_articulos	Autorizar artículos
sun_sel_art_envaseubi	Envasar y ubicar
sun_asignartarh	Ticket de atención
apps_pos_moveh	Movimiento offline
gvenpedh	Origen
gvenmovh	Origen
sun_relacion_negocio	es.HDR_RELACION_UNINEG
sun_gcompedh_numact	es.HDR_GCOMPEDH_NUMACT
gcompedl	Detalle artículos
cerrcode_workflow	
cerrauth	

-- WMS_INVENTORY
--FECHA DE ENTRADA EN STOCK  FA LTA
select * from wms_inventory_char where chr_seqno = 315186;
-- FALTA
select * from wms_inbound_order_head;
-- FALTA
select * from wms_inbound_order_line;
select * from wms_incidence;
-- FALTA
select * from wms_items_uom;
-- FALTA
select * from wms_bins;
-- FALTA
select * from wms_hlunith;

select * from wms_inbound_stkmov_head;
select * from wms_incidence;
-- FALTA
select * from wms_hlunith;
select * from wms_employee;
select * from wms_stk_account;
select * from wms_inbound_stkmov_doc;
select * from wms_company;
select * from wms_warehouse;
select * from wms_supplier;
select * from wms_inbound_ship_head;
SELECT * FROM wms_customer;
SELECT * FROM wms_outbound_order_head;
SELECT * FROM wms_uom_defs;
SELECT * FROM wms_wave_picking_head;
SELECT * FROM wms_outbound_order_line;
SELECT * FROM choldinh;
SELECT * FROM cleasinh;
SELECT * FROM wms_inhouse_hu_link;
--FALTA
SELECT * FROM wms_inhouse_line_link;
--FALTA
SELECT * FROM wms_inhouse_stkmov_dates;
SELECT * FROM wms_inhouse_stkmov_doc;
SELECT * FROM wms_inhouse_stkmov_head;
--FALTA
SELECT * FROM wms_inhouse_stkmov_hu;
SELECT * FROM wms_inhouse_stkmov_inci;
--FALTA
SELECT * FROM wms_inhouse_stkmov_infohu;
SELECT * FROM wms_inhouse_stkmov_line;
SELECT * FROM wms_inhouse_stkmov_supply;
SELECT * FROM wms_count_request_doc;
SELECT * FROM wms_enclosure;
SELECT * FROM wms_warehouse;
SELECT * FROM wms_count_order_head;
SELECT * FROM wms_warehouse;
SELECT * FROM wms_stk_account;
SELECT * FROM wms_count_request_line;
SELECT * FROM wms_uom_defs;
SELECT * FROM wms_uom_defs;
SELECT * FROM wms_employee;
--FALTA
SELECT * FROM wms_count_order_hu_line;
SELECT * FROM wms_enclosure;
SELECT * FROM wms_task_group;
--FALTA
SELECT * FROM wms_items;
SELECT * FROM wms_task_type;
SELECT * FROM wms_emp_profile;

--FALTA
SELECT * FROM wms_count_order_hu_line;
--FALTA
SELECT * FROM wms_outbound_line_link;


SELECT * FROM gcommovd;
SELECT * FROM galmacen;
SELECT * FROM gproveed;
SELECT * FROM gproveed;
SELECT * FROM cterdire;
SELECT * FROM cempresa;
SELECT * FROM gdeparta;
SELECT * FROM cpar_parpreh;
--FALTA gcommovl
SELECT * FROM gartvarl;


SELECT * FROM wms_inbound_order_doc;
SELECT * FROM wms_inbound_order_head;
SELECT * FROM wms_inbound_order_line;
SELECT * FROM wms_inbound_rules_defs;
SELECT * FROM wms_inbound_rules_head;
SELECT * FROM wms_inbound_rules_line;
SELECT * FROM wms_inbound_ship_char1;
SELECT * FROM wms_inbound_ship_char2;
SELECT * FROM wms_inbound_ship_doc;
SELECT * FROM wms_inbound_ship_head;
SELECT * FROM wms_inbound_ship_packs;
SELECT * FROM wms_inbound_stkmov_doc;
SELECT * FROM wms_inbound_stkmov_head;
SELECT * FROM wms_inbound_stkmov_line;
SELECT * FROM wms_outbound_group_link;
SELECT * FROM wms_outbound_group_lot;
--FALTA
SELECT * FROM wms_outbound_line_link;
SELECT * FROM wms_outbound_load_cond;
SELECT * FROM wms_outbound_order_class;
SELECT * FROM wms_outbound_order_dlvnote;
SELECT * FROM wms_outbound_order_doc;
SELECT * FROM wms_outbound_order_head;
SELECT * FROM wms_outbound_order_line;
SELECT * FROM wms_outbound_order_pclas;
SELECT * FROM wms_outbound_pick2step_launch;
SELECT * FROM wms_outbound_rules_defs;
SELECT * FROM wms_outbound_rules_head;
SELECT * FROM wms_outbound_rules_line;
SELECT * FROM wms_outbound_ship_doc;
SELECT * FROM wms_outbound_ship_head;
SELECT * FROM wms_outbound_ship_item;
SELECT * FROM wms_outbound_stkmov_doc;
SELECT * FROM wms_outbound_stkmov_head;
SELECT * FROM wms_outbound_stkmov_line;