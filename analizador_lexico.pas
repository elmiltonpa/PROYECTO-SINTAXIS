UNIT analizador_Lexico;



INTERFACE

USES
    crt,SysUtils;

CONST

    MaxSim = 200;
    FinArch = #0;

TYPE

    TipoSG = (Tprogram, Tid , Tpuntoyc , Tllavea , Tllavec , Tdef , Tdosp , Tmatriz , Tcorchetea , Tcorchetec , Treal , Tasig , 
              Tmas , Tmenos , Tmulti , Tdivi , Texpo , Tcreal , Tfilas , Ttrans ,Tparentesisa , Tparentesisc , Tcolumnas , Tcoma , Tleer , 
              Tcadena , Tescribir , Tif , Telse, Twhile , Tnot , Tand , Tor , Tigual , Tdiferente, Tmayor , Tmenor , Tmayori ,Tpregunta , Tmenori,
              pesos,ErrorLexico ,Vprograma , Vdefiniciones, Vlistadefiniciones, Vmasdefiniciones , Vdefinicion , Vtipo , Vcuerpo ,
              Vsentencias, Vasignacion, Vasignacionp, Vop , Vopp , Vop2 , Vop2p , Vop3 , Vop3p , Vop4 , Vop4p , Vcmatriz , Vfilas ,
              Vfilasextra , Vfila , Vnumeros , Vnumerosp , Vleer , Vescribir , Vlista , Vlistap , Velemento , Vcondicional , Vsino , 
              Vciclo , Vcondicion , Vexpresionl , Vexpresionlp , Vexpresionr , Vcomparacion );


    t_archivo = file of char; 
    t_elem_TS = record  
        complex : TipoSG;
        lexema : string;
        end;

    tabla_simbolos = record
        elem: array [1..MaxSim] of T_elem_TS;
        cant: 0..MaxSim;
        end; 

    procedure inicializarTS(var ts: tabla_simbolos);
    procedure completarTS(var ts: tabla_simbolos);
    procedure leer_car(var fuente:t_archivo;var control:longint; var car:char);
    function es_id(var fuente:t_archivo;var control:longint;var lexema:string):boolean;
    function es_constante_real(var fuente:t_archivo;var control:longint;var lexema:string):boolean;
    function es_cadena(var fuente:t_archivo;var control:longint;var lexema:string):boolean;
    function es_simbolo_especial(var fuente:t_archivo;var control:longint;var lexema:string;var compLex:TipoSG):boolean;
    procedure obtener_siguiente_complex(var fuente:t_archivo;var control:longint; var compLex:TipoSG;var lexema:string;
                                        var ts:tabla_simbolos);

IMPLEMENTATION

procedure inicializarTS(var ts: tabla_simbolos);
    begin
        ts.cant := 0;
    end;

procedure completarTS(var ts: tabla_simbolos);
    begin
        Inc(ts.cant);
        ts.elem[ts.cant].lexema := 'while';
        ts.elem[ts.cant].complex := Twhile;
        Inc(ts.cant);
        ts.elem[ts.cant].lexema := 'if';
        ts.elem[ts.cant].complex := Tif;
        Inc(ts.cant);
        ts.elem[ts.cant].lexema := 'def';
        ts.elem[ts.cant].complex := Tdef;
        Inc(ts.cant);
        ts.elem[ts.cant].lexema := 'program';
        ts.elem[ts.cant].complex := Tprogram;
        Inc(ts.cant);
        ts.elem[ts.cant].lexema := 'leer';
        ts.elem[ts.cant].complex := Tleer;
        Inc(ts.cant);
        ts.elem[ts.cant].lexema := 'escribir';
        ts.elem[ts.cant].complex := Tescribir;
        Inc(ts.cant);
        ts.elem[ts.cant].lexema := 'else';
        ts.elem[ts.cant].complex := Telse;
        Inc(ts.cant);
        ts.elem[ts.cant].lexema := 'matriz';
        ts.elem[ts.cant].complex := Tmatriz;
        Inc(ts.cant);
        ts.elem[ts.cant].lexema := 'real';
        ts.elem[ts.cant].complex := Treal;
        Inc(ts.cant);
        ts.elem[ts.cant].lexema := 'columnas';
        ts.elem[ts.cant].complex := Tcolumnas;
        Inc(ts.cant);
        ts.elem[ts.cant].lexema := 'filas';
        ts.elem[ts.cant].complex := Tfilas;
        Inc(ts.cant);
        ts.elem[ts.cant].lexema := 'trans';
        ts.elem[ts.cant].complex := Ttrans;
    end;

