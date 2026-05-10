module Checker

import AST;
import List;

alias VarEnv = map[str, AST::Type];
alias OpEnv = map[str, list[AST::Type]];

data Check = checkResult(AST::Type tp, list[str] errors);

private str typeName(AST::Type tp) {
  switch (tp) {
    case AST::intType(): return "Int";
    case AST::boolType(): return "Bool";
    case AST::charType(): return "Char";
    case AST::stringType(): return "String";
    case AST::userType(name): return name;
  }
}

private bool sameType(AST::Type left, AST::Type right) = typeName(left) == typeName(right);

private bool builtinType(AST::Type tp) {
  switch (tp) {
    case AST::intType(): return true;
    case AST::boolType(): return true;
    case AST::charType(): return true;
    case AST::stringType(): return true;
    default: return false;
  }
}

private bool knownType(AST::Type tp, set[str] spaces) {
  if (builtinType(tp)) return true;
  if (AST::userType(name) := tp) return name in spaces;
  return false;
}

private set[str] spacesOf(AST::Module m) {
  set[str] spaces = {};
  for (def <- m.defs) {
    if (AST::spaceDefinition(AST::spaceNode(name, _)) := def) {
      spaces += name;
    }
  }
  return spaces;
}

private VarEnv varsOf(AST::Module m) {
  VarEnv vars = ();
  for (def <- m.defs) {
    if (AST::varDefinition(AST::varNode(decls)) := def) {
      for (AST::varDeclNode(name, tp) <- decls) {
        vars[name] = tp;
      }
    }
  }
  return vars;
}

private OpEnv opsOf(AST::Module m) {
  OpEnv ops = ();
  for (def <- m.defs) {
    if (AST::opDefinition(AST::operatorNode(name, sig, _)) := def) {
      ops[name] = sig;
    }
  }
  return ops;
}

private list[str] checkDeclaredTypes(AST::Definition def, set[str] spaces) {
  list[str] errors = [];
  switch (def) {
    case AST::spaceDefinition(AST::spaceNode(name, AST::spaceParentNode(parent))):
      if (!(parent in spaces)) errors += "Undefined parent space <parent> in definition of space <name>";

    case AST::varDefinition(AST::varNode(decls)):
      for (AST::varDeclNode(name, tp) <- decls) {
        if (!knownType(tp, spaces)) errors += "Undefined type or space <typeName(tp)> in variable <name>";
      }

    case AST::opDefinition(AST::operatorNode(name, sig, _)): {
      if (size(sig) < 2) errors += "Operator <name> must have at least one argument type and one result type";
      for (tp <- sig) {
        if (!knownType(tp, spaces)) errors += "Undefined type or space <typeName(tp)> in operator <name>";
      }
    }

    default: ;
  }
  return errors;
}

private Check withBool(Check c, str context) {
  list[str] errors = c.errors;
  if (!sameType(c.tp, AST::boolType())) {
    errors += "Expected Bool in <context>, found <typeName(c.tp)>";
  }
  return checkResult(AST::boolType(), errors);
}

private list[str] requireBool(AST::Type tp, str context) {
  return sameType(tp, AST::boolType())
    ? []
    : ["Expected Bool in <context>, found <typeName(tp)>"];
}

private Check typeOfApp(str name, list[AST::Expression] args, VarEnv vars, OpEnv ops, set[str] spaces) {
  list[str] errors = [];
  if (!(name in ops)) {
    errors += "Undefined operator: <name>";
    for (arg <- args) errors += typeOf(arg, vars, ops, spaces).errors;
    return checkResult(AST::boolType(), errors);
  }

  list[AST::Type] sig = ops[name];
  if (size(sig) < 2) {
    return checkResult(AST::boolType(), ["Operator <name> must have at least one argument type and one result type"]);
  }

  int arity = size(sig) - 1;
  if (size(args) != arity) {
    errors += "Operator <name> expects <arity> argument(s), found <size(args)>";
  }

  int limit = size(args) < arity ? size(args) : arity;
  for (i <- [0 .. limit]) {
    Check arg = typeOf(args[i], vars, ops, spaces);
    errors += arg.errors;
    if (arg.errors == [] && !sameType(arg.tp, sig[i])) {
      errors += "Argument <i + 1> of operator <name> expects <typeName(sig[i])>, found <typeName(arg.tp)>";
    }
  }

  return checkResult(sig[size(sig) - 1], errors);
}

private Check typeOfComparison(AST::ComparisonOp op, AST::Expression lhs, AST::Expression rhs,
    VarEnv vars, OpEnv ops, set[str] spaces) {
  Check l = typeOf(lhs, vars, ops, spaces);
  Check r = typeOf(rhs, vars, ops, spaces);
  list[str] errors = l.errors + r.errors;

  switch (op) {
    case AST::eqOp():
      if (l.errors == [] && r.errors == [] && !sameType(l.tp, r.tp)) errors += "Equality requires operands of the same type, found <typeName(l.tp)> and <typeName(r.tp)>";
    case AST::neqOp():
      if (l.errors == [] && r.errors == [] && !sameType(l.tp, r.tp)) errors += "Inequality requires operands of the same type, found <typeName(l.tp)> and <typeName(r.tp)>";
    case AST::equivOp():
      errors += requireBool(l.tp, "equivalence") + requireBool(r.tp, "equivalence");
    case AST::implOp():
      errors += requireBool(l.tp, "implication") + requireBool(r.tp, "implication");
    case AST::inOp():
      if (l.errors == [] && r.errors == [] && !sameType(l.tp, r.tp)) errors += "Membership requires matching element and domain types, found <typeName(l.tp)> and <typeName(r.tp)>";
    default:
      if (l.errors == [] && r.errors == [] && (!sameType(l.tp, AST::intType()) || !sameType(r.tp, AST::intType()))) {
        errors += "Ordering comparisons require Int operands, found <typeName(l.tp)> and <typeName(r.tp)>";
      }
  }

  return checkResult(AST::boolType(), errors);
}

