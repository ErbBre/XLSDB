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
        fecha_disp: no tiene
        acta_disp: Referencia al codigo del documento de seguimiento (sun_gcompedh_memorandum.numdoc_seg)
        motivo: Autorizar documento de seguimiento
        

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

Seleccionar articulo para propuesta de lote:
    Se registra un movimiento interno (wms_inhouse_stkmov_head):
        mov_type: 42
        mov_number: codigo de Documento del movimiento interno
        mov_status:E

        Se registra linea del movimiento interno (wms_inhouse_stkmov_line):
            linm_ctaori: cuenta origen UDIS
            linm_ctades: cuenta destino ADES
            linm_canmov:stock
            linm_canalt: peso en movimiento
            linm_ubiori: ubicacion origen 1002
            linm_ubides: ubicacion destino
            linm_status: T
            linm_tabori: null
          
            Se registra los movimientos de stock en wms_stkmovs :
                Primer registro de destino:
                    stkm_tabori: Tabla de la cabecera del movimiento interno (wms_inhouse_stkmov_head)
                    stkm_docori: wms_inhouse_stkmov_head.mov_number
                    stkm_linori: wms_inhouse_stkmov_line.linm_seqno
                    stkm_cuenta: cuenta destino ADES
                    stkm_codubi: ubicacion destino
                    stkm_canmov: stock en destino
                    stkm_canalt: peso en destino

                Segundo registro de origen:
                    stkm_tabori: Tabla de la cabecera del movimiento interno (wms_inhouse_stkmov_head)
                    stkm_docori: wms_inhouse_stkmov_head.mov_number
                    stkm_linori: wms_inhouse_stkmov_line.linm_seqno
                    stkm_cuenta: cuenta origen UDIS
                    stkm_codubi: ubicacion origen
                    stkm_canmov: stock en origen
                    stkm_canalt: peso en origen

                
                Nace en la nueva ubicacion y cuenta en wms_inventory:
                    Se quita el stock y peso de la ubicacion y cuenta origen
                    Se agrega un nuevo registro con las indicaciones del movimiento de stock destino

    Se inserta un registro historico en sun_hist_disposicion:
        docser: gcompedh.refter
        ctaori: cuenta origen
        ctades: cuenta destino
        stkact: stock en movimiento
        cantid: stock
        stkaux: peso en movimiento
        peso: peso
        estfis: 10
        acta_disp: Documento de seguimiento(sun_gcompedh_memorandum.numdoc_seg) 
        fecha_disp: tiene
        resp_lote: my user
        motivo: Dispuesto para generar el prelote

    Se actualiza el registro en disposicion (sun_ins_prelote_user):
        accion: 1 -> 4
        ctaori UDIS  ->  ADES
        date_asignar: fecha today
        destin: null -> C
        acta_disp: Documento de seguimiento (sun_gcompedh_memorandum.numdoc_seg)
        observ: mensaje que se inserta en el field(btn seleccionar Articulos para propuesta de lote)

A este punto el articulo se encuentra con documento de seguimiento en la parte inferior de pasar a disposicion en la seccion de destruccion listo para generar el prelote

Prelote Generado:
    Se genera el documento de salida(lote):
        gvenpedh:
            tipdoc:24
            depart:0
            tipdir:39
            impres:N
            estcab:E
            wkfcab:9999
            errcab:1
            tipefe:'01'
            frmpag:000
            direnv:0
            dirfac:0
            imptot: importe total
            imppen: importe neto
            entpar:S
            adjpar:S
            portes:D
            metfac:A
            indmod:S
            auxnum4:1
        gvenpedl:
            varlog:0
            canped: stock actual
            canalt: peso
            impnet: importe neto
            estlin:E
            errlin:25400
            indmod:S
            regalo:N
            auxchr1:'01'
            auxchr3:'10'
    
    Se registra el historico de disposicion (sun_hist_disposicion):
        docser: gcompedh.refter
        ctaori: cuenta origen
        ctades: cuenta destino
        stkact: stock
        cantid: stock
        stkaux: peso
        peso:peso
        numlot: Aqui se inserta la primera vez el documento de salida o lote(gvenpedh.docser)
        acta_disp: Codigo de documento de disposicion(sun_gcompedh_memorandum.numdoc_seg)
        resp_lote: null
        motivo: prelote generado
        fecha_disp: fecha del registro (Articulo dispuesto para generar el prelote)
    
    Se actualiza disposicion (sun_ins_prelote_user):
        accion: 4 -> 5
        date_asignar: today
        date_cerrar: today
        cabdes: gcompepdh.cabid -> gvenpedh.cabid
        lindes: null -> gvenpedl.linid
        valida: 0 -> 1
        