procedure agregar_TS(var ts: tabla_simbolos; lexema:string;var complex:TipoSG);
    var
        i:byte;
        encontrado:boolean;
    begin
        encontrado := false;
        i := 1;
        while (i <= ts.cant) and (not encontrado) do
            begin
                if (ts.elem[i].lexema = lexema) then
                    begin
                        complex := ts.elem[i].complex;
                        encontrado := true
                    end
                else
                    i := i + 1;
            end;
        
        if not encontrado then
            begin
                Inc(ts.cant);
                ts.elem[ts.cant].lexema := lexema;
                ts.elem[ts.cant].complex := Tid;
                complex := Tid;
            end;
    end;

procedure leer_car(var fuente:t_archivo;var control:longint; var car:char);
    begin
        if control < filesize(fuente) then
            begin
                seek(fuente,control);
                read(fuente,car);
            end
        else
            car := FinArch;
    end;

function es_id(var fuente:t_archivo;var control:longint;var lexema:string):boolean;

    CONST
        q0 = 0;
        F = [2];

    TYPE
        Q = 0..3;
        sigma = (L,D,O);
        tipo_delta = array [Q,sigma] of Q;

    VAR
        estado_actual: Q;
        car: char;
        delta: tipo_delta;
        control_local: longint;

    function car_a_simbolo(car:char):sigma;
        begin
            case car of
                'a'..'z','A'..'Z': car_a_simbolo := L;
                '0'..'9': car_a_simbolo := D;
                else    
                    car_a_simbolo := O;
            end;
        end;

    begin
        lexema := '';
        control_local := control;
        delta[0,L] := 1;
        delta[0,D] := 3;
        delta[0,O] := 3;
        delta[1,L] := 1;
        delta[1,D] := 1;
        delta[1,O] := 2;
 
        estado_actual := q0;

        while (estado_actual <> 3) and (estado_actual <> 2) do
            begin
                leer_car(fuente,control_local,car);
                estado_actual := delta[estado_actual,car_a_simbolo(car)];
                Inc(control_local);
                if (estado_actual <> 3) and (estado_actual <> 2 ) then
                    lexema := lexema + car;
            end;

        if estado_actual in F then
            begin
                es_id := true;
                control := (control_local - 1);
            end
        else
            es_id := false;

    end;

function es_constante_real(var fuente:t_archivo;var control:longint;var lexema:string):boolean;

    CONST
        q0 = 0;
        F = [5];

    TYPE
        Q = 0..5;
        sigma = (D,P,O);
        tipo_delta = array [Q,sigma] of Q;

    VAR
        estado_actual: Q;
        car: char;
        delta: tipo_delta;
        control_local: longint;

    function car_a_simbolo(car:char):sigma;
        begin
            case car of
                '0'..'9': car_a_simbolo := D;
                '.': car_a_simbolo := P;
                else    
                    car_a_simbolo := O;
            end;
        end;

    begin
        lexema := '';
        control_local := control;
        delta[0,D] := 1;
        delta[0,P] := 4;
        delta[0,O] := 4;
        delta[1,D] := 1;
        delta[1,P] := 2;
        delta[1,O] := 5;
        delta[2,D] := 3;
        delta[2,P] := 4;
        delta[2,O] := 4;
        delta[3,D] := 3;
        delta[3,P] := 4;
        delta[3,O] := 5;
    

        estado_actual := q0;
      

        while (estado_actual <> 4) and (estado_actual <> 5) do
            begin
                leer_car(fuente,control_local,car);
                estado_actual := delta[estado_actual,car_a_simbolo(car)];
                Inc(control_local);
                if (estado_actual <> 4) and (estado_actual <> 5) then
                    begin
                        lexema := lexema + car;
                    end;
            end;
        if estado_actual in F then
            begin
                es_constante_real := true;
                control := (control_local-1);
            end
        else
            es_constante_real := false;

    end;

