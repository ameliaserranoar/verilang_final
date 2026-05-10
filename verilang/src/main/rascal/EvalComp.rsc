module EvalComp

import AST;
import Val;

public Val evalComparison(AST::ComparisonOp op, Val l, Val r) {
  switch (op) {
    case AST::eqOp(): return boolVal(l == r);
    case AST::neqOp(): return boolVal(l != r);
    case AST::equivOp(): {
      if (boolVal(lb) := l, boolVal(rb) := r) return boolVal(lb == rb);
      throw "Type error in equivalence";
    }
    case AST::implOp(): {
      if (boolVal(lb) := l, boolVal(rb) := r) return boolVal(!lb || rb);
      throw "Type error in implication";
    }
    case AST::inOp(): return appVal("in", [l, r]);
    default: {
      if (intVal(li) := l, intVal(ri) := r) {
        switch (op) {
          case AST::ltOp(): return boolVal(li < ri);
          case AST::gtOp(): return boolVal(li > ri);
          case AST::lteOp(): return boolVal(li <= ri);
          case AST::gteOp(): return boolVal(li >= ri);
          default: throw "Unsupported comparison";
        }
      }
      throw "Type error in comparison";
    }
  }
}
