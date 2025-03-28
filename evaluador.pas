UNIT evaluador;

INTERFACE

USES
  crt, analizador_lexico, analizador_sintactico, math, sysutils;

CONST 
    max_var = 200;
    max_real = 200;
    max_matriz = 300;

TYPE
    t_tipo = (Treal_estado, Tmatriz_estado);

    t_tipo_matriz = array[1..max_matriz, 1..max_matriz] of real;

    t_elem_estado = record
        id_lexema: string;
        valor_real: real;
        tipo: t_tipo;
        valor_matriz: t_tipo_matriz;
        dim_fila: integer;
        dim_columna: integer;
    end;

    t_estado = record
        elem: array[1..max_var] of t_elem_estado;
        cant: word;
    end;


procedure inicializar_estado(var estado: t_estado); 
procedure evaluar_programa(var arbol: puntero_arbol; var estado: t_estado);
procedure evaluar_definiciones(var arbol: puntero_arbol; var estado: t_estado);
procedure evaluar_lista_definiciones(var arbol: puntero_arbol; var estado: t_estado);
procedure evaluar_mas_definiciones(var arbol: puntero_arbol; var estado: t_estado);
procedure evaluar_definicion(var arbol: puntero_arbol; var estado: t_estado);
procedure evaluar_tipo(var arbol: puntero_arbol; var estado: t_estado;var id:string);
procedure evaluar_cuerpo(var arbol: puntero_arbol; var estado: t_estado);
procedure evaluar_sentencias(var arbol: puntero_arbol; var estado: t_estado);
procedure evaluar_asignacion(var arbol: puntero_arbol; var estado: t_estado);
procedure evaluar_asignacion_prima(var arbol: puntero_arbol; var estado: t_estado;var lexema:string);
procedure evaluar_op(var arbol: puntero_arbol; var estado: t_estado; var valor:real; var matriz:t_tipo_matriz;var tipo:t_tipo;var lexema:string);
procedure evaluar_op_prima(var arbol: puntero_arbol; var estado: t_estado; var valor: real; var matriz:t_tipo_matriz;var tipo:t_tipo;var lexema:string);
procedure evaluar_op_2(var arbol: puntero_arbol; var estado: t_estado; var valor:real; var matriz:t_tipo_matriz; var tipo:t_tipo; var lexema:string);
procedure evaluar_op_2_prima(var arbol: puntero_arbol; var estado: t_estado; var valor:real; var matriz:t_tipo_matriz; var tipo:t_tipo; var lexema:string);
procedure evaluar_op_3(var arbol: puntero_arbol; var estado: t_estado; var valor:real; var matriz:t_tipo_matriz; var tipo:t_tipo; var lexema:string);
procedure evaluar_op_3_prima(var arbol: puntero_arbol; var estado: t_estado; var valor:real; var matriz:t_tipo_matriz;var tipo_izq:t_tipo;var lexema_izq:string);
procedure evaluar_op_4(var arbol: puntero_arbol; var estado: t_estado; var valor:real;var matriz:t_tipo_matriz;var tipo:t_tipo;var lexema:string);
procedure evaluar_cmatriz(var arbol: puntero_arbol; var estado: t_estado; var matriz:t_tipo_matriz;var fila,columna:integer);
procedure evaluar_filas(var arbol: puntero_arbol; var estado: t_estado; var matriz:t_tipo_matriz;var fila,columna:integer);
procedure evaluar_filas_extra(var arbol: puntero_arbol; var estado: t_estado; var matriz:t_tipo_matriz;var fila,columna:integer);
procedure evaluar_fila(var arbol: puntero_arbol; var estado: t_estado; var matriz:t_tipo_matriz;var fila,columna:integer);
procedure evaluar_numeros(var arbol: puntero_arbol; var estado: t_estado; var matriz:t_tipo_matriz;var fila,columna:integer);
procedure evaluar_numeros_prima(var arbol: puntero_arbol; var estado: t_estado; var matriz:t_tipo_matriz;var fila,columna:integer);
procedure evaluar_leer(var arbol: puntero_arbol; var estado: t_estado);
procedure evaluar_escribir(var arbol: puntero_arbol; var estado: t_estado);
procedure evaluar_lista(var arbol: puntero_arbol; var estado: t_estado);
procedure evaluar_lista_prima(var arbol: puntero_arbol; var estado: t_estado);
procedure evaluar_elemento(var arbol: puntero_arbol; var estado: t_estado);

IMPLEMENTATION  

procedure inicializar_estado(var estado: t_estado);
    begin
        estado.cant := 0;
    end;

function pasar_a_real(lexema:string):real;
    var
        valor: real;
        codigo: integer;
    begin
        valor := 0;
        // lexema := Copy(lexema, 1, Length(lexema) - 1);
        val(lexema, valor, codigo);
        pasar_a_real := valor;
    end;

function valor_de_real(var estado: t_estado; lexema:string):real;
    var
        i: integer;
    begin
        for i:=1 to estado.cant do
            begin
            if AnsiLowerCase(estado.elem[i].id_lexema) = AnsiLowerCase(lexema) then
                begin
                    writeln('QUE ONDA PAAAAAA');
                    writeln('estado, ',estado.elem[i].valor_real);
                    valor_de_real := estado.elem[i].valor_real;
                end;
            end;
    end;

