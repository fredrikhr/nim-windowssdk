import macros, strutils, unicode

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
        strLit = newLit(unicode.toUpper($value))
      of nnkAccQuoted:
        value.expectLen(1)
        value[0].expectKind({nnkIdent, nnkSym})
        strLit = newLit(unicode.toUpper($value[0]))
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

proc infixBorrowOperatorProc(`distinct`, base: NimNode, op: string, returnType: NimNode = ident("bool"), exportable: bool = true, docString: string = nil): NimNode =
  let
    leftArgIdent = ident("a")
    rightArgIdent = ident("b")
    leftBaseValue = newDotExpr(leftArgIdent, base)
    rightBaseValue = newDotExpr(rightArgIdent, base)
    argsIdentDefs = newNimNode(nnkIdentDefs).add(leftArgIdent, rightArgIdent, `distinct`, newEmptyNode())
  var procBody = infix(leftBaseValue, op, rightBaseValue)
  if docString.len > 0:
    var docComment = newNimNode(nnkCommentStmt)
    #docComment.strVal = docString
    procBody = newStmtList(docComment, procBody)
  var procName = newNimNode(nnkAccQuoted).add(ident(op))
  if exportable: procName = postfix(procName, "*")
  result = newProc(
    name = procName, params = [returnType, argsIdentDefs],
    body = procBody)
  echo repr(result)

macro distinctValueTypeCommonProcs*(`distinct`, base: typed, knownValues: varargs[untyped]): typed =
  ## Declares common procs for a distinct value type with the specified base type
  ## 
  ## Common procs for distinct value types:
  ## - Equality (``==``) and Inequality (`!=`) operators, comparing by using the base type value
  ## - Stringify (``$``) operator, which returns the matching identifier name in **all uppercase**
  ##   specified in the ``knownValues`` parameter.
  ## - ``parse<distinct>`` which parses a string value using case-insensitive matching against
  ##   the identifiers specified in the ``knownValues`` parameter. Throws a ``ValueError`` if
  ##   no match is found
  ## - ``tryParse<distinct>`` does the same as ``parse<distinct>``, but writes the result into an
  ##   optional var argument and returns a boolean value to indicate success. Does not throw an error.

  # echo `distinct`.treeRepr
  `distinct`.expectKind({nnkIdent, nnkSym})
  # echo base.treeRepr
  base.expectKind({nnkIdent, nnkSym})
  # echo knownValues.treeRepr
  knownValues.expectKind({nnkArgList, nnkBracket})

  let eqNeqSuffix = "Compares the argument values casted to their base type (``$#``)" % [$base]
  result = newStmtList()
  result.add(infixBorrowOperatorProc(`distinct`, base, "==", docString = "Equality operator for $# values. $#" % [$`distinct`, eqNeqSuffix]))
  result.add(infixBorrowOperatorProc(`distinct`, base, "!=", docString = "Inequality operator for $# values. $#" % [$`distinct`, eqNeqSuffix]))

type StrangeInt = distinct int

distinctValueTypeCommonProcs(StrangeInt, int)