Validar prelote (Se genera la orden de picking para el almacen):
    Se actualiza el lote o documento de salida:
        gvenpedh:
            send_wms: 0 -> 1
        gvenpedl: (No se actualiza el campo date_updated a pesar de haber actualizado un campo)
            errlin:25400


    Se inserta un nuevo registro historico de disposicion (sun_hist_disposicion):
        docser: gcompedh.refter
        ctaori: cuenta origen ADES
        ctades: cuenta destino PSAL
        stkact: stock
        cantid: stock
        stkaux: peso
        peso:peso
        numlot: Codigo de lote (gvenpedh.docser)

    Se crea el primer (1) movimiento interno(Pasa el stock a PSAL pero aun sin terdep, documento de salida o lote)
        wms_inhouse_stkmov_head (Cabecera del movimiento interno):
            mov_type: 43 (Generación de lote) en PSAL        
            mov_number: Codigo de movimiento
            mov_tabori: Origen del movimiento: documento de salida (gvenpedh)
            mov_docori: Codigo del lote o documento de salida que se esta generando
            mov_status: E

            wms_inhouse_stkmov_line (Linea del movimiento interno):
                linm_ctaori: cuenta origen ADES
                linm_ctades: Cuenta destino PSAL
                linm_canpro: null
                linm_canmov: stock 
                linm_terdep: null
                linm_canalt: peso
                linm_ubiori: ubicacion origen
                linm_ubides: ubicacion destino
                linm_status: T
                linm_done: 1
                
                Se crea los el registro de movimiento origen y destino:
                    wms_stkmovs:
                        Registro de destino:
                            stkm_tabori: wms_inhouse_stkmov_head
                            stkm_linori:wms_inhouse_stkmov_line.linm_seqno
                            stkm_cuenta: cuenta destino PSAL
                            stkm_codubi: ubicacion destino
                            stkm_canmov: stock en movimiento (positivo)
                            stkm_canalt: peso en movimiento (positivo)

                        Registro que quita el stock en el origen
                            stkm_tabori: wms_inhouse_stkmov_head
                            stkm_linori:wms_inhouse_stkmov_line.linm_seqno
                            stkm_cuenta: cuenta origen ADES
                            stkm_codubi: ubicacion origen
                            stkm_canmov: stock en movimiento 0
                            stkm_canalt: peso en movimiento 0
    
    Se trazpasa el stock al documento de salida
    Se crea una orden de recuento OINS para establecer Documento de salida en el registro de stock de los articulos (wms_count_order_head) Orden de recuento:
        count_type: OINS
        count_number: codigo de la orden de recuento interna
        count_status:3

        wms_count_order_line (Linea de la orden de recuento: se generan 2 lineas con su respectiva numeracion de ejecucion)
            Prinera linea: se resta el stock y peso(practicamente mata el stock del registro actual en el wms_inventory)
                linc_ordexe: 1
                linc_codubi: ubicacion actual
                linc_cuenta: cuenta actual PSAL
                linc_terdep: null
                linc_stkact: stock
                linc_stkaux: peso
                linc_canrec: cantidad recontada = 0
                linc_altrec:0
                linc_ini_stkact: stock
                linc_ini_stkaux: peso
                linc_status: 4
            Segundo registro (Aqui se revive el stock ahora comprometido con un lote)
                linc_ordexe: 2
                linc_codubi: misma ubicacion de la linea 1
                linc_cuenta: misma CUENTA
                linc_terdep: Ahora se le asigna un lote
                linc_stkact: 0
                linc_stkaux: 0
                linc_canrec: cantidad recontada = stock que se reconto a cero en la primera linea para poder revivirlo
                linc_altrec: cantidad de peso recontado = mismo peso que se mato en la primera linea
                linc_ini_stkact: 0
                linc_ini_stkaux: 0
                linc_status: 4


            Se crean 2 movimientos  de recuento de stock en wms_stkcount una para cada linea de wms_count_order_line
                Primer registro (Movimiento de la orden de recuento)
                    count_number: wms_count_order_head.count_number
                    linc_seqno: Referencia a la linea de la orden de recuento (wms_count_order_line.linc_seqno)
                    inv_cuenta: PSAL
                    inv_terdep: null
                    inv_codubi: ubicacion actual
                    inv_canmov: 0
                    inv_stkact: stock actual
                    inv_canalt: 0
                    inv_stkaux:peso actual

                Segundo registro (Movimiento de la orden de recuento)
                    count_number: wms_count_order_head.count_number
                    linc_seqno: Referencia a la linea de la orden de recuento (wms_count_order_line.linc_seqno)
                    inv_cuenta: PSAL
                    inv_terdep: Ahora se le asigna el documento de salida
                    inv_codubi: misma ubicacion inicial de la anterior linea
                    inv_canmov: cantidad de stock
                    inv_stkact: 0
                    inv_canalt: peso diferente a cero
                    inv_stkaux: peso auxiliar cero 

                Se registran 2 movimientos de Stock (wms_stkmovs) Aqui la logica es a la inversa, primero se quita el stock de la cuenta que no tiene documento de salida y se le asigna todo en el segundo registro
                    Primer registro:
                        stkm_tabori: tabla origen wms_stkcount (Movimiento de linea de orden de recuento)
                        stkm_docori: null no tiene
                        stkm_linori: Referencia al movimiento de la orden (wms_stkmovs.inv_seqno)
                        stkm_cuenta: PSAL
                        stkm_terdep: no tiene
                        stkm_codubi: ubicaicon actual
                        stkm_canmov: cantidad de stock quitado(negativo)
                        stkm_canalt: cantidad de peso quitado(negativo)
                    Primer registro:
                        stkm_tabori: tabla origen wms_stkcount (Movimiento de linea de orden de recuento)
                        stkm_docori: null no tiene
                        stkm_linori: Referencia al movimiento de la orden (wms_stkmovs.inv_seqno)
                        stkm_cuenta: PSAL
                        stkm_terdep: Aqui se asigna el documento de salida o lote
                        stkm_codubi: ubicaicon actual
                        stkm_canmov: Aqui se inserta el stock que se quito en el registro anterior(positivo)
                        stkm_canalt: Aqui se inserta el peso que se retiro en el registro anterior(positivo)
    
    Aqui existen tareas de picking pendiente
    Se crea el segundo (2) movimiento interno y este es de picking (PSAL -> DISP), Este proviene de una orden de salida:
        Se crea la orden de salida (wms_outbound_order_head):
            order_type:24 (Orden de picking para destruccion)
            order_number: Codigo de la orden de salida
            order_tabori: Tabla origen de la orden, en este caso gvenpedh ya que esta orden se origina por salida de lote
            order_docori: Documento de salida a este punto los articulos en wms_inventory ya se encuentran con terdep ya que se les asigno en el movimiento anterior gvenpedh.docser
            order_status: X
            order_complete: 1

            wms_outbound_order_line(Linea de orden de salida): 
                ordl_cuenta: cuenta PSAL(Ya se encuentran en PSAL antes estaban en ADES pero el movimiento interno a este lo asigno al lote o documento de salida)
                ordl_terdep: documento de salida
                ordl_cantid: stock
                ordl_canext: stock
                ordl_tabori: tabla origen en este caso gvenpedh
                ordl_docori: Referencia al documento de salida (gvenpedh.docser)
                ordl_linori: Referencia a la linea del documento de salida (gvenpedl.linid)
                ordl_complete_line: 1
                ordl_status: X

                wms_inhouse_stkmov_head (Se genera el movimiento interno. Este movimiento interno aún no genera el registro de movimientos en wms_stkmovs se continuará al finalizar picking):
                    mov_type: 46 Picking
                    mov_number: Codigo de este registro o documento
                    mov_tabori: tabla en cual origina este movimiento interno en este caso una orden de salida(wms_outbound_order_head)
                    mov_docori: Referencia al codigo de la orden de salida (wms_outbound_order_head.order_number)
                    mov_zonlog: 10
                    mov_subzon: 10
                    mov_status: E

                    wms_inhouse_stkmov_line (Linea del movimiento interno):
                        linm_ctaori: cuenta origen PSAL
                        linm_ctades: cuenta destino DISP
                        linm_canpro: stock
                        linm_canmov: null
                        linm_terdep: documento de salida (gvenpedh.docser)
                        linm_canalt: null
                        linm_ubiori: ubicacion origen 
                        linm_ubides: ubicacion Destino (Zona de trabajo)
                        linm_status: E
                        linm_done:1
                        linm_tabori: tabla que origino este movimiento en este caso (wms_outbound_order_head)
                        linm_linori: Referencia a la linea de la orden de salida(wms_outbound_order_line.ordl_seqno)
                        linm_emp_code: null
                        linm_dateini:

                    wms_tasks (Se crean 2 tareas el primero es para extraer articulo de la ubicacion y la siguiente para manipular y confirmar la extraccion de articulos):
                        Primera tarea:
                            task_type: PVUB (EXTRAER UM O ARTÍCULO DE LA UBICACIÓN)
                            task_ctaori: cuenta origen PSAL
                            task_ctades: cuenta destino DISP
                            task_canmov: stock
                            task_ubiori: ubicacion actual 
                            task_terdep: Documento de salida (gvenpedh.docser)
                            task_emp_code: my user
                            task_ope_type: 9
                            task_start: null
                            task_end: null
                            task_status: 1
                            task_reference: Documento de salida (gvenpedh.docser)
                            task_tabori: tabla que origina la tarea en este caso (wms_inhouse_stkmov_line)
                            task_docori: Codigo del movimiento (wms_inhouse_stkmov_head.mov_number)
                            task_linori: referencia a la linea del movimiento interno(wms_inhouse_stkmov_line.linm_seqno)
                        
                        Segunda tarea:
                            task_type: PMVB (MANIPULAR Y CONFIRMAR EXTRACCIÓN ARTÍCULOS)
                            task_ctaori: cuenta origen PSAL
                            task_ctades: cuenta destino DISP
                            task_canmov: stock
                            task_ubiori: ubicacion actual, en este caso zona de trabajo 1000 ya que este se asigno en la tarea anterior
                            task_ubides: ubicacion destino (se queda en zona de trabajo 1000)
                            task_terdep: Codigo de documneto de salida (gvenpedh.docser)
                            task_emp_code: null
                            task_ope_type: 3
                            task_start: null
                            task_end: null
                            task_status: 0
                            task_reference: Codigo de documento de salida
                            task_tabori: tabla que origino el movimiento, en este caso (wms_inhouse_stkmov_line)
                            task_docori: Codigo del movimiento de la tabla que lo origina (wms_inhouse_stkmov_head.mov_number)
                            task_linori: Referencia a la linea de la tabla que origina el movimiento en este caso (wms_inhouse_stkmov_line.linm_seqno)


    Se actualiza disposicion (sun_ins_prelote_user):
        ctaori: ADES -> PSAL

    Se actualiza el documento de salida (gvenpedh):
        send_wms: 0 -> 1
        Se actualiza la linea del documento de salida(gvenpedl):
            errlin:25400 -> 25410

