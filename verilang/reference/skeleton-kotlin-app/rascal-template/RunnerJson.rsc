// TODO: cambia "milang" por el nombre del módulo de tu lenguaje (debe coincidir con la carpeta en src/)
module milang::RunnerJson

// TODO: importa los modulos de tu propio lenguaje
// ejemplo (ajusta los nombres según los tuyos):
import milang::Syntax;
import milang::AST;
import milang::Parser;       // o como hayas llamado al modulo con buildModule / buildAST
import milang::Interpreter;  // o el modulo que tenga tu función de ejecución
import ParseTree;
import Message;
import IO;
import Set;
import List;
import String;

// utilidades para construir el JSON manualmente


// escapa caracteres especiales dentro de strings JSON
str esc(str s) =
    replaceAll(replaceAll(replaceAll(replaceAll(
        s, "\\", "\\\\"), "\"", "\\\""), "\n", "\\n"), "\t", "\\t");

// convierte una lista de strings a un arreglo JSON  ["a","b","c"]
str jsonArr(list[str] items) =
    "[<intercalate(", ", [ "\"<esc(i)>\"" | i <- items ])>]";

// Construye el objeto JSON de resultado final.
// IMPORTANTE: los nombres de las claves DEBEN coincidir con los campos de RunResult.kt
str jsonResult(
    bool success,
    str modName,
    bool parseOk,
    bool tcOk,        // type check ok 
    bool semOk,       // semántica ok  
    list[str] tcErrs,
    list[str] semErrs,
    list[str] output,
    str err,
    str codigoFormateado,  
    str resumen             // resumen del AST          
) =
    "{\"success\":<success>,"
    + "\"module\":\"<esc(modName)>\","
    + "\"parseOk\":<parseOk>,"
    + "\"typeCheckOk\":<tcOk>,"
    + "\"semanticOk\":<semOk>,"
    + "\"typeErrors\":<jsonArr(tcErrs)>,"
    + "\"semanticErrors\":<jsonArr(semErrs)>,"
    + "\"output\":<jsonArr(output)>,"
    + "\"error\":\"<esc(err)>\","
    + "\"codigoFormateado\":\"<esc(codigoFormateado)>\","
    + "\"resumen\":\"<esc(resumen)>\"}";

// Punto de entrada, Kotlin llama a este módulo con la ruta del archivo fuente

void main(list[str] args) {

    //Leer el archivo fuente
    str src;
    try {
        loc file = isEmpty(args)
            // archivo por defecto para pruebas rápidas desde Rascal directamente
            // TODO: ajusta la ruta de prueba
            ? |project://mi-proyecto/tests/ejemplo.ml|
            : (startsWith(args[0], "/") ? |file:///| + args[0] : |cwd:///| + args[0]);
        src = readFile(file);
    } catch e: {
        println(jsonResult(false, "", false, false, false, [], [], [], "No se pudo leer el archivo: <e>", "", ""));
        return;
    }

    //Parsing
    // TODO: ajusta el tipo de start según la gramática de tu lenguaje
    // Ejemplo: parse(#start[Program], src) si tu símbolo inicial es "Program"
    Tree cst;
    try {
        cst = resolveAmb(parse(#start[Program], src, allowAmbiguity=true));
    } catch ParseError(loc at): {
        println(jsonResult(false, "", false, false, false, [], [], [], "Error de parsing en <at>", "", ""));
        return;
    } catch e: {
        println(jsonResult(false, "", false, false, false, [], [], [], "Error de parsing: <e>", "", ""));
        return;
    }

    // Construcción del AST
    // TODO: reemplaza "AProgram" y "buildProgram" por los tipos y funciones de tu AST
    AProgram ast;
    try {
        ast = buildProgram(cst.top);
    } catch e: {
        println(jsonResult(false, "", true, false, false, [], [], [], "Error construyendo AST: <e>", "", ""));
        return;
    }

    //Pretty Printer
    // si no tienes pretty printer, deja codigoFormateado = ""
    str codigoFormateado = "";
    // str codigoFormateado = prettyPrint(ast);

    //Verificación semántica
    list[str] semErrs = [];
    bool semOk = true;

    // Ejemplo si tienes checkProgram(ast) que devuelve set[Message]:
    // set[Message] semMsgs = checkProgram(ast);
    // semErrs = [ msg.msg | msg <- toList(semMsgs), msg is error ];
    // semOk   = isEmpty(semErrs);
    // if (!semOk) {
    //     println(jsonResult(false, "programa", true, true, false, [], semErrs, [], "", codigoFormateado, ""));
    //     return;
    // }

    // ejecución
    // TODO: reemplaza "runProgram" por la función de tu intérprete
    // La función debe devolver list[str] con las líneas de salida
    list[str] output = [];
    try {
        output = runProgram(ast);
    } catch str errMsg: {
        println(jsonResult(false, "programa", true, true, true, [], [], [], "Error en ejecución: <errMsg>", codigoFormateado, ""));
        return;
    } catch e: {
        println(jsonResult(false, "programa", true, true, true, [], [], [], "Error en ejecución: <e>", codigoFormateado, ""));
        return;
    }

    //Todo OK
    println(jsonResult(true, "programa", true, true, true, [], [], output, "", codigoFormateado, ""));
}
