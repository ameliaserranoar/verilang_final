module AST

data Module
  = moduleNode(str name, list[Definition] defs)
  ;

data Definition
  = usingDefinition(Using usingDecl)
  | spaceDefinition(SpaceDef spaceDecl)
  | operatorDefinition(OperatorDef operatorDecl)
  | varDefinition(VarDef varDecl)
  | ruleDefinition(RuleDef ruleDecl)
  | expressionDefinition(ExpressionDef exprDecl)
  ;

data Using
  = usingNode(str name)
  ;

data SpaceDef
  = spaceNode(str name, SpaceParent parent)
  ;

data SpaceParent
  = noSpaceParent()
  | spaceParentNode(str name)
  ;

data OperatorDef
  = operatorNode(str name, list[Type] typeSig, list[Attribute] attrs)
  ;

data VarDef
  = varNode(list[VarDecl] decls)
  ;

data VarDecl
  = varDeclNode(str name, Type tp)
  ;

data RuleDef
  = ruleNode(Application lhs, Application rhs)
  ;

data ExpressionDef
  = expressionNode(Expression expr, list[Attribute] attrs)
  ;

data Expression
  = identifier(str name)
  | applicationExpr(Application app)
  | negation(Expression expr)
  | quantified(Quantifier quantifier, str var, str domain, Expression body)
  | disjunction(Expression lhs, Expression rhs)
  | conjunction(Expression lhs, Expression rhs)
  | comparison(ComparisonOp compOp, Expression lhs, Expression rhs)
  | arithmetic(ArithOp arithOp, Expression lhs, Expression rhs)
  | power(Expression base, Expression exponent)
  | literal(Literal lit)
  ;

data Quantifier
  = forallQuantifier()
  | existsQuantifier()
  ;

data ComparisonOp
  = eqOp()
  | neqOp()
  | ltOp()
  | gtOp()
  | lteOp()
  | gteOp()
  | equivOp()
  | implOp()
  | inOp()
  ;

data ArithOp
  = addOp()
  | subOp()
  | mulOp()
  | divOp()
  | modOp()
  ;

data Literal
  = intLiteral(int intVal)
  | floatLiteral(real floatVal)
  | charLiteral(str charVal)
  | boolLiteral(bool boolVal)
  | stringLiteral(str stringVal)
  ;

data Application
  = applicationNode(str name, list[Expression] args)
  ;

data Type
  = intType()
  | boolType()
  | charType()
  | stringType()
  | userType(str name)
  ;

data Attribute
  = bareAttribute(str name)
  | valuedAttribute(str name, str attrValue)
  ;
