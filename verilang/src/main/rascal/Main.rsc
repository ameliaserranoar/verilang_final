module Main

import IO;
import ParseTree;
import Syntax;
import ToAST;

public int main(list[str] args) {
    loc input = |cwd:///instance/test.vl|;
    str code = readFile(input);
    Tree tree = parse(#start[Module], code, input).top;

    println("Parse tree:");
    println(tree);
    println("");
    println("AST:");
    println(toAST(tree));
    return 0;
}
