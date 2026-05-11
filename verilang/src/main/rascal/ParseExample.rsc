module ParseExample
import IO;
import ParseTree;
import Syntax;
import Parser;
import AST;

public void main(list[str] args) {
  loc input = |cwd:///instance/test_2.vl|;
  str code = readFile(input);
  try {
    Tree tree = parse(#start[Module], code, input);
    println("Parsed successfully!");
    
    AST::Module ast = toAST(tree);
    println("AST generated successfully:");
    iprintln(ast);
    
  } catch e: {
    println("Error: <e>");
  }
}
