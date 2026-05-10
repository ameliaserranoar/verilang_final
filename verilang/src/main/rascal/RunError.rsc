module RunError
import IO;
import ParseTree;
import Syntax;
import ToAST;
import Validate;
import AST;

public void main(list[str] args) {
  loc input = |file:///mnt/datos/Proyectos-Linux/Verilang/Entrega_3/verilang/instance/error_test.vl|;
  str code = readFile(input);
  Tree tree = parse(#start[Module], code, input).top;
  AST::Module ast = toAST(tree);
  errors = Validate::check(ast);
  if (errors == []) println("No errors");
  else for (e <- errors) println("  <e>");
}
