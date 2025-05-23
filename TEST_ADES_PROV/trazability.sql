Numero Acta: BRE-ADES-0001-XXXXXX
articulo: 0000000221668

Registro del documento de origen
    gcompedh:
        tipdoc: AN (Acta de incautacion)
        docser: codido de 'Documento interno'
        tercer: almacen
        impres: N
        estcab:E
        errcab:0
        wkfcab:null
        imptot:0
        impant:0
        codcom: supervisor
        indmod:S
        auxchr1:
    gcompedl:
        cabid: gcompedh.cabid
        canped: cantidad de stock recibido
        canalt: peso
        impnet: valor total (stock por valor unitario)
        estlin: E
        errlin: 25103
        wkflin: 1
        indmod: S
        regalo: N
        auxnum3: supervisor

Se registra el o los articulos en garticul:
    lotes: N
    stock: S
    estado:A
    relvar:1
    codfam: familita MEF
    clamed:N
    desvar:F
    expvl:N
    vencom:N
    indser:N
    difalb:N
    vendir:0
    indmod:S
    auxchr4: documento de consignatario (gcompedh.auxchr2)
    auxchr5:gcompedh.refter
    auxfec2:
    auxnum1:1
    auxnum3:gcompedl.auxnum1(Peso en kg unitario redondeado a 4 decimales)
    cabped:gcompedh.cabid (referencia al documento de origen)

Al presionar en el boton de autorizar en detalle de articulos en el documento de origen
    Se actualiza el documento de origen y sus lineas:
        gcompedh:
            errcab: 0 -> 25101
            wkfcab: null -> 1
            imptot: 0 -> Valor total
            user_updated: admsia -> user xsql
        gcompedl:
            estlin: E -> V
            errlin: 25103 -> 0
    Se registra una orden de recepcion (wms_inbound_order_head):
        order_number: codigo de la orden de recepcion
        order_tabori: tabla origen en este caso gcompedh
        order_docori:gcompedh.docser
        order_ref_number:gcompedh.refter
        order_status:P
    
        Se registra la linea de la orden de recepion (wms_inbound_order_line):
            order_seqno: wms_inbound_order_head.order_seqno
            ordl_codart: codigo de articulo
            ordl_cantid: cantidad de stock
            ordl_canalt: peso
            ordl_canrec: cantidad de stock
            ordl_docori: gcompedh.docser
            ordl_linori: gcompedl.linid
            ordl_status: P
            ordl_priori: 99
    
    Se registra un movimiento de entrada (wms_inbound_stkmov_head):
        mov_type:02
        mov_number: wms_inbound_order_head.order_number
        order_number: wms_inbound_order_head.order_number
        mov_status: E
        send_erp:0

        Se registra la linea del movimiento (wms_inbound_stkmov_line):
            mov_seqno: wms_inbound_order_head.mov_seqno
            linm_cuenta: PUBI
            linm_canmov: STOCK
            linm_canstk:STOCK
            linm_canalt:peso
            linm_codubi: ubicacion 1000 zona de recepcion del almacen
            linm_actstk:1
            ordl_seqno:wms_inbound_order_line.ordl_seqno
            linm_status: E
            
    Se registra un movimiento de stock wms_stkmovs proveniente del movimiento de entrada wms_inbound_stkmov_head
        stkm_tabori: tabla de donde proviene el movimiento (wms_inbound_stkmov_head)
        stkm_docori: Referencia al Documento de la orden de recepcion(wms_inbound_order_head.order_number)
        stkm_linori: Referencia a la linea del movimiento de entrada (wms_inbound_stkmov_line.linm_seqno)
        stkm_cuenta: PUBI
        stkm_codubi: 1000
        stkm_canmov: STOCK
        stkm_canalt: PESO
    
    Nace en wms_inventory:
        inv_cuenta:PUBI
        inv_codubi:1000
        inv_stkact: STOCK
        inv_stkaux: PESO

Al generar el acta de recepcion:
    Se actualiza la cabecera del documento de origen gcompedh:
        estcab: E -> V
        errcab: 25101 -> 0
        wkfcab: 1 -> 0

    Se actualiza la orden de recepcion 
        wms_inbound_order_head:
            order_status: P -> T

        wms_inbound_order_line:
            ordl_status: P -> C
    Se actualiza la cabecera del movimiento de entrada (wms_inbound_stkmov_head):
        mov_status: E -> T
    
    Se genera el documento de recepcion(Acta de recepcion)
        gcommovh:
            tipdoc: 10
            impres: N
            estcab: V
            tipefe: '01'
            direnv:39
            refter: gcompedh.refter
            docori: gcompedh.docser
            imptot: valor total
            portes: D
            valstk:N
            indmod:S
        gcommovl:
            canmov: stock
            canalt: peso
            estlin: V
            ubiori: 1000
            auxchr2: gcompedl.auxchr2

