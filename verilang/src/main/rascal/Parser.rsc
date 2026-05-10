module Parser

import AST;
import ParseTree;
import String;
import Syntax;

public AST::Module toAST(Tree tree) {
  if (start[Module] s := tree) {
    return toAST(s.top);
  }
  switch (tree) {
    case (Module) `defmodule <Id name> <Definition* defs> end`:
      return AST::moduleNode(text(name), [toDefinition(def) | def <- defs]);
    default:
      throw "Expected a VeriLang module parse tree, found <tree>";
  }
}

private AST::Definition toDefinition(Tree tree) {
  switch (tree) {
    case (Definition) `<Using usingDecl>`:
      return AST::usingDefinition(toUsing(usingDecl));
    case (Definition) `<SpaceDef spaceDecl>`:
      return AST::spaceDefinition(toSpaceDef(spaceDecl));
    case (Definition) `<OperatorDef operatorDecl>`:
      return AST::opDefinition(toOperatorDef(operatorDecl));
    case (Definition) `<VarDef varDecl>`:
      return AST::varDefinition(toVarDef(varDecl));
    case (Definition) `<RuleDef ruleDecl>`:
      return AST::ruleDefinition(toRuleDef(ruleDecl));
    case (Definition) `<ExpressionDef exprDecl>`:
      return AST::expressionDefinition(toExpressionDef(exprDecl));
    default:
      throw "Unsupported definition parse tree: <tree>";
  }
}

private AST::Using toUsing(Tree tree) {
  switch (tree) {
    case (Using) `using <Id name>`:
      return AST::usingNode(text(name));
    default:
      throw "Unsupported using parse tree: <tree>";
  }
}

private AST::SpaceDef toSpaceDef(Tree tree) {
  switch (tree) {
    case (SpaceDef) `defspace <Id name> end`:
      return AST::spaceNode(text(name), AST::noSpaceParent());
    case (SpaceDef) `defspace <Id name> <SpaceParent parent> end`:
      return AST::spaceNode(text(name), toSpaceParent(parent));
    default:
      throw "Unsupported space definition parse tree: <tree>";
  }
}

private AST::SpaceParent toSpaceParent(Tree tree) {
  switch (tree) {
    case (SpaceParent) `\< <Id name>`:
      return AST::spaceParentNode(text(name));
    default:
      throw "Unsupported space parent parse tree: <tree>";
  }
}

private AST::OperatorDef toOperatorDef(Tree tree) {
  switch (tree) {
    case (OperatorDef) `defoperator <Id name> : <{Type "-\>"}+ typeSig> end`:
      return AST::operatorNode(text(name), [toType(tp) | tp <- typeSig], []);
    case (OperatorDef) `defoperator <Id name> : <{Type "-\>"}+ typeSig> <AttributeList attrs> end`:
      return AST::operatorNode(text(name), [toType(tp) | tp <- typeSig], toAttributes(attrs));
    default:
      throw "Unsupported operator definition parse tree: <tree>";
  }
}

private AST::VarDef toVarDef(Tree tree) {
  switch (tree) {
    case (VarDef) `defvar <{VarDecl ","}+ decls> end`:
      return AST::varNode([toVarDecl(decl) | decl <- decls]);
    default:
      throw "Unsupported variable definition parse tree: <tree>";
  }
}

private AST::VarDecl toVarDecl(Tree tree) {
  switch (tree) {
    case (VarDecl) `<Id name> : <Type tp>`:
      return AST::varDeclNode(text(name), toType(tp));
    default:
      throw "Unsupported variable declaration parse tree: <tree>";
  }
}

private AST::RuleDef toRuleDef(Tree tree) {
  switch (tree) {
    case (RuleDef) `defrule <Application lhs> -\> <Application rhs> end`:
      return AST::ruleNode(toApplication(lhs), toApplication(rhs));
    default:
      throw "Unsupported rule definition parse tree: <tree>";
  }
}

private AST::ExpressionDef toExpressionDef(Tree tree) {
  switch (tree) {
    case (ExpressionDef) `defexpression <LogicalExpression expr> end`:
      return AST::expressionNode(toExpression(expr), []);
    case (ExpressionDef) `defexpression <LogicalExpression expr> <AttributeList attrs> end`:
      return AST::expressionNode(toExpression(expr), toAttributes(attrs));
    default:
      throw "Unsupported expression definition parse tree: <tree>";
  }
}

