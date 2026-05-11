module Checker

import AST;
import List;
import Message;
import ParseTree;
import Syntax;
import String;

extend analysis::typepal::TypePal;

data AType
  = vlType(str name)
  ;

data IdRole
  = spaceId()
  | operatorId()
  | variableId()
  ;

str prettyAType(vlType(name)) = name;

alias VarEnv = map[str, AST::Type];
alias OpEnv = map[str, list[AST::Type]];

data Check = checkResult(AST::Type tp, list[str] errors);

private str text(Tree tree) = trim(unparse(tree));

void collect(current: (Module) `defmodule <Id name> <Definition* defs> end`, Collector c) {
  c.enterScope(current);
  collect(defs, c);
  c.leaveScope(current);
}

void collect(current: (Definition) `<Using usingDecl>`, Collector c) {
  collect(usingDecl, c);
}

void collect(current: (Definition) `<SpaceDef spaceDecl>`, Collector c) {
  collect(spaceDecl, c);
}

void collect(current: (Definition) `<OperatorDef operatorDecl>`, Collector c) {
  collect(operatorDecl, c);
}

void collect(current: (Definition) `<VarDef varDecl>`, Collector c) {
  collect(varDecl, c);
}

void collect(current: (Definition) `<RuleDef ruleDecl>`, Collector c) {
  collect(ruleDecl, c);
}

void collect(current: (Definition) `<ExpressionDef exprDecl>`, Collector c) {
  collect(exprDecl, c);
}

void collect(current: (Using) `using <Id name>`, Collector c) {
}

void collect(current: (AttributeList) `[<Attribute+ attrs>]`, Collector c) {
  collect(attrs, c);
}

void collect(current: (Attribute) `<Id name>`, Collector c) {
}

void collect(current: (Attribute) `<Id name> <AttributeValue attrValue>`, Collector c) {
  collect(attrValue, c);
}

void collect(current: (AttributeValue) `: <Id name>`, Collector c) {
}

void collect(current: (SpaceDef) `defspace <Id name> end`, Collector c) {
  c.define(text(name), spaceId(), name, defType(vlType(text(name))));
}

void collect(current: (SpaceDef) `defspace <Id name> <SpaceParent parent> end`, Collector c) {
  c.define(text(name), spaceId(), name, defType(vlType(text(name))));
  collect(parent, c);
}

void collect(current: (SpaceParent) `\< <Id name>`, Collector c) {
  c.use(name, {spaceId()});
}

void collect(current: (OperatorDef) `defoperator <Id name> : <{Type "-\>"}+ typeSig> end`, Collector c) {
  c.define(text(name), operatorId(), name, defType(vlType(text(name))));
  collect(typeSig, c);
}

void collect(current: (OperatorDef) `defoperator <Id name> : <{Type "-\>"}+ typeSig> <AttributeList attrs> end`, Collector c) {
  c.define(text(name), operatorId(), name, defType(vlType(text(name))));
  collect(typeSig, c);
  collect(attrs, c);
}

void collect(current: (VarDef) `defvar <{VarDecl ","}+ decls> end`, Collector c) {
  collect(decls, c);
}

void collect(current: (VarDecl) `<Id name> : <Type tp>`, Collector c) {
  c.define(text(name), variableId(), name, defType(tp));
  collect(tp, c);
}

void collect(current: (Type) `Int`, Collector c) {
  c.fact(current, vlType("Int"));
}

void collect(current: (Type) `Float`, Collector c) {
  c.fact(current, vlType("Float"));
}

void collect(current: (Type) `Bool`, Collector c) {
  c.fact(current, vlType("Bool"));
}

void collect(current: (Type) `Char`, Collector c) {
  c.fact(current, vlType("Char"));
}

void collect(current: (Type) `String`, Collector c) {
  c.fact(current, vlType("String"));
}

