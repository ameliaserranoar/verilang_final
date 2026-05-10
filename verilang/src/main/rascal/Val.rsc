module Val

import String;

data Val
  = intVal(int n)
  | floatVal(real f)
  | boolVal(bool b)
  | charVal(str c)
  | stringVal(str s)
  | appVal(str name, list[Val] args)
  ;

private str showApp(str name, list[Val] args) {
  str result = "(<name>";
  for (a <- args) {
    result += " <show(a)>";
  }
  result += ")";
  return result;
}

public str show(Val v) {
  switch (v) {
    case intVal(n): return "<n>";
    case floatVal(f): return "<f>";
    case boolVal(b): return b ? "true" : "false";
    case charVal(c): return "\'<c>\'";
    case stringVal(s): return "\"<s>\"";
    case appVal(name, args): return showApp(name, args);
    default: return "?";
  }
}
