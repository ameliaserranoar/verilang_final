module RunnerJson

import IO;
import ParseTree;
import String;
import List;
import Syntax;
import Parser;
import Checker;
import Interpreter;
import RuntimeValue;
import AST;

private str esc(str s) =
  replaceAll(replaceAll(replaceAll(replaceAll(s, "\\", "\\\\"), "\"", "\\\""), "\n", "\\n"), "\t", "\\t");

private str jsonArr(list[str] items) =
  "[<intercalate(",", ["\"<esc(item)>\"" | item <- items])>]";

private str jsonResult(
    bool success,
    str modName,
    list[str] modules,
    bool parseOk,
    bool tcOk,
    bool semOk,
    list[str] tcErrs,
    list[str] semErrs,
    list[str] output,
    str err,
    str formatted,
    str summary
) =
  "{\"success\":<success>,"
  + "\"module\":\"<esc(modName)>\","
  + "\"modules\":<jsonArr(modules)>,"
  + "\"parseOk\":<parseOk>,"
  + "\"typeCheckOk\":<tcOk>,"
  + "\"semanticOk\":<semOk>,"
  + "\"typeErrors\":<jsonArr(tcErrs)>,"
  + "\"semanticErrors\":<jsonArr(semErrs)>,"
  + "\"output\":<jsonArr(output)>,"
  + "\"error\":\"<esc(err)>\","
  + "\"codigoFormateado\":\"<esc(formatted)>\","
  + "\"resumen\":\"<esc(summary)>\"}";

private loc sourceLoc(str path) =
  startsWith(path, "/") ? |file:///| + path : |cwd:///| + path;

private void emit(list[str] args, str json) {
  if (size(args) > 1) {
    try {
      writeFile(sourceLoc(args[1]), json);
    } catch e: {
      ;
    }
  }
  println(json);
}

private map[str, list[AST::RuleDef]] buildRuleMap(AST::Module m) {
  map[str, list[AST::RuleDef]] rules = ();
  for (def <- m.defs) {
    switch (def) {
      case AST::ruleDefinition(r): {
        str opName = r.lhs.name;
        if (opName in rules) rules[opName] += r;
        else rules[opName] = [r];
      }
      default: ;
    }
  }
  return rules;
}

private int countExpressions(AST::Module m) {
  int total = 0;
  for (def <- m.defs) {
    if (AST::expressionDefinition(_) := def) total += 1;
  }
  return total;
}

private str moduleSummary(AST::Module m) =
  "modulo=<m.name>; definiciones=<size(m.defs)>; expresiones=<countExpressions(m)>";

private list[str] evaluateExpressions(AST::Module ast) {
  list[str] output = [];
  map[str, list[AST::RuleDef]] ruleMap = buildRuleMap(ast);
  for (def <- ast.defs) {
    switch (def) {
      case AST::expressionDefinition(AST::expressionNode(expr, _)):
        try {
          output += RuntimeValue::show(Interpreter::eval(expr, (), ruleMap));
        } catch e: {
          output += "Cannot evaluate: <e>";
        }
      default: ;
    }
  }
  return output;
}

public void main(list[str] args) {
  if (isEmpty(args)) {
    emit(args, jsonResult(false, "", [], false, false, false, [], [], [], "No input file was provided", "", ""));
    return;
  }

  str src;
  loc input = sourceLoc(args[0]);
  try {
    src = readFile(input);
  } catch e: {
    emit(args, jsonResult(false, "", [], false, false, false, [], [], [], "No se pudo leer el archivo: <e>", "", ""));
    return;
  }

  Tree tree;
  try {
    tree = parse(#start[Module], src, input).top;
  } catch ParseError(loc at): {
    emit(args, jsonResult(false, "", [], false, false, false, [], [], [], "Error de parsing en <at>", "", ""));
    return;
  } catch e: {
    emit(args, jsonResult(false, "", [], false, false, false, [], [], [], "Error de parsing: <e>", "", ""));
    return;
  }

  AST::Module ast;
  try {
    ast = Parser::toAST(tree);
  } catch e: {
    emit(args, jsonResult(false, "", [], true, false, false, [], [], [], "Error construyendo AST: <e>", "", ""));
    return;
  }

  list[str] errors = Checker::check(tree, ast);
  bool ok = isEmpty(errors);
  list[str] output = ok ? evaluateExpressions(ast) : [];
  emit(args, jsonResult(ok, ast.name, [ast.name], true, ok, ok, errors, errors, output, "", src, moduleSummary(ast)));
}
