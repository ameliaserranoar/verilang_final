module RunValidExample
import IO;
import ParseTree;
import Syntax;
import Parser;
import Checker;
import Interpreter;
import RuntimeValue;
import AST;
import List;

public void main(list[str] args) {
  loc input = |cwd:///instance/test.vl|;
  str code = readFile(input);
  Tree tree = parse(#start[Module], code, input).top;
  AST::Module ast = toAST(tree);
  println("Validation:");
  errors = Checker::check(ast);
  if (errors == []) println("  No errors");
  else for (e <- errors) println("  ERROR: <e>");

  println("Rule map:");
  map[str, list[AST::RuleDef]] ruleMap = ();
  for (def <- ast.defs) {
    switch (def) {
      case AST::ruleDefinition(r): {
        str opName = "<r.lhs.name>";
        println("  <opName>");
        if (opName in ruleMap) ruleMap[opName] += r;
        else ruleMap[opName] = [r];
      }
      default: ;
    }
  }

  println("Evaluation:");
  for (def <- ast.defs) {
    switch (def) {
      case AST::expressionDefinition(AST::expressionNode(expr, _)):
        try {
          Val v = Interpreter::eval(expr, (), ruleMap);
          println("  Result: " + show(v));
        } catch e:
          println("  Error: <e>");
      default: ;
    }
  }
}
