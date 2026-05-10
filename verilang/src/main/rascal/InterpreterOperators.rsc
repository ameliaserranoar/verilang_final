module InterpreterOperators

import RuntimeValue;

public Val evalNeg(Val v) {
  if (boolVal(b) := v) return boolVal(!b);
  throw "Type error in negation";
}

public Val evalPower(Val l, Val r) {
  if (intVal(li) := l, intVal(ri) := r) {
    if (ri < 0) throw "Negative power not supported";
    return intVal(powHelper(li, ri));
  }
  throw "Type error in power";
}

private int powHelper(int base, int exp) {
  if (exp == 0) return 1;
  return base * powHelper(base, exp - 1);
}