void collect(current: (Type) `<Id name>`, Collector c) {
  c.use(name, {spaceId()});
  c.fact(current, vlType(text(name)));
}

void collect(current: (RuleDef) `defrule <Application lhs> -\> <Application rhs> end`, Collector c) {
  collect(lhs, c);
  collect(rhs, c);
}

void collect(current: (ExpressionDef) `defexpression <LogicalExpression expr> end`, Collector c) {
  collect(expr, c);
}

void collect(current: (ExpressionDef) `defexpression <LogicalExpression expr> <AttributeList attrs> end`, Collector c) {
  collect(expr, c);
  collect(attrs, c);
}

void collect(current: (LogicalExpression) `<OrExpr expr>`, Collector c) {
  collect(expr, c);
}

void collect(current: (OrExpr) `<AndExpr expr>`, Collector c) {
  collect(expr, c);
}

void collect(current: (OrExpr) `<OrExpr lhs> or <AndExpr rhs>`, Collector c) {
  collect(lhs, c);
  collect(rhs, c);
}

void collect(current: (AndExpr) `<EqExpr expr>`, Collector c) {
  collect(expr, c);
}

void collect(current: (AndExpr) `<AndExpr lhs> and <EqExpr rhs>`, Collector c) {
  collect(lhs, c);
  collect(rhs, c);
}

void collect(current: (EqExpr) `<AddExpr expr>`, Collector c) {
  collect(expr, c);
}

void collect(current: (EqExpr) `<EqExpr lhs> = <AddExpr rhs>`, Collector c) {
  collect(lhs, c);
  collect(rhs, c);
}

void collect(current: (EqExpr) `<EqExpr lhs> \<\> <AddExpr rhs>`, Collector c) {
  collect(lhs, c);
  collect(rhs, c);
}

void collect(current: (EqExpr) `<EqExpr lhs> \< <AddExpr rhs>`, Collector c) {
  collect(lhs, c);
  collect(rhs, c);
}

void collect(current: (EqExpr) `<EqExpr lhs> \> <AddExpr rhs>`, Collector c) {
  collect(lhs, c);
  collect(rhs, c);
}

void collect(current: (EqExpr) `<EqExpr lhs> \<= <AddExpr rhs>`, Collector c) {
  collect(lhs, c);
  collect(rhs, c);
}

void collect(current: (EqExpr) `<EqExpr lhs> \>= <AddExpr rhs>`, Collector c) {
  collect(lhs, c);
  collect(rhs, c);
}

void collect(current: (EqExpr) `<EqExpr lhs> ≡ <AddExpr rhs>`, Collector c) {
  collect(lhs, c);
  collect(rhs, c);
}

void collect(current: (EqExpr) `<EqExpr lhs> =\> <AddExpr rhs>`, Collector c) {
  collect(lhs, c);
  collect(rhs, c);
}

void collect(current: (EqExpr) `<EqExpr lhs> in <AddExpr rhs>`, Collector c) {
  collect(lhs, c);
  collect(rhs, c);
}

void collect(current: (AddExpr) `<MultExpr expr>`, Collector c) {
  collect(expr, c);
}

void collect(current: (AddExpr) `<AddExpr lhs> + <MultExpr rhs>`, Collector c) {
  collect(lhs, c);
  collect(rhs, c);
}

void collect(current: (AddExpr) `<AddExpr lhs> - <MultExpr rhs>`, Collector c) {
  collect(lhs, c);
  collect(rhs, c);
}

void collect(current: (MultExpr) `<PowExpr expr>`, Collector c) {
  collect(expr, c);
}

void collect(current: (MultExpr) `<MultExpr lhs> * <PowExpr rhs>`, Collector c) {
  collect(lhs, c);
  collect(rhs, c);
}

void collect(current: (MultExpr) `<MultExpr lhs> / <PowExpr rhs>`, Collector c) {
  collect(lhs, c);
  collect(rhs, c);
}

