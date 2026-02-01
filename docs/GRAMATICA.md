# Gramática del Lenguaje

A continuación se detalla la gramática formal del lenguaje, especificada en **BNF (Backus-Naur Form)**. Esta gramática define la estructura sintáctica permitida para declarar variables, matrices y estructuras de control.

## Estructura General

```ebnf
<Programa>          ::= "program" "id" ";" <Definiciones> "{" <Cuerpo> "}"

<Definiciones>      ::= "def" <ListaDefiniciones> 
                      | eps

<ListaDefiniciones> ::= <Definicion> ";" <MasDefiniciones>

<MasDefiniciones>   ::= <ListaDefiniciones> 
                      | eps

<Definicion>        ::= "id" ":" <Tipo>

<Tipo>              ::= "matriz" "[" "creal" "]" "[" "creal" "]" 
                      | "real"

<Cuerpo>            ::= <Sentencias> ";" <Cuerpo> 
                      | eps
```

## Sentencias y Estructuras de Control

```ebnf
<Sentencias>    ::= <Asignacion> 
                  | <Leer> 
                  | <Escribir> 
                  | <Condicional> 
                  | <Ciclo>

<Leer>          ::= "leer" "(" "cadena" "," "id" ")"

<Escribir>      ::= "escribir" "(" <Lista> ")"

<Lista>         ::= <Elemento> <Lista'>
<Lista'>        ::= "," <Lista> | eps
<Elemento>      ::= "cadena" | <OP>

<Condicional>   ::= "if" <Condicion> "{" <Cuerpo> "}" <SiNo>
<SiNo>          ::= "else" "{" <Cuerpo> "}" 
                  | eps

<Ciclo>         ::= "while" <Condicion> "{" <Cuerpo> "}"
```

## Operaciones y Asignaciones

```ebnf
<Asignacion>    ::= "id" ":=" <OP> 
                  | "id" ":=" <CMatriz> 
                  | "id" "[" <OP> "]" "[" <OP> "]" ":=" <OP>

<CMatriz>       ::= "[" <Filas> "]"
<Filas>         ::= <Fila> | <Fila> "," <Filas>
<Fila>          ::= "[" <Numeros> "]"
<Numeros>       ::= <OP4> | <OP4> "," <Numeros>
```

## Expresiones y Operadores (Jerarquía)

El manejo de expresiones sigue una jerarquía para respetar la precedencia matemática estándar.

```ebnf
<OP>   ::= <OP> "+" <OP2> 
         | <OP> "-" <OP2> 
         | <OP2>

<OP2>  ::= <OP2> "*" <OP3> 
         | <OP2> "/" <OP3> 
         | <OP3>

<OP3>  ::= <OP3> "^" <OP4> 
         | <OP4>

<OP4>  ::= "id" 
         | "id" "[" <OP> "]" "[" <OP> "]" 
         | "creal"
         | "filas" "(" "id" ")"
         | "columnas" "(" "id" ")"
         | "tras" "(" "id" ")"
         | "-" <OP4>
         | "(" <OP> ")"
```

## Condiciones Lógicas

```ebnf
<Condicion>    ::= "(" <ExpresionL> ")"

<ExpresionL>   ::= <ExpresionL> "&&" <ExpresionR>
                 | <ExpresionL> "||" <ExpresionR>
                 | "!" "(" <ExpresionL> ")"
                 | <ExpresionR>

<ExpresionR>   ::= <OP> "==" <OP>
                 | <OP> "!=" <OP>
                 | <OP> ">" <OP>
                 | <OP> "<" <OP>
                 | <OP> ">=" <OP>
                 | <OP> "<=" <OP>
```

---
*Nota: `eps` denota la cadena vacía (Epsilon).*
