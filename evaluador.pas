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
        inicializado: boolean;
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
procedure evaluar_tipo(var arbol: puntero_arbol; var estado: t_estado; id_lexema: string);
procedure evaluar_cuerpo(var arbol: puntero_arbol; var estado: t_estado);
procedure evaluar_sentencias(var arbol: puntero_arbol; var estado: t_estado);
procedure evaluar_asignacion(var arbol: puntero_arbol; var estado: t_estado);
procedure evaluar_asignacion_prima(var arbol: puntero_arbol; var estado: t_estado; lexema: string);
procedure evaluar_asignacion_prima_prima(var arbol: puntero_arbol; var estado: t_estado;var valor: real; var matriz: t_tipo_matriz; var tipo_2: t_tipo);
procedure evaluar_op(var arbol: puntero_arbol; var estado: t_estado; var valor: real; var matriz: t_tipo_matriz; var tipo: t_tipo);
procedure evaluar_op_prima(var arbol: puntero_arbol; var estado: t_estado; var valor: real; var matriz: t_tipo_matriz; var tipo: t_tipo);
procedure evaluar_op_2(var arbol: puntero_arbol; var estado: t_estado; var valor:real; var matriz:t_tipo_matriz; var tipo:t_tipo);
procedure evaluar_op_2_prima(var arbol: puntero_arbol; var estado: t_estado; var valor: real; var matriz: t_tipo_matriz; var tipo: t_tipo);
procedure evaluar_op_3(var arbol: puntero_arbol; var estado: t_estado; var valor: real; var matriz: t_tipo_matriz; var tipo: t_tipo);
procedure evaluar_op_3_prima(var arbol: puntero_arbol; var estado: t_estado; var valor: real; var matriz: t_tipo_matriz; var tipo: t_tipo);
procedure evaluar_op_4(var arbol: puntero_arbol; var estado: t_estado; var valor: real; var matriz: t_tipo_matriz; var tipo: t_tipo);
procedure evaluar_op_4_prima(var arbol: puntero_arbol; var estado: t_estado; var valor: real; var matriz: t_tipo_matriz; var tipo: t_tipo);
procedure evaluar_cmatriz(var arbol: puntero_arbol; var estado: t_estado; var matriz:t_tipo_matriz);
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
procedure evaluar_si_no(var arbol:puntero_arbol; var estado:t_estado);
procedure evaluar_condicional(var arbol: puntero_arbol; var estado: t_estado);
procedure evaluar_ciclo(var arbol: puntero_arbol; var estado: t_estado);
procedure evaluar_condicion(var arbol:puntero_arbol; var estado:t_estado; var resultado_condicion:boolean);
procedure evaluar_expresion_l(var arbol:puntero_arbol; var estado:t_estado; var resultado_condicion:boolean);
procedure evaluar_expresion_l_prima(var arbol:puntero_arbol; var estado:t_estado; var resultado_condicion:boolean);
procedure evaluar_expresion_r(var arbol:puntero_arbol; var estado:t_estado; var resultado_condicion:boolean);
procedure evaluar_comparacion(var arbol:puntero_arbol;var estado:t_estado;var valor_izq,valor_der:real;var matriz_izq,matriz_der:t_tipo_matriz;
                              var tipo_izq,tipo_der:t_tipo;var resultado_condicion:boolean);

IMPLEMENTATION

procedure inicializar_estado(var estado: t_estado);
    begin
        estado.cant := 0;
    end;

procedure inicializar_matriz_NaN(var matriz:t_tipo_matriz);
    var
        i,j: integer;
    begin
        for i:=1 to max_matriz do
            for j:=1 to max_matriz do
                matriz[i,j] := NaN;
    end;

procedure inicializar_matriz_parcial(var matriz:t_tipo_matriz; filas,columnas:integer);
    var
        i,j: integer;
    begin
        for i:=1 to filas do
            for j:=1 to columnas do
                matriz[i,j] := 0;
    end;

function tipos_iguales(tipo1, tipo2: t_tipo): boolean;
    begin
        tipos_iguales := (tipo1 = tipo2);
    end;

function pasar_a_real(lexema:string):real;
    var
        valor: real;
        codigo: integer;
    begin
        val(lexema, valor, codigo);
        if codigo <> 0 then
            begin
                writeln('Error: No se puede convertir a real el valor ', lexema);
                halt();
            end;
        pasar_a_real := valor;
    end;

procedure obtener_dimensiones_cmatriz(var matriz:t_tipo_matriz; var filas,columnas:integer);
    var
        i,j: integer;
    begin
        filas := 0;
        columnas := 0;

        for i:=1 to max_matriz do
            for j:=1 to max_matriz do
                if not IsNan(matriz[i,j]) then
                    begin
                        if i > filas then
                            filas := i;
                        if j > columnas then
                            columnas := j;
                    end;
    end;

procedure escribir_matriz(var matriz:t_tipo_matriz);
    var
        i,j,filas,columnas: integer;
    begin
        obtener_dimensiones_cmatriz(matriz, filas, columnas);
        for i:=1 to filas do
            begin
                for j:=1 to columnas do
                    write(matriz[i,j]:0:2, ' ');
                writeln();
            end;
    end;

