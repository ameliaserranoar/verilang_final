# Proyecto 4 - VeriLang en Kotlin

## Cambios principales

- Se agrego soporte para `defstruct` y `defdata` en la gramatica, AST, parser y checker.
- El checker valida existencia de tipos usados en campos, constructores, variables, operadores y padres de espacios.
- Los constructores declarados en `defdata` se registran como operadores y participan en el chequeo de aridad/tipos.
- Se agrego `RunnerJson.rsc`, que parsea, construye AST, ejecuta chequeo semantico/tipos, evalua expresiones y emite un unico JSON.
- La app Kotlin fue movida a `verilang/kotlin-app` y adaptada a VeriLang (`.vl`, titulo VeriLang, servicio `VeriLangService`).

## Estructura

```text
verilang/
├── META-INF/RASCAL.MF
├── instance/
│   ├── test.vl
│   └── error_test.vl
├── src/main/rascal/
│   ├── Syntax.rsc
│   ├── AST.rsc
│   ├── Parser.rsc
│   ├── Checker.rsc
│   ├── Interpreter.rsc
│   └── RunnerJson.rsc
└── kotlin-app/
    ├── build.gradle.kts
    └── src/main/kotlin/verilang/
        ├── Main.kt
        ├── model/RunResult.kt
        ├── service/VeriLangService.kt
        └── ui/MainWindow.kt
```

## JSON producido por Rascal

`RunnerJson.rsc` imprime un objeto JSON con:

- `success`
- `parseOk`
- `typeCheckOk`
- `semanticOk`
- `module`
- `modules`
- `typeErrors`
- `semanticErrors`
- `output`
- `error`
- `codigoFormateado`
- `resumen`

La interfaz Kotlin muestra el estado del parser, tipos, semantica, lista de modulos, errores y salida.

## Ejecucion

Ubicar `rascal-shell-stable.jar` en `verilang/` o en la carpeta padre del proyecto. Luego:

```bash
cd verilang/kotlin-app
gradle run
```

La app invoca:

```bash
java -Dfile.encoding=UTF-8 -Drascal.projectPath=<verilang> -jar rascal-shell-stable.jar RunnerJson <archivo.vl>
```
