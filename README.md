## 🚀 Prueba el Proyecto en Vivo

¿Quieres probar este analizador sintáctico sin instalar nada? 

**[👉 Prueba la versión web aquí](https://front-notlim.vercel.app)**

O si prefieres explorar el código de la versión web en TypeScript:
**[📦 Repositorio NOTLIM-WEB](https://github.com/elmiltonpa/NOTLIM-WEB)**

---

# Compilador e Intérprete (Custom Language)

Este proyecto es un **compilador e intérprete completo** construido desde cero en **Pascal**.

El objetivo principal no es el lenguaje en sí, sino la implementación "a mano" de todas las fases de un compilador. No se utilizaron herramientas de generación automática; toda la lógica de análisis léxico, sintáctico y ejecución está implementada manualmente.

---

##  ¿De qué trata el proyecto?

El programa lee un archivo de texto con código fuente (un lenguaje propio similar a C/Pascal), lo analiza gramaticalmente y lo ejecuta. El lenguaje está diseñado específicamente para realizar operaciones de álgebra lineal sobre matrices.

### Lo que puede hacer el lenguaje:
*   Declarar variables (`real` y `matriz`).
*   Operar matrices nativamente: Sumas, restas, multiplicaciones, trasposiciones y potencias de matrices.
*   Controlar el flujo con `if`, `else` y bucles `while`.
*   Manejar entrada y salida de datos por consola.

## Aspectos Técnicos Destacados

Este proyecto sirve como demostración práctica de conceptos fundamentales de ingeniería de software y teoría de compiladores:

### 1. Gestión Dinámica de Memoria y Punteros
La arquitectura se fundamenta en el uso intensivo de **punteros** para la gestión de estructuras de datos dinámicas. El Árbol de Sintaxis Abstracta (AST) se construye y enlaza en memoria manualmente, reflejando cómo funcionan los compiladores reales a bajo nivel.

### 2. Implementación Integral del Pipeline de Compilación
El proyecto prescinde de herramientas de generación automática (como Lex/Yacc), implementando cada fase de forma manual:
*   **Análisis Léxico (Scanner):** Empleo de autómatas finitos deterministas (AFDs) para el reconocimiento de tokens a nivel de caracteres.
*   **Análisis Sintáctico (Parser):** Implementación de un analizador **LL(1) Predictivo**. Se utiliza una estructura de **Pila** y una Tabla de Análisis Sintáctico (TAS) para validar la gramática sin backtracking.

### 3. Motor de Ejecución y Evaluación Semántica
El intérprete realiza un recorrido recursivo sobre el AST para la ejecución del código. Este componente destaca por:
*   **Sistema de Tipos:** Gestión de tipos escalares (`real`) y complejos (`matriz`).
*   **Lógica de Álgebra Lineal:** Implementación de algoritmos para operaciones matriciales (multiplicación, potencia, trasposición) con validación semántica de dimensiones en tiempo de ejecución.
*   **Control de Flujo:** Resolución de estructuras de control y expresiones booleanas con precedencia de operadores.

---

## Estructura del Código

*   `principal.pas`: El orquestador. Conecta el lexer, el parser y el evaluador.
*   `analizador_lexico.pas`: Convierte el texto en tokens usando autómatas.
*   `analizador_sintactico.pas`: Valida la gramática usando una Pila y construye el Árbol.
*   `evaluador.pas`: Recorre el árbol y ejecuta la lógica matemática.
*   `docs/`: Documentación técnica del proyecto.
    *   `GRAMATICA.md`: Definición formal de la gramática (BNF).
    *   `TAS FINAL.xlsx`: Tabla de Análisis Sintáctico calculada manualmente.

---

## Ejemplo de Código del Lenguaje

Así se ve el código que el intérprete es capaz de entender y ejecutar:

```c
program miMatriz;
def
    x: real;
    mat: matriz[2][2];
{
    x := 5.0;
    // Asignación directa de matrices
    mat := [[1, 2], [3, 4]]; 
    
    // Operaciones complejas: (Matriz * Escalar) + Matriz
    mat := (mat * x) + [[1, 1], [1, 1]];
    
    while (x > 0) {
        escribir(mat);
        x := x - 1;
    }
}
```

## Cómo ejecutarlo

El proyecto compila con **Free Pascal (FPC)**.

1.  Asegúrate de tener `fpc` instalado.
2.  Compila el archivo principal:
    ```bash
    fpc principal.pas
    ```
3.  Ejecuta el binario generado.
    *(Nota: Revisa las rutas de los archivos de entrada en `principal.pas` si lo pruebas en tu entorno local).*