procedure agregar_real(var estado: t_estado; id_lexema: string; tipo: t_tipo);
    begin
        estado.cant := estado.cant + 1;
        estado.elem[estado.cant].id_lexema := id_lexema;
        estado.elem[estado.cant].inicializado := false;
        estado.elem[estado.cant].valor_real := 0;
        estado.elem[estado.cant].tipo := tipo;
    end;

procedure agregar_matriz(var estado: t_estado; id_lexema: string; tipo: t_tipo;var filas,columnas: integer);
    var
        i,j: integer;
    begin
        estado.cant := estado.cant + 1;
        estado.elem[estado.cant].id_lexema := id_lexema;
        estado.elem[estado.cant].inicializado := false;
        estado.elem[estado.cant].tipo := tipo;
        estado.elem[estado.cant].dim_fila := filas;
        estado.elem[estado.cant].dim_columna := columnas;
        for i:=1 to max_matriz do
            for j:=1 to max_matriz do
                estado.elem[estado.cant].valor_matriz[i,j] := NaN;
    end;

procedure asignar_real(var estado: t_estado; id_lexema: string; valor: real);
    var
        i: integer;
    begin
        for i := 1 to estado.cant do
            if estado.elem[i].id_lexema = id_lexema then
                begin
                    estado.elem[i].valor_real := valor;
                    estado.elem[i].inicializado := true;
                    exit;
                end;
    end;

procedure asignar_matriz(var estado: t_estado; id_lexema: string; matriz: t_tipo_matriz);
    var
        i,filas,columnas: integer;
    begin
        obtener_dimensiones_cmatriz(matriz,filas,columnas);
        for i := 1 to estado.cant do
            if AnsiLowerCase(estado.elem[i].id_lexema) = AnsiLowerCase(id_lexema) then
                begin
                    if (estado.elem[i].dim_fila <> filas) or (estado.elem[i].dim_columna <> columnas) then
                        begin 
                            writeln('Error: La matriz ',id_lexema ,' no tiene la misma dimension que la que estoy asignando');
                            halt();
                        end;
                    estado.elem[i].valor_matriz := matriz;
                    estado.elem[i].inicializado := true;
                    exit;
                end;
    end;

function variable_inicializada(var estado: t_estado; id_lexema: string): boolean;
    var
        i: integer;
    begin
        variable_inicializada := false;
        for i := 1 to estado.cant do
            if AnsiLowerCase(estado.elem[i].id_lexema) = AnsiLowerCase(id_lexema) then
                begin
                    variable_inicializada := estado.elem[i].inicializado;
                    exit;
                end;
    end;

procedure asignar_valor_matriz(var estado: t_estado; valor: real; id_lexema: string; var fila,columna: integer);
    var
        i: integer;
    begin
        for i := 1 to estado.cant do
            if AnsiLowerCase(estado.elem[i].id_lexema) = AnsiLowerCase(id_lexema) then
                begin
                    if not estado.elem[i].inicializado then
                        begin
                            inicializar_matriz_parcial(estado.elem[i].valor_matriz, estado.elem[i].dim_fila, estado.elem[i].dim_columna);
                            estado.elem[i].inicializado := true;
                        end;
                    estado.elem[i].valor_matriz[fila, columna] := valor;
                    exit;
                end;
    end;

procedure obtener_tipo(var estado: t_estado; id_lexema: string; var tipo: t_tipo);
    var
        i: integer;
    begin
        for i := 1 to estado.cant do
            if AnsiLowerCase(estado.elem[i].id_lexema) = AnsiLowerCase(id_lexema) then
                begin
                    tipo := estado.elem[i].tipo;
                    exit;
                end;
        writeln('Error: Variable no declarada ', id_lexema);
        halt();
    end;

procedure obtener_matriz(var estado: t_estado; id_lexema: string; var matriz: t_tipo_matriz);
    var
        i: integer;
    begin
        for i := 1 to estado.cant do
            if AnsiLowerCase(estado.elem[i].id_lexema) = AnsiLowerCase(id_lexema) then
                begin
                    matriz := estado.elem[i].valor_matriz;
                    exit;
                end;
    end;

procedure obtener_real(var estado: t_estado; id_lexema: string; var valor: real);
    var
        i: integer;
    begin
        for i := 1 to estado.cant do
            if AnsiLowerCase(estado.elem[i].id_lexema) = AnsiLowerCase(id_lexema) then
                begin
                    valor := estado.elem[i].valor_real;
                    exit;
                end;
    end;

procedure obtener_dimensiones(var estado: t_estado; id_lexema: string; var filas,columnas: integer);
    var
        i: integer;
    begin
        for i := 1 to estado.cant do
            if AnsiLowerCase(estado.elem[i].id_lexema) = AnsiLowerCase(id_lexema) then
                begin
                    filas := estado.elem[i].dim_fila;
                    columnas := estado.elem[i].dim_columna;
                    exit;
                end;
    end;

procedure trasponer_matriz(var matriz:t_tipo_matriz);
    var
        i,j,filas,columnas: integer;
        aux: t_tipo_matriz;
    begin
        inicializar_matriz_NaN(aux);
        obtener_dimensiones_cmatriz(matriz, filas, columnas);
        for i:=1 to filas do
            for j:=1 to columnas do
                aux[j,i] := matriz[i,j];
        matriz := aux;
    end;

