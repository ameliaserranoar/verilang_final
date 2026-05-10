module Syntax

layout Layout = WhitespaceAndComment* !>> [\ \t\n\r#];
lexical WhitespaceAndComment = [\ \t\n\r] | @category="Comment" "#" ![\n]* $;

start syntax Module = \module: "defmodule" Id name Definition* defs "end";

syntax Definition 
  = usingDef: Using
  | spaceDef: SpaceDef
  | operatorDef: OperatorDef
  | varDef: VarDef
  | ruleDef: RuleDef
  | expressionDef: ExpressionDef
  ;

syntax Using = using: "using" Id name;

syntax SpaceDef = spaceDef: "defspace" Id name SpaceParent? parent "end";

syntax SpaceParent = spaceParent: "\<" Id name;

syntax OperatorDef = operatorDef: "defoperator" Id name ":" {Type "-\>"}+ typeSig AttributeList? attrs "end";

syntax VarDef = varDef: "defvar" {VarDecl ","}+ decls "end";

syntax VarDecl = varDecl: Id name ":" Type tp;

syntax RuleDef = ruleDef: "defrule" Application lhs "-\>" Application rhs "end";

syntax ExpressionDef = expressionDef: "defexpression" LogicalExpression expr AttributeList? attrs "end";

syntax LogicalExpression = OrExpr;

syntax OrExpr 
  = AndExpr
  | or: OrExpr "or" AndExpr
  ;

syntax AndExpr 
  = EqExpr
  | and: AndExpr "and" EqExpr
  ;

syntax EqExpr 
  = AddExpr
  | eq: EqExpr "=" AddExpr
  | neq: EqExpr "\<\>" AddExpr
  | lt: EqExpr "\<" AddExpr
  | gt: EqExpr "\>" AddExpr
  | lte: EqExpr "\<=" AddExpr
  | gte: EqExpr "\>=" AddExpr
  | equiv: EqExpr "≡" AddExpr
  | impl: EqExpr "=\>" AddExpr
  | inn: EqExpr "in" AddExpr
  ;

syntax AddExpr
  = MultExpr
  | add: AddExpr "+" MultExpr
  | sub: AddExpr "-" MultExpr
  ;

syntax MultExpr
  = PowExpr
  | mul: MultExpr "*" PowExpr
  | div: MultExpr "/" PowExpr
  | modulo: MultExpr "%" PowExpr
  ;

syntax PowExpr
  = UnaryExpr
  | pow: PowExpr "**" UnaryExpr
  ;

syntax UnaryExpr 
  = Atom
  | neg: "neg" Atom
  | forall: "forall" Id var "in" Id domain "." LogicalExpression body
  | exists: "exists" Id var "in" Id domain "." LogicalExpression body
  ;

syntax Atom 
  = atomId: Id
  | atomApp: Application
  | atomInt: IntLiteral
  | atomFloat: FloatLiteral
  | atomChar: CharLiteral
  | atomBool: BoolLiteral
  | atomString: StringLiteral
  | paren: "(" LogicalExpression ")"
  ;

syntax Application = app: "(" Id name LogicalExpression* args ")";

syntax Type 
  = intType: "Int"
  | boolType: "Bool"
  | charType: "Char"
  | stringType: "String"
  | userType: Id name
  ;

syntax AttributeList = attrList: "[" Attribute+ attrs "]";

syntax Attribute = attr: Id name AttributeValue? value;

syntax AttributeValue = attrValue: ":" Id val;

lexical Id = ([a-zA-Z][a-zA-Z0-9\-]* !>> [a-zA-Z0-9\-]) \ Reserved;

lexical IntLiteral = [0-9]+ !>> [0-9];

lexical FloatLiteral = [0-9]+ "." [0-9]+ !>> [0-9];

lexical CharLiteral = "\'" [a-zA-Z] "\'";

lexical BoolLiteral = "true" | "false";

lexical StringLiteral = "\"" ![\"]* "\"";

keyword Reserved = 
  "defmodule" | "using" | "defspace" | "defoperator" | 
  "defexpression" | "defrule" | "defvar" | "end" | 
  "forall" | "exists" | "in" | "defer" | "neg" | 
  "or" | "and" | "true" | "false" | 
  "Int" | "Bool" | "Char" | "String";
