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

--VALORES AUXILIAR POR ARTÍCULO POR ORDEN DE RECUENTO
SELECT * FROM sun_count_order_aux;

SELECT * FROM sun_count_order_head;
SELECT * FROM sun_count_order_line;
SELECT * FROM sun_count_order_line_stage;

--ARTÍCULOS SIN CÓDIGO
SELECT * FROM sun_count_order_surplus;

SELECT * FROM apps_pos_countries;
SELECT * FROM sun_count_locked_acc;
SELECT * FROM sun_count_order_aux;
SELECT * FROM sun_count_order_head;
SELECT * FROM sun_count_order_line;
SELECT * FROM sun_count_order_line_stage;
SELECT * FROM sun_count_order_surplus;
SELECT * FROM sun_count_request_auxiliar;
SELECT * FROM sun_count_request_head;
SELECT * FROM sun_count_stk_photo;
SELECT * FROM sun_stkcount;
SELECT * FROM wms_count_hu_photo;
SELECT * FROM wms_count_order_acc;
SELECT * FROM wms_count_order_doc;
SELECT * FROM wms_count_order_head;
SELECT * FROM wms_count_order_head_aux;
SELECT * FROM wms_count_order_head_sun_aux;
SELECT * FROM wms_count_order_hu_head;
SELECT * FROM wms_count_order_hu_line;
SELECT * FROM wms_count_order_hu_seal;
SELECT * FROM wms_count_order_line;
SELECT * FROM wms_count_order_line_aux;
SELECT * FROM wms_count_order_line_sun_aux;
SELECT * FROM wms_count_order_stkdist;
SELECT * FROM wms_count_order_wkf_status;
SELECT * FROM wms_count_request_doc;
SELECT * FROM wms_count_request_emp;
SELECT * FROM wms_count_request_employee;
SELECT * FROM wms_count_request_file_class;
SELECT * FROM wms_count_request_files;
SELECT * FROM wms_count_request_head;
SELECT * FROM wms_count_request_line;
SELECT * FROM wms_count_request_wkf_status;
SELECT * FROM wms_count_stk_photo;
SELECT * FROM wms_stkcount;


SELECT * FROM ctipodir;
SELECT * FROM galmacen WHERE codigo = '370';
SELECT * FROM wms_inbound_rules_head WHERE rule_recint = '370';
SELECT * FROM galmreci WHERE codigo = '370';
SELECT * FROM cper_delegac WHERE codigo = 'CHA';
SELECT * FROM ctipodir;
SELECT * FROM cterdire;
SELECT * FROM gdelegac WHERE codigo = 'CHA';
SELECT * FROM gdeparta WHERE delega = 'CHA';
SELECT * FROM galmubic WHERE codalm = '370';
SELECT * FROM glog_alm_subzon WHERE subz_recint='370';
SELECT * FROM wms_task_rules_head WHERE rule_code matches'370*';
SELECT * FROM wms_task_rules_filter WHERE  rfilt_recint = '370';
SELECT * FROM wms_outbound_rules_head WHERE rule_code matches'370*';
SELECT * FROM wms_outbound_rules_line WHERE rule_code matches'370*';
SELECT * FROM wms_task_rules_line WHERE rule_code matches'370*';
SELECT * FROM galmdele WHERE codalm = '370';
SELECT * FROM gusergrp WHERE grpcode IN ('CHA', '370');
SELECT * FROM guserdefs WHERE grpcode IN ('CHA', '370');
SELECT * FROM sun_reglaubi_asignada WHERE codalm = '370';