void collect(current: (MultExpr) `<MultExpr lhs> % <PowExpr rhs>`, Collector c) {
  collect(lhs, c);
  collect(rhs, c);
}

void collect(current: (PowExpr) `<UnaryExpr expr>`, Collector c) {
  collect(expr, c);
}

void collect(current: (PowExpr) `<PowExpr lhs> ** <UnaryExpr rhs>`, Collector c) {
  collect(lhs, c);
  collect(rhs, c);
}

void collect(current: (UnaryExpr) `<Atom atom>`, Collector c) {
  collect(atom, c);
}

void collect(current: (UnaryExpr) `neg <Atom atom>`, Collector c) {
  collect(atom, c);
}

void collect(current: (UnaryExpr) `forall <Id var> in <Id domain> . <LogicalExpression body>`, Collector c) {
  c.use(domain, {spaceId()});
  c.enterScope(current);
  c.define(text(var), variableId(), var, defType(vlType(text(domain))));
  collect(body, c);
  c.leaveScope(current);
}

void collect(current: (UnaryExpr) `exists <Id var> in <Id domain> . <LogicalExpression body>`, Collector c) {
  c.use(domain, {spaceId()});
  c.enterScope(current);
  c.define(text(var), variableId(), var, defType(vlType(text(domain))));
  collect(body, c);
  c.leaveScope(current);
}

void collect(current: (Atom) `<Id name>`, Collector c) {
  c.use(name, {variableId()});
}

void collect(current: (Atom) `<Application app>`, Collector c) {
  collect(app, c);
}

void collect(current: (Atom) `<IntLiteral val>`, Collector c) {
}

void collect(current: (Atom) `<FloatLiteral val>`, Collector c) {
}

void collect(current: (Atom) `<CharLiteral val>`, Collector c) {
}

void collect(current: (Atom) `<BoolLiteral val>`, Collector c) {
}

void collect(current: (Atom) `<StringLiteral val>`, Collector c) {
}

void collect(current: (Atom) `(<LogicalExpression expr>)`, Collector c) {
  collect(expr, c);
}

void collect(current: (Application) `(<Id name> <LogicalExpression* args>)`, Collector c) {
  c.use(name, {operatorId()});
  collect(args, c);
}

private str messageText(Message msg) {
  switch (msg) {
    case error(m, _): return m;
    case warning(m, _): return "Warning: <m>";
    case info(m, _): return "Info: <m>";
    default: return "<msg>";
  }
}

private list[str] typePalCheck(Tree tree) {
  return [messageText(msg) | msg <- getMessages(collectAndSolve(tree))];
}

private str typeName(AST::Type tp) {
  switch (tp) {
    case AST::intType(): return "Int";
    case AST::floatType(): return "Float";
    case AST::boolType(): return "Bool";
    case AST::charType(): return "Char";
    case AST::stringType(): return "String";
    case AST::userType(name): return name;
  }
}

private bool sameType(AST::Type left, AST::Type right) = typeName(left) == typeName(right);

private AST::Type unknownType() = AST::userType("__unknown__");

private bool unknown(AST::Type tp) = sameType(tp, unknownType());

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

private list[str] checkOperatorShape(AST::Definition def) {
  list[str] errors = [];
  switch (def) {
    case AST::opDefinition(AST::operatorNode(name, sig, _)):
      if (size(sig) < 2) errors += "Operator <name> must have at least one argument type and one result type";
    default: ;
  }
  return errors;
}

private Check withBool(Check c, str context) {
  list[str] errors = c.errors;
  if (!unknown(c.tp) && !sameType(c.tp, AST::boolType())) {
    errors += "Expected Bool in <context>, found <typeName(c.tp)>";
  }
  return checkResult(AST::boolType(), errors);
}

private list[str] requireBool(AST::Type tp, str context) {
  return unknown(tp) || sameType(tp, AST::boolType())
    ? []
    : ["Expected Bool in <context>, found <typeName(tp)>"];
}

