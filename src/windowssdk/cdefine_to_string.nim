import macros, unicode

macro defineDistinctToStringProc*(`distinct`, base: typed, values: varargs[untyped]): typed =
  # echo `distinct`.treeRepr
  `distinct`.expectKind({nnkIdent, nnkSym})
  # echo base.treeRepr
  base.expectKind({nnkIdent, nnkSym})
  # echo values.treeRepr
  values.expectKind(nnkArgList)
  var procBody = newStmtList()
  var valueIdent = ident("v")
  var stringify = newNimNode(nnkAccQuoted).add(ident("$"))
  var caseStmt = newNimNode(nnkCaseStmt).add(valueIdent)
  if values.len > 0:
    for value in values.children:
      var strLit: NimNode
      case value.kind
      of nnkIdent, nnkSym:
        strLit = newLit(($value).toUpper)
      of nnkAccQuoted:
        value.expectLen(1)
        value[0].expectKind({nnkIdent, nnkSym})
        strLit = newLit(($value[0]).toUpper)
      else: value.expectKind({nnkIdent, nnkSym, nnkAccQuoted})
      caseStmt.add(newNimNode(nnkOfBranch).add(value, strLit))
  caseStmt.add(newNimNode(nnkElse).add(prefix(newDotExpr(valueIdent, base), "$")))
  procBody.add(caseStmt)
  var procDef = newProc(
    name = postfix(stringify, "*"),
    params = [newIdentNode("string"), newIdentDefs(valueIdent, `distinct`)],
    body = procBody)
  result = newStmtList(procDef)
  # echo repr(result)