function valor_de_matriz(var estado: t_estado;var lexema:string):t_tipo_matriz;
    var
        i: integer;
    begin
        for i:=1 to estado.cant do
            if AnsiLowerCase(estado.elem[i].id_lexema) = AnsiLowerCase(lexema) then
                begin
                    writeln('HOLA DESDE VALOR DE MATRIZ');
                    valor_de_matriz := estado.elem[i].valor_matriz;
                end;
    end;

procedure obtener_dimensiones_cmatriz(var matriz:t_tipo_matriz; var fila, columna: integer);
var
    i, j: integer;
begin
    fila := 0;  
    columna := 0; 
    for i := 1 to 6 do 
        begin
            for j := 1 to 6 do
                begin
                    if not IsNan(matriz[i, j]) then
                        begin
                            if i > fila then
                                fila := i;
                            if j > columna then
                                columna := j;
                        end;
                end;
        end;
end;


procedure agregar_real(var estado: t_estado; var lexema:string; var tipo:t_tipo);
    begin
        estado.cant := estado.cant + 1;
        estado.elem[estado.cant].id_lexema := lexema;
        estado.elem[estado.cant].valor_real := 0;
        estado.elem[estado.cant].tipo := tipo;
    end;

procedure agregar_matriz(var estado: t_estado; var lexema:string; var tipo:t_tipo; fila,columna:integer);
    var
        i,j: integer;
    begin
        estado.cant := estado.cant + 1;
        estado.elem[estado.cant].id_lexema := lexema;
        estado.elem[estado.cant].dim_fila := fila;
        estado.elem[estado.cant].dim_columna := columna;
        estado.elem[estado.cant].tipo := tipo;
        for i:=1 to max_matriz do
            for j:=1 to max_matriz do
                estado.elem[estado.cant].valor_matriz[i,j] := NaN;
            
    end;

procedure asignar_matriz(var estado:t_estado;lexema_izq:string;var matriz_der:t_tipo_matriz);
    var
        i: integer;

    begin
        for i:=1 to estado.cant do
            begin
                if AnsiLowerCase(estado.elem[i].id_lexema) = AnsiLowerCase(lexema_izq) then
                    begin
                        
                        estado.elem[i].valor_matriz := matriz_der;
                    end;
            end;
    end;

procedure asignar_valor_matriz(var estado:t_estado; lexema:string;var  valor:real;var fila,columna:integer);
    var
        i: integer;
    begin

        for i:=1 to estado.cant do
            begin
                if AnsiLowerCase(estado.elem[i].id_lexema) = AnsiLowerCase(lexema) then
                    begin
          
                        estado.elem[i].valor_matriz[fila,columna] := valor;
                    end;
            end;
    end;

procedure asignar_real(var estado:t_estado;var lexema_izq:string;var valor_der:real);
    var 
        i: integer;

    begin
        for i:=1 to estado.cant do
            begin
                if AnsiLowerCase(estado.elem[i].id_lexema) = AnsiLowerCase(lexema_izq) then
                    begin
                      
                        estado.elem[i].valor_real := valor_der;
                    end;
            end;
    end;

procedure obtener_tipo(var estado: t_estado; lexema:string; var tipo:t_tipo);
    var
        i: integer;
    begin
        for i:=1 to estado.cant do
            begin
                if AnsiLowerCase(estado.elem[i].id_lexema) = AnsiLowerCase(lexema) then
                    tipo := estado.elem[i].tipo;
            end;
    end;

procedure obtener_matriz(var estado: t_estado; lexema:string; var matriz:t_tipo_matriz);
    var
        i: integer;
    begin
        for i:=1 to estado.cant do
            begin
                if AnsiLowerCase(estado.elem[i].id_lexema) = AnsiLowerCase(lexema) then
                    begin
                        matriz := estado.elem[i].valor_matriz;
                    end;
            end;
    end;

procedure obtener_dimensiones(var estado: t_estado; lexema:string; var fila,columna:integer);
    var
        i: integer;
    begin
        for i:=1 to estado.cant do
            begin
                if AnsiLowerCase(estado.elem[i].id_lexema) = AnsiLowerCase(lexema) then
                    begin
                        fila := estado.elem[i].dim_fila;
                        columna := estado.elem[i].dim_columna;
                    end;
            end;
    end;

procedure transponer_matriz(var matriz:t_tipo_matriz; var matriz_transpuesta:t_tipo_matriz; fila,columna:integer);
    var
        i,j: integer;
    begin
        for i:=1 to fila do
            for j:=1 to columna do
                matriz_transpuesta[j,i] := matriz[i,j];
    end;


procedure multiplicar_matrices(var A, B, resultado: t_tipo_matriz; filas_A, columnas_A, filas_B,columnas_B: integer);
var
    i, j, k: integer;
    temp: t_tipo_matriz;