private Check typeOfApp(str name, list[AST::Expression] args, VarEnv vars, OpEnv ops) {
  list[str] errors = [];
  if (!(name in ops)) {
    for (arg <- args) errors += typeOf(arg, vars, ops).errors;
    return checkResult(unknownType(), errors);
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
    Check arg = typeOf(args[i], vars, ops);
    errors += arg.errors;
    if (arg.errors == [] && !unknown(arg.tp) && !sameType(arg.tp, sig[i])) {
      errors += "Argument <i + 1> of operator <name> expects <typeName(sig[i])>, found <typeName(arg.tp)>";
    }
  }

  return checkResult(sig[size(sig) - 1], errors);
}

private Check typeOfComparison(AST::ComparisonOp op, AST::Expression lhs, AST::Expression rhs,
    VarEnv vars, OpEnv ops) {
  Check l = typeOf(lhs, vars, ops);
  Check r = typeOf(rhs, vars, ops);
  list[str] errors = l.errors + r.errors;

  switch (op) {
    case AST::eqOp():
      if (l.errors == [] && r.errors == [] && !unknown(l.tp) && !unknown(r.tp) && !sameType(l.tp, r.tp)) errors += "Equality requires operands of the same type, found <typeName(l.tp)> and <typeName(r.tp)>";
    case AST::neqOp():
      if (l.errors == [] && r.errors == [] && !unknown(l.tp) && !unknown(r.tp) && !sameType(l.tp, r.tp)) errors += "Inequality requires operands of the same type, found <typeName(l.tp)> and <typeName(r.tp)>";
    case AST::equivOp():
      errors += requireBool(l.tp, "equivalence") + requireBool(r.tp, "equivalence");
    case AST::implOp():
      errors += requireBool(l.tp, "implication") + requireBool(r.tp, "implication");
    case AST::inOp():
      if (AST::identifier(domain) := rhs) {
        if (l.errors == [] && !unknown(l.tp) && typeName(l.tp) != domain) {
          errors += "Membership requires left operand of type <domain>, found <typeName(l.tp)>";
        }
      } else if (l.errors == [] && r.errors == [] && !unknown(l.tp) && !unknown(r.tp) && !sameType(l.tp, r.tp)) {
        errors += "Membership requires matching element and domain types, found <typeName(l.tp)> and <typeName(r.tp)>";
      }
    default:
      if (l.errors == [] && r.errors == [] && !unknown(l.tp) && !unknown(r.tp) &&
          !((sameType(l.tp, AST::intType()) && sameType(r.tp, AST::intType())) ||
            (sameType(l.tp, AST::floatType()) && sameType(r.tp, AST::floatType())))) {
        errors += "Ordering comparisons require Int or Float operands, found <typeName(l.tp)> and <typeName(r.tp)>";
      }
  }

  return checkResult(AST::boolType(), errors);
}

