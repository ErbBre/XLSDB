Al registrar doc origen cabecera y líneas:
	se registran datos en gcompedh y gcompedl
		gcompedh inicia:
			errcab = 0
			imptot = 0
			user_updated = admsia
			wkfcab: null
		gcompedl inicia:
			estlin = E
			errlin = 25103
			wkflin = 1
	Se registra en el maestro de articulos
		garticul			
Al autorizar las líneas de gcompedl(El movimiento de entrada queda en stand by y se culmina al generar el acta de recepcion):
	gcompedh : 
		errcab:25101
		imptot: gcompedl.impnet
		wkfcab:1
	gcompedl:
		estlin: E -> V
		errlin:25103 -> 0
		wkflin:1 -> null

	Se registra 1 Orden de recepcion:
		wms_inbound_order_head.order_number
		wms_inbound_order_line.ordl_seqno

	Se registra un movimiento de entrada
		wms_inbound_stkmov_head:
			mov_number	: código el movimiento
			order_number: código el movimiento
			mov_status	: E
			order_number : wms_inbound_order_head.order_number
		wms_inbound_stkmov_line:
			linm_cuenta	: PUBI-cuenta hacia donde se mueve el stock por primera vez
			linm_codart	: articulo
			linm_canmov	: Stock recibido(Cantidad según unidad del movimiento)
			linm_coduni	: Unidad de medida
			linm_canstk	: Cantidad en la unidad de stock
			linm_canalt	: Cantidad según unidad de medida alternativa
			ordl_seqno : wms_inbound_order_line.ordl_seqno

	Se registra 1 Movimiento de stock:
		wms_stkmovs:
			stkm_tabori : wms_inbound_stkmov_head -> tabla de donde proviene el movimiento
			stkm_docori : (wms_inbound_stkmov_head.order_number) en este caso proviene del movimiento de recepcion
			stkm_linori : wms_inbound_stkmov_line.linm_seqno

	Nace en wms_inventory:
		cuenta:	PUBI (Se define en wms_inbound_stkmov_line.linm_cuenta)
		inv_codubi : zona de trabajo(1000) - Se define en wms_inbound_stkmov_line.linm_cuenta
		inv_status : A activo

Al Generar el acta de recepción:
	Se actualiza la orden de recepcion: wms_inbound_order_head
		order_status : P -> T
	Se actualiza la linea de la orden de recepcion wms_inbound_order_line
		ordl_status: P -> C
	Se actualiza el movimiento de entrada: wms_inbound_stkmov_head
		mov_status : E -> T

	Se registra gcommovh y gcommovl (Acta de recepción tipo 10):

	Se actualiza gcompedh:
		estcab : E -> V
		errcab : 25101 -> 0
		wkfcab : 1 -> null