procedure multiplicar_matrices(var matriz_1, matriz_2, resultado:t_tipo_matriz);
    var
        i,j,k,filas_1,columnas_1,filas_2,columnas_2: integer;
    begin
        inicializar_matriz_NaN(resultado);
        obtener_dimensiones_cmatriz(matriz_1, filas_1, columnas_1);
        obtener_dimensiones_cmatriz(matriz_2, filas_2, columnas_2);
        if columnas_1 <> filas_2 then
            begin
                writeln('Error: Las matrices no se pueden multiplicar');
                halt();
            end;
        for i:=1 to filas_1 do
            for j:=1 to columnas_2 do
                begin
                    resultado[i,j] := 0;
                    for k:=1 to columnas_1 do
                        resultado[i,j] := resultado[i,j] + (matriz_1[i,k] * matriz_2[k,j]);
                end;
    end;

procedure potencia_matriz(var matriz:t_tipo_matriz; potencia: real);
    var
        i,j,k,l,filas,columnas,dimension,potencia_aux: integer;
        resultado,aux:t_tipo_matriz;
    begin
        inicializar_matriz_NaN(resultado);
        obtener_dimensiones_cmatriz(matriz, filas, columnas);
        potencia_aux := trunc(potencia);
        if frac(potencia) <> 0 then
            begin
                writeln('Error: La potencia no puede ser decimal');
                halt();
            end;

        if filas <> columnas then
            begin
                writeln('Error: La matriz no es cuadrada');
                halt();
            end;

        if potencia_aux < 0 then
            begin
                writeln('Error: La potencia no puede ser negativa');
                halt();
            end;

        dimension := filas;
        if potencia_aux = 0 then
            for i:=1 to dimension do
                for j:=1 to dimension do
                    if i = j then
                        resultado[i,j] := 1
                    else
                        resultado[i,j] := 0;
      
        if potencia_aux > 1 then
            begin
               aux := matriz;
               for k:=1 to potencia_aux-1 do
                    begin
                        for i:=1 to dimension do
                            for j:=1 to dimension do
                                begin
                                    resultado[i,j] := 0;
                                    for l:=1 to dimension do
                                        resultado[i,j] := resultado[i,j] + (aux[i,l] * matriz[k,l]);
                                end;
                        aux := resultado;
                    end;
            end;
        matriz := resultado;
    end;

procedure matriz_escalar(var matriz:t_tipo_matriz; escalar:real);
    var
        i,j,fila,columna: integer;
    begin
        obtener_dimensiones_cmatriz(matriz, fila, columna);
        for i:=1 to fila do
            for j:=1 to columna do
                matriz[i,j] := matriz[i,j] * escalar;
    end;

procedure suma_matriz(var matriz_1, matriz_2:t_tipo_matriz);
    var
        i,j,filas,columnas,filas_2,columnas_2: integer;
    begin
        obtener_dimensiones_cmatriz(matriz_1, filas, columnas);
        obtener_dimensiones_cmatriz(matriz_2, filas_2, columnas_2);
        if (filas <> filas_2) or (columnas <> columnas_2) then
            begin
                writeln('Error: Las matrices no se pueden sumar por diferentes dimensiones');
                halt();
            end;
        for i:=1 to filas do
            for j:=1 to columnas do
                matriz_1[i,j] := matriz_1[i,j] + matriz_2[i,j];
    end;

procedure resta_matriz(var matriz_1, matriz_2:t_tipo_matriz);
    var
        i,j,filas,columnas,filas_2,columnas_2: integer;
    begin
        obtener_dimensiones_cmatriz(matriz_1, filas, columnas);
        obtener_dimensiones_cmatriz(matriz_2, filas_2, columnas_2);
        if (filas <> filas_2) or (columnas <> columnas_2) then
            begin
                writeln('Error: Las matrices no se pueden restar por diferente dimension');
                halt();
            end;
        for i:=1 to filas do
            for j:=1 to columnas do
                matriz_1[i,j] := matriz_1[i,j] - matriz_2[i,j];
    end;



function pasar_a_matriz(lexema: string; var matriz: t_tipo_matriz): boolean;
    var
    i, j, inicio_numero, columnas_actual: integer;
    fila_str, numero_str: string;
    matriz_valida: boolean;
    filas,columnas: integer;

    begin
        inicializar_matriz_NaN(matriz);
        if (Length(lexema) < 4) or (lexema[1] <> '[') or (lexema[Length(lexema)] <> ']') then
            begin
                WriteLn('Error: Formato inválido.');
                pasar_a_matriz := false;
                Exit;
            end;

        Delete(lexema, 1, 1);
        Delete(lexema, Length(lexema), 1);

        filas := 0;
        i := 1;
        columnas := -1; 
        matriz_valida := true;

        while i <= Length(lexema) do
        begin
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
                        end;
                    j := 1;
                    inicio_numero := 1;
                    while j <= Length(fila_str) do
                        begin
                            if (fila_str[j] = ',') or (j = Length(fila_str)) then
                                begin
                                    columnas_actual := columnas_actual + 1;
                                    numero_str := Copy(fila_str, inicio_numero, j - inicio_numero + Ord(j = Length(fila_str)));
                                    matriz[filas, columnas_actual] := pasar_a_real(numero_str);
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