Al finalizar picking BTN finalizar picking:
    
    Se crea un movimiento interno (wms_inhouse_stkmov_head) Solo para cambio de ubicacion ya que el sistema incialmente lo puso en 1000 y lo cambie mediante el field:
        mov_type: 60 -Extraer UM/Artículo de ubicación a zona trabajo (Permite realizar las acciones de stock ocasianodas por las tareas de picking.)
        mov_number: Codigo del movimiento
        mov_tabori: null
        mov_docori: null
        mov_zonlog: null
        mov_subzon: null
        mov_status: T
        mov_emp_code: my user
        user_created: admsia
        user_updated: admsia

        Se registra linea del movimiento interno (wms_inhouse_stkmov_line):
            linm_ctaori: cuenta origen PSAL
            linm_ctades: cuenta destino PSAL
            linm_canpro: null
            linm_canmov: stock
            linm_terdep: codigo de documento de salida
            linm_canalt: stock
            linm_ubiori: ubicacion origen
            linm_ubides: ubicacion destino es la ubicacion que se inserta en el fiels en este caso inserte 1099
            linm_status: T
            linm_tabori: null
            linm_linori: null

            Se registra el movimiento de stock en wms_stkmovs
                Primer registro (Destino)
                    stkm_tabori: tabla que origina el movimiento (wms_inhouse_stkmov_head)
                    stkm_docori: Referencia al movimiento Codigo del movimiento (wms_inhouse_stkmov_head.mov_number)
                    stkm_linori: Referencia a la linea del movimiento (wms_inhouse_stkmov_line.linm_seqno)
                    stkm_cuenta: cuenta de destino
                    stkm_terdep: documento de salida
                    stkm_codubi: ubicacion destino(en este caso la ubicacion que ingrese en el field)
                    stkm_canmov: stock en movimiento
                    stkm_canalt: peso en movimiento
                Primer registro (Origen)
                    stkm_tabori: tabla que origina el movimiento (wms_inhouse_stkmov_head)
                    stkm_docori: Referencia al movimiento Codigo del movimiento (wms_inhouse_stkmov_head.mov_number)
                    stkm_linori: Referencia a la linea del movimiento (wms_inhouse_stkmov_line.linm_seqno)
                    stkm_cuenta: cuenta origen de donde se extrae el stock
                    stkm_terdep: documento de salida
                    stkm_codubi: ubicacion origen (de donde se extrae el stock)
                    stkm_canmov: stock extraido
                    stkm_canalt: peso extraido

                    Finalmente se muestra el estado final del stock hasta el momento en wms_inventory:
                        Se cambia la ubicacion
                        con la misma cuenta segun el movimiento

    Se actualiza el registro de tareas (wms_tasks)  con la ubicacion que escogi en el field del boton:
        Para PVUB:
            task_ubides: Se actualiza la ubicacion destino al que se selecciono en el field del boton
            task_emp_code: my user
            task_start: null -> Fecha de inicio de finalizacion de tarea
            task_end: null -> fecha de finalizacion de tarea
            task_status: 1 -> 4
        Para PMVB:
            task_ubiori: Se actualiza la ubicacion origen antes de ejecutar la tarea a la ubicacion que se selecciono en el field
            task_ubides: ubicacion seleccionada en el field
            task_emp_code: my user
            task_start: fecha de inicio de finalizacion de la tarea
            task_end: fecha de finalizacion de la tarea
            task_status: 0 -> 4
                    
    Se continua con el movimiento interno de picking(wms_inhouse_stkmov_head) que anteriormente solo creo tareas(wms_tasks) y no dejo registros en wms_stkmovs donde esta vez se pasara el stock a DISP con la ubicacion seleccionada el el field o de lo contrario se quedaria con la zona de trabajo preselccionada por el sistema:
    Se actualiza la cabecera del movimiento interno de picking(wms_inhouse_stkmov_head):
        mov_status: E -> D
        Se actualiza la linea del movimiento interno(wms_inhouse_stkmov_line): Aqui se indica el pase de PSAL a DISP del lote y posteriormente se registra en wms_stkmovs
            linm_canmov: null -> stock en DISP que quedo pendiente de pasar
            linm_canalt: null -> stock ahora en DISP (destino)
            linm_ubiori: se cambia de la ubicacion original del articulo a lo que seleccione en el field del boton finalizar picking
            linm_ubides: ubicacion destino(se cambia la zona de trabajo seleccionada por el sistema 1000 a la ubicacion seleccionada en el field del boton 1099)
            linm_status: E -> D
            linm_emp_code: null -> my user
            linm_dateini: null -> fecha de inicio de finalizacion de picking
            linm_daterea: null -> fecha de finalizacion de tarea de picking


            Se registra el movimiento en wms_stkmovs segun las tareas de wms_tasks:
                Primer registro de (Destino):
                    stkm_tabori: tabla que origina el movimiento, en este caso wms_inhouse_stkmov_head
                    stkm_docori: Codigo del movimiento interno (wms_inhouse_stkmov_head.mov_number)
                    stkm_linori: Referencia a la linea del movimiento (wms_inhouse_stkmov_line.linm_seqno)
                    stkm_cuenta: cuenta destino DISP
                    stkm_terdep: Documento de salida
                    stkm_codubi: ubicacion destino el que escogi en el field del boton finalizar picking
                    stkm_canmov: stock positivo en destino
                    stkm_canalt: peso positivo en destino
                Segundo registro de (Origen):
                    stkm_tabori: tabla que origina el movimiento, en este caso wms_inhouse_stkmov_head
                    stkm_docori: Codigo del movimiento interno (wms_inhouse_stkmov_head.mov_number)
                    stkm_linori: Referencia a la linea del movimiento (wms_inhouse_stkmov_line.linm_seqno)
                    stkm_cuenta: cuenta origen PSAL
                    stkm_terdep: Documento de salida
                    stkm_codubi: ubicacion origen
                    stkm_canmov: stock negativo porque se extrae
                    stkm_canalt: peso negativo porque se extrae

    Se actualiza la orden de salida (wms_outbound_order_head)
        order_first_launch: fecha -> null
        order_status: X -> L

        Se actualiza la linea de la orden de salida (wms_outbound_order_line):
            ordl_canext: stock -> 0
            ordl_canrea: 0 -> stock
            ordl_status: X -> L

    Finalmente el stock queda en DISP con lote listo para poder generar el acta de entrega

