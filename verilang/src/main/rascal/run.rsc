module run
import IO;
import ParseTree;
import Syntax;
import ToAST;
import AST;

public void main(list[str] args) {
  loc input = |file:///mnt/datos/Proyectos-Linux/Verilang/Entrega_3/verilang/instance/test_2.vl|;
  str code = readFile(input);
  try {
    Tree tree = parse(#start[Module], code, input);
    println("Parsed successfully!");
    
    AST::Module ast = toAST(tree);
    println("AST generated successfully:");
    iprintln(ast);
    
  } catch ParseError(loc l): {
    println("ParseError at <l>");
  } catch Ambiguity(loc l, str rule, str s): {
    println("Ambiguity at <l>");
  }
}
