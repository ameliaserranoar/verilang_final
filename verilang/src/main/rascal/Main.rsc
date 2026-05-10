module Main

import IO;
import ParseTree;
import Syntax;
import ToAST;
import Validate;

public int main(list[str] args) {
    loc input = |cwd:///instance/test.vl|;
    str code = readFile(input);
    Tree tree = parse(#start[Module], code, input).top;

    println("Parse tree:");
    println(tree);
    println("");
    println("AST:");
    ast = toAST(tree);
    println(ast);
    println("");
    println("Validation errors:");
    errors = Validate::check(ast);
    if (errors == []) {
      println("No errors found.");
    } else {
      for (err <- errors) {
        println("- <err>");
      }
    }
    return 0;
}