Al envasar y ubicar
    Se actualiza la linea del movimiento de entrada (wms_inbound_stkmov_line):
        linm_loc_qty: stock Ubicado
    Se registra un movimiento interno 
        mov_type: 48 Ubicar bienes sin propuesta
        mov_number: Codigo del movimiento interno
        mov_status: E

        Se registra la linea del movimiento interno (wms_inhouse_stkmov_line)
            linm_ctaori: cuenta origen PUBI
            linm_ctades: cuenta destino
            linm_canmov: stock en movimiento
            linm_canalt: peso en movimiento
            linm_ubiori: ubicacion origen
            linm_ubides: ubicacion destino
            linm_status: T
            linm_tabori: tabla origen de donde proviene la creacion de este movimiento interno  par este caso proviene del movimiento de entrada(wms_inbound_stkmov_head)
            linm_linori: wms_inbound_stkmov_line.linm_seqno
            linm_inhibit_ind: 0

            Se crea una tarea en wms_tasks para la linea del movimiento interno (wms_inhouse_stkmov_line):
                task_type: UBIC
                task_ctaori: cuenta origen PUBI
                task_ctades cuenta destino UPEN
                task_canmov: cantidad de stock
                task_canalt: peso
                task_ubiori: ubicacion origen
                task_ubides: ubicacion destino
                task_ope_type: 6 
                task_status: 4 
                task_tabori: tabla origen de donde proviene esta tarea(wms_inhouse_stkmov_line)
                task_linori: Hace referencia a la linea del movimiento de donde proviene esta tarea : wms_inhouse_stkmov_line.linm_seqno
            
            Se registra en movimiento en wms_stkmovs(Se registran 2 Movimientos uno de destino y otro de origen):
                El primer registro es de destino:
                    stkm_tabori: tabla origen del movimiento en este caso el movimiento interno (wms_inhouse_stkmov_head)
                    stkm_linori: Referencia a la linea del movimiento wms_inhouse_stkmov_line.linm_seqno
                    stkm_cuenta: UPEN ya que este es el registro de destino
                    stkm_codubi: ubicacion destino
                    stkm_canmov: stock en destino
                    stkm_canalt: peso en destino
                El segundo registro es el origen:
                    stkm_tabori: tabla origen del movimiento en este caso el movimiento interno (wms_inhouse_stkmov_head)
                    stkm_linori: Referencia a la linea del movimiento wms_inhouse_stkmov_line.linm_seqno
                    stkm_cuenta: PUBI ya que este es el registro de origen donde se encontraba el stock
                    stkm_codubi: ubicacion origen de donde se retira el stock
                    stkm_canmov: stock en origen de donde se retira el stock(negatio)
                    stkm_canalt: peso en origen de donde se terira el peso(negatio)

                
                Nace en wms_inventory:
                    inv_cuenta: UPEN
                    inv_stkact:  wms_stkmovs.stkm_canmov
                    inv_codubi: wms_stkmovs.stkm_codubi
                    inv_cuenta: wms_stkmovs.stkm_cuenta
                Se actualiza el registro origen a 0 el stock y peso

Al mover articulo a otra ubicacion:
    Se genera un movimiento interno  (wms_inhouse_stkmov_head):
        mov_type: 51
        mov_number: Codigo del movimiento interno
        mov_status:E
        mov_emp_code: mi usuario

        Se genera la linea del movimiento interno (wms_inhouse_stkmov_line):
            linm_ctaori: cuenta origen UPEN
            linm_ctades: cuenta destino UPEN
            linm_canmov: stock en movimiento
            linm_canalt: peso en movimiento
            linm_ubiori: ubicacion origen
            linm_ubides: ubicacion destino
            linm_status: T
            linm_tabori: vacio (El movimiento no tiene una orden)
            linm_linori: vaio (El movimiento no tiene una orden)
            
            Se crea una tarea en wms_tasks proveniente de la linea del movimiento interno (wms_inhouse_stkmov_line)
                task_type: MVUB
                task_ctaori: cuenta origen
                task_ctades: cuenta destino
                task_canmov: cantidad en movimiento
                task_canalt: peso en movimiento
                task_ubiori: ubicacion origen
                task_ubides: ubicacion destino
                task_ope_type: 3
                task_status: 4
                task_tabori: tabla origen de esta tarea (wms_inhouse_stkmov_line)
                task_linori: Referencia a la linea del movimiento interno (wms_inhouse_stkmov_line.linm_seqno)

                Para esta tarea se registran los movimientos de stock en wms_stkmovs:
                    Primer Movimiento de stock (destino):
                        stkm_tabori: Movimiento interno (wms_inhouse_stkmov_head)
                        stkm_docori: Codigo del movimiento interno (wms_inhouse_stkmov_head.mov_number)
                        stkm_linori: Referencia a la linea del movimiento interno (wms_inhouse_stkmov_line.linm_seqno)
                        stkm_codubi: ubicacion destino
                        stkm_canmov: stock en destino
                        stkm_canalt: peso en destino
                    Segundo Movimiento de stock (origen):
                        stkm_tabori: Movimiento interno (wms_inhouse_stkmov_head)
                        stkm_docori: Codigo del movimiento interno (wms_inhouse_stkmov_head.mov_number)
                        stkm_linori: Referencia a la linea del movimiento interno (wms_inhouse_stkmov_line.linm_seqno)
                        stkm_codubi: ubicacion origen
                        stkm_canmov: stock en origen(negatio)
                        stkm_canalt: peso en origen(negatio)
                        
                    