begin
    // Verificar que las dimensiones son compatibles para multiplicar
    if columnas_A <> filas_B then
    begin
        writeln('Error: Las dimensiones de las matrices no son compatibles para la multiplicación');
        exit;
    end;

    // Inicializar la matriz temp en 0
    for i := 1 to filas_A do
        for j := 1 to columnas_B do
            temp[i, j] := 0;

    // Multiplicar las matrices
    for i := 1 to filas_A do
        for j := 1 to columnas_B do
            for k := 1 to columnas_A do
                temp[i, j] := temp[i, j] + A[i, k] * B[k, j];

    // Copiar el resultado a la matriz resultado
    for i := 1 to filas_A do
        for j := 1 to columnas_B do
            resultado[i, j] := temp[i, j];
end;

procedure potencia_matriz(var estado:t_estado; var matriz:t_tipo_matriz; potencia:real; lexema:string);
    var 
        i,j,n:integer;
        matriz_resultado:t_tipo_matriz;
        potencia_aux:integer;
    begin
        if frac(potencia) <> 0 then
            writeln('Error: No se puede elevar una matriz a una potencia no entera')
        else
            for i:=1 to estado.cant do
                if AnsiLowerCase(estado.elem[i].id_lexema) = AnsiLowerCase(lexema) then
                    if estado.elem[i].dim_columna <> estado.elem[i].dim_fila then
                        writeln('Error: No se puede elevar una matriz que no sea cuadrada')
                    else
                        begin
                            potencia_aux:=trunc(potencia);
                            for j:=1 to potencia_aux do
                                begin
                                    if j = 1 then
                                        matriz_resultado := matriz
                                    else
                                        begin
                                            n:=estado.elem[j].dim_fila;
                                            multiplicar_matrices(matriz,matriz,matriz_resultado, n,n,n,n);  
                                        end;                                    
                                end;
                            matriz := matriz_resultado;
                        end;
    end;

procedure matriz_escalar(var matriz:t_tipo_matriz; escalar:real; fila,columna:integer);
    var
        i,j: integer;
    begin
        for i:=1 to fila do
            for j:=1 to columna do
                matriz[i,j] := matriz[i,j] * escalar;
    end;

procedure suma_matrices(var A, B, resultado: t_tipo_matriz; fila,columna:integer);
    var
        i,j: integer;
    begin
        for i:=1 to fila do
            for j:=1 to columna do
                resultado[i,j] := A[i,j] + B[i,j];
    end;

procedure resta_matrices(var A, B, resultado: t_tipo_matriz; fila,columna:integer);
    var
        i,j: integer;
    begin
        for i:=1 to fila do
            for j:=1 to columna do
                resultado[i,j] := A[i,j] - B[i,j];
    end;

function pasar_a_matriz(lexema: string; var matriz: t_tipo_matriz;var filas, columnas: integer): boolean;
    var
    i, j, inicio_numero, columnas_actual: integer;
    fila_str, numero_str: string;
    matriz_valida: boolean;

    begin
        Delete(lexema, 1, 1);
        Delete(lexema, Length(lexema), 1);

        filas := 0;
        i := 1;
        columnas := -1; 
        matriz_valida := true;

        while i <= Length(lexema) do
        begin
            // [1,2,3],[4,5,6],[7,8,9]
            if lexema[i] = '[' then
                begin
                    filas := filas + 1;
                    columnas_actual := 0;
                    fila_str := '';
                    i := i + 1;

                    while (i <= Length(lexema)) and (lexema[i] <> ']') do
                        begin
                            fila_str := fila_str + lexema[i];
                            i := i + 1;
                            // 1,2,3
                        end;
                    j := 1;
                    inicio_numero := 1;
                    while j <= Length(fila_str) do
                        begin
                            if (fila_str[j] = ',') or (j = Length(fila_str)) then
                                begin
                                    columnas_actual := columnas_actual + 1;
                                    numero_str := Copy(fila_str, inicio_numero, j - inicio_numero + Ord(j = Length(fila_str)));
                                    matriz[filas, columnas_actual] := StrToFloat(numero_str);
                                    inicio_numero := j + 1;
                                end;
                            j := j + 1;
                        end;
                    if columnas = -1 then
                        columnas := columnas_actual
                    else 
                        if columnas_actual <> columnas then
                            begin
                                WriteLn('Error: Fila ', filas, ' tiene ', columnas_actual, ' columnas, pero se esperaban ', columnas);
                                matriz_valida := false;
                            end;
                end;
            i := i + 1;
        end;
        pasar_a_matriz := matriz_valida;
    end;


// <Programa> ::= "program" "id" ";" <Definiciones> "{" <Cuerpo> "}"
procedure evaluar_programa(var arbol: puntero_arbol; var estado: t_estado);
    begin
        evaluar_definiciones(arbol^.hijos.elem[4], estado);
        evaluar_cuerpo(arbol^.hijos.elem[6], estado);
    end;

// <Definiciones> ::= "def" <ListaDefiniciones> | eps
procedure evaluar_definiciones(var arbol: puntero_arbol; var estado: t_estado);
    begin
        if arbol^.hijos.cant > 0 then
            evaluar_lista_definiciones(arbol^.hijos.elem[2], estado);
    end;

// <ListaDefiniciones> ::= <Definicion> ";" <MasDefiniciones>
procedure evaluar_lista_definiciones(var arbol: puntero_arbol; var estado: t_estado);
    begin
        evaluar_definicion(arbol^.hijos.elem[1], estado);
        evaluar_mas_definiciones(arbol^.hijos.elem[3], estado);
    end;