Al 'Envasar y ubicar' Despues de recepcionar:
		
		Se actualiza wms_inbound_stkmov_line:
			linm_loc_qty: 0 > 750 (Ubicado)
		
		Se genera un Movimiento interno (Picking)
			wms_inhouse_stkmov_head:
			wms_inhouse_stkmov_line: 
				linm_ctaori: Cuenta origen
				linm_ctades: cuenta destino
				linm_canmov: Stock en movimiento
				linm_canalt: peso en movimiento
				linm_ubiori: ubicacion origen
				linm_ubides: ubicacion destino
				linm_linori: linm_seqno del movimiento de entrada(Linea) wms_inbound_stkmov_line.linm_seqno
				linm_tabori: tabla origen del movimiento (wms_inbound_stkmov_head - Movimiento de entrada) 
		
		Se crea una tarea de linea del picking(una tarea por cada linea de picking)
			wms_tasks:
				task_type  : UBIC
				task_ctaori: cuenta origen
				task_ctades: cuenta destino
				task_canmov: stock en movimiento
				task_canalt: peso en movimiento
				task_ubiori: ubicacion origen
				task_ubides: ubicacion destino
				task_status: estado de la tarea(4)
				task_tabori: tabla origen del movimiento(linea de Picking: wms_inhouse_stkmov_line)
				linm_seqno : wms_inhouse_stkmov_line.linm_seqno

		Se crean 2 registros(movimientos) 1 de partida y otra de llegada del stock en wms_stkmovs por cada linea de picking wms_inhouse_stkmov_line.linm_seqno
			primer registro wms_stkmovs(donde termina el stock):
				stkm_tabori: tabla origen del movimiento (wms_inhouse_stkmov_head-Picking)
				stkm_docori: Documento origen del movimiento picking : wms_inhouse_stkmov_head.mov_number
				stkm_linori: linea del picking
				stkm_cuenta: Cuenta destino
				stkm_codart: articulo
				stkm_codubi: Ubicacion destino
				stkm_canmov: stock en destino
				stkm_canalt: peso en destino
			
			Segundo registro wms_stkmovs(de donde se quita el stock)
				stkm_tabori: tabla origen del movimiento (wms_inhouse_stkmov_head-Picking)
				stkm_docori: Documento origen del movimiento picking : wms_inhouse_stkmov_head.mov_number
				stkm_linori: linea del picking
				stkm_cuenta: Cuenta origen
				stkm_codart: articulo
				stkm_codubi: Ubicacion origen
				stkm_canmov: Se resta el stock en el origen que fue a destino 
				stkm_canalt: Se resta el peso en el origen
		
		
		wms_inventory: 
			Se inserta el nuevo registro segun el movimiento destino de wms_stkmovs
			Se quita el stock y peso de la cuenta PUBI segun el segundo movimiento de wms_stkmovs 
		
Cambio de ubicacion desde 'Envasar y ubicar':
	Se registra un Movimiento interno picking 
		wms_inhouse_stkmov_head:
	Se registra linea de Movimiento interno picking
		wms_inhouse_stkmov_line
	
	wms_tasks
		task_type: MVUB
		task_ctaori: cuenta origen
		task_ctades: cuenta destino
		task_canmov: stock a mover
		task_canalt: peso en movimiento
		task_ubiori: ubicacion origen
		task_ubides: ubicacion destino
		task_tabori: tabla origen del movimiento (wms_inhouse_stkmov_line) 
		task_linori: wms_inhouse_stkmov_line.linm_seqno  serial de la linea del movimiento de picking

	wms_stkmovs(Se insertan 2 registros el primer registro es el destino y el segundo registro es el origen)
		stkm_tabori: tabla origen (wms_inhouse_stkmov_head -> Movimiento interno de picking)
		stkm_linori: wms_inhouse_stkmov_line.linm_seqno (Linea del movimiento picking)
		stkm_docori: wms_inhouse_stkmov_head.mov_number
		
		stkm_cuenta: cuenta destino para el primer registro y origen para el segundo
		stkm_codubi: ubicacion destino para el primer registro y origen para el segundo
		stkm_canmov: stock positivo para el primer registro ya que es el destino y -Stock para el segundo por ser el origen de donde se extraen
		stkm_canalt: peso destino para el primer registro y peso negativo para el segundo registro ya que es el origen de donde se extrae

	wms_inventory: Se crea nuevo registro con los datos del destino


Al crear un documento de salida de tipo devolucion desde el menu del salida
	Se crea 
		gvenpedh:
			impres: N
			estcab: E
			errcab: 25450
			wkfcab: 1
			docser: codigo del documento de salida
			docori: gcompedh.docser
			auxnum2: gcompedh.refter
		
		gvenpedl:
			estlin: V
			errlin: 0
			indmod: S
			auxchr3: Estado del articulo en este caso NUEVO / BUENO
			auxchr1: Situacion legal en este caso abandono


