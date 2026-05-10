module RunErrorExample
import IO;
import ParseTree;
import Syntax;
import Parser;
import Checker;
import AST;

public void main(list[str] args) {
  loc input = |cwd:///instance/error_test.vl|;
  str code = readFile(input);
  Tree tree = parse(#start[Module], code, input).top;
  AST::Module ast = toAST(tree);
  errors = Checker::check(ast);
  if (errors == []) println("No errors");
  else for (e <- errors) println("  <e>");
}
