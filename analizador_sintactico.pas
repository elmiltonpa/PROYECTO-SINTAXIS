UNIT analizador_sintactico;


INTERFACE 

USES
    crt,analizador_lexico;

CONST
    max_producciones = 8;

TYPE
    t_produccion = record
        elem: array[1..max_producciones] of TipoSG;
        cant: 0..max_producciones;
    end;    

    t_variable = Vprograma..Vcomparacion;
    t_terminales = Tprogram..pesos;

    t_TAS = array[t_variable,t_terminales] of ^t_produccion;

    puntero_arbol = ^t_nodo_arbol;

    t_hijos = record
        elem: array[1..max_producciones] of puntero_arbol;
        cant: 0..max_producciones;
    end;

    t_nodo_arbol = record
        simbolo: TipoSG;
        lexema: string;
        hijos:t_hijos;
    end;

    // PILAS

    t_elem_pila = record
        simbolo: tipoSG;
        n_arbol: puntero_arbol;
    end;

    puntero_pila = ^t_nodo_pila;

    t_pila = record
        tope: puntero_pila;
        tam: word;
    end;

    t_nodo_pila = record
        info: t_elem_pila;
        sig: puntero_pila;
    end;

    array_producciones = array[0..max_producciones] of TipoSG;
    
    procedure crear_pila(var p: t_pila);
    procedure apilar(var p: t_pila; x: t_elem_pila);
    procedure desapilar(var p: t_pila; var x: t_elem_pila);
    procedure guardar_arbol(ruta: string;var arbol: puntero_arbol);
    procedure analizador_predictivo(var ruta_fuente:string; var arbol: puntero_arbol;var error:boolean);

IMPLEMENTATION

procedure crear_pila(var p: t_pila);
    begin
        p.tope:=nil;
        p.tam:=0;
    end;

procedure apilar(var p: t_pila; x: t_elem_pila);
    var
        nuevo: puntero_pila;
    begin
        new(nuevo);
        nuevo^.info:=x;
        nuevo^.sig:=p.tope;
        p.tope:=nuevo;
        Inc(p.tam);
    end;

procedure desapilar(var p: t_pila; var x: t_elem_pila);
    var
        aux: puntero_pila;
    begin
        aux:=p.tope;
        x:=aux^.info;
        p.tope:=aux^.sig;
        dispose(aux);
        Dec(p.tam);
    end;

procedure apilar_todos(var celda: t_produccion; var padre:puntero_arbol;var p: t_pila);
    var
        i: integer;
        elem: t_elem_pila;
    begin
        for i:=celda.cant downto 1 do
            begin
                elem.simbolo := celda.elem[i];
                elem.n_arbol := padre^.hijos.elem[i];
                apilar(p,elem);
            end;
    end;

procedure inicializarTAS(var TAS: t_TAS);
    var
        i,j: TipoSG;
    begin
        for i:=Vprograma to Vcomparacion do
            for j:=Tprogram to pesos do
                TAS[i,j]:=nil;
    end;