Al presionar el el boton "Autorizar inicio de salida" del documento de salida:
	Se genera una orden de salida: 
		wms_outbound_order_head: CABECERA DE LA ORDEN DE SALIDA
			order_type: tipo de salida
			order_number: codigo de la orden de salida
			order_tabori: gvenpedh
			order_docori: gvenpedh.docser
			order_status: X Pendiente picking
			order_complete: 1

		wms_outbound_order_line: LINEAS
			ordl_cuenta: PSAL
			ordl_terdep: gvenpedh.docser
			ordl_tabori: gvenpedh
			ordl_status: X Pendiente picking
			ordl_linori: gvenpedl.linid
			ordl_cantid: stock Cantidad pedida
			ordl_canph1: cantidad fase 1 0
			ordl_canext: Pendiente extracción
			ordl_canrea: Cantidad extraída 0
			ordl_reaph1: extraido fase 1
			ordl_canpack: cantidad embalada 0
			ordl_canser: cantidad servida 0
			ordl_return_qty: Cantidad abonada 0
			ordl_tabori: tabla Origen de la orden de salida en este caso gvenpedh
			ordl_factor: Factor 1
			ordl_complete_line: 1

	Se genera 2 movimientos internos
		
		UPEN a PSAL(Generacion de lote) esto se concluye y se deja la linea en estado terminado T
			
			wms_inhouse_stkmov_head:
				mov_status: 
				mov_type: 43(Generacion de lote)
				mov_number: codigo de movimiento
				mov_tabori: gvenpedh
				mov_docori: codigo de lote o documento de salida(gvenpedh.docser)
				mov_emp_code: no tiene

			wms_inhouse_stkmov_line:
				mov_seqno: wms_inhouse_stkmov_head.mov_seqno
				linm_ctaori: cuenta origen
				linm_ctades: cuenta destino
				linm_ubiori: ubicacion origen
				linm_ubides: ubicacion destino igual que el origen
				linm_status: T (terminado)
				linm_emp_code: tiene usuario que le dio click al boton de autorizar inicio de salida
				linm_dateini: tiene fecha
				linm_daterea: tiene fecha

				Se genera un movimiento con 2 registros wms_stkmovs de UPEN A PSAL: (wms_stkmovs tiene 2 registros, el primero es el destino y el segundo el origen de donde se toman lo datos)
					Primer registro DESTINO:
						stkm_docori: wms_inhouse_stkmov_head.mov_number
						stkm_tabori: wms_inhouse_stkmov_head (Picking movimiento interno)
						stkm_cuenta: cuenta destino en este caso PSAL
						stkm_codubi: ubicacion destino en este caso el mismo 2002
						stkm_canmov: stock en destino (positivo)
						stkm_canalt: peso en destino (positivo)
					Segundo registro:
						stkm_docori: wms_inhouse_stkmov_head.mov_number
						stkm_tabori: wms_inhouse_stkmov_head (Picking movimiento interno)
						stkm_cuenta: cuenta origen UPEN
						stkm_codubi: ubicacion origen en este caso el mismo 2002
						stkm_canmov: stock de origen (negativo porque se resta el stock que ya esta en detino)
						stkm_canalt: peso de origen (negativo por que se resta el stock que ya esta en destino)


		PSAL a DISP (Picking)
			wms_inhouse_stkmov_head:
				mov_type: 43 tipo Picking
				mov_number: Codigo del movimiento
				mov_tabori: wms_outbound_order_head
				mov_docori: wms_outbound_order_head.order_number (Orden de salida)
				mov_status: E
			wms_inhouse_stkmov_line:
				linm_ctaori: cuenta origen PSAL
				linm_ctades: cuenta destino DISP
				linm_canpro: cantidad propuesta para salida(es el stock del articulo en lote)
				linm_canmov: No tiene
				linc_terdep: tiene codigo del documento de salida (gvenpedh.docser)
				linm_ubiori: ubicacion origen
				linm_ubides: ubicacion destino zona 1000
				linm_status: E (Pendiente - picking iniciado)
				linm_tabori: wms_outbound_order_head tabla de orden de salida
				linm_linori: id de la linea de la orden de salida wms_outbound_order_line.ordl_seqno
				linm_emp_code: no tiene
				linm_dateini: no tiene
				linm_daterea: no tiene

				*Aun no se genera el movimiento de picking que pasara de PSAL a DISP*
					Pero quedan 2 tarea pendiente en wms_tasks el primero con tipo de operacion 3 Transaccion y el segundo con tipo de operacion 9 Bajar articulo, ambas tareas pertenecen a la misma linea de movimiento:
					Primer registro:
						task_type: PVUB
						task_ctaori: cuenta origen PSAL
						task_ctades: cuenta destino DISP
						task_canmov: Cantidad diferente de cero
						task_canalt: null
						task_ubiori: ubicaicon origen 2002
						task_ubides: ubicacion destino 1000
						task_terdep: codigo de documento de salida gvenpedh.docser
						task_emp_code: null
						task_ope_type: 9
						task_status: 1 Pendiente
						task_reference: codigo de documento de salida
						task_tabori: origen de la tarea en este caso wms_inhouse_stkmov_line linea de movimiento de picking
						task_docori: wms_inhouse_stkmov_head.mov_number
						task_linori: wms_inhouse_stkmov_line.linm_seqno
					Segundo registro:
						task_type: PMVB
						task_ctaori: PSAL
						task_ctades: PSAL
						task_canmov: cantidad diferente de cero
						task_canalt: null
						task_ubiori: 1000
						task_ubides: 1000
						task_terdep: Documento de salida
						task_emp_code: null
						task_ope_type: 3
						task_status: 0 En espera
						task_reference: codigo de documento de salida
						task_tabori: tabla origen  de la tarea en este caso del movimiento wms_inhouse_stkmov_line
						task_docori: wms_inhouse_stkmov_head.mov_number
						task_linori: wms_inhouse_stkmov_line.linm_seqno

	Se genera una orden de recuento OINS
		wms_count_order_head:
			count_type: OINS
			count_number: codigo de la orden de recuento
			count_status: 3 Cerrado
			req_number: No tiene peticion porque es una orden de recuento interna para que el stock nazca con lote

		wms_count_order_line: (Genera 2 lineas con orden de ejecucion 1 y 2)
			Primera linea: se resta stock y peso (practicamente se mata el articulo)
				linc_ordexe:1
				linc_codubi: ubicacion del articulo
				linc_cuenta: cuenta actual PSAL
				linc_terdep: no tiene
				linc_stkact: stock actual en la ubicacion y cuenta
				linc_stkaux: peso actual en la ubicacion y cuenta
				linc_canrec: cantidad a la que fue recontada, en este caso a cero 0
				linc_altrec: Peso a la que fue recontado, en este caso a cero 0
				linc_ini_stkact: Stock inicial antes de recontar
				linc_ini_stkaux: Peso inicial antes de recuento
				linc_status: 4 Procesada con ajuste
			Segunda linea en orden de ejecucion (practicamente se vuelve a revivir el stock pero ahora comprometido con un lote)
				linc_ordexe: 2
				linc_codubi: ubicacion en este caso igual que el anterior
				linc_cuenta: cuenta igual que el anterior para este caso
				linc_terdep: Codigo de lote gvenpedh.docser
				linc_stkact: Stock 0 porque en la anterior linea se reconto a cero
				linc_stkaux: Peso cero porque en la anterior linea se reconto a cero
				linc_canrec: Cantidad recontada, en este caso con el stock que habia, entonces se revive el stock ahora en lote
				linc_altrec: Peso recontado con el mismo que tenia, entonces se revive el peso que tenia antes del primer recuento OINS
				linc_ini_stkact: Stock inicial en este caso cero porque se mato el stock en el recuento anterior
				linc_ini_stkaux: Peso cero en este caso porque en el anterior recuento se reconto a cero y asi se encontro para este recuento
				linc_status: 4 Procesada con ajuste

			
			Se crean 2 Movimientos de recuento de stock en wms_stkcount una para cada linea de wms_count_order_line (Lineas de la orden de recuento)
				Primera Linea:
					linc_seqno: wms_count_order_line.linc_seqno
					count_number: wms_count_order_head.count_number
					linc_cuenta: PSAL
					inv_terdep: no tiene
					inv_codubi: ubicacion actual
					inv_canmov: Cantidad de stock 0
					inv_stkact: stock actual difente a cero
					inv_canalt: 0
					inv_stkaux: stock auxiliar diferente a cero

				Segundo registro:
					linc_seqno: wms_count_order_line.linc_seqno
					count_number: wms_count_order_head.count_number
					inv_cuenta: PSAL 
					inv_terdep: Codigo de documento de salida
					inv_codubi: Misma ubicacion 2002
					inv_canmov: cantidad de stock diferente a cero
					inv_stkact: Stock actual
					inv_canalt: peso diferente a cero
					inv_stkaux: peso auxiliar cero

	Se muestra la distribucion de stock en wms_inventory:
		UPEN -> PSAL stock y peso 0
		PSAL: Stock y peso en la misma ubicacion con inv_terdep y inv_stksal = el stock que se encuentra con tarea de movimiento de picking por completar ya que hay una tarea pendiente y otra en espera
		DISP: tiene terdep en la ubicacion 1000 sin stock ni peso pero con inv_stkent que es el stock que se encuentra pendiente de completar el movimiento de picking


