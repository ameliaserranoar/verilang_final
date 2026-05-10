module run
import IO;
import ParseTree;
import Syntax;
public void main(list[str] args) {
  loc input = |file:///mnt/datos/Proyectos-Linux/Verilang/Entrega_3/verilang/instance/test_2.vl|;
  str code = readFile(input);
  try {
    Tree tree = parse(#start[Module], code, input);
    println("Parsed successfully!");
  } catch ParseError(loc l): {
    println("ParseError at <l>");
  } catch Ambiguity(loc l, str rule, str s): {
    println("Ambiguity at <l>");
  }
}
