module RuleMatcher

import AST;
import RuntimeValue;
import List;

alias Env = map[str, Val];

data Match = matched(Env env) | noMatch();

public Match tryMatch(list[Val] args, list[AST::Expression] patterns, Env env) {
  if (size(args) != size(patterns)) {
    return noMatch();
  }
  Env newEnv = env;
  for (i <- [0 .. size(args) - 1]) {
    switch (patterns[i]) {
      case AST::identifier(name): {
        newEnv[name] = args[i];
      }
      case AST::literal(AST::intLiteral(n)):
        if (intVal(v) := args[i]) {
          if (v != n) return noMatch();
        } else return noMatch();
      case AST::literal(AST::boolLiteral(b)):
        if (boolVal(v) := args[i]) {
          if (v != b) return noMatch();
        } else return noMatch();
      case AST::literal(AST::charLiteral(c)):
        if (charVal(v) := args[i]) {
          if (v != c) return noMatch();
        } else return noMatch();
      case AST::literal(AST::stringLiteral(s)):
        if (stringVal(v) := args[i]) {
          if (v != s) return noMatch();
        } else return noMatch();
      case AST::literal(AST::floatLiteral(f)):
        if (floatVal(v) := args[i]) {
          if (v != f) return noMatch();
        } else return noMatch();
      default: return noMatch();
    }
  }
  return matched(newEnv);
}