private Check typeOf(AST::Expression expr, VarEnv vars, OpEnv ops, set[str] spaces) {
  switch (expr) {
    case AST::identifier(name):
      return name in vars
        ? checkResult(vars[name], [])
        : checkResult(AST::boolType(), ["Undefined variable: <name>"]);

    case AST::literal(AST::intLiteral(_)): return checkResult(AST::intType(), []);
    case AST::literal(AST::boolLiteral(_)): return checkResult(AST::boolType(), []);
    case AST::literal(AST::charLiteral(_)): return checkResult(AST::charType(), []);
    case AST::literal(AST::stringLiteral(_)): return checkResult(AST::stringType(), []);
    case AST::literal(AST::floatLiteral(_)):
      return checkResult(AST::intType(), ["Float literals are not part of the declared VeriLang type system"]);

    case AST::applicationExpr(AST::applicationNode(name, args)):
      return typeOfApp(name, args, vars, ops, spaces);

    case AST::negation(e):
      return withBool(typeOf(e, vars, ops, spaces), "negation");

    case AST::disjunction(lhs, rhs):
      return checkResult(AST::boolType(),
        withBool(typeOf(lhs, vars, ops, spaces), "disjunction").errors +
        withBool(typeOf(rhs, vars, ops, spaces), "disjunction").errors);

    case AST::conjunction(lhs, rhs):
      return checkResult(AST::boolType(),
        withBool(typeOf(lhs, vars, ops, spaces), "conjunction").errors +
        withBool(typeOf(rhs, vars, ops, spaces), "conjunction").errors);

    case AST::comparison(op, lhs, rhs):
      return typeOfComparison(op, lhs, rhs, vars, ops, spaces);

    case AST::arithmetic(_, lhs, rhs): {
      Check l = typeOf(lhs, vars, ops, spaces);
      Check r = typeOf(rhs, vars, ops, spaces);
      list[str] errors = l.errors + r.errors;
      if (l.errors == [] && r.errors == [] && (!sameType(l.tp, AST::intType()) || !sameType(r.tp, AST::intType()))) {
        errors += "Arithmetic operators require Int operands, found <typeName(l.tp)> and <typeName(r.tp)>";
      }
      return checkResult(AST::intType(), errors);
    }

    case AST::power(lhs, rhs): {
      Check l = typeOf(lhs, vars, ops, spaces);
      Check r = typeOf(rhs, vars, ops, spaces);
      list[str] errors = l.errors + r.errors;
      if (l.errors == [] && !sameType(l.tp, AST::intType())) errors += "Power base must be Int, found <typeName(l.tp)>";
      if (r.errors == [] && !sameType(r.tp, AST::intType())) errors += "Power exponent must be Int, found <typeName(r.tp)>";
      return checkResult(AST::intType(), errors);
    }

    case AST::quantified(_, var, domain, body): {
      list[str] errors = domain in spaces ? [] : ["Undefined quantifier domain <domain>"];
      VarEnv scopedVars = vars;
      scopedVars[var] = AST::userType(domain);
      errors += withBool(typeOf(body, scopedVars, ops, spaces), "quantifier body").errors;
      return checkResult(AST::boolType(), errors);
    }

    default:
      return checkResult(AST::boolType(), ["Unsupported expression in type checker"]);
  }
}

private list[str] checkRule(AST::RuleDef rule, VarEnv vars, OpEnv ops, set[str] spaces) {
  Check lhs = typeOfApp(rule.lhs.name, rule.lhs.args, vars, ops, spaces);
  Check rhs = typeOfApp(rule.rhs.name, rule.rhs.args, vars, ops, spaces);
  list[str] errors = lhs.errors + rhs.errors;

  if ((rule.lhs.name in ops) && (rule.rhs.name in ops) && !sameType(lhs.tp, rhs.tp)) {
    errors += "Rule result types must match, found <typeName(lhs.tp)> and <typeName(rhs.tp)>";
  }

  return errors;
}

public list[str] check(AST::Module m) {
  set[str] spaces = spacesOf(m);
  VarEnv vars = varsOf(m);
  OpEnv ops = opsOf(m);

  list[str] errors = [];
  for (def <- m.defs) {
    errors += checkDeclaredTypes(def, spaces);
    switch (def) {
      case AST::ruleDefinition(rule):
        errors += checkRule(rule, vars, ops, spaces);
      case AST::expressionDefinition(AST::expressionNode(expr, _)):
        errors += typeOf(expr, vars, ops, spaces).errors;
      default: ;
    }
  }
  return errors;
}