function matrices_iguales(var A, B: t_tipo_matriz):boolean;
    var
        i, j: integer;
        filas_A, columnas_A,filas_B,columnas_B: integer;
        iguales: boolean;
    begin
        obtener_dimensiones_cmatriz(A, filas_A, columnas_A);
        obtener_dimensiones_cmatriz(B, filas_B, columnas_B);
        iguales := true;

        if (filas_A <> filas_B) or (columnas_A <> columnas_B) then
                iguales := false
        else
            for i := 1 to filas_A do
                for j := 1 to columnas_A do
                    if A[i, j] <> B[i, j] then
                        begin
                            matrices_iguales := false;
                            exit;
                        end;
        matrices_iguales := iguales;
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

// <Tipo> ::=  "matriz" "[" “creal” "]" "["  “creal“ "]" | "real"  
procedure evaluar_tipo(var arbol: puntero_arbol; var estado: t_estado; id_lexema: string);
    var
        tipo: t_tipo;
        fila,columna: integer;
        fila_aux,columna_aux:real;
    begin
        case arbol^.hijos.elem[1]^.simbolo of
            Treal:
                begin
                    tipo := Treal_estado;
                    agregar_real(estado, id_lexema, tipo);
                end;
            Tmatriz:
                begin
                    fila_aux := pasar_a_real(arbol^.hijos.elem[3]^.lexema);
                    columna_aux := pasar_a_real(arbol^.hijos.elem[6]^.lexema);
                    fila := trunc(fila_aux);
                    columna := trunc(columna_aux);
                    tipo := Tmatriz_estado;
                    agregar_matriz(estado, id_lexema, tipo, fila, columna);
                end;
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

// <Sentencias> ::= <Asignacion> | <Leer>| <Escribir> | <Condicinal> | <Ciclo>
procedure evaluar_sentencias(var arbol: puntero_arbol; var estado: t_estado);
    begin
        case arbol^.hijos.elem[1]^.simbolo of
            Vasignacion : evaluar_asignacion(arbol^.hijos.elem[1], estado);
            Vleer : evaluar_leer(arbol^.hijos.elem[1], estado);
            Vescribir : evaluar_escribir(arbol^.hijos.elem[1], estado);
            Vcondicional : evaluar_condicional(arbol^.hijos.elem[1], estado);
            Vciclo : evaluar_ciclo(arbol^.hijos.elem[1], estado);
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


// <Asigancion’> ::=  ":=" <Asignacion’’> |  “[“ <OP>”]””[“<OP> “]” “:=” <OP> 
procedure evaluar_asignacion_prima(var arbol: puntero_arbol; var estado: t_estado; lexema: string);
    var
        tipo_1,tipo_2: t_tipo;
        matriz: t_tipo_matriz;
        fila,columna: integer;
        fila_op,columna_op,valor:real;
    begin
        obtener_tipo(estado, lexema, tipo_1);
        case arbol^.hijos.elem[1]^.simbolo of
            Tasig:
                begin

                    evaluar_asignacion_prima_prima(arbol^.hijos.elem[2], estado, valor, matriz, tipo_2);
               
                    if tipos_iguales(tipo_1, tipo_2) then
                        begin
                            if tipo_1 = Treal_estado then
                                asignar_real(estado, lexema, valor)
                            else
                                asignar_matriz(estado, lexema, matriz);
                        end
                    else
                        begin
                            writeln('Error de tipos en la asignacion de ', lexema);
                            halt();
                        end;

                end;
            Tcorchetea:
                begin
                    obtener_dimensiones(estado, lexema, fila, columna);
                    evaluar_op(arbol^.hijos.elem[2], estado, fila_op, matriz,tipo_2);
                    evaluar_op(arbol^.hijos.elem[5], estado, columna_op, matriz,tipo_2);
                    evaluar_op(arbol^.hijos.elem[8], estado, valor, matriz,tipo_2);
                  
                    if (fila_op > 0) and (columna_op > 0) and (fila_op <= fila) and (columna_op <= columna) then
                        begin
                            columna := trunc(columna_op);
                            fila := trunc(fila_op);
                            if (tipo_1 = Tmatriz_estado) and (tipo_2 = Treal_estado) then
                                asignar_valor_matriz(estado, valor, lexema, fila, columna)
                            else
                                begin
                                    writeln('Error de tipos en la asignacion de ', lexema);
                                    halt();
                                end;
                        end
                    else
                        begin
                            writeln('Error de indices en la asignacion de ', lexema);
                            halt();
                        end;
                end;
        end;


    end;



// <Asignacin’’> :=  <OP> | <CMatriz>   OP PUEDE SER MATRIZ O REAL Y CMATRIZ SIEMPRE MATRIZ
procedure evaluar_asignacion_prima_prima(var arbol: puntero_arbol; var estado: t_estado;var valor: real; var matriz: t_tipo_matriz; var tipo_2: t_tipo);
    begin
        case arbol^.hijos.elem[1]^.simbolo of
            Vop: evaluar_op(arbol^.hijos.elem[1], estado, valor, matriz,tipo_2);

            Vcmatriz:
                begin
                    tipo_2 := Tmatriz_estado;
                    inicializar_matriz_NaN(matriz);
                    evaluar_cmatriz(arbol^.hijos.elem[1], estado, matriz);
                end;
        end;


    end;