// <MasDefiniciones> ::= <ListaDefiniciones> | eps
procedure evaluar_mas_definiciones(var arbol: puntero_arbol; var estado: t_estado);
    begin
        if arbol^.hijos.cant > 0 then
            evaluar_lista_definiciones(arbol^.hijos.elem[1], estado);
    end;

// <Definicion> ::= “id” “:” <Tipo>
procedure evaluar_definicion(var arbol: puntero_arbol; var estado: t_estado);
    begin
        evaluar_tipo(arbol^.hijos.elem[3], estado,arbol^.hijos.elem[1]^.lexema);
    end;

// <Tipo> ::=  "matriz" "[" <OP> "]" "[" <OP> "]" | "real"  
procedure evaluar_tipo(var arbol: puntero_arbol; var estado: t_estado;var id:string);
    var
        aux_fila,aux_columna:real;
        fila,columna:integer;
        matriz:t_tipo_matriz;
        tipo:t_tipo;
        lexema:string;
    begin
        if arbol^.hijos.elem[1]^.simbolo = Treal then
            begin
                tipo:= Treal_estado;
                agregar_real(estado, id, tipo)
            end
        else
            if arbol^.hijos.elem[1]^.simbolo = Tmatriz then
                begin
                    evaluar_op(arbol^.hijos.elem[3], estado,aux_fila,matriz,tipo,lexema);
                    evaluar_op(arbol^.hijos.elem[6], estado,aux_columna,matriz,tipo,lexema);
                    fila := trunc(aux_fila);
                    columna := trunc(aux_columna);
                    tipo:= Tmatriz_estado;
                    agregar_matriz(estado, id,tipo,fila,columna);
                end;
    end;

// <Cuerpo> ::= <Sentencias> “;” <Cuerpo> | eps
procedure evaluar_cuerpo(var arbol: puntero_arbol; var estado: t_estado);
    begin
        if arbol^.hijos.cant > 0 then
            begin
                evaluar_sentencias(arbol^.hijos.elem[1], estado);
                evaluar_cuerpo(arbol^.hijos.elem[3], estado);
            end;
    end;

//<Sentencias> ::= <Asignacion> | <Leer>| <Escribir> | <Condicinal> | <Ciclo>
procedure evaluar_sentencias(var arbol: puntero_arbol; var estado: t_estado);
    begin
        case arbol^.hijos.elem[1]^.simbolo of
            Vasignacion : evaluar_asignacion(arbol^.hijos.elem[1], estado);
            Vleer : evaluar_leer(arbol^.hijos.elem[1], estado);
            Vescribir : evaluar_escribir(arbol^.hijos.elem[1], estado);
            // Vcondicional : evaluar_condicional(arbol^.hijos.elem[1], estado);
            // Vciclo : evaluar_ciclo(arbol^.hijos.elem[1], estado);
        end;
    end;

// <Asignacion> ::= "id" <Asingacion’> 
procedure evaluar_asignacion(var arbol: puntero_arbol; var estado: t_estado);
    var
        lexema:string;
    begin
        lexema := arbol^.hijos.elem[1]^.lexema;
        evaluar_asignacion_prima(arbol^.hijos.elem[2], estado, lexema);
    end;



procedure mostrar_matriz(matriz: t_tipo_matriz; filas, columnas: integer);
    var
        i, j: integer;
    begin
        for i := 1 to filas do
        begin
            for j := 1 to columnas do
                write(matriz[i, j]:0:2, ' ');
            writeln;
        end;
    end;




