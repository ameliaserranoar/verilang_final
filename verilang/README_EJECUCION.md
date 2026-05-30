# Ejecucion de VeriLang

## Aplicacion Kotlin

Desde esta carpeta del proyecto:

```bash
cd kotlin-app
gradle run
```

Esta forma sigue el skeleton del proyecto: requiere Gradle instalado globalmente. La primera
ejecucion puede descargar dependencias de Kotlin/Compose. La app busca
`rascal-shell-stable.jar` en la carpeta padre (`verilang/`) y los modulos Rascal en
`src/main/rascal`.

Archivos de prueba:

```text
instance/test.vl
instance/error_test.vl
instance/test_2.vl
```

## Prueba directa de Rascal

Desde `verilang/`:

```bash
java -Dfile.encoding=UTF-8 \
  -Drascal.projectPath="$PWD" \
  -jar rascal-shell-stable.jar \
  RunnerJson "$PWD/instance/test.vl" /tmp/verilang-test.json
```

El comando imprime el JSON por consola y tambien lo escribe en la ruta JSON indicada.