// <OP> ::= <OP2> <OP'>
procedure evaluar_op(var arbol: puntero_arbol; var estado: t_estado; var valor:real; var matriz:t_tipo_matriz; var tipo:t_tipo);
    begin
        evaluar_op_2(arbol^.hijos.elem[1], estado,valor,matriz,tipo);
        evaluar_op_prima(arbol^.hijos.elem[2], estado,valor,matriz,tipo);
    end;

// <OP'> ::= "+" <OP2> <OP'> | "-" <OP2> <OP'> | eps 
// MATRIZ + MATRIZ || MATRIZ - MATRIZ || REAL + REAL || REAL - REAL
procedure evaluar_op_prima(var arbol: puntero_arbol; var estado: t_estado; var valor:real; var matriz:t_tipo_matriz;var tipo:t_tipo);
    var
        valor_2: real;
        matriz_2: t_tipo_matriz;
        tipo_2: t_tipo;
    begin
        if arbol^.hijos.cant > 0 then
            begin
                evaluar_op_2(arbol^.hijos.elem[2], estado, valor_2, matriz_2, tipo_2);
                if tipos_iguales(tipo, tipo_2) then
                    begin
                        case arbol^.hijos.elem[1]^.simbolo of
                            Tmas:
                                begin
                                    if tipo = Treal_estado then
                                        valor := valor + valor_2
                                    else 
                                        suma_matriz(matriz, matriz_2);
                                end;
                            Tmenos:
                                begin
                                    if tipo = Treal_estado then
                                        valor := valor - valor_2
                                    else 
                                        resta_matriz(matriz, matriz_2);
                                end;
                        end;
                    end
                else 
                    begin
                        writeln('Error de tipos en la suma o resta');
                        halt();
                    end;

                evaluar_op_prima(arbol^.hijos.elem[3], estado, valor, matriz, tipo);

            end;
    end;


// <OP2> ::= <OP3> <OP2'>
procedure evaluar_op_2(var arbol: puntero_arbol; var estado: t_estado; var valor:real; var matriz:t_tipo_matriz; var tipo:t_tipo);
    begin       
        evaluar_op_3(arbol^.hijos.elem[1], estado,valor,matriz,tipo);
        evaluar_op_2_prima(arbol^.hijos.elem[2], estado,valor,matriz,tipo);
    end;

// <OP2'> ::= "*" <OP3> <OP2'> | "/" <OP3> <OP2'> | eps
// MATRIZ * MATRIZ  || REAL * REAL || REAL / REAL || MATRIZ * REAL || REAL * MATRIZ
procedure evaluar_op_2_prima(var arbol: puntero_arbol; var estado: t_estado; var valor:real; var matriz:t_tipo_matriz; var tipo:t_tipo);
    var
        valor_2: real;
        matriz_2,resultado: t_tipo_matriz;
        tipo_2: t_tipo;
    begin
        if arbol^.hijos.cant > 0 then
            begin
                evaluar_op_3(arbol^.hijos.elem[2], estado, valor_2, matriz_2, tipo_2);
                case arbol^.hijos.elem[1]^.simbolo of
                    Tmulti:
                        begin
                            if tipo = Treal_estado then
                                begin
                                    if tipo_2 = Treal_estado then
                                        valor := valor * valor_2
                                    else 
                                        matriz_escalar(matriz, valor_2);
                                end
                            else 
                                begin
                                    if tipo_2 = Treal_estado then
                                        matriz_escalar(matriz, valor_2)
                                    else 
                                        begin
                                            multiplicar_matrices(matriz, matriz_2,resultado);
                                            matriz := resultado;
                                        end;
                                end;
                        end;
                    Tdivi:
                        begin
                            if tipos_iguales(tipo, tipo_2) then
                                begin
                                    if tipo = Treal_estado then
                                        begin
                                            if valor_2 = 0 then
                                                begin
                                                    writeln('Error: Division por cero');
                                                    halt();
                                                end;
                                            valor := valor / valor_2;
                                        end
                                    else 
                                        begin
                                            writeln('Error, no se puede dividir matrices');
                                            halt();
                                        end;
                                end
                            else 
                                begin
                                    writeln('Error de tipos en la division');
                                    halt();
                                end;
                        end;
                end;

                evaluar_op_2_prima(arbol^.hijos.elem[3], estado, valor, matriz, tipo);
            end;

    end;


// <OP3> ::= <OP4> <OP3'>
procedure evaluar_op_3(var arbol: puntero_arbol; var estado: t_estado; var valor:real; var matriz:t_tipo_matriz; var tipo:t_tipo);
    begin
        evaluar_op_4(arbol^.hijos.elem[1], estado,valor,matriz,tipo);
        evaluar_op_3_prima(arbol^.hijos.elem[2], estado,valor,matriz,tipo);
    end;