//<Asigancion’> ::=  ":=" <OP> |  “[“ <OP> ”]” ”[“ <OP> “]” “:=” <OP>
// ASIGNAR MATRIZ TENGO QUE VERIFICAR QUE LA MATRIZ QUE ESTA EN ESTADO SEA DE LAS MISMAS DIMENSIONES QUE 
// LA QUE ESTOY ASIGNANDO, 
// VERIFICAR EN OP4 SI ES UNA MATRIZ O UN REAL, SI HAGO FILAS(A) ENTONCES DEBERIA TAMBIEN SER REAL, 
// LA TRANSPUESTA DEUVLEVE UNA MATRIZ
procedure evaluar_asignacion_prima(var arbol: puntero_arbol; var estado: t_estado;var lexema:string);
    var
        valor,valor_fila,valor_columna:real;
        matriz:t_tipo_matriz;
        tipo:t_tipo;
        lexema_der,lexema_columna,lexema_fila:string;
        fila,columna,fila_op,columna_op,fila_der,columna_der,fila_cmatriz,columna_cmatriz:integer;
    begin
        case arbol^.hijos.elem[1]^.simbolo of
            Tasig: 
                begin
                    writeln(arbol^.hijos.elem[2]^.lexema);
                    obtener_tipo(estado,lexema,tipo);
                    // LEXEMA A ; 
                    writeln('tipo ',tipo);
                    if tipo = Tmatriz_estado then
                        begin
                            evaluar_op(arbol^.hijos.elem[2], estado,valor,matriz,tipo,lexema_der);
                            writeln('LEXEMA DER ',lexema_der);
                            writeln('tipo 2 ',tipo);
                            obtener_matriz(estado,lexema,matriz);
                            obtener_dimensiones(estado,lexema, fila,columna);
                            writeln('fila ',fila);
                            writeln('columna ',columna);
                            obtener_dimensiones_cmatriz(matriz,fila_cmatriz,columna_cmatriz);
                            writeln('fila cmatriz ',fila_cmatriz);
                            writeln('columna cmatriz ',columna_cmatriz);

                            if (fila = fila_cmatriz) and (columna = columna_cmatriz) then
                                begin
                                    
                                    asignar_matriz(estado,lexema,matriz);
                                end
                            else
                                writeln('Error: No se pueden asignar matrices de distinta dimension');
                        end
                    else    
                        if tipo = Treal_estado then
                            begin

                                asignar_real(estado,lexema,valor);    
                            end;
                end;
            Tcorchetea: 
                begin
                    obtener_dimensiones(estado,lexema, fila,columna);
                    evaluar_op(arbol^.hijos.elem[2], estado,valor_fila,matriz,tipo,lexema_fila);
                    evaluar_op(arbol^.hijos.elem[5], estado,valor_columna,matriz,tipo,lexema_columna);
                    evaluar_op(arbol^.hijos.elem[8], estado,valor,matriz,tipo,lexema_der);          

                    fila_op:= trunc(valor_fila);
                    columna_op:= trunc(valor_columna);
                    if  tipo = Tmatriz_estado then
                        writeln('Error no puedo asingar una matriz a un elemento de una matriz A[i,j] = Matriz')
                    else
                        begin
                            if fila_op > fila then
                                writeln('Error: La matriz declarada tiene menores filas que la que estoy intendo acceder')
                            else
                                if columna_op > columna then
                                    writeln('Error: La matriz declarada tiene menores columnas que la que estoy intendo acceder')
                                else
                                    begin
                                        asignar_valor_matriz(estado,lexema,valor,fila_op,columna_op);

        
                                    end;
                    end;

                end;
        end;
    end;

// <OP> ::= <OP2> <OP'>
procedure evaluar_op(var arbol: puntero_arbol; var estado: t_estado; var valor:real; var matriz:t_tipo_matriz;var tipo:t_tipo;var lexema:string);
    var
        valor_der:real;
        matriz_der:t_tipo_matriz;
        tipo_der:t_tipo;
        lexema_der:string;
    begin
        evaluar_op_2(arbol^.hijos.elem[1], estado,valor,matriz,tipo,lexema);
        evaluar_op_prima(arbol^.hijos.elem[2], estado,valor_der,matriz_der,tipo_der,lexema_der);
    end;

// <OP'> ::= "+" <OP> | "-" <OP> | eps
// <OP'> ::= "+" <OP2> <OP'> | "-" <OP2> <OP'> | eps
// OPERACIONES PERMITIDAS REAL + REAL, MATRIZ + MATRIZ, REAL - REAL, MATRIZ - MATRIZ
procedure evaluar_op_prima(var arbol: puntero_arbol; var estado: t_estado; var valor: real; var matriz:t_tipo_matriz;var tipo:t_tipo;var lexema:string);
    var
        valor_der,valor_1: real;
        matriz_1,matriz_2,matriz_resultado,matriz_der: t_tipo_matriz;
        tipo_1,tipo_2,tipo_der: t_tipo;
        lexema_1,lexema_2,lexema_der: string;
        fila,columna,fila_der,columna_der:integer;

    begin
        if arbol^.hijos.cant > 0 then
            begin
                evaluar_op_2(arbol^.hijos.elem[2], estado,valor_1,matriz_1,tipo_1,lexema_1);
            
                case arbol^.hijos.elem[1]^.simbolo of
                    Tmas: begin
                             case tipo_1 of 
                                Treal_estado: if tipo_der = Treal_estado then
                                            valor := valor + valor_der
                                        else
                                            writeln('Error: No se puede sumar un real con una matriz');
                                Tmatriz_estado: if tipo_der = Tmatriz_estado then
                                            begin
                                                obtener_dimensiones(estado,lexema, fila,columna);
                                                obtener_dimensiones(estado,lexema_der, fila_der,columna_der);
                                                if (fila = fila_der) and (columna = columna_der) then
                                                    begin
                                                        suma_matrices(matriz,matriz_der,matriz_resultado,fila,columna);
                                                        matriz:=matriz_resultado;
                                                    end
                                                else
                                                    writeln('Error: No se pueden sumar matrices de distinta dimension');
                                            end
                                        else
                                            writeln('Error: No se puede sumar una matriz con un real');
                             end;
                          end;

                    Tmenos: begin
                                case tipo of
                                    Treal_estado: if tipo_der = Treal_estado then
                                                valor := valor - valor_der
                                            else
                                                writeln('Error: No se puede restar un real con una matriz');
                                    Tmatriz_estado: if tipo_der = Tmatriz_estado then
                                                begin
                                                    obtener_dimensiones(estado,lexema, fila,columna);
                                                    obtener_dimensiones(estado,lexema_der, fila_der,columna_der);
                                                    if (fila = fila_der) and (columna = columna_der) then
                                                        begin
                                                            resta_matrices(matriz,matriz_der,matriz_resultado,fila,columna);
                                                            matriz:=matriz_resultado;
                                                        end
                                                    else
                                                        writeln('Error: No se pueden restar matrices de distinta dimension');
                                                end
                                            else
                                                writeln('Error: No se puede restar una matriz con un real');
                                end;
                            end;
                end;
            end;
    end;