private AST::Expression toExpression(Tree tree) {
  switch (tree) {
    case (LogicalExpression) `<OrExpr expr>`:
      return toExpression(expr);
    case (OrExpr) `<AndExpr expr>`:
      return toExpression(expr);
    case (OrExpr) `<OrExpr lhs> or <AndExpr rhs>`:
      return AST::disjunction(toExpression(lhs), toExpression(rhs));
    case (AndExpr) `<EqExpr expr>`:
      return toExpression(expr);
    case (AndExpr) `<AndExpr lhs> and <EqExpr rhs>`:
      return AST::conjunction(toExpression(lhs), toExpression(rhs));
    case (EqExpr) `<AddExpr expr>`:
      return toExpression(expr);
    case (EqExpr) `<EqExpr lhs> = <AddExpr rhs>`:
      return AST::comparison(AST::eqOp(), toExpression(lhs), toExpression(rhs));
    case (EqExpr) `<EqExpr lhs> \<\> <AddExpr rhs>`:
      return AST::comparison(AST::neqOp(), toExpression(lhs), toExpression(rhs));
    case (EqExpr) `<EqExpr lhs> \< <AddExpr rhs>`:
      return AST::comparison(AST::ltOp(), toExpression(lhs), toExpression(rhs));
    case (EqExpr) `<EqExpr lhs> \> <AddExpr rhs>`:
      return AST::comparison(AST::gtOp(), toExpression(lhs), toExpression(rhs));
    case (EqExpr) `<EqExpr lhs> \<= <AddExpr rhs>`:
      return AST::comparison(AST::lteOp(), toExpression(lhs), toExpression(rhs));
    case (EqExpr) `<EqExpr lhs> \>= <AddExpr rhs>`:
      return AST::comparison(AST::gteOp(), toExpression(lhs), toExpression(rhs));
    case (EqExpr) `<EqExpr lhs> ≡ <AddExpr rhs>`:
      return AST::comparison(AST::equivOp(), toExpression(lhs), toExpression(rhs));
    case (EqExpr) `<EqExpr lhs> =\> <AddExpr rhs>`:
      return AST::comparison(AST::implOp(), toExpression(lhs), toExpression(rhs));
    case (EqExpr) `<EqExpr lhs> in <AddExpr rhs>`:
      return AST::comparison(AST::inOp(), toExpression(lhs), toExpression(rhs));
    case (AddExpr) `<MultExpr expr>`:
      return toExpression(expr);
    case (AddExpr) `<AddExpr lhs> + <MultExpr rhs>`:
      return AST::arithmetic(AST::addOp(), toExpression(lhs), toExpression(rhs));
    case (AddExpr) `<AddExpr lhs> - <MultExpr rhs>`:
      return AST::arithmetic(AST::subOp(), toExpression(lhs), toExpression(rhs));
    case (MultExpr) `<PowExpr expr>`:
      return toExpression(expr);
    case (MultExpr) `<MultExpr lhs> * <PowExpr rhs>`:
      return AST::arithmetic(AST::mulOp(), toExpression(lhs), toExpression(rhs));
    case (MultExpr) `<MultExpr lhs> / <PowExpr rhs>`:
      return AST::arithmetic(AST::divOp(), toExpression(lhs), toExpression(rhs));
    case (MultExpr) `<MultExpr lhs> % <PowExpr rhs>`:
      return AST::arithmetic(AST::modOp(), toExpression(lhs), toExpression(rhs));
    case (PowExpr) `<UnaryExpr expr>`:
      return toExpression(expr);
    case (PowExpr) `<PowExpr lhs> ** <UnaryExpr rhs>`:
      return AST::power(toExpression(lhs), toExpression(rhs));
    case (UnaryExpr) `<Atom atom>`:
      return toExpression(atom);
    case (UnaryExpr) `neg <Atom atom>`:
      return AST::negation(toExpression(atom));
    case (UnaryExpr) `forall <Id var> in <Id domain> . <LogicalExpression body>`:
      return AST::quantified(AST::forallQuantifier(), text(var), text(domain), toExpression(body));
    case (UnaryExpr) `exists <Id var> in <Id domain> . <LogicalExpression body>`:
      return AST::quantified(AST::existsQuantifier(), text(var), text(domain), toExpression(body));
    case (Atom) `<Id name>`:
      return AST::identifier(text(name));
    case (Atom) `<Application app>`:
      return AST::applicationExpr(toApplication(app));
    case (Atom) `<IntLiteral val>`:
      return AST::literal(AST::intLiteral(toInt(text(val))));
    case (Atom) `<FloatLiteral val>`:
      return AST::literal(AST::floatLiteral(toReal(text(val))));
    case (Atom) `<CharLiteral val>`:
      return AST::literal(AST::charLiteral(text(val)));
    case (Atom) `<BoolLiteral val>`:
      return AST::literal(AST::boolLiteral(text(val) == "true"));
    case (Atom) `<StringLiteral val>`:
      return AST::literal(AST::stringLiteral(text(val)[1..size(text(val))-1]));
    case (Atom) `(<LogicalExpression expr>)`:
      return toExpression(expr);
    default:
      throw "Unsupported expression parse tree: <tree>";
  }
}

private AST::Application toApplication(Tree tree) {
  switch (tree) {
    case (Application) `(<Id name> <LogicalExpression* args>)`:
      return AST::applicationNode(text(name), [toExpression(arg) | arg <- args]);
    default:
      throw "Unsupported application parse tree: <tree>";
  }
}

private AST::Type toType(Tree tree) {
  switch (tree) {
    case (Type) `Int`:    return AST::intType();
    case (Type) `Bool`:   return AST::boolType();
    case (Type) `Char`:   return AST::charType();
    case (Type) `String`: return AST::stringType();
    case (Type) `<Id name>`: return AST::userType(text(name));
    default: throw "Unsupported type parse tree: <tree>";
  }
}

private list[AST::Attribute] toAttributes(Tree tree) {
  switch (tree) {
    case (AttributeList) `[<Attribute+ attrs>]`:
      return [toAttribute(attr) | attr <- attrs];
    default:
      throw "Unsupported attribute list parse tree: <tree>";
  }
}

private AST::Attribute toAttribute(Tree tree) {
  switch (tree) {
    case (Attribute) `<Id name>`:
      return AST::bareAttribute(text(name));
    case (Attribute) `<Id name> <AttributeValue attrValue>`:
      return AST::valuedAttribute(text(name), toAttributeValue(attrValue));
    default:
      throw "Unsupported attribute parse tree: <tree>";
  }
}

private str toAttributeValue(Tree tree) {
  switch (tree) {
    case (AttributeValue) `: <Id name>`:
      return text(name);
    default:
      throw "Unsupported attribute value parse tree: <tree>";
  }
}

private str text(Tree tree) = trim(unparse(tree));