// <OP3'> ::= “^” <OP4> <OP3'> | eps
// REAL ^ REAL || MATRIZ ^ REAL 
procedure evaluar_op_3_prima(var arbol: puntero_arbol; var estado: t_estado; var valor:real; var matriz:t_tipo_matriz; var tipo:t_tipo);
    var
        valor_2: real;
        matriz_2: t_tipo_matriz;
        tipo_2: t_tipo;
    begin
        if arbol^.hijos.cant > 0 then
            begin
                evaluar_op_4(arbol^.hijos.elem[2], estado, valor_2, matriz_2, tipo_2);
                
                case tipo of
                    Treal_estado:
                        begin
                            if tipo_2 = Treal_estado then
                                valor := power(valor, valor_2)
                            else 
                                begin
                                    writeln('Error de tipos en la potencia, REAL ^ MATRIZ');
                                    halt();
                                end;
                        end;
                    Tmatriz_estado:
                        begin
                            if tipo_2 = Treal_estado then
                                potencia_matriz(matriz, valor_2)
                            else 
                                begin
                                    writeln('Error de tipos en la potencia , MATRIZ ^ MATRIZ');
                                    halt();
                                end;
                        end;
                end;
                evaluar_op_3_prima(arbol^.hijos.elem[3], estado, valor, matriz, tipo);
            end;
    end;


// <OP4> ::= “id” <OP4’> | “creal” | “filas” “(“ “id” “)” | “columnas” “(“ “id” “)” |
//                   “tras” “(“ “id” “)”  | “-” <OP4> | “(“ <OP> “)” 
procedure evaluar_op_4(var arbol: puntero_arbol; var estado: t_estado; var valor:real; var matriz:t_tipo_matriz; var tipo:t_tipo);
    var
        lexema:string;
        fila,columna: integer;
    begin
        case arbol^.hijos.elem[1]^.simbolo of
            Tid:
                begin
                    lexema := arbol^.hijos.elem[1]^.lexema;
                    obtener_tipo(estado, lexema, tipo);
 
                    if not variable_inicializada(estado, lexema) then
                        begin
                            writeln('Error: La variable ', lexema, ' no ha sido inicializada');
                            halt();
                        end;
                    if tipo = Treal_estado then
                        obtener_real(estado, lexema, valor)
                    else 
                        obtener_matriz(estado, lexema, matriz);

       
                    evaluar_op_4_prima(arbol^.hijos.elem[2], estado, valor, matriz, tipo);
     
                    
                end;
            Tcreal:
                begin
                    valor := pasar_a_real(arbol^.hijos.elem[1]^.lexema);
                    tipo := Treal_estado;
                end;
            Tfilas:
                begin
                    lexema := arbol^.hijos.elem[3]^.lexema;
                    obtener_dimensiones(estado, lexema, fila, columna);
                    valor := fila;
                    tipo := Treal_estado;
                end;
            Tcolumnas:
                begin
                    lexema := arbol^.hijos.elem[3]^.lexema;
                    obtener_dimensiones(estado, lexema, fila, columna);
                    valor := columna;
                    tipo := Treal_estado;
                end;
            Ttras:
                begin
                    lexema := arbol^.hijos.elem[3]^.lexema;
               
                    if not variable_inicializada(estado, lexema) then
                        begin
                            writeln('Error: La variable ', lexema, ' no ha sido inicializada');
                            halt();
                        end;
                    obtener_tipo(estado, lexema, tipo);
                    if tipo <> Tmatriz_estado then
                        begin
                            writeln('Error: No se puede transponer una variable que no es matriz');
                            halt();
                        end;
                    obtener_matriz(estado, lexema, matriz);
                    trasponer_matriz(matriz);
                    tipo := Tmatriz_estado;
                end;
            Tmenos:
                begin
                    evaluar_op_4(arbol^.hijos.elem[2], estado, valor, matriz, tipo);
                    if tipo = Treal_estado then
                        valor := -valor
                    else 
                        matriz_escalar(matriz, -1);
                end;
            Tparentesisa: evaluar_op(arbol^.hijos.elem[2], estado, valor, matriz, tipo);
    

        end;

    end;




// <OP4’> ::= “[“ <OP> “]” “[“ <OP> “]” | eps
procedure evaluar_op_4_prima(var arbol: puntero_arbol; var estado: t_estado; var valor:real; var matriz:t_tipo_matriz; var tipo:t_tipo);
    var
        fila_aux,columna_aux: real;
        fila,columna: integer;
        matriz_2: t_tipo_matriz;
        tipo_2: t_tipo;
    begin
        if arbol^.hijos.cant > 0 then
            begin
                evaluar_op(arbol^.hijos.elem[2], estado, fila_aux, matriz_2, tipo_2);
                evaluar_op(arbol^.hijos.elem[5], estado, columna_aux, matriz_2, tipo_2);
        
                fila := trunc(fila_aux);
                columna := trunc(columna_aux);
  
                if (tipo = Tmatriz_estado) and (fila > 0) and (columna > 0) then
                    begin
                 
                        tipo := Treal_estado;
                        valor := matriz[fila, columna];
                    end
                else 
                    begin
                        writeln('Error de indices en la matriz');
                        halt();
                    end;
            end;
    end;

// <CMatriz> ::= "[" <Filas> "]”
procedure evaluar_cmatriz(var arbol: puntero_arbol; var estado: t_estado; var matriz:t_tipo_matriz);
    var
        fila_aux,columna_aux: integer;
    begin
        fila_aux := 1;
        columna_aux := 1;
        evaluar_filas(arbol^.hijos.elem[2], estado,matriz,fila_aux,columna_aux);
    end;