procedure cargarTAS(var TAS: t_TAS);

    begin

        new(TAS[Vprograma,Tprogram]);
        TAS[Vprograma,Tprogram]^.elem[1]:=Tprogram;
        TAS[Vprograma,Tprogram]^.elem[2]:=Tid;
        TAS[Vprograma,Tprogram]^.elem[3]:=Tpuntoyc;
        TAS[Vprograma,Tprogram]^.elem[4]:=Vdefiniciones;
        TAS[Vprograma,Tprogram]^.elem[5]:=Tllavea;
        TAS[Vprograma,Tprogram]^.elem[6]:=Vcuerpo;
        TAS[Vprograma,Tprogram]^.elem[7]:=Tllavec;
        TAS[Vprograma,Tprogram]^.cant:=7;

        new(TAS[Vdefiniciones,Tllavea]);
        TAS[Vdefiniciones,Tllavea]^.cant:=0;

        new(TAS[Vdefiniciones,Tdef]);
        TAS[Vdefiniciones,Tdef]^.elem[1]:=Tdef;
        TAS[Vdefiniciones,Tdef]^.elem[2]:=Vlistadefiniciones;
        TAS[Vdefiniciones,Tdef]^.cant:=2;

        new(TAS[Vlistadefiniciones,Tid]);
        TAS[Vlistadefiniciones,Tid]^.elem[1]:=Vdefinicion;
        TAS[Vlistadefiniciones,Tid]^.elem[2]:=Tpuntoyc;
        TAS[Vlistadefiniciones,Tid]^.elem[3]:=Vmasdefiniciones;
        TAS[Vlistadefiniciones,Tid]^.cant:=3;

        new(TAS[Vmasdefiniciones,Tid]);
        TAS[Vmasdefiniciones,Tid]^.elem[1]:=Vlistadefiniciones;
        TAS[Vmasdefiniciones,Tid]^.cant:=1;

        new(TAS[Vmasdefiniciones,Tllavea]);
        TAS[Vmasdefiniciones,Tllavea]^.cant:=0;

        new(TAS[Vdefinicion,Tid]);
        TAS[Vdefinicion,Tid]^.elem[1]:=Tid;
        TAS[Vdefinicion,Tid]^.elem[2]:=Tdosp;
        TAS[Vdefinicion,Tid]^.elem[3]:=Vtipo;
        TAS[Vdefinicion,Tid]^.cant:=3;

        new(TAS[Vtipo,Tmatriz]);
        TAS[Vtipo,Tmatriz]^.elem[1]:=Tmatriz;
        TAS[Vtipo,Tmatriz]^.elem[2]:=Tcorchetea;
        TAS[Vtipo,Tmatriz]^.elem[3]:=Tcreal;
        TAS[Vtipo,Tmatriz]^.elem[4]:=Tcorchetec;
        TAS[Vtipo,Tmatriz]^.elem[5]:=Tcorchetea;
        TAS[Vtipo,Tmatriz]^.elem[6]:=Tcreal;
        TAS[Vtipo,Tmatriz]^.elem[7]:=Tcorchetec;
        TAS[Vtipo,Tmatriz]^.cant:=7;

        new(TAS[Vtipo,Treal]);
        TAS[Vtipo,Treal]^.elem[1]:=Treal;
        TAS[Vtipo,Treal]^.cant:=1;

        new(TAS[Vcuerpo,Tid]);
        TAS[Vcuerpo,Tid]^.elem[1]:=Vsentencias;
        TAS[Vcuerpo,Tid]^.elem[2]:=Tpuntoyc;
        TAS[Vcuerpo,Tid]^.elem[3]:=Vcuerpo;
        TAS[Vcuerpo,Tid]^.cant:=3;

        new(TAS[Vcuerpo,Tllavec]);
        TAS[Vcuerpo,Tllavec]^.cant:=0;

        new(TAS[Vcuerpo,Tleer]);
        TAS[Vcuerpo,Tleer]^.elem[1]:=Vsentencias;
        TAS[Vcuerpo,Tleer]^.elem[2]:=Tpuntoyc;
        TAS[Vcuerpo,Tleer]^.elem[3]:=Vcuerpo;
        TAS[Vcuerpo,Tleer]^.cant:=3;

        new(TAS[Vcuerpo,Tescribir]);
        TAS[Vcuerpo,Tescribir]^.elem[1]:=Vsentencias;
        TAS[Vcuerpo,Tescribir]^.elem[2]:=Tpuntoyc;
        TAS[Vcuerpo,Tescribir]^.elem[3]:=Vcuerpo;
        TAS[Vcuerpo,Tescribir]^.cant:=3;

        new(TAS[Vcuerpo,Tif]);
        TAS[Vcuerpo,Tif]^.elem[1]:=Vsentencias;
        TAS[Vcuerpo,Tif]^.elem[2]:=Tpuntoyc;
        TAS[Vcuerpo,Tif]^.elem[3]:=Vcuerpo;
        TAS[Vcuerpo,Tif]^.cant:=3;

        new(TAS[Vcuerpo,Twhile]);
        TAS[Vcuerpo,Twhile]^.elem[1]:=Vsentencias;
        TAS[Vcuerpo,Twhile]^.elem[2]:=Tpuntoyc;
        TAS[Vcuerpo,Twhile]^.elem[3]:=Vcuerpo;
        TAS[Vcuerpo,Twhile]^.cant:=3;

        new(TAS[Vsentencias,Tid]);
        TAS[Vsentencias,Tid]^.elem[1]:=Vasignacion;
        TAS[Vsentencias,Tid]^.cant:=1;

        new(TAS[Vsentencias,Tleer]);
        TAS[Vsentencias,Tleer]^.elem[1]:=Vleer;
        TAS[Vsentencias,Tleer]^.cant:=1;

        new(TAS[Vsentencias,Tescribir]);
        TAS[Vsentencias,Tescribir]^.elem[1]:=Vescribir;
        TAS[Vsentencias,Tescribir]^.cant:=1;

        new(TAS[Vsentencias,Tif]);
        TAS[Vsentencias,Tif]^.elem[1]:=Vcondicional;
        TAS[Vsentencias,Tif]^.cant:=1;

        new(TAS[Vsentencias,Twhile]);
        TAS[Vsentencias,Twhile]^.elem[1]:=Vciclo;
        TAS[Vsentencias,Twhile]^.cant:=1;

        new(TAS[Vasignacion,Tid]);
        TAS[Vasignacion,Tid]^.elem[1]:=Tid;
        TAS[Vasignacion,Tid]^.elem[2]:=Vasignacionp;
        TAS[Vasignacion,Tid]^.cant:=2;

        new(TAS[Vasignacionp,Tcorchetea]);
        TAS[Vasignacionp,Tcorchetea]^.elem[1]:=Tcorchetea;
        TAS[Vasignacionp,Tcorchetea]^.elem[2]:=Vop;
        TAS[Vasignacionp,Tcorchetea]^.elem[3]:=Tcorchetec;
        TAS[Vasignacionp,Tcorchetea]^.elem[4]:=Tcorchetea;
        TAS[Vasignacionp,Tcorchetea]^.elem[5]:=Vop;
        TAS[Vasignacionp,Tcorchetea]^.elem[6]:=Tcorchetec;
        TAS[Vasignacionp,Tcorchetea]^.elem[7]:=Tasig;
        TAS[Vasignacionp,Tcorchetea]^.elem[8]:=Vop;
        TAS[Vasignacionp,Tcorchetea]^.cant:=8;

        new(TAS[Vasignacionp,Tasig]);
        TAS[Vasignacionp,Tasig]^.elem[1]:=Tasig;
        TAS[Vasignacionp,Tasig]^.elem[2]:=Vasignacionpp;
        TAS[Vasignacionp,Tasig]^.cant:=2;

        new(TAS[Vasignacionpp,Tid]);
        TAS[Vasignacionpp,Tid]^.elem[1]:=Vop;
        TAS[Vasignacionpp,Tid]^.cant:=1;

        new(TAS[Vasignacionpp,Tcorchetea]);
        TAS[Vasignacionpp,Tcorchetea]^.elem[1]:=Vcmatriz;
        TAS[Vasignacionpp,Tcorchetea]^.cant:=1;

        new(TAS[Vasignacionpp,Tmenos]);
        TAS[Vasignacionpp,Tmenos]^.elem[1]:=Vop;
        TAS[Vasignacionpp,Tmenos]^.cant:=1;

        new(TAS[Vasignacionpp,Tcreal]);
        TAS[Vasignacionpp,Tcreal]^.elem[1]:=Vop;
        TAS[Vasignacionpp,Tcreal]^.cant:=1;

        new(TAS[Vasignacionpp,Tfilas]);
        TAS[Vasignacionpp,Tfilas]^.elem[1]:=Vop;
        TAS[Vasignacionpp,Tfilas]^.cant:=1;

        new(TAS[Vasignacionpp,Tparentesisa]);
        TAS[Vasignacionpp,Tparentesisa]^.elem[1]:=Vop;
        TAS[Vasignacionpp,Tparentesisa]^.cant:=1;

        new(TAS[Vasignacionpp,Ttras]);
        TAS[Vasignacionpp,Ttras]^.elem[1]:=Vop;
        TAS[Vasignacionpp,Ttras]^.cant:=1;

        new(TAS[Vasignacionpp,Tcolumnas]);
        TAS[Vasignacionpp,Tcolumnas]^.elem[1]:=Vop;
        TAS[Vasignacionpp,Tcolumnas]^.cant:=1;

        new(TAS[Vop,Tid]);
        TAS[Vop,Tid]^.elem[1]:=Vop2;
        TAS[Vop,Tid]^.elem[2]:=Vopp;
        TAS[Vop,Tid]^.cant:=2;

        new(TAS[Vop,Tmenos]);
        TAS[Vop,Tmenos]^.elem[1]:=Vop2;
        TAS[Vop,Tmenos]^.elem[2]:=Vopp;
        TAS[Vop,Tmenos]^.cant:=2;

        new(TAS[Vop,Tcreal]);
        TAS[Vop,Tcreal]^.elem[1]:=Vop2;
        TAS[Vop,Tcreal]^.elem[2]:=Vopp;
        TAS[Vop,Tcreal]^.cant:=2;

        new(TAS[Vop,Tfilas]);
        TAS[Vop,Tfilas]^.elem[1]:=Vop2;
        TAS[Vop,Tfilas]^.elem[2]:=Vopp;
        TAS[Vop,Tfilas]^.cant:=2;

        new(TAS[Vop,Tparentesisa]);
        TAS[Vop,Tparentesisa]^.elem[1]:=Vop2;
        TAS[Vop,Tparentesisa]^.elem[2]:=Vopp;
        TAS[Vop,Tparentesisa]^.cant:=2;

        new(TAS[Vop,Ttras]);
        TAS[Vop,Ttras]^.elem[1]:=Vop2;
        TAS[Vop,Ttras]^.elem[2]:=Vopp;
        TAS[Vop,Ttras]^.cant:=2;

        new(TAS[Vop,Tcolumnas]);
        TAS[Vop,Tcolumnas]^.elem[1]:=Vop2;
        TAS[Vop,Tcolumnas]^.elem[2]:=Vopp;
        TAS[Vop,Tcolumnas]^.cant:=2;

        new(TAS[Vopp,Tpuntoyc]);
        TAS[Vopp,Tpuntoyc]^.cant:=0;

        new(TAS[Vopp,Tcorchetec]);
        TAS[Vopp,Tcorchetec]^.cant:=0;

        new(TAS[Vopp,Tmas]);
        TAS[Vopp,Tmas]^.elem[1]:=Tmas;
        TAS[Vopp,Tmas]^.elem[2]:=Vop2;
        TAS[Vopp,Tmas]^.elem[3]:=Vopp;
        TAS[Vopp,Tmas]^.cant:=3;

        new(TAS[Vopp,Tmenos]);
        TAS[Vopp,Tmenos]^.elem[1]:=Tmenos;
        TAS[Vopp,Tmenos]^.elem[2]:=Vop2;
        TAS[Vopp,Tmenos]^.elem[3]:=Vopp;
        TAS[Vopp,Tmenos]^.cant:=3;

        new(TAS[Vopp,Tparentesisc]);
        TAS[Vopp,Tparentesisc]^.cant:=0;

        new(TAS[Vopp,Tcoma]);
        TAS[Vopp,Tcoma]^.cant:=0;

        new(TAS[Vopp,Tigual]);
        TAS[Vopp,Tigual]^.cant:=0;

        new(TAS[Vopp,Tdiferente]);
        TAS[Vopp,Tdiferente]^.cant:=0;

        new(TAS[Vopp,Tmayor]);
        TAS[Vopp,Tmayor]^.cant:=0;

        new(TAS[Vopp,Tmenor]);
        TAS[Vopp,Tmenor]^.cant:=0;

        new(TAS[Vopp,Tmayori]);
        TAS[Vopp,Tmayori]^.cant:=0;

        new(TAS[Vopp,Tmenori]);
        TAS[Vopp,Tmenori]^.cant:=0;

        new(TAS[Vopp,Tpregunta]);
        TAS[Vopp,Tpregunta]^.cant:=0;

        new(TAS[Vop2,Tid]);
        TAS[Vop2,Tid]^.elem[1]:=Vop3;
        TAS[Vop2,Tid]^.elem[2]:=Vop2p;
        TAS[Vop2,Tid]^.cant:=2;

        new(TAS[Vop2,Tmenos]);
        TAS[Vop2,Tmenos]^.elem[1]:=Vop3;
        TAS[Vop2,Tmenos]^.elem[2]:=Vop2p;
        TAS[Vop2,Tmenos]^.cant:=2;

        new(TAS[Vop2,Tcreal]);
        TAS[Vop2,Tcreal]^.elem[1]:=Vop3;
        TAS[Vop2,Tcreal]^.elem[2]:=Vop2p;
        TAS[Vop2,Tcreal]^.cant:=2;

        new(TAS[Vop2,Tfilas]);
        TAS[Vop2,Tfilas]^.elem[1]:=Vop3;
        TAS[Vop2,Tfilas]^.elem[2]:=Vop2p;
        TAS[Vop2,Tfilas]^.cant:=2;

        new(TAS[Vop2,Tparentesisa]);
        TAS[Vop2,Tparentesisa]^.elem[1]:=Vop3;
        TAS[Vop2,Tparentesisa]^.elem[2]:=Vop2p;
        TAS[Vop2,Tparentesisa]^.cant:=2;

        new(TAS[Vop2,Ttras]);
        TAS[Vop2,Ttras]^.elem[1]:=Vop3;
        TAS[Vop2,Ttras]^.elem[2]:=Vop2p;
        TAS[Vop2,Ttras]^.cant:=2;

        new(TAS[Vop2,Tcolumnas]);
        TAS[Vop2,Tcolumnas]^.elem[1]:=Vop3;
        TAS[Vop2,Tcolumnas]^.elem[2]:=Vop2p;
        TAS[Vop2,Tcolumnas]^.cant:=2;

        new(TAS[Vop2p,Tpuntoyc]);
        TAS[Vop2p,Tpuntoyc]^.cant:=0;

        new(TAS[Vop2p,Tcorchetec]);
        TAS[Vop2p,Tcorchetec]^.cant:=0;

        new(TAS[Vop2p,Tmas]);
        TAS[Vop2p,Tmas]^.cant:=0;

        new(TAS[Vop2p,Tmenos]);
        TAS[Vop2p,Tmenos]^.cant:=0;

        new(TAS[Vop2p,Tmulti]);
        TAS[Vop2p,Tmulti]^.elem[1]:=Tmulti;
        TAS[Vop2p,Tmulti]^.elem[2]:=Vop3;
        TAS[Vop2p,Tmulti]^.elem[3]:=Vop2p;
        TAS[Vop2p,Tmulti]^.cant:=3;

        new(TAS[Vop2p,Tdivi]);
        TAS[Vop2p,Tdivi]^.elem[1]:=Tdivi;
        TAS[Vop2p,Tdivi]^.elem[2]:=Vop3;
        TAS[Vop2p,Tdivi]^.elem[3]:=Vop2p;
        TAS[Vop2p,Tdivi]^.cant:=3;

        new(TAS[Vop2p,Tparentesisc]);
        TAS[Vop2p,Tparentesisc]^.cant:=0;

        new(TAS[Vop2p,Tcoma]);
        TAS[Vop2p,Tcoma]^.cant:=0;

        new(TAS[Vop2p,Tigual]);
        TAS[Vop2p,Tigual]^.cant:=0;

        new(TAS[Vop2p,Tdiferente]);
        TAS[Vop2p,Tdiferente]^.cant:=0;

        new(TAS[Vop2p,Tmayor]);
        TAS[Vop2p,Tmayor]^.cant:=0;

        new(TAS[Vop2p,Tmenor]);
        TAS[Vop2p,Tmenor]^.cant:=0;

        new(TAS[Vop2p,Tmayori]);
        TAS[Vop2p,Tmayori]^.cant:=0;

        new(TAS[Vop2p,Tmenori]);
        TAS[Vop2p,Tmenori]^.cant:=0;

        new(TAS[Vop2p,Tpregunta]);
        TAS[Vop2p,Tpregunta]^.cant:=0;

        new(TAS[Vop3,Tid]);
        TAS[Vop3,Tid]^.elem[1]:=Vop4;
        TAS[Vop3,Tid]^.elem[2]:=Vop3p;
        TAS[Vop3,Tid]^.cant:=2;

        new(TAS[Vop3,Tmenos]);
        TAS[Vop3,Tmenos]^.elem[1]:=Vop4;
        TAS[Vop3,Tmenos]^.elem[2]:=Vop3p;
        TAS[Vop3,Tmenos]^.cant:=2;

        new(TAS[Vop3,Tcreal]);
        TAS[Vop3,Tcreal]^.elem[1]:=Vop4;
        TAS[Vop3,Tcreal]^.elem[2]:=Vop3p;
        TAS[Vop3,Tcreal]^.cant:=2;

        new(TAS[Vop3,Tfilas]);
        TAS[Vop3,Tfilas]^.elem[1]:=Vop4;
        TAS[Vop3,Tfilas]^.elem[2]:=Vop3p;
        TAS[Vop3,Tfilas]^.cant:=2;

        new(TAS[Vop3,Tparentesisa]);
        TAS[Vop3,Tparentesisa]^.elem[1]:=Vop4;
        TAS[Vop3,Tparentesisa]^.elem[2]:=Vop3p;
        TAS[Vop3,Tparentesisa]^.cant:=2;

        new(TAS[Vop3,Ttras]);
        TAS[Vop3,Ttras]^.elem[1]:=Vop4;
        TAS[Vop3,Ttras]^.elem[2]:=Vop3p;
        TAS[Vop3,Ttras]^.cant:=2;

        new(TAS[Vop3,Tcolumnas]);
        TAS[Vop3,Tcolumnas]^.elem[1]:=Vop4;
        TAS[Vop3,Tcolumnas]^.elem[2]:=Vop3p;
        TAS[Vop3,Tcolumnas]^.cant:=2;

        new(TAS[Vop3p,Tpuntoyc]);
        TAS[Vop3p,Tpuntoyc]^.cant:=0;

        new(TAS[Vop3p,Tcorchetec]);
        TAS[Vop3p,Tcorchetec]^.cant:=0;

        new(TAS[Vop3p,Tmas]);
        TAS[Vop3p,Tmas]^.cant:=0;

        new(TAS[Vop3p,Tmenos]);
        TAS[Vop3p,Tmenos]^.cant:=0;

        new(TAS[Vop3p,Tmulti]);
        TAS[Vop3p,Tmulti]^.cant:=0;

        new(TAS[Vop3p,Tdivi]);
        TAS[Vop3p,Tdivi]^.cant:=0;

        new(TAS[Vop3p,Texpo]);
        TAS[Vop3p,Texpo]^.elem[1]:=Texpo;
        TAS[Vop3p,Texpo]^.elem[2]:=Vop4;
        TAS[Vop3p,Texpo]^.elem[3]:=Vop3p;
        TAS[Vop3p,Texpo]^.cant:=3;

        new(TAS[Vop3p,Tparentesisc]);
        TAS[Vop3p,Tparentesisc]^.cant:=0;

        new(TAS[Vop3p,Tcoma]);
        TAS[Vop3p,Tcoma]^.cant:=0;

        new(TAS[Vop3p,Tigual]);
        TAS[Vop3p,Tigual]^.cant:=0;

        new(TAS[Vop3p,Tdiferente]);
        TAS[Vop3p,Tdiferente]^.cant:=0;

        new(TAS[Vop3p,Tmayor]);
        TAS[Vop3p,Tmayor]^.cant:=0;

        new(TAS[Vop3p,Tmenor]);
        TAS[Vop3p,Tmenor]^.cant:=0;

        new(TAS[Vop3p,Tmayori]);
        TAS[Vop3p,Tmayori]^.cant:=0;

        new(TAS[Vop3p,Tmenori]);
        TAS[Vop3p,Tmenori]^.cant:=0;

        new(TAS[Vop3p,Tpregunta]);
        TAS[Vop3p,Tpregunta]^.cant:=0;

        new(TAS[Vop4,Tid]);
        TAS[Vop4,Tid]^.elem[1]:=Tid;
        TAS[Vop4,Tid]^.elem[2]:=Vop4p;
        TAS[Vop4,Tid]^.cant:=2;

        new(TAS[Vop4,Tmenos]);
        TAS[Vop4,Tmenos]^.elem[1]:=Tmenos;
        TAS[Vop4,Tmenos]^.elem[2]:=Vop4;
        TAS[Vop4,Tmenos]^.cant:=2;

        new(TAS[Vop4,Tcreal]);
        TAS[Vop4,Tcreal]^.elem[1]:=Tcreal;
        TAS[Vop4,Tcreal]^.cant:=1;

        new(TAS[Vop4,Tfilas]);
        TAS[Vop4,Tfilas]^.elem[1]:=Tfilas;
        TAS[Vop4,Tfilas]^.elem[2]:=Tparentesisa;
        TAS[Vop4,Tfilas]^.elem[3]:=Tid;
        TAS[Vop4,Tfilas]^.elem[4]:=Tparentesisc;
        TAS[Vop4,Tfilas]^.cant:=4;

        new(TAS[Vop4,Tparentesisa]);
        TAS[Vop4,Tparentesisa]^.elem[1]:=Tparentesisa;
        TAS[Vop4,Tparentesisa]^.elem[2]:=Vop;
        TAS[Vop4,Tparentesisa]^.elem[3]:=Tparentesisc;
        TAS[Vop4,Tparentesisa]^.cant:=3;

        new(TAS[Vop4,Ttras]);
        TAS[Vop4,Ttras]^.elem[1]:=Ttras;
        TAS[Vop4,Ttras]^.elem[2]:=Tparentesisa;
        TAS[Vop4,Ttras]^.elem[3]:=Tid;
        TAS[Vop4,Ttras]^.elem[4]:=Tparentesisc;
        TAS[Vop4,Ttras]^.cant:=4;

        new(TAS[Vop4,Tcolumnas]);
        TAS[Vop4,Tcolumnas]^.elem[1]:=Tcolumnas;
        TAS[Vop4,Tcolumnas]^.elem[2]:=Tparentesisa;
        TAS[Vop4,Tcolumnas]^.elem[3]:=Tid;
        TAS[Vop4,Tcolumnas]^.elem[4]:=Tparentesisc;
        TAS[Vop4,Tcolumnas]^.cant:=4;

        new(TAS[Vop4p,Tpuntoyc]);
        TAS[Vop4p,Tpuntoyc]^.cant:=0;

        new(TAS[Vop4p,Tcorchetea]);
        TAS[Vop4p,Tcorchetea]^.elem[1]:=Tcorchetea;
        TAS[Vop4p,Tcorchetea]^.elem[2]:=Vop;
        TAS[Vop4p,Tcorchetea]^.elem[3]:=Tcorchetec;
        TAS[Vop4p,Tcorchetea]^.elem[4]:=Tcorchetea;
        TAS[Vop4p,Tcorchetea]^.elem[5]:=Vop;
        TAS[Vop4p,Tcorchetea]^.elem[6]:=Tcorchetec;
        TAS[Vop4p,Tcorchetea]^.cant:=6;

        new(TAS[Vop4p,Tcorchetec]);
        TAS[Vop4p,Tcorchetec]^.cant:=0;

        new(TAS[Vop4p,Tmas]);
        TAS[Vop4p,Tmas]^.cant:=0;

        new(TAS[Vop4p,Tmenos]);
        TAS[Vop4p,Tmenos]^.cant:=0;

        new(TAS[Vop4p,Tmulti]);
        TAS[Vop4p,Tmulti]^.cant:=0;
 
        new(TAS[Vop4p,Tdivi]);
        TAS[Vop4p,Tdivi]^.cant:=0;

        new(TAS[Vop4p,Texpo]);
        TAS[Vop4p,Texpo]^.cant:=0;

        new(TAS[Vop4p,Tparentesisc]);
        TAS[Vop4p,Tparentesisc]^.cant:=0;

        new(TAS[Vop4p,Tcoma]);
        TAS[Vop4p,Tcoma]^.cant:=0;

        new(TAS[Vop4p,Tigual]);
        TAS[Vop4p,Tigual]^.cant:=0;

        new(TAS[Vop4p,Tdiferente]);
        TAS[Vop4p,Tdiferente]^.cant:=0;

        new(TAS[Vop4p,Tmayor]);
        TAS[Vop4p,Tmayor]^.cant:=0;

        new(TAS[Vop4p,Tmenor]);
        TAS[Vop4p,Tmenor]^.cant:=0;

        new(TAS[Vop4p,Tmayori]);
        TAS[Vop4p,Tmayori]^.cant:=0;

        new(TAS[Vop4p,Tmenori]);
        TAS[Vop4p,Tmenori]^.cant:=0;

        new(TAS[Vop4p,Tpregunta]);
        TAS[Vop4p,Tpregunta]^.cant:=0;

        new(TAS[Vop4p,pesos]);
        TAS[Vop4p,pesos]^.cant:=0;

        new(TAS[Vcmatriz,Tcorchetea]);
        TAS[Vcmatriz,Tcorchetea]^.elem[1]:=Tcorchetea;
        TAS[Vcmatriz,Tcorchetea]^.elem[2]:=Vfilas;
        TAS[Vcmatriz,Tcorchetea]^.elem[3]:=Tcorchetec;
        TAS[Vcmatriz,Tcorchetea]^.cant:=3;

        new(TAS[VFilas,Tcorchetea]);
        TAS[VFilas,Tcorchetea]^.elem[1]:=Vfila;
        TAS[VFilas,Tcorchetea]^.elem[2]:=Vfilasextra;
        TAS[VFilas,Tcorchetea]^.cant:=2;

        new(TAS[Vfilasextra,Tcorchetec]);
        TAS[Vfilasextra,Tcorchetec]^.cant:=0;

        new(TAS[Vfilasextra,Tcoma]);
        TAS[Vfilasextra,Tcoma]^.elem[1]:=Tcoma;
        TAS[Vfilasextra,Tcoma]^.elem[2]:=Vfilas;
        TAS[Vfilasextra,Tcoma]^.cant:=2;

        new(TAS[Vfila,Tcorchetea]);
        TAS[Vfila,Tcorchetea]^.elem[1]:=Tcorchetea;
        TAS[Vfila,Tcorchetea]^.elem[2]:=Vnumeros;
        TAS[Vfila,Tcorchetea]^.elem[3]:=Tcorchetec;
        TAS[Vfila,Tcorchetea]^.cant:=3;

        new(TAS[Vnumeros,Tid]);
        TAS[Vnumeros,Tid]^.elem[1]:=Vop4;
        TAS[Vnumeros,Tid]^.elem[2]:=Vnumerosp;
        TAS[Vnumeros,Tid]^.cant:=2;

        new(TAS[Vnumeros,Tmenos]);
        TAS[Vnumeros,Tmenos]^.elem[1]:=Vop4;
        TAS[Vnumeros,Tmenos]^.elem[2]:=Vnumerosp;
        TAS[Vnumeros,Tmenos]^.cant:=2;

        new(TAS[Vnumeros,Tcreal]);
        TAS[Vnumeros,Tcreal]^.elem[1]:=Vop4;
        TAS[Vnumeros,Tcreal]^.elem[2]:=Vnumerosp;
        TAS[Vnumeros,Tcreal]^.cant:=2;

        new(TAS[Vnumeros,Tfilas]);
        TAS[Vnumeros,Tfilas]^.elem[1]:=Vop4;
        TAS[Vnumeros,Tfilas]^.elem[2]:=Vnumerosp;
        TAS[Vnumeros,Tfilas]^.cant:=2;

        new(TAS[Vnumeros,Tparentesisa]);
        TAS[Vnumeros,Tparentesisa]^.elem[1]:=Vop4;
        TAS[Vnumeros,Tparentesisa]^.elem[2]:=Vnumerosp;
        TAS[Vnumeros,Tparentesisa]^.cant:=2;

        new(TAS[Vnumeros,Ttras]);
        TAS[Vnumeros,Ttras]^.elem[1]:=Vop4;
        TAS[Vnumeros,Ttras]^.elem[2]:=Vnumerosp;
        TAS[Vnumeros,Ttras]^.cant:=2;

        new(TAS[Vnumeros,Tcolumnas]);
        TAS[Vnumeros,Tcolumnas]^.elem[1]:=Vop4;
        TAS[Vnumeros,Tcolumnas]^.elem[2]:=Vnumerosp;
        TAS[Vnumeros,Tcolumnas]^.cant:=2;

        new(TAS[Vnumerosp,Tcorchetec]);
        TAS[Vnumerosp,Tcorchetec]^.cant:=0;

        new(TAS[Vnumerosp,Tcoma]);
        TAS[Vnumerosp,Tcoma]^.elem[1]:=Tcoma;
        TAS[Vnumerosp,Tcoma]^.elem[2]:=Vnumeros;
        TAS[Vnumerosp,Tcoma]^.cant:=2;

        new(TAS[Vleer,Tleer]);
        TAS[Vleer,Tleer]^.elem[1]:=Tleer;
        TAS[Vleer,Tleer]^.elem[2]:=Tparentesisa;
        TAS[Vleer,Tleer]^.elem[3]:=Tcadena;
        TAS[Vleer,Tleer]^.elem[4]:=Tcoma;
        TAS[Vleer,Tleer]^.elem[5]:=Tid;
        TAS[Vleer,Tleer]^.elem[6]:=Tparentesisc;
        TAS[Vleer,Tleer]^.cant:=6;

        new(TAS[Vescribir,Tescribir]);
        TAS[Vescribir,Tescribir]^.elem[1]:=Tescribir;
        TAS[Vescribir,Tescribir]^.elem[2]:=Tparentesisa;
        TAS[Vescribir,Tescribir]^.elem[3]:=Vlista;
        TAS[Vescribir,Tescribir]^.elem[4]:=Tparentesisc;
        TAS[Vescribir,Tescribir]^.cant:=4;

        new(TAS[Vlista,Tid]);  
        TAS[Vlista,Tid]^.elem[1]:=Velemento;
        TAS[Vlista,Tid]^.elem[2]:=Vlistap;
        TAS[Vlista,Tid]^.cant:=2;

        new(TAS[Vlista,Tmenos]);
        TAS[Vlista,Tmenos]^.elem[1]:=Velemento;
        TAS[Vlista,Tmenos]^.elem[2]:=Vlistap;
        TAS[Vlista,Tmenos]^.cant:=2;

        new(TAS[Vlista,Tcreal]);
        TAS[Vlista,Tcreal]^.elem[1]:=Velemento;
        TAS[Vlista,Tcreal]^.elem[2]:=Vlistap;
        TAS[Vlista,Tcreal]^.cant:=2;

        new(TAS[Vlista,Tfilas]);
        TAS[Vlista,Tfilas]^.elem[1]:=Velemento;
        TAS[Vlista,Tfilas]^.elem[2]:=Vlistap;
        TAS[Vlista,Tfilas]^.cant:=2;

        new(TAS[Vlista,Tparentesisa]);
        TAS[Vlista,Tparentesisa]^.elem[1]:=Velemento;
        TAS[Vlista,Tparentesisa]^.elem[2]:=Vlistap;
        TAS[Vlista,Tparentesisa]^.cant:=2;

        new(TAS[Vlista,Ttras]);
        TAS[Vlista,Ttras]^.elem[1]:=Velemento;
        TAS[Vlista,Ttras]^.elem[2]:=Vlistap;
        TAS[Vlista,Ttras]^.cant:=2;

        new(TAS[Vlista,Tcolumnas]);
        TAS[Vlista,Tcolumnas]^.elem[1]:=Velemento;
        TAS[Vlista,Tcolumnas]^.elem[2]:=Vlistap;
        TAS[Vlista,Tcolumnas]^.cant:=2;

        new(TAS[Vlista,Tcadena]);
        TAS[Vlista,Tcadena]^.elem[1]:=Velemento;
        TAS[Vlista,Tcadena]^.elem[2]:=Vlistap;
        TAS[Vlista,Tcadena]^.cant:=2;

        new(TAS[Vlistap,Tparentesisc]);
        TAS[Vlistap,Tparentesisc]^.cant:=0;

        new(TAS[Vlistap,Tcoma]);
        TAS[Vlistap,Tcoma]^.elem[1]:=Tcoma;
        TAS[Vlistap,Tcoma]^.elem[2]:=Vlista;
        TAS[Vlistap,Tcoma]^.cant:=2;

        new(TAS[Velemento,Tid]);
        TAS[Velemento,Tid]^.elem[1]:=Vop;
        TAS[Velemento,Tid]^.cant:=1;

        new(TAS[Velemento,Tmenos]);
        TAS[Velemento,Tmenos]^.elem[1]:=Vop;
        TAS[Velemento,Tmenos]^.cant:=1;

        new(TAS[Velemento,Tcreal]);
        TAS[Velemento,Tcreal]^.elem[1]:=Vop;
        TAS[Velemento,Tcreal]^.cant:=1;

        new(TAS[Velemento,Tfilas]);
        TAS[Velemento,Tfilas]^.elem[1]:=Vop;
        TAS[Velemento,Tfilas]^.cant:=1;

        new(TAS[Velemento,Tparentesisa]);
        TAS[Velemento,Tparentesisa]^.elem[1]:=Vop;
        TAS[Velemento,Tparentesisa]^.cant:=1;

        new(TAS[Velemento,Ttras]);
        TAS[Velemento,Ttras]^.elem[1]:=Vop;
        TAS[Velemento,Ttras]^.cant:=1;

        new(TAS[Velemento,Tcolumnas]);
        TAS[Velemento,Tcolumnas]^.elem[1]:=Vop;
        TAS[Velemento,Tcolumnas]^.cant:=1;

        new(TAS[Velemento,Tcadena]);
        TAS[Velemento,Tcadena]^.elem[1]:=Tcadena;
        TAS[Velemento,Tcadena]^.cant:=1;

        new(TAS[Vcondicional,Tif]);
        TAS[Vcondicional,Tif]^.elem[1]:=Tif;
        TAS[Vcondicional,Tif]^.elem[2]:=Vcondicion;
        TAS[Vcondicional,Tif]^.elem[3]:=Tllavea;
        TAS[Vcondicional,Tif]^.elem[4]:=Vcuerpo;
        TAS[Vcondicional,Tif]^.elem[5]:=Tllavec;
        TAS[Vcondicional,Tif]^.elem[6]:=Vsino;
        TAS[Vcondicional,Tif]^.cant:=6;

        new(TAS[Vsino,Tpuntoyc]);
        TAS[Vsino,Tpuntoyc]^.cant:=0;

        new(TAS[Vsino,Telse]);
        TAS[Vsino,Telse]^.elem[1]:=Telse;
        TAS[Vsino,Telse]^.elem[2]:=Tllavea;
        TAS[Vsino,Telse]^.elem[3]:=Vcuerpo;
        TAS[Vsino,Telse]^.elem[4]:=Tllavec;
        TAS[Vsino,Telse]^.cant:=4;

        new(TAS[Vciclo,Twhile]);
        TAS[Vciclo,Twhile]^.elem[1]:=Twhile;
        TAS[Vciclo,Twhile]^.elem[2]:=Vcondicion;
        TAS[Vciclo,Twhile]^.elem[3]:=Tllavea;
        TAS[Vciclo,Twhile]^.elem[4]:=Vcuerpo;
        TAS[Vciclo,Twhile]^.elem[5]:=Tllavec;
        TAS[Vciclo,Twhile]^.cant:=5;

        new(TAS[Vcondicion,Tparentesisa]);
        TAS[Vcondicion,Tparentesisa]^.elem[1]:=Tparentesisa;
        TAS[Vcondicion,Tparentesisa]^.elem[2]:=Vexpresionl;
        TAS[Vcondicion,Tparentesisa]^.elem[3]:=Tparentesisc;
        TAS[Vcondicion,Tparentesisa]^.cant:=3;

        new(TAS[Vexpresionl,Tparentesisa]);
        TAS[Vexpresionl,Tparentesisa]^.elem[1]:=Vexpresionr;
        TAS[Vexpresionl,Tparentesisa]^.elem[2]:=Vexpresionlp;
        TAS[Vexpresionl,Tparentesisa]^.cant:=2;

        new(TAS[Vexpresionl,Tnot]);
        TAS[Vexpresionl,Tnot]^.elem[1]:=Tnot;
        TAS[Vexpresionl,Tnot]^.elem[2]:=Tparentesisa;
        TAS[Vexpresionl,Tnot]^.elem[3]:=Vexpresionl;
        TAS[Vexpresionl,Tnot]^.elem[4]:=Tparentesisc;
        TAS[Vexpresionl,Tnot]^.cant:=4;

        new(TAS[Vexpresionl,Tpregunta]);
        TAS[Vexpresionl,Tpregunta]^.elem[1]:=VexpresionR;
        TAS[Vexpresionl,Tpregunta]^.elem[2]:=Vexpresionlp;
        TAS[Vexpresionl,Tpregunta]^.cant:=2;

        new(TAS[Vexpresionlp,Tparentesisc]);
        TAS[Vexpresionlp,Tparentesisc]^.cant:=0;

        new(TAS[Vexpresionlp,Tand]);
        TAS[Vexpresionlp,Tand]^.elem[1]:=Tand;
        TAS[Vexpresionlp,Tand]^.elem[2]:=Vexpresionr;
        TAS[Vexpresionlp,Tand]^.elem[3]:=Vexpresionlp;
        TAS[Vexpresionlp,Tand]^.cant:=3;

        new(TAS[Vexpresionlp,Tor]);
        TAS[Vexpresionlp,Tor]^.elem[1]:=Tor;
        TAS[Vexpresionlp,Tor]^.elem[2]:=Vexpresionr;
        TAS[Vexpresionlp,Tor]^.elem[3]:=Vexpresionlp;
        TAS[Vexpresionlp,Tor]^.cant:=3;

        new(TAS[Vexpresionr,Tparentesisa]);
        TAS[Vexpresionr,Tparentesisa]^.elem[1]:=Tparentesisa;
        TAS[Vexpresionr,Tparentesisa]^.elem[2]:=Vexpresionl;
        TAS[Vexpresionr,Tparentesisa]^.elem[3]:=Tparentesisc;
        TAS[Vexpresionr,Tparentesisa]^.cant:=3;

        new(TAS[Vexpresionr,Tpregunta]);
        TAS[Vexpresionr,Tpregunta]^.elem[1]:=Tpregunta;
        TAS[Vexpresionr,Tpregunta]^.elem[2]:=Vop;
        TAS[Vexpresionr,Tpregunta]^.elem[3]:=Vcomparacion;
        TAS[Vexpresionr,Tpregunta]^.elem[4]:=Vop;
        TAS[Vexpresionr,Tpregunta]^.elem[5]:=Tpregunta;
        TAS[Vexpresionr,Tpregunta]^.cant:=5;

        new(TAS[Vcomparacion,Tigual]);
        TAS[Vcomparacion,Tigual]^.elem[1]:=Tigual;
        TAS[Vcomparacion,Tigual]^.cant:=1;

        new(TAS[Vcomparacion,Tdiferente]);
        TAS[Vcomparacion,Tdiferente]^.elem[1]:=Tdiferente;
        TAS[Vcomparacion,Tdiferente]^.cant:=1;

        new(TAS[Vcomparacion,Tmayor]);
        TAS[Vcomparacion,Tmayor]^.elem[1]:=Tmayor;
        TAS[Vcomparacion,Tmayor]^.cant:=1;

        new(TAS[Vcomparacion,Tmenor]);
        TAS[Vcomparacion,Tmenor]^.elem[1]:=Tmenor;
        TAS[Vcomparacion,Tmenor]^.cant:=1;

        new(TAS[Vcomparacion,Tmayori]);
        TAS[Vcomparacion,Tmayori]^.elem[1]:=Tmayori;
        TAS[Vcomparacion,Tmayori]^.cant:=1;

        new(TAS[Vcomparacion,Tmenori]);
        TAS[Vcomparacion,Tmenori]^.elem[1]:=Tmenori;
        TAS[Vcomparacion,Tmenori]^.cant:=1;

        new(TAS[Vopp,pesos]);
        TAS[Vopp,pesos]^.cant:=0;

        new(TAS[Vop2p,pesos]);
        TAS[Vop2p,pesos]^.cant:=0;

        new(TAS[Vop3p,pesos]);
        TAS[Vop3p,pesos]^.cant:=0;

        new(TAS[Vcuerpo,pesos]);
        TAS[Vcuerpo,pesos]^.cant:=0;

        new(TAS[Vdefinicion,pesos]);
        TAS[Vdefinicion,pesos]^.cant:=0;

        new(TAS[Vfilasextra,pesos]);
        TAS[Vfilasextra,pesos]^.cant:=0;

        new(TAS[Vnumerosp,pesos]);
        TAS[Vnumerosp,pesos]^.cant:=0;

        new(TAS[Vsino,pesos]);
        TAS[Vsino,pesos]^.cant:=0;

        new(TAS[Vexpresionlp,pesos]);
        TAS[Vexpresionlp,pesos]^.cant:=0;

    end;

