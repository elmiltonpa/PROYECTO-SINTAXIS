program pruebas;

USES
    crt,sysutils,math;

CONST
    max_filas=10;
    max_columnas=10;

TYPE
     t_tipo_matriz = array[1..max_filas, 1..max_columnas] of real;
    

function EliminarEspacios(entrada: string): string;
var
  i: integer;
  salida: string;
begin
  salida := '';
  for i := 1 to Length(entrada) do
    if entrada[i] <> ' ' then
      salida := salida + entrada[i];

    EliminarEspacios := salida;
end;


function StringAMatrizReal(cadena: string; var matriz: t_tipo_matriz;var filas, columnas: integer): boolean;
var
  i, j, k, inicioNumero, columnasActual: integer;
  filaStr, numeroStr: string;
  matriz_valida: boolean;
begin
  // Eliminar corchetes exteriores
  Delete(cadena, 1, 1);
  Delete(cadena, Length(cadena), 1);

  filas := 0;
  i := 1;
  columnas := -1;  // Inicialmente desconocido
  matriz_valida := true;

  while i <= Length(cadena) do
  begin
    if cadena[i] = '[' then
    begin
      filas := filas + 1;
      columnasActual := 0;
      filaStr := '';
      i := i + 1; // Avanzar después de '['

      while (i <= Length(cadena)) and (cadena[i] <> ']') do
      begin
        filaStr := filaStr + cadena[i];
        i := i + 1;
      end;

      // Extraer números de la fila
      j := 1;
      inicioNumero := 1;
      while j <= Length(filaStr) do
      begin
        if (filaStr[j] = ',') or (j = Length(filaStr)) then
        begin
          columnasActual := columnasActual + 1;
          numeroStr := Copy(filaStr, inicioNumero, j - inicioNumero + Ord(j = Length(filaStr)));
          matriz[filas, columnasActual] := StrToFloat(numeroStr);
          inicioNumero := j + 1;
        end;
        j := j + 1;
      end;

      // Validar que la cantidad de columnas sea consistente
      if columnas = -1 then
        columnas := columnasActual  // Guardamos la cantidad de columnas de la primera fila
      else if columnasActual <> columnas then
      begin
        WriteLn('Error: Fila ', filas, ' tiene ', columnasActual, ' columnas, pero se esperaban ', columnas);
        matriz_valida := false;
      end;
    end;
    i := i + 1;
  end;

  // Si no hubo errores, devolver true
  StringAMatrizReal := matriz_valida;
end;


procedure mostrar_matriz(var matriz: t_tipo_matriz; filas, columnas: integer);
var
    i, j: integer;
begin
    for i := 1 to filas do
    begin
        write('[');
        for j := 1 to columnas do
        begin
            write(matriz[i, j]:0:2); // Imprime con 2 decimales
            if j < columnas then
                write(', '); // Separador de columnas
        end;
        writeln(']'); // Cierra la fila
    end;
end;

var

    matriz: t_tipo_matriz;
    lexema: string;
    fila,columna: integer;
BEGIN
    lexema := '[[11]]';
    if StringAMatrizReal(lexema,matriz,fila,columna) then
        begin
            writeln('FILA: ',fila);
            writeln('COLUMNAS: ',columna);
            mostrar_matriz(matriz, 10, 10);
        end
    else
        begin
            writeln('Error al convertir la cadena a matriz');
        end;


END.