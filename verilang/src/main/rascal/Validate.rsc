module Validate

import AST;

set[str] collectOps(AST::Module m) {
  set[str] ops = {};
  for (def <- m.defs) {
    switch (def) {
      case AST::opDefinition(od):
        ops += od.name;
      default: ;
    }
  }
  return ops;
}

set[str] collectVarDecls(list[AST::VarDecl] decls) {
  set[str] names = {};
  for (decl <- decls) {
    switch (decl) {
      case AST::varDeclNode(name, _):
        names += name;
      default: ;
    }
  }
  return names;
}

set[str] collectVars(AST::Module m) {
  set[str] vars = {};
  for (def <- m.defs) {
    switch (def) {
      case AST::varDefinition(vd):
        vars += collectVarDecls(vd.decls);
      default: ;
    }
  }
  return vars;
}

list[str] checkArgs(list[AST::Expression] args, set[str] ops, set[str] vars) {
  errors = [];
  for (arg <- args) {
    errors += checkExpr(arg, ops, vars);
  }
  return errors;
}

list[str] checkExpr(AST::Expression e, set[str] ops, set[str] vars) {
  switch (e) {
    case AST::identifier(name):
      return !(name in vars) ? ["Undefined variable: <name>"] : [];
    case AST::applicationExpr(AST::applicationNode(name, args)):
      return (!(name in ops) ? ["Undefined operator: <name>"] : []) + checkArgs(args, ops, vars);
    case AST::negation(expr):
      return checkExpr(expr, ops, vars);
    case AST::quantified(_, var, _, body):
      return checkExpr(body, ops, vars + var);
    case AST::disjunction(lhs, rhs):
      return checkExpr(lhs, ops, vars) + checkExpr(rhs, ops, vars);
    case AST::conjunction(lhs, rhs):
      return checkExpr(lhs, ops, vars) + checkExpr(rhs, ops, vars);
    case AST::comparison(_, lhs, rhs):
      return checkExpr(lhs, ops, vars) + checkExpr(rhs, ops, vars);
    case AST::arithmetic(_, lhs, rhs):
      return checkExpr(lhs, ops, vars) + checkExpr(rhs, ops, vars);
    case AST::power(lhs, rhs):
      return checkExpr(lhs, ops, vars) + checkExpr(rhs, ops, vars);
    case AST::literal(_):
      return [];
    default:
      return [];
  }
}

list[str] checkApp(AST::Application app, set[str] ops, set[str] vars) {
  switch (app) {
    case AST::applicationNode(name, args):
      return (!(name in ops) ? ["Undefined operator: <name>"] : []) + checkArgs(args, ops, vars);
    default:
      return [];
  }
}

list[str] check(AST::Module m) {
  ops = collectOps(m);
  vars = collectVars(m);

  errors = [];
  for (def <- m.defs) {
    switch (def) {
      case AST::expressionDefinition(ed):
        errors += checkExpr(ed.expr, ops, vars);
      case AST::ruleDefinition(rd):
        errors += checkApp(rd.lhs, ops, vars) + checkApp(rd.rhs, ops, vars);
      default: ;
    }
  }
  return errors;
}