Al seleccionar por acta en 'Asignar documento de seguimiento':

    Se genera un documento de seguimiento (sun_gcompedh_memorandum):
        cabid: referencia al documento de origen gcompedh.cabid
        numdoc_seg: codigo del documento de seguimiento
        version: 0
        tipo: 06
        estado:S
        tipdoc_ref: 270
        areemi_ref:000ADS
        anodoc_ref: año del documento
        numdoc_ref: numero de documento(Aqui si admite  6 o mas caracteres)

        Se genera la linea del documento de seguimiento (sun_gcompedh_memorandum_item):
            seqno: sun_gcompedh_memorandum.seqno
            cantini: Stock
            cantidad: stock
            peso: peso
            dispon: E


        Se registra en disposicion (sun_ins_prelote_user):
            accion: 13
            ctaori: UPEN (Ultima cuenta en inventory)
            canact: Stock
            canalt: peso
            user_prelote: my user
            cabdes: gcompedh.cabid
            cantid: stock
            peso: peso
            nodisp: S
            valor: valor unitario
            seqdoc: Referencia al documento de seguimiento (sun_gcompedh_memorandum.seqno)
            acta_disp: Codigo del documento de seguimiento (sun_gcompedh_memorandum.numdoc_seg)
            tipdoc_ref: 270
            areemi_ref:000ADS
            anodoc_ref: año que se pone en el field
            numdoc_ref: numero de documento(revisar si el campo tiene solo  5 caracteres )
            respon: my user

Asignando base y situacion legal antes de pase a autorizar:
    Actualizacion del documento de seguimiento (sun_gcompedh_memorandum):
        basleg: base legal seleccionada
        estleg: situacion legal seleccionada

Click en pase a autorizar:
    Se actualiza el maestro de articulos garticul:
        auxchr1: 09  ->  01

    Se actualiza el documento de seguimiento sun_gcompedh_memorandum:
        estado: S -> C

    Se actualiza la disposicion sun_ins_prelote_user:
        accion: 13 -> 1
        ctaori: cuenta origen UPEN  -> UDIS
        date_cerrar: today
        fecha_disp: date(today)

    Se agrega el primer registro al historico de disposicion (sun_hist_disposicion):
        docser: gcompedh.refter
        ctaori: cuenta origen al entrar a disposicion UPEN
        ctades: cuenta destino UDIS
        stkact: stock
        cantid: stock
        stkaux: peso
        peso: peso
        estfis: 10
        acta_disp: Referencia al codigo del documento de seguimiento (sun_gcompedh_memorandum.numdoc_seg)

    Se crea un movimiento interno
        mov_type:41
        mov_number: Codigo del movimiento interno
        mov_emp_code: null

        Linea del movimiento interno (wms_inhouse_stkmov_line):
            linm_ctaori: cuenta origen  UPEN
            linm_ctades: cuenta destino UDIS
            linm_canmov:stock
            linm_ubiori: ubicacion origen
            linm_ubides:ubicacion destino
            linm_status: T
            linm_tabori:null


            Se crean 2 registros de movimiento en wms_stkmovs
                El primero es de destino:
                    stkm_tabori: proviene de(wms_inhouse_stkmov_head)
                    stkm_docori: Codigo de movimiento interno wms_inhouse_stkmov_head.mov_number
                    stkm_linori: Referencia a la linea de movimiento interno (wms_inhouse_stkmov_line.linm_seqno)
                    stkm_codubi: ubicacion
                    stkm_canmov: stock
                    stkm_canalt: peso
                El segundo es el origen:
                    stkm_tabori: proviene de(wms_inhouse_stkmov_head)
                    stkm_docori: Codigo de movimiento interno wms_inhouse_stkmov_head.mov_number
                    stkm_linori: Referencia a la linea de movimiento interno (wms_inhouse_stkmov_line.linm_seqno)
                    stkm_codubi: ubicacion
                    stkm_canmov: stock(negativo)
                    stkm_canalt: peso(negativo)
        Nace en wms_inventory:
            inv_cuenta: UDIS
            inv_codubi: 1002
            inv_stkact: stock
            inv_stkaux: peso
            