// <OP2> ::= <OP3> <OP2'>
procedure evaluar_op_2(var arbol: puntero_arbol; var estado: t_estado; var valor:real; var matriz:t_tipo_matriz; var tipo:t_tipo; var lexema:string);
    var
        valor_der:real;
        matriz_der:t_tipo_matriz;
        tipo_der:t_tipo;
        lexema_der:string;
    begin
        evaluar_op_3(arbol^.hijos.elem[1], estado,valor,matriz,tipo,lexema);
        evaluar_op_2_prima(arbol^.hijos.elem[2], estado,valor_der,matriz_der,tipo_der,lexema_der);
    end;

// <OP2'> ::= "*" <OP3> <OP2'> | "/" <OP3> <OP2'> | eps  
// OP PERMITIDAS REAL * REAL, MATRIZ * REAL, REAL * MATRIZ, MATRIZ * MATRIZ, REAL / REAL, MATRIZ / REAL
procedure evaluar_op_2_prima(var arbol: puntero_arbol; var estado: t_estado; var valor:real; var matriz:t_tipo_matriz; var tipo:t_tipo; var lexema:string);
    var
        valor_der:real;
        matriz_der:t_tipo_matriz;
        tipo_der:t_tipo;
        lexema_der:string;
        fila_der,columna_der,fila_izq,columna_izq:integer;
        matriz_resultado:t_tipo_matriz;
    begin
        if arbol^.hijos.cant > 0 then
            begin
                evaluar_op_2(arbol^.hijos.elem[2], estado,valor_der,matriz_der,tipo_der,lexema_der);
                
                case arbol^.hijos.elem[1]^.simbolo of
                    Tmulti: begin
                                case tipo of
                                    Treal_estado: if tipo_der = Treal_estado then
                                                valor := valor * valor_der
                                            else
                                                begin
                                                    obtener_dimensiones(estado,lexema, fila_izq,columna_izq);
                                                    matriz_escalar(matriz_der,valor,fila_izq,columna_izq);
                                                end;
                                    Tmatriz_estado: if tipo_der = Treal_estado then
                                                begin
                                                    obtener_dimensiones(estado,lexema_der, fila_der,columna_der);
                                                    matriz_escalar(matriz,valor_der,fila_der,columna_der);
                                                end
                                            else
                                                begin
                                                    obtener_dimensiones(estado,lexema, fila_izq,columna_izq);
                                                    obtener_dimensiones(estado,lexema_der, fila_der,columna_der);
                                                    multiplicar_matrices(matriz,matriz_der,matriz_resultado,fila_izq,columna_izq,fila_der,columna_der);
                                                    matriz := matriz_resultado;
                                                end;
                                end;

                            end;
                    Tdivi: begin
                            case tipo of
                                Treal_estado: if tipo_der = Treal_estado then
                                            valor := valor / valor_der
                                        else
                                            writeln('Error: No se puede dividir un real por una matriz');
                                Tmatriz_estado: if tipo_der = Treal_estado then
                                            begin
                                                obtener_dimensiones(estado,lexema, fila_der,columna_der);
                                                matriz_escalar(matriz,1/valor_der,fila_der,columna_der)
                                            end
                                        else
                                            writeln('Error: No se puede dividir una matriz por otra matriz');
                            end;
                        end;

                end;
            end;
    end;

// <OP3> ::= <OP4> <OP3'>;
procedure evaluar_op_3(var arbol: puntero_arbol; var estado: t_estado; var valor:real; var matriz:t_tipo_matriz; var tipo:t_tipo; var lexema:string);
    var
        valor_der:real;
        matriz_der:t_tipo_matriz;
        tipo_der:t_tipo;
        lexema_der:string;
    begin
        evaluar_op_4(arbol^.hijos.elem[1], estado,valor,matriz,tipo,lexema);
        evaluar_op_3_prima(arbol^.hijos.elem[2], estado,valor_der,matriz_der,tipo_der,lexema_der);
    end;

// <OP3'> ::= “^” <OP4> <OP3'> | eps   OPERACIONES PERMITIDAS REAL ^REAL , MATRIZ ^ REAL, 
procedure evaluar_op_3_prima(var arbol: puntero_arbol; var estado: t_estado; var valor:real; var matriz:t_tipo_matriz;var tipo_izq:t_tipo;var lexema_izq:string);
    var
        valor_der:real;
        tipo_der:t_tipo;
        lexema_der:string;
        matriz_der:t_tipo_matriz;
    begin
        if arbol^.hijos.cant > 0 then
            begin
                evaluar_op_3(arbol^.hijos.elem[2], estado,valor_der,matriz_der,tipo_der,lexema_der);
                case tipo_izq of
                    Treal_estado: if tipo_der = Treal_estado then
                                valor := power(valor,valor_der)
                            else
                                writeln('Error: No se puede elevar un real a una amtriz');
                    Tmatriz_estado: if tipo_der = Treal_estado then
                                potencia_matriz(estado,matriz,valor_der,lexema_izq);
                            else
                                writeln('Error: No se puede elevar una matriz a otra matriz');
                end;
                
            end;
    end;
    
