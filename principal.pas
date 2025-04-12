program principal;
{$codepage utf8}


USES
    crt,analizador_sintactico,evaluador;

VAR
    arbol:   puntero_arbol;
    error:   boolean;
    estado:   t_estado;
    ruta_fuente,ruta_archivo:   string;

BEGIN
    clrscr;
    ruta_fuente:='C:\ARCHIVOS\FUENTE.txt';
    ruta_archivo:='C:\ARCHIVOS\ARBOL.txt';
    analizador_predictivo(ruta_fuente,arbol,error);
    IF NOT error THEN
        BEGIN
            guardar_arbol(ruta_archivo,arbol);
            inicializar_estado(estado);
            evaluar_programa(arbol,estado);
        END;
    readln;

END.