private Check typeOf(AST::Expression expr, VarEnv vars, OpEnv ops) {
  switch (expr) {
    case AST::identifier(name):
      return name in vars
        ? checkResult(vars[name], [])
        : checkResult(unknownType(), []);

    case AST::literal(AST::intLiteral(_)): return checkResult(AST::intType(), []);
    case AST::literal(AST::floatLiteral(_)): return checkResult(AST::floatType(), []);
    case AST::literal(AST::boolLiteral(_)): return checkResult(AST::boolType(), []);
    case AST::literal(AST::charLiteral(_)): return checkResult(AST::charType(), []);
    case AST::literal(AST::stringLiteral(_)): return checkResult(AST::stringType(), []);

    case AST::applicationExpr(AST::applicationNode(name, args)):
      return typeOfApp(name, args, vars, ops);

    case AST::negation(e):
      return withBool(typeOf(e, vars, ops), "negation");

    case AST::disjunction(lhs, rhs):
      return checkResult(AST::boolType(),
        withBool(typeOf(lhs, vars, ops), "disjunction").errors +
        withBool(typeOf(rhs, vars, ops), "disjunction").errors);

    case AST::conjunction(lhs, rhs):
      return checkResult(AST::boolType(),
        withBool(typeOf(lhs, vars, ops), "conjunction").errors +
        withBool(typeOf(rhs, vars, ops), "conjunction").errors);

    case AST::comparison(op, lhs, rhs):
      return typeOfComparison(op, lhs, rhs, vars, ops);

    case AST::arithmetic(arithOp, lhs, rhs): {
      Check l = typeOf(lhs, vars, ops);
      Check r = typeOf(rhs, vars, ops);
      list[str] errors = l.errors + r.errors;
      if (l.errors == [] && r.errors == [] && !unknown(l.tp) && !unknown(r.tp)) {
        if (arithOp == AST::modOp()) {
          if (!sameType(l.tp, AST::intType()) || !sameType(r.tp, AST::intType())) {
            errors += "Modulo requires Int operands, found <typeName(l.tp)> and <typeName(r.tp)>";
          }
        } else if (!((sameType(l.tp, AST::intType()) && sameType(r.tp, AST::intType())) ||
                     (sameType(l.tp, AST::floatType()) && sameType(r.tp, AST::floatType())))) {
          errors += "Arithmetic operators require matching Int or Float operands, found <typeName(l.tp)> and <typeName(r.tp)>";
        }
      }
      return checkResult(sameType(l.tp, AST::floatType()) ? AST::floatType() : AST::intType(), errors);
    }

    case AST::power(lhs, rhs): {
      Check l = typeOf(lhs, vars, ops);
      Check r = typeOf(rhs, vars, ops);
      list[str] errors = l.errors + r.errors;
      if (l.errors == [] && !unknown(l.tp) && !sameType(l.tp, AST::intType())) errors += "Power base must be Int, found <typeName(l.tp)>";
      if (r.errors == [] && !unknown(r.tp) && !sameType(r.tp, AST::intType())) errors += "Power exponent must be Int, found <typeName(r.tp)>";
      return checkResult(AST::intType(), errors);
    }

    case AST::quantified(_, var, domain, body): {
      VarEnv scopedVars = vars;
      scopedVars[var] = AST::userType(domain);
      list[str] errors = withBool(typeOf(body, scopedVars, ops), "quantifier body").errors;
      return checkResult(AST::boolType(), errors);
    }

    default:
      return checkResult(AST::boolType(), ["Unsupported expression in type checker"]);
  }
}

private list[str] checkRule(AST::RuleDef rule, VarEnv vars, OpEnv ops) {
  Check lhs = typeOfApp(rule.lhs.name, rule.lhs.args, vars, ops);
  Check rhs = typeOfApp(rule.rhs.name, rule.rhs.args, vars, ops);
  list[str] errors = lhs.errors + rhs.errors;

  if ((rule.lhs.name in ops) && (rule.rhs.name in ops) && !unknown(lhs.tp) && !unknown(rhs.tp) && !sameType(lhs.tp, rhs.tp)) {
    errors += "Rule result types must match, found <typeName(lhs.tp)> and <typeName(rhs.tp)>";
  }

  return errors;
}

public list[str] check(AST::Module m) {
  VarEnv vars = varsOf(m);
  OpEnv ops = opsOf(m);

  list[str] errors = [];
  for (def <- m.defs) {
    errors += checkOperatorShape(def);
    switch (def) {
      case AST::ruleDefinition(rule):
        errors += checkRule(rule, vars, ops);
      case AST::expressionDefinition(AST::expressionNode(expr, _)):
        errors += typeOf(expr, vars, ops).errors;
      default: ;
    }
  }
  return errors;
}

public list[str] check(Tree tree, AST::Module m) {
  return typePalCheck(tree) + check(m);
}