// <OP4> ::= <CMatriz> | “id” | “creal” | “filas” “(“ “id” “)” | “columnas” “(“ “id” “)” 
//                     | "trans" "(" "id" ")" | “-” <OP4> | “(“ <OP> “)” 
procedure evaluar_op_4(var arbol: puntero_arbol; var estado: t_estado; var valor:real;var matriz:t_tipo_matriz;var tipo:t_tipo;var lexema:string);
    var
        fila,columna:integer;
        matriz_transpuesta:t_tipo_matriz;
    begin
        case arbol^.hijos.elem[1]^.simbolo of
            Tid: begin
                    lexema:=arbol^.hijos.elem[1]^.lexema;
                    obtener_tipo(estado, lexema, tipo);
                    case tipo of
                        Treal_estado: begin
                             valor := valor_de_real(estado, lexema);
                            end;
                        Tmatriz_estado:begin
                         matriz := valor_de_matriz(estado, lexema);
                        end;
                    end;
                 end;
            Tcreal: begin
                    
                        lexema:=arbol^.hijos.elem[1]^.lexema;
                        valor := pasar_a_real(lexema);
                        tipo := Treal_estado;
                    end;
            Tfilas: 
                begin
                    obtener_tipo(estado, arbol^.hijos.elem[3]^.lexema, tipo);
                    if tipo = Treal_estado then
                        writeln('Error: No se puede obtener las filas de un real')
                    else
                        begin
                            obtener_dimensiones(estado, arbol^.hijos.elem[3]^.lexema, fila,columna);
                            valor := fila;
                            tipo:=Treal_estado;
                        end;
                end;
            Tcolumnas: 
                begin
                    obtener_tipo(estado, arbol^.hijos.elem[3]^.lexema, tipo);
                    if tipo = Treal_estado then
                        writeln('Error: No se puede obtener las filas de un real')
                    else
                        begin
                            obtener_dimensiones(estado, arbol^.hijos.elem[3]^.lexema, fila,columna);
                            valor := columna;
                            tipo:=Treal_estado;
                        end;
                end;
            Tmenos: evaluar_op_4(arbol^.hijos.elem[2], estado,valor,matriz,tipo,lexema);
            Ttrans: 
                begin
                    obtener_tipo(estado, arbol^.hijos.elem[3]^.lexema, tipo);
                    if tipo = Treal_estado then
                        writeln('Error: No se puede transponer un real')
                    else
                        begin
                            obtener_matriz(estado, arbol^.hijos.elem[3]^.lexema, matriz);
                            transponer_matriz(matriz, matriz_transpuesta, fila,columna);
                        end;
                end;
            Tparentesisa: evaluar_op(arbol^.hijos.elem[2], estado,valor,matriz,tipo,lexema);
            Vcmatriz: 
                begin
                    tipo := Tmatriz_estado;
                    // obtener_matriz(estado, lexema, matriz);
                    writeln('HOLA');
                    fila:=1;
                    columna:=1;
                    evaluar_cmatriz(arbol^.hijos.elem[1], estado,matriz,fila,columna);


                end;
        end;
    end;

// <CMatriz> ::= "[" <Filas> "]”
procedure evaluar_cmatriz(var arbol: puntero_arbol; var estado: t_estado; var matriz:t_tipo_matriz;var fila,columna:integer);
    begin
        evaluar_filas(arbol^.hijos.elem[2], estado,matriz,fila,columna);
    end;

// <Filas> ::= <Fila> <FilasExtra>
procedure evaluar_filas(var arbol: puntero_arbol; var estado: t_estado; var matriz:t_tipo_matriz;var fila,columna:integer);
    var
        columnas_aux,filas_aux:integer;
    begin

        columnas_aux:=0;
        evaluar_fila(arbol^.hijos.elem[1], estado,matriz,fila,columna);

        if columnas_aux > 0 then
            begin
                if columna <> columnas_aux then
                    writeln('Error: Filas con un número de columnas diferente.');
            end
        else
            begin
                columnas_aux := columna;
            end;


        evaluar_filas_extra(arbol^.hijos.elem[2], estado, matriz, fila, columna);









        // writeln('EN FILAS');
        // // writeln('CANT ARBOL, ',arbol^.hijos.cant);
        // columnas_aux:=0;
        // // filas_aux:=1;
        // if arbol^.hijos.cant <> 0 then
        //     begin
        //         writeln('ACA ADENTRO');
        //         evaluar_fila(arbol^.hijos.elem[1], estado,matriz,fila,columna);
        //     end
        // else
        //     writeln('ACA AFUERA');
        // writeln('EN FILAS 2');
        // if columnas_aux > 0 then
        //     begin
        //         if columna <> columnas_aux then
        //             writeln('Error: Filas con un número de columnas diferente.');
        //     end
        // else
        //     begin
        //         columnas_aux := columna;
        //     end;
        
        // if arbol^.hijos.elem[2] <> nil then
        //     begin
        //     writeln('EN FILAS 3');
        //     evaluar_filas_extra(arbol^.hijos.elem[2], estado, matriz, fila, columna);
        //     end;
        // writeln('EN FILAS 4');
    end;