procedure crear_nodo(SG: TipoSG; var puntero: puntero_arbol);
    begin
        new(puntero);
        puntero^.simbolo:=SG;
        puntero^.lexema:='';
        puntero^.hijos.cant:=0;
    end;

procedure agregar_hijo(var raiz: puntero_arbol; hijo: puntero_arbol);
    begin
        if raiz^.hijos.cant < max_producciones then
            begin
                Inc(raiz^.hijos.cant);
                raiz^.hijos.elem[raiz^.hijos.cant]:=hijo;
            end;
    end;

procedure analizador_predictivo(var ruta_fuente:string; var arbol:puntero_arbol; var error:boolean);
    var
        control: longint;
        TS: tabla_simbolos;
        TAS: t_TAS;
        pila: t_pila;
        estado: (proceso, error_lexico, error_sintactico, exito );
        elem: t_elem_pila;
        fuente: t_archivo;
        complex: TipoSG;
        lexema: string;
        i: 0..max_producciones;
        aux: TipoSG;
        aux2: puntero_arbol;
        car: char;
    begin
        assign(fuente,ruta_fuente);
        {$i-}
            reset(fuente);
        {$i+}
        if IOresult<>0 then
            begin
            writeln('X');
            readkey;
            end;
        read(fuente,car);

        inicializarTS(TS);
        completarTS(TS);

        inicializarTAS(TAS);
        cargarTAS(TAS);

        crear_pila(pila);

        crear_nodo(Vprograma,arbol);
        elem.simbolo:=pesos;
        elem.n_arbol:=nil;

        apilar(pila,elem);
        elem.simbolo:=Vprograma;
        elem.n_arbol:=arbol;
        apilar(pila,elem);

        control:=0;
        obtener_siguiente_complex(fuente,control,complex,lexema,TS);

        estado:=proceso;

        while (estado = proceso) do 
            begin
                desapilar(pila,elem);
                if elem.simbolo in [Tprogram..Tmenori] then
                    begin
                        if elem.simbolo = complex Then
                            begin
                                elem.n_arbol^.lexema:=lexema;
                                obtener_siguiente_complex(fuente,control,complex,lexema,TS);
                            end
                        else
                            begin
                                estado:=error_sintactico;
                                writeln('Error sintactico: se esperaba ',elem.simbolo,' y se encontro ',complex);
                                writeln(control);
                                error:=true;
                            end;
                    end;
                if elem.simbolo in [Vprograma..Vcomparacion] then
                    begin
                        if TAS[elem.simbolo,complex] = nil then
                            begin
                                estado:= error_sintactico;
                                writeln('Error sintactico: no se encontro produccion para ',elem.simbolo,' y ',complex);
                                writeln(control);
                                error:=true;
                            end
                        else
                            begin
                                for i:=1 to TAS[elem.simbolo,complex]^.cant do
                                    begin
                                        aux := TAS[elem.simbolo,complex]^.elem[i];
                                        crear_nodo(aux,aux2);
                                        agregar_hijo(elem.n_arbol,aux2);
                                    end;    
                                apilar_todos(TAS[elem.simbolo,complex]^,elem.n_arbol,pila); 
                            end;
                    end
                else
                    begin
                        if (complex = pesos) and (elem.simbolo = pesos) then
                            begin
                                estado:= exito;
                                error:= false;
                            end;
                    end;
            end;
        close(fuente);
    end;

procedure guardar_nodo(var archivo:text; var arbol:puntero_arbol; dezpl:string);
    var
        i:byte;
    begin
        writeln(archivo, dezpl, arbol^.simbolo, ' (', arbol^.lexema, ')');
        for i:=1 to arbol^.hijos.cant do
            guardar_nodo(archivo, arbol^.hijos.elem[i], dezpl+'  ');
    end;

procedure guardar_arbol(ruta: string;var arbol: puntero_arbol);
    var
        archivo: text;
    begin
        assign(archivo,ruta);
        rewrite(archivo);
        guardar_nodo(archivo,arbol,'');
        close(archivo);
    end;

END.

