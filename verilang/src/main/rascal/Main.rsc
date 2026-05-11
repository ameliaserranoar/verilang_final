module Main

import IO;
import ParseTree;
import Syntax;
import Parser;
import Checker;
import Interpreter;
import RuntimeValue;
import AST;
import List;

private map[str, list[AST::RuleDef]] buildRuleMap(AST::Module m) {
  map[str, list[AST::RuleDef]] rules = ();
  for (def <- m.defs) {
    switch (def) {
      case AST::ruleDefinition(r): {
        str opName = "<r.lhs.name>";
        if (opName in rules) {
          rules[opName] += r;
        } else {
          rules[opName] = [r];
        }
      }
      default: ;
    }
  }
  return rules;
}

private str evalExprDef(AST::ExpressionDef ed, map[str, list[AST::RuleDef]] ruleMap) {
  switch (ed) {
    case AST::expressionNode(expr, _):
      try
        return "Result: <show(Interpreter::eval(expr, (), ruleMap))>";
      catch err:
        return "Cannot evaluate: <err>";
    default: return "Unknown expression definition";
  }
}

public int main(list[str] args) {
    loc input = |cwd:///instance/test.vl|;
    str code = readFile(input);
    Tree tree = parse(#start[Module], code, input).top;

    println("Parse tree:");
    println(tree);
    println("");
    println("AST:");
    AST::Module ast = toAST(tree);
    println(ast);
    println("");
    println("Validation errors:");
    list[str] errors = Checker::check(tree, ast);
    if (errors == []) {
      println("No errors found.");
    } else {
      for (err <- errors) {
        println("- <err>");
      }
    }

    map[str, list[AST::RuleDef]] ruleMap = buildRuleMap(ast);
    println("");
    println("Evaluation:");
    for (def <- ast.defs) {
      switch (def) {
        case AST::expressionDefinition(ed):
          println("  <evalExprDef(ed, ruleMap)>");
        default: ;
      }
    }
    return 0;
}