// <FilasExtra> ::= "," <Filas> | eps
procedure evaluar_filas_extra(var arbol: puntero_arbol; var estado: t_estado; var matriz:t_tipo_matriz;var fila,columna:integer);
    begin
        if arbol^.hijos.cant > 0 then
            begin
                fila:=fila + 1;
                columna:=1;
                evaluar_filas(arbol^.hijos.elem[2], estado,matriz,fila,columna);
            end;
    end;
    
// <Fila> ::= “[“ <Numeros> “]”
procedure evaluar_fila(var arbol: puntero_arbol; var estado: t_estado; var matriz:t_tipo_matriz;var fila,columna:integer);

    begin
        evaluar_numeros(arbol^.hijos.elem[2], estado,matriz,fila,columna);
    end;

// <Numeros> ::= <OP4> <Numeros'>
procedure evaluar_numeros(var arbol: puntero_arbol; var estado: t_estado; var matriz:t_tipo_matriz;var fila,columna:integer);
    var
        tipo:t_tipo;
        lexema:string;
        valor:real;
    begin

        evaluar_op_4(arbol^.hijos.elem[1], estado,valor,matriz,tipo,lexema);


        if tipo = Treal_estado then
            begin
               
                matriz[fila,columna] := valor;
            end
        else
            writeln('Error: No se puede asignar un valor no numerico a una matriz');
        evaluar_numeros_prima(arbol^.hijos.elem[2], estado,matriz,fila,columna);
       
    end;

// <Numeros'> ::= “,” <Numeros> | eps
procedure evaluar_numeros_prima(var arbol: puntero_arbol; var estado: t_estado; var matriz:t_tipo_matriz;var fila,columna:integer);
    begin
        if arbol^.hijos.cant > 0 then
            begin
                columna:=columna + 1;
                evaluar_numeros(arbol^.hijos.elem[2], estado,matriz,fila,columna);
            end;
    end;

// <Leer> ::= “leer” “(“ “cadena” “,” “id” “)”
procedure evaluar_leer(var arbol: puntero_arbol; var estado: t_estado);
    var
        valor_leido:string;
        valor:real;
        matriz:t_tipo_matriz;
        lexema: string;
        tipo: t_tipo;
        filas, columnas: integer;

    begin
        lexema := arbol^.hijos.elem[5]^.lexema;
        obtener_tipo(estado, lexema, tipo);
        readln(valor_leido);

        case tipo of
            Treal_estado: 
                begin
                    valor := pasar_a_real(valor_leido);
                    asignar_real(estado, lexema, valor);
                end;
            Tmatriz_estado: 
                begin
                    if pasar_a_matriz(valor_leido, matriz, filas, columnas) then
                        begin
                            agregar_matriz(estado, lexema, tipo, filas, columnas);
                            asignar_matriz(estado, lexema, matriz)
                        end
                    else
                        writeln('Error: La matriz ingresada no es válida');
                end;
        end;
    end;

// <Escribir> ::= “escribir” “(“ <Lista> “)”
procedure evaluar_escribir(var arbol: puntero_arbol; var estado: t_estado);
    begin
        evaluar_lista(arbol^.hijos.elem[3], estado);
    end;

// <Lista> ::= <Elemento> <Lista'>
procedure evaluar_lista(var arbol: puntero_arbol; var estado: t_estado);
    begin
        evaluar_elemento(arbol^.hijos.elem[1], estado);
        evaluar_lista_prima(arbol^.hijos.elem[2], estado);
    end;

// <Lista'> ::= “,” <Lista> | ε
procedure evaluar_lista_prima(var arbol: puntero_arbol; var estado: t_estado);
    begin
        if arbol^.hijos.cant > 0 then
            begin
             evaluar_lista(arbol^.hijos.elem[2], estado);
            end;
    end;

//<Elemento> ::= “cadena” | <OP> 
procedure evaluar_elemento(var arbol: puntero_arbol; var estado: t_estado);
    var
        valor:real;
        matriz:t_tipo_matriz;
        tipo:t_tipo;
        lexema:string;
        i,j,fila,columna:integer;
    begin
        writeln(arbol^.hijos.elem[1]^.simbolo);
        case arbol^.hijos.elem[1]^.simbolo of
            Tcadena: begin
                        writeln(arbol^.hijos.elem[1]^.lexema);
                    end;
            Vop: begin
                    evaluar_op(arbol^.hijos.elem[1], estado,valor,matriz,tipo,lexema);
                    case tipo of
                        Treal_estado: writeln(valor:0:2);
                        Tmatriz_estado: 
                            begin
                                obtener_dimensiones(estado,lexema, fila,columna);
                                for i:=1 to fila do
                                    begin
                                        for j:=1 to columna do
                                            write(matriz[i,j]:0:2,' ');
                                        writeln;
                                    end;


                        
                            end;
                    end;
                end;
        end;
    end;

END.