function es_cadena(var fuente:t_archivo;var control:longint;var lexema:string):boolean;

    CONST
        q0 = 0;
        F = [2];

    TYPE
        Q = 0..3;
        sigma = (C,O);
        tipo_delta = array [Q,sigma] of Q;

    VAR
        estado_actual: Q;
        car: char;
        delta: tipo_delta;
        control_local: longint;

    function car_a_simbolo(car:char):sigma;
        begin
            case car of
                #39 : car_a_simbolo := C;
                else    
                    car_a_simbolo := O;
            end;
        end;

    begin
        lexema := '';
        control_local := control;
        delta[0,C] := 1;
        delta[0,O] := 3;
        delta[1,C] := 2;
        delta[1,O] := 1;
    
        estado_actual := q0;

        while (estado_actual <> 3) and (estado_actual <> 2) do
            begin
                leer_car(fuente,control_local,car);
                estado_actual := delta[estado_actual,car_a_simbolo(car)];
                Inc(control_local);
                if estado_actual in [0,1,2] then
                    begin
                        lexema := lexema + car;   
                    end;
                if car = FinArch then
                    begin
                        estado_actual := 3;
                    end;
            end;
        if estado_actual in F then
            begin
                es_cadena := true;
                control := (control_local);
            end
        else
            es_cadena := false;

    end;

function es_simbolo_especial(var fuente:t_archivo;var control:longint;var lexema:string;var complex:TipoSG):boolean;

    var
        car: char;

    begin
        leer_car(fuente,control,car);
        Inc(control);
        lexema:=car;
        es_simbolo_especial := true;

        case car of
            ';' : complex := Tpuntoyc;
            ',' : complex := Tcoma;
            '{' : complex := Tllavea;
            '}' : complex := Tllavec;
            '(' : complex := Tparentesisa;
            ')' : complex := Tparentesisc;
            '[' : complex := Tcorchetea;
            ']' : complex := Tcorchetec;
            '+' : complex := Tmas;
            '-' : complex := Tmenos;
            '*' : complex := Tmulti;
            '/' : complex := Tdivi;
            '^' : complex := Texpo;
            '?' : complex := Tpregunta;
            '&' : begin
                    leer_car(fuente,control,car);
                    if car = '&' then
                        begin
                            lexema := '&&';
                            Inc(control);
                            complex := Tand;
                        end
                    else
                        begin
                            Dec(control);
                            es_simbolo_especial := false;
                        end;
                  end;
            ':' : begin
                    leer_car(fuente,control,car);
                    if car = '=' then
                        begin
                            lexema := ':=';
                            Inc(control);
                            complex := Tasig;
                        end
                    else
                        complex := Tdosp;
                  end;
            '=' : begin
                    leer_car(fuente,control,car);
                    if car = '=' then
                        begin
                            lexema := '==';
                            Inc(control);
                            complex := Tigual;
                        end
                    else
                        begin
                            Dec(control);
                            es_simbolo_especial := false;
                        end;
                    end;
            '!' : begin
                    leer_car(fuente,control,car);
                    if car = '=' then
                        begin
                            lexema := '!=';
                            Inc(control);
                            complex := Tdiferente;
                        end
                    else
                        complex := Tnot;
                  end;
            '|' : begin
                    leer_car(fuente,control,car);
                    if car = '|' then
                        begin
                            lexema := '||';
                            Inc(control);
                            complex := Tor;
                        end
                    else
                        begin
                            Dec(control);
                            es_simbolo_especial := false;
                        end;
                  end;  
            '<' : begin
                    leer_car(fuente,control,car);
                    if car = '=' then
                        begin
                            lexema := '<=';
                            Inc(control);
                            complex := Tmenori;
                        end
                    else
                        complex := Tmenor;
                  end;
            '>' : begin
                    leer_car(fuente,control,car);
                    if car = '=' then
                        begin
                            lexema := '>=';
                            Inc(control);
                            complex := Tmayori;
                        end
                    else
                        complex := Tmayor;
                  end;
            else
                begin
                    es_simbolo_especial := false;
                    
                end;
        end;

    end;

procedure obtener_siguiente_complex(var fuente:t_archivo;var control:longint; var complex:TipoSG;var lexema:string;
                                    var ts:tabla_simbolos);

    var
        car: char;

    begin 

        leer_car(fuente,control,car);
        while car in [#1..#32] do
            begin
                Inc(control);
                leer_car(fuente,control,car);
            end;    
        if car = FinArch then
            complex := pesos
        else
            begin
                if es_id(fuente,control,lexema) then
                    agregar_TS(ts,lexema,complex)
                else
                    if es_constante_real(fuente,control,lexema) then
                        begin
                            complex := Tcreal
                        end
                    else
                        if es_cadena(fuente,control,lexema) then
                            complex := Tcadena
                        else
                            if not es_simbolo_especial(fuente,control,lexema,complex) then
                               begin
                                    complex := ErrorLexico;
                                end;
            end;



        
    end;

END.