Al generar segundo documento de picking:
    Se crea otra orden de salida (wms_outbound_order_head):
        order_type: 50 (Orden de picking para salida)
        order_number: Codigo de la orden de salida
        order_tabori: gvenpedh
        order_docori: documento de salida
        order_first_launch: TODAY
        order_dlv_date: fecha en que se creo el documento de picking
        order_status: X

        Se crea la linea de la orden de salida (wms_outbound_order_line):
            ordl_cuenta: DISP
            ordl_terdep: documento de salida
            ordl_cantid: stock del lote
            ordl_canext: stock
            ordl_canrea: 0
            ordl_tabori: tabla que origina la orden (gvenpedh)
            ordl_docori: documento de salida
            ordl_linori: Referencia a la linea del documento de salida o lote (gvenpedl.linid)
            ordl_status: X
            
            Se crea el movimiento interno(wms_inhouse_stkmov_head)
                mov_type: 500 (Picking de salida)
                mov_number: Referencia al codigo de la cabecera de la orden de salida
                mov_tabori: tabla que origina el movimiento
                mov_docori:  Referencia al codigo de la cabecera de la orden de salida
                mov_zonlog: 10
                mov_subzon: 1
                mov_status: E
            
                Se crea la linea del movimiento interno (wms_inhouse_stkmov_line):
                    mov_seqno: Referencia a la cabecera (wms_inhouse_stkmov_head.mov_seqno)
                    linm_ctaori: cuenta origen para este momento ya se encuentra en DISP
                    linm_ctades: cuenta destino DISP
                    linm_canpro: stock
                    linm_canmov: null
                    linm_terdep: Documento de salida
                    linm_canalt: null
                    linm_udmalt: null
                    linm_ubiori: ubicacion actual(la que eleji en el field del boton finalizar picking)
                    linm_ubides: zona de trabajo 1000(predeterminado)
                    linm_status: E
                    linm_tabori: tabla que origina el movimiento en este caso una orden de salida (wms_outbound_order_head)
                    linm_linori: Referencia a la linea de la orden de salida (wms_outbound_order_line.ordl_seqno)
                    linm_emp_code: null
                    linm_dateini: null
                    linm_daterea: null

                Se crea la tarea correspondient (wms_tasks):
                    task_type: PMVB (MANIPULAR Y CONFIRMAR EXTRACCIÓN ARTÍCULOS)
                    task_ctaori: cuenta origen DISP
                    task_ctades: cuenta destino DISP
                    task_canmov: stock en movimiento
                    task_ubiori: ubicaicon origen
                    task_ubides: ubicacion destino por defecto es zona de trabajo 1000
                    task_terdep: documento de salida
                    task_emp_code: null
                    task_ope_type: 3
                    task_start: null
                    task_end: null
                    task_status: 1
                    task_reference: documento de salida
                    task_tabori: tabla que origina el movimiento en este caso (wms_inhouse_stkmov_line)
                    task_docori: Referencia al codigo del documento de la orden de salida (wms_inbound_order_head.order_number)
                    task_linori: Referencia a la linea del movimiento interno al que pertenece esta tarea (wms_inhouse_stkmov_line.linm_seqno)

                Se refleja en wms_inventory:
                    Registro normal en lote:
                        inv_cuenta: DISP
                        inv_terdep: documento de salida o lote
                        inv_codubi: Ultima ubicacion seleccionada en el field al finalizar pickking
                        inv_stkact: stock
                        inv_stkaux: peso
                        inv_stkent: Stock de entrada 0 porque se encuentra con tarea de picking pendiente de finalizar
                        inv_stksal: Stock de salida es el total del stock 

                    Registro de lote para picking:
                        inv_cuenta: DISP
                        inv_terdep: documento de salida o lote
                        inv_codubi: Ultima ubicacion seleccionada en el field al finalizar pickking
                        inv_stkact: 0
                        inv_stkaux: 0
                        inv_stkent: Stock que esta penditente de finalizar picking
                        inv_stksal: 0