// <Filas> ::= <Fila> <FilasExtra>
procedure evaluar_filas(var arbol: puntero_arbol; var estado: t_estado; var matriz:t_tipo_matriz;var fila,columna:integer);
    var
        columnas_aux:integer;
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
        valor:real;
    begin
        evaluar_op_4(arbol^.hijos.elem[1], estado,valor,matriz,tipo);
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
        lexema,cadena,valor_leido:string;
        tipo:t_tipo;
        matriz:t_tipo_matriz;
        valor:real;
        fila,columna,fila_op,columna_op:integer;
    begin
        cadena := Copy(arbol^.hijos.elem[3]^.lexema, 2, Length(arbol^.hijos.elem[3]^.lexema) - 2);
        lexema := arbol^.hijos.elem[5]^.lexema;
        obtener_tipo(estado, lexema, tipo);

        if Trim(cadena) <> '' then
            writeln(cadena,': ');
        readln(valor_leido);


        if tipo = Treal_estado then
            begin
                valor := pasar_a_real(valor_leido);
                asignar_real(estado, lexema, valor);
            end
        else 
            begin
                if pasar_a_matriz(valor_leido, matriz) then
                    begin
                        obtener_dimensiones(estado, lexema, fila, columna);
                        obtener_dimensiones_cmatriz(matriz, fila_op, columna_op);
                        if (fila_op > 0) and (columna_op > 0) and (fila_op <= fila) and (columna_op <= columna) then
                            asignar_matriz(estado, lexema, matriz)
                        else 
                            begin
                                writeln('Error de indices en la asignacion de ', lexema);
                                halt();
                            end;
                    end
                else 
                    begin
                        writeln('Error: No se puede asignar un valor no numerico a una matriz');
                        halt();
                    end;
            end;
    end;

// <Escribir> ::= “escribir” “(“ <Lista> “)”
procedure evaluar_escribir(var arbol: puntero_arbol; var estado: t_estado);
    begin
        evaluar_lista(arbol^.hijos.elem[3], estado);
        writeln();
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
            evaluar_lista(arbol^.hijos.elem[2], estado);
    end;
// TODO AL MOSTRAR UNA MATRIZ MOSTRAR CON CORCHETES Y SIN ESPACIOS ENTRE LOS VALORES
// TODO TAMBIEN SI UNA MATRI TIENE NAN EN ALGUN ELEMENTO MOSTRAR -- EN VES DE NAN
// EJ [[1,2],[3,4]] -> 

    // | 1 2 |
    // | 3 4 |

// EJ [[1,2],[NAN,4]] -> 

    // | 1 2 |
    // | - 4 |


// <Elemento> ::= “cadena” | <OP>
procedure evaluar_elemento(var arbol: puntero_arbol; var estado: t_estado);
    var
        valor:real;
        matriz:t_tipo_matriz;
        tipo:t_tipo;

    begin
        case arbol^.hijos.elem[1]^.simbolo of
            Tcadena:
                begin
                    write(Copy(arbol^.hijos.elem[1]^.lexema, 2, Length(arbol^.hijos.elem[1]^.lexema) - 2));
                end;
            Vop:
                begin
                    evaluar_op(arbol^.hijos.elem[1], estado, valor, matriz, tipo);
                    
                    if tipo = Treal_estado then
                        write(valor:0:2)
                    else 
                        begin
                            writeln();
                            escribir_matriz(matriz);
                            writeln();
                        end;
                end;
        end;
    end;

// <Condicional> ::= “if” <Condicion> “{“ <Cuerpo> “}” <SiNo> 
procedure evaluar_condicional(var arbol:puntero_arbol; var estado:t_estado);
    var
        resultado_condicion:boolean;
    begin
        evaluar_condicion(arbol^.hijos.elem[2], estado,resultado_condicion);
        if resultado_condicion then
            evaluar_cuerpo(arbol^.hijos.elem[4], estado)
        else
            evaluar_si_no(arbol^.hijos.elem[6], estado);
    end;

// <SiNo> ::= “else” “{“ <Cuerpo> “}” | eps
procedure evaluar_si_no(var arbol:puntero_arbol; var estado:t_estado);
    begin
        if arbol^.hijos.cant > 0 then
            evaluar_cuerpo(arbol^.hijos.elem[3], estado);
    end;

// <Ciclo> ::= “while” <Condicion> “{“ <Cuerpo> “}” 
procedure evaluar_ciclo(var arbol:puntero_arbol; var estado:t_estado);
    var
        resultado_condicion:boolean;
    begin
        evaluar_condicion(arbol^.hijos.elem[2], estado,resultado_condicion);
        while resultado_condicion do
            begin
                evaluar_cuerpo(arbol^.hijos.elem[4], estado);
                evaluar_condicion(arbol^.hijos.elem[2], estado,resultado_condicion);
            end;

    end;

// <Condicion> ::= “(“  <ExpresionL>  “)” 
procedure evaluar_condicion(var arbol:puntero_arbol; var estado:t_estado; var resultado_condicion:boolean);
    begin
        evaluar_expresion_l(arbol^.hijos.elem[2], estado,resultado_condicion);
    end;
