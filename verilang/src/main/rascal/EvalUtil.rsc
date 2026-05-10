module EvalUtil

import AST;
import Val;

public Val evalLiteral(AST::Literal lit) {
  switch (lit) {
    case AST::intLiteral(n): return intVal(n);
    case AST::floatLiteral(f): return floatVal(f);
    case AST::boolLiteral(b): return boolVal(b);
    case AST::charLiteral(c): return charVal(c);
    case AST::stringLiteral(s): return stringVal(s);
    default: throw "Unknown literal";
  }
}

public Val evalArith(AST::ArithOp op, Val l, Val r) {
  if (intVal(li) := l, intVal(ri) := r) {
    switch (op) {
      case AST::addOp(): return intVal(li + ri);
      case AST::subOp(): return intVal(li - ri);
      case AST::mulOp(): return intVal(li * ri);
      case AST::divOp(): if (ri == 0) throw "Division by zero"; else return intVal(li / ri);
      case AST::modOp(): return intVal(li % ri);
    }
  }
  if (floatVal(lf) := l, floatVal(rf) := r) {
    switch (op) {
      case AST::addOp(): return floatVal(lf + rf);
      case AST::subOp(): return floatVal(lf - rf);
      case AST::mulOp(): return floatVal(lf * rf);
      case AST::divOp(): if (rf == 0.0) throw "Division by zero"; else return floatVal(lf / rf);
      default: throw "Unsupported float operation";
    }
  }
  throw "Type error in arithmetic";
}
