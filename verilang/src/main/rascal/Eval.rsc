module Eval

import AST;
import Val;
import String;
import List;
import MatchUtil;
import EvalUtil;
import EvalComp;
import EvalExtra;

private Val evalAppExpr(
    AST::Application app, map[str, Val] env,
    map[str, list[AST::RuleDef]] ruleMap
) {
  list[Val] evaledArgs = [eval(a, env, ruleMap) | a <- app.args];
  str name = app.name;

  if (name in ruleMap) {
    for (rule <- ruleMap[name]) {
      Match m = tryMatch(evaledArgs, rule.lhs.args, env);
      switch (m) {
        case matched(matchEnv): {
          return eval(AST::applicationExpr(rule.rhs), matchEnv, ruleMap);
        }
        default: ;
      }
    }
  }

  return appVal(name, evaledArgs);
}

public Val eval(
    AST::Expression expr, map[str, Val] env,
    map[str, list[AST::RuleDef]] ruleMap
) {
  switch (expr) {
    case AST::literal(lit): return evalLiteral(lit);

    case AST::identifier(name): {
      if (name in env) return env[name];
      throw "Undefined variable";
    }

    case AST::applicationExpr(app): return evalAppExpr(app, env, ruleMap);

    case AST::arithmetic(op, lhs, rhs):
      return evalArith(op, eval(lhs, env, ruleMap), eval(rhs, env, ruleMap));

    case AST::comparison(op, lhs, rhs):
      return evalComparison(op, eval(lhs, env, ruleMap), eval(rhs, env, ruleMap));

    case AST::negation(sub):
      return evalNeg(eval(sub, env, ruleMap));

    case AST::power(lhs, rhs):
      return evalPower(eval(lhs, env, ruleMap), eval(rhs, env, ruleMap));

    case AST::disjunction(lhs, rhs): {
      Val l = eval(lhs, env, ruleMap);
      if (boolVal(lb) := l) {
        if (lb) return boolVal(true);
        Val r = eval(rhs, env, ruleMap);
        if (boolVal(rb) := r) return boolVal(rb);
      }
      throw "Type error in disjunction";
    }

    case AST::conjunction(lhs, rhs): {
      Val l = eval(lhs, env, ruleMap);
      if (boolVal(lb) := l) {
        if (!lb) return boolVal(false);
        Val r = eval(rhs, env, ruleMap);
        if (boolVal(rb) := r) return boolVal(rb);
      }
      throw "Type error in conjunction";
    }

    case AST::quantified(q, var, domain, body): {
      map[str, Val] newEnv = (var : appVal(var, []));
      newEnv += env;
      try
        return eval(body, newEnv, ruleMap);
      catch err:
        return appVal("quantified", [stringVal("<err>")]);
    }

    default: throw "Cannot evaluate expression";
  }
}