// <ExpresionL> ::= <ExpresionR> <ExpresionL'>
//                | “!” “(“ <ExpresionL> “)”
procedure evaluar_expresion_l(var arbol:puntero_arbol; var estado:t_estado; var resultado_condicion:boolean);

    begin
       case arbol^.hijos.elem[1]^.simbolo of
            VexpresionR: begin
                            evaluar_expresion_r(arbol^.hijos.elem[1], estado, resultado_condicion);
                            evaluar_expresion_l_prima(arbol^.hijos.elem[2], estado, resultado_condicion);
                        end;
            Tnot: begin
                            evaluar_expresion_l(arbol^.hijos.elem[3], estado, resultado_condicion);
                            resultado_condicion := not resultado_condicion;
                        end;
        end;
    end;

// <ExpresionL'> ::= “&&” <ExpresionR> <ExpresionL'> 
//                 | “||” <ExpresionR> <ExpresionL'> 
//                 | eps
procedure evaluar_expresion_l_prima(var arbol:puntero_arbol; var estado:t_estado; var resultado_condicion:boolean);
    var
        resultado_condicion_der:boolean;
    begin
        if arbol^.hijos.cant > 0 then
            begin
                case arbol^.hijos.elem[1]^.simbolo of
                    Tand: begin
                            evaluar_expresion_r(arbol^.hijos.elem[2], estado, resultado_condicion_der);
                            resultado_condicion := (resultado_condicion and resultado_condicion_der);
                        end;
                    Tor: begin
                            evaluar_expresion_r(arbol^.hijos.elem[2], estado, resultado_condicion_der);
                            resultado_condicion := (resultado_condicion or resultado_condicion_der);
                        end;
                end;
            
           
                evaluar_expresion_l_prima(arbol^.hijos.elem[3], estado, resultado_condicion);

            end;
    end;

// <ExpresionR> ::= “?” <OP> <Comparacion> <OP> “?” | “(“ <ExpresionL> “)”
procedure evaluar_expresion_r(var arbol:puntero_arbol; var estado:t_estado; var resultado_condicion:boolean);
    var
        valor_izq,valor_der:real;
        matriz_izq,matriz_der:t_tipo_matriz;
        tipo_izq,tipo_der:t_tipo;
    begin
        case arbol^.hijos.elem[1]^.simbolo of
            Tpregunta: begin  
                        evaluar_op(arbol^.hijos.elem[2], estado,valor_izq,matriz_izq,tipo_izq);
                        evaluar_op(arbol^.hijos.elem[4], estado,valor_der,matriz_der,tipo_der);

                        evaluar_comparacion(arbol^.hijos.elem[3], estado,valor_izq,valor_der,matriz_izq,matriz_der,tipo_izq,tipo_der,resultado_condicion);
                       end;
            Tparentesisa: evaluar_expresion_l(arbol^.hijos.elem[2], estado, resultado_condicion);
        end;
    end;

// <Comparacion> ::= “==” | “!=” | “>” | “<” | “ >=” | “<=”  
procedure evaluar_comparacion(var arbol:puntero_arbol;var estado:t_estado;var valor_izq,valor_der:real;var matriz_izq,matriz_der:t_tipo_matriz;
                              var tipo_izq,tipo_der:t_tipo;var resultado_condicion:boolean);

    begin
        if tipo_izq <> tipo_der then
            begin
                writeln('Error: No se puede comparar valor de distinto tipo');
                halt();
            end
        else
            begin
                case arbol^.hijos.elem[1]^.simbolo of
                    Tigual: begin
                                if tipo_izq = Treal_estado then
                                    resultado_condicion := (valor_izq = valor_der)
                                else
                                    resultado_condicion := (matrices_iguales(matriz_izq, matriz_der));
                            end;
                    Tdiferente: begin
                                    if tipo_izq = Treal_estado then
                                        resultado_condicion := (valor_izq <> valor_der)
                                    else
                                        resultado_condicion := not matrices_iguales(matriz_izq, matriz_der);
                                end;
                    Tmayor: begin
                                if tipo_izq = Treal_estado then
                                    resultado_condicion := (valor_izq > valor_der)
                                else
                                    begin
                                        writeln('Error: No se puede comparar una matriz con otra con >');
                                        halt();
                                    end;
                            end;
                    Tmenor: begin
                                if tipo_izq = Treal_estado then
                                    resultado_condicion := (valor_izq < valor_der)
                                else
                                    begin
                                        writeln('Error: No se puede comparar una matriz con otra con <');
                                        halt();
                                    end;
                            end;
                    Tmayori: begin 
                                    if tipo_izq = Treal_estado then
                                        resultado_condicion := (valor_izq >= valor_der)
                                    else
                                        begin
                                            writeln('Error: No se puede comparar una matriz con otra con >=');
                                            halt();
                                        end;
                                end; 
                    Tmenori: begin 
                                    if tipo_izq = Treal_estado then
                                        resultado_condicion := (valor_izq <= valor_der)
                                    else
                                        begin
                                            writeln('Error: No se puede comparar una matriz con otra con <=');
                                            halt();
                                        end;
                                end; 
                    end;

            end;
    end;

END.