Al finalizar el segundo picking:
    Se registra el movimiento en (wms_stkmovs):
        Primer registro de destino
            stkm_tabori: tabla que origina el movimiento en este caso (wms_inhouse_stkmov_head)
            stkm_docori: codigo de documento del movimiento  (wms_order_head.order_number)
            stkm_linori: Referencia a la linea del movimiento (wms_inhouse_stkmov_line.linm_seqno)
            stkm_cuenta: cuenta destino DISP
            stkm_terdep: documento de salida
            stkm_codubi: ubicacion destino: zona de trabajo
            stkm_canmov: stock en destino
            stkm_canalt: peso en destino

        Segundo registro de origen:
            stkm_tabori: tabla que origina el movimiento en este caso (wms_inhouse_stkmov_head)
            stkm_docori: codigo de documento del movimiento  (wms_order_head.order_number)
            stkm_linori: Referencia a la linea del movimiento (wms_inhouse_stkmov_line.linm_seqno)
            stkm_cuenta: cuenta origen DISP de donde se extrae el stock
            stkm_terdep: documento de salida
            stkm_codubi: ubciacion origen 1099(la ubicacion que eleji en el primer picking)
            stkm_canmov: stock de origen 
            stkm_canalt: peso de origen
    
    Se refleja en wms_inventory :
        Todo el stock pasa al registro que solo tenia inv_stkent (stock de entrada)

    Se actualiza la orden de salida (wms_outbound_order_head):
        order_first_launch: la fecha que se asigno al generar el picking -> null
        order_status: X -> L

        Se actualiza la linea de la orden de salida (wms_outbound_order_line):
            ordl_canext: stock - > 0
            ordl_canrea: 0 -> stock
            ordl_status: X -> L
    
    Se actualiza la cabecera del movimiento (wms_inhouse_stkmov_head):
        mov_status: E -> D
    
        Se actualiza la linea del movimeinto interno(wms_inhouse_stkmov_line):
            linm_canmov: null -> stock
            linm_canalt: null -> stock
            linm_status: E -> D
            linm_emp_code: null -> my user
            linm_dateini: null -> fecha de inicio de finalizacion del movimiento
            linm_daterea: null -> fecha de finalizacion de movimiento

    Se actualiza la tarea wms_tasks:
        task_emp_code: null -> my user
        task_start: fecha de inicio de finalizacion de la tarea
        task_end: fecha de finalizacion de la tarea
        task_status: 1 -> 4


Al cambiar el representante:
    Se actualiza el documento de salida gvenpedh:
        auxchr3: null -> 4
        auxchr4: ruc del representante

Click en validar prelote regresando a disposicion:
    Se inserta un nuevo registro en el historico de disposicion(sun_hist_disposicion):
        docser: gcompedh.refter
        ctaori: cuenta origen PSAL
        ctades: cuenta destino DISP
        stkact: stock
        cantid: stock
        stkaux: peso
        peso: peso
        estfis: 10
        numlot: Documento de salida o lote
        acta_disp: sun_gcompedh_memorandum.numdoc_seg
        motivo: (picking validado. lote generado)

    Se actualiza sun_ins_prelote_user Dispocicion recien aqui pasa a DISP:
        ctaori: PSAL - DISP
        accion: se mantiene en 5
        valida: 2 -> 4

Documento autorizante generado:
    
    Se actualiza gvenpedh:
        refter: null -> 1-000-000ADS-2025-1(esto es lo que se ingreso en el field del boton documento autorizante)
        