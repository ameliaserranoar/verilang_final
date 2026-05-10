module RunTest
import IO;
import ParseTree;
import Syntax;
import ToAST;
import Validate;
import Eval;
import Val;
import AST;
import List;

public void main(list[str] args) {
  loc input = |file:///mnt/datos/Proyectos-Linux/Verilang/Entrega_3/verilang/instance/test.vl|;
  str code = readFile(input);
  Tree tree = parse(#start[Module], code, input).top;
  AST::Module ast = toAST(tree);
  println("Validation:");
  errors = Validate::check(ast);
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
          Val v = Eval::eval(expr, (), ruleMap);
          println("  Result: " + show(v));
        } catch e:
          println("  Error: <e>");
      default: ;
    }
  }
}
