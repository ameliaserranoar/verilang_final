# Esqueleto de la App Kotlin para tu Lenguaje

esta carpeta contiene todo lo necesario para conectar tu lenguaje creado en Rascal
con una interfaz gráfica de escritorio.


## Estructura del proyecto completo

el proyecto debe quedar así con la app Kotlin vive dentro:

```
mi-proyecto/
├── rascal-shell-stable.jar     < jar de Rascal (no mover)
├── META-INF/
│   └── RASCAL.MF
├── src/
│   └── milang/                 < TODO: renombra a tu lenguaje
│       ├── Syntax.rsc
│       ├── AST.rsc
│       ├── Parser.rsc
│       ├── Interpreter.rsc
│       └── RunnerJson.rsc      < copia y adapta desde rascal-template/
├── tests/
│   └── ejemplo.ml              < archivos de prueba de tu lenguaje
└── kotlin-app/                 < esta carpeta (la app)
    ├── build.gradle.kts
    ├── settings.gradle.kts
    ├── gradlew / gradlew.bat
    └── src/main/kotlin/milang/
        ├── Main.kt
        ├── model/RunResult.kt
        ├── service/LangService.kt
        └── ui/MainWindow.kt
```


## Pasos para adaptar el esqueleto a tu lenguaje

### 1. Adaptar el lado Rascal

cpoia `rascal-template/RunnerJson.rsc` dentro de `src/milang/` (o la carpeta de tu lenguaje)

luego edita el archivo siguiendo los `TODO` internos:
- cambia el nombre del módulo (`module milang::RunnerJson` > `module tulenguaje::RunnerJson`)
- importa tus propios módulos de Syntax, AST, Parser, Interpreter, etc.
- ajusta el simbolo inicial del parser (`#start[Program]` > el tuyo)
- ajusta las llamadas a `buildProgram`, `runProgram`, etc. por las funciones reales de tu lenguaje

**la función `main` de RunnerJson debe imprimir exactamente un objeto JSON** con la estructura
que espera `RunResult.kt`. No imprimas nada más (ni logs) antes de ese JSON

### 2. adaptar el lado Kotlin

hay exactamente **3 lugares** donde debes cambiar cosas:

| Archivo | Qué cambiar |
|---------|-------------|
| `service/LangService.kt` línea ~67 | `"milang::RunnerJson"` → `"tulenguaje::RunnerJson"` |
| `ui/MainWindow.kt` línea ~50 | la etiqueta y extensión del file chooser (ej. `"ml"` > la tuya) |
| `ui/MainWindow.kt` línea ~35 | el título que aparece en la ventana |

si quieres renombrar el paquete (`milang` → `tulenguaje`), haz find & replace en todos
los archivos `.kt` y en `build.gradle.kts`.

### 3. Requisito: tener Gradle instalado

Este zip no incluye los scripts de Gradle por restricciones del correo corporativo.
Necesitas tener **Gradle instalado** en tu máquina:

- **Mac:** `brew install gradle`
- **Windows/Linux:** descarga el instalador en https://gradle.org/install/

Verifica que funciona con: `gradle --version`

### 4. Correr la app

Desde la carpeta `kotlin-app/`:

```bash
gradle run
```

La primera vez descarga dependencias de Compose (~2 min). Las siguientes veces es inmediato.


## Cómo funciona la comunicación Kotlin ↔ Rascal

```
[Usuario selecciona archivo] 
        ↓
[LangService.kt] llama a:
  java -jar rascal-shell-stable.jar tulenguaje::RunnerJson /ruta/archivo.ml
        ↓
[RunnerJson.rsc] parsea, verifica, ejecuta y hace println() de un JSON
        ↓
[LangService.kt] captura el stdout, extrae el JSON, lo deserializa a RunResult
        ↓
[MainWindow.kt] muestra el resultado en pantalla
```

el JSON que produce Rascal debe tener esta forma mínima:

```json
{
  "success": true,
  "parseOk": true,
  "typeCheckOk": true,
  "semanticOk": true,
  "output": ["línea 1", "línea 2"],
  "typeErrors": [],
  "semanticErrors": [],
  "error": "",
  "module": "nombreModulo",
  "codigoFormateado": "",
  "resumen": ""
}
```