Al cambiar el representante:
	se actualiza gvenpedh:
		auxchr3: de nulo a 4
		auxchr4: de nulo a numeor de ruc del representante

Al finalizar picking
	Actualizacion en la orden de salida wms_outbound_order_head:
		order_first_launch: con fecha a sin fecha
		order_status: X -> L
	Actualizacion de la linea de la orden de salida wms_outbound_order_line
		ordl_canext: con stock a  0
		ordl_canrea: pasa de stock 0 a tener el contenido de ordl_canext
		ordl_status: X -> L

	Actualizacion de la cabecera de la orden del picking wms_inhouse_stkmov_head:
		mov_status: E -> D

	Nuevo registro wms_inhouse_stkmov_head:
		mov_number: codigo de picking
		mov_status: T
		mov_tabori: no tiene
		mov_docori: no tiene
		mov_zonlog: no tiene
		mov_subzon: no tiene
		mov_status: T
		mov_emp_code: usuario de sesion xsql
		user_created y updated: admsia

		Nuevo movimiento de stock en wms_stkmovs con 2 registros:
			Primer registro Destino:
				stkm_tabori: wms_inhouse_stkmov_head
				stkm_docori: wms_inhouse_stkmov_head.mov_number (Padre)
				stkm_cuenta: PSAL
				stkm_terdep: Documento de salida 
				stkm_codubi: Ubicacion destino que se pone en el field al finalizar picking
				stkm_canmov: positivo porque es el destino
				stkm_canalt: positivo porque es el destino del stock
			Segundo registro Origen:
				stkm_tabori: wms_inhouse_stkmov_head
				stkm_docori: wms_inhouse_stkmov_head.mov_number (Padre)
				stkm_cuenta: PSAL
				stkm_terdep: Documento de salida 
				stkm_codubi: Ubicacion 2002 el anterior
				stkm_canmov: negativo porque es el destino
				stkm_canalt: negativo porque es el destino del stock

				
	Actualizacion de la linea de picking: wms_inhouse_stkmov_line:
		linm_canmov: ya tiene stock
		linm_ubiori: 1099
		linm_ubides: 1099
		linm_status: D
		linm_ctaori:PSAL
		linm_ctades:DISP
		linm_tabori: wms_outbound_order_head
		linm_linori: wms_outbound_order_line.ordl_seqno
		
		Actualizacion de Tarea wms_tasks
			task_linori:wms_inhouse_stkmov_line.linm_seqno (Para ambas tareas)

			Primera tarea:
				task_type:PVUB
				task_ubides: 1099 ubicacion en field de finalizar picking
				task_emp_code: se completa
				task_start: se completa
				task_end: se completa
				task_status: 4 Cerrado
				task_ope_type:9
				task_reference: Documento de salida
				task_tabori:wms_inhouse_stkmov_line
				task_docori: wms_inhouse_stkmov_head.mov_number
			Segundo registro:
				task_type:PMVB
				task_ubiori: 1099 ubicacion desde el field de finalizar picking
				task_ubides: misma ubicacion del field
				task_ope_type:3
				task_start: se completa
				task_end: se completa
				task_status: 4 Cerrado
				task_reference: Documento de salida
				task_tabori:wms_inhouse_stkmov_line
				task_docori: wms_inhouse_stkmov_head.mov_number

		Nuevo movimiento de stock en wms_stkmovs con 2 registros uno para cada tarea:
			Primer registro Destino:
				stkm_linori:wms_inhouse_stkmov_line.linm_seqno
				stkm_tabori: wms_inhouse_stkmov_head
				stkm_docori: wms_inhouse_stkmov_head.mov_number (Padre)
				stkm_cuenta: PSAL
				stkm_terdep: Documento de salida 
				stkm_codubi: Ubicacion destino que se pone en el field al finalizar picking
				stkm_canmov: positivo porque es el destino
				stkm_canalt: positivo porque es el destino del stock
				stkm_docori: wms_inhouse_stkmov_head.mov_number
			Segundo registro Origen:
				stkm_linori:wms_inhouse_stkmov_line.linm_seqno
				stkm_tabori: wms_inhouse_stkmov_head
				stkm_docori: wms_inhouse_stkmov_head.mov_number (Padre)
				stkm_cuenta: PSAL
				stkm_terdep: Documento de salida 
				stkm_codubi: Ubicacion 2002 el anterior
				stkm_canmov: negativo porque es el destino
				stkm_canalt: negativo porque es el destino del stock
				stkm_docori: wms_inhouse_stkmov_head.mov_number

	Nuevo registro en linea de picking: wms_inhouse_stkmov_line
		mov_seqno: wms_inhouse_stkmov_head.mov_seqno
		linm_ctaori: PSAL
		linm_ctades: PSAL
		linm_canpro: null
		linm_canmov:contiene stock
		linm_terdep: gvenpedh.docser - documento de salida
		linm_canalt: peso
		linm_ubiori: 2002
		linm_ubides: 1099 zona de trabajo
		linm_status: T
		linm_tabori: no tiene
		linm_linori: not tiene
	
	wms_inventory (Como termina el stock):
		inv_cuenta: DISP
		inv_terdep: Documento de salida


BRE-TEST-BH25-XXXXXX

SELECT * FROM ctipodir;
SELECT * FROM galmacen WHERE codigo = '974';
SELECT * FROM wms_inbound_rules_head WHERE rule_recint = '974';
SELECT * FROM galmreci WHERE codigo = '974';
SELECT * FROM cper_delegac WHERE codigo = 'GDA';
SELECT * FROM ctipodir;
SELECT * FROM cterdire;
SELECT * FROM gdelegac WHERE codigo = 'GDA';
SELECT * FROM gdeparta WHERE delega = 'GDA';
SELECT * FROM galmubic WHERE codalm = '974';
SELECT * FROM glog_alm_subzon WHERE subz_recint='974';
SELECT * FROM wms_task_rules_head WHERE rule_code matches'370*';
SELECT * FROM wms_task_rules_filter WHERE  rfilt_recint = '974';
SELECT * FROM wms_outbound_rules_head WHERE rule_code matches'974*';
SELECT * FROM wms_outbound_rules_line WHERE rule_code matches'974*';
SELECT * FROM wms_task_rules_line WHERE rule_code matches'974*';
SELECT * FROM galmdele WHERE codalm = '974';
SELECT * FROM gusergrp;
SELECT * FROM guserdefs;
SELECT * FROM sun_reglaubi_asignada WHERE codalm = '974';
