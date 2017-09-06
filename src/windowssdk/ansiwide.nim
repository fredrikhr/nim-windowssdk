import macros

type
  IdentReplacement = tuple[src, dst: string]
  AnsiWideReplacement = tuple[src, ansi, wide: string]

proc getIdentOrSymString(n: NimNode): string =
  if n.isNil(): return nil
  case n.kind
  of nnkIdent:
    result = $n.ident
  of nnkSym:
    result = $n.symbol
  else:
    expectKind(n, {nnkIdent, nnkSym})

proc pragmaImportcReplace(pragma, importc: NimNode): NimNode =
  var foundImportc = false
  var newPragma = copyNimNode(pragma)
  for pragmaChild in pragma.children:
    var addPragmaChild = true
    case pragmaChild.kind
    of nnkIdent, nnkSym:
      if pragmaChild.eqIdent("importC"):
        foundImportc = true
        var importcColonExpr = newNimNode(nnkExprColonExpr)
        importcColonExpr.add(newIdentNode("importC"), importc.copy())
        newPragma.add(importcColonExpr)
        addPragmaChild = false
    of nnkExprColonExpr:
      if pragmaChild.len > 0 and pragmaChild[0].eqIdent("importC"):
        foundImportc = true
        var importcColonExpr = newNimNode(nnkExprColonExpr)
        importcColonExpr.add(newIdentNode("importC"), importc.copy())
        newPragma.add(importcColonExpr)
        addPragmaChild = false
    else: discard
    if addPragmaChild: newPragma.add(pragmaChild.copy())
  result = if foundImportc: newPragma else: pragma

proc modifyAstRecursive(identReplacements: openarray[IdentReplacement], ast: NimNode, importc: NimNode): NimNode =
  if ast.isNil(): return
  result = copyNimNode(ast)
  if ast.kind in {nnkIdent, nnkSym}:
    for replace in identReplacements:
      if ast.eqIdent(replace.src):
        result = newIdentNode(replace.dst)
        break
  if ast.len > 0:
    for astChild in ast.children:
      result.add(modifyAstRecursive(identReplacements, astChild, importc))
  if not(importc.isNil()) and result.kind == nnkPragma and result.len > 0:
    result = pragmaImportcReplace(result, importc)

proc unpackAnsiWideReplacement(replace: AnsiWideReplacement): auto =
  (ansi: (replace.src, replace.ansi), wide: (replace.src, replace.wide))

proc unpackAnsiWideReplacements(ansiWideReplacements: openarray[AnsiWideReplacement]): auto =
  var ansiReplacements = newSeq[IdentReplacement](ansiWideReplacements.len)
  var wideReplacements = newSeq[IdentReplacement](ansiWideReplacements.len)
  var i = 0
  for replace in ansiWideReplacements:
    let x = unpackAnsiWideReplacement(replace)
    ansiReplacements[i] = x.ansi
    wideReplacements[i] = x.wide
    i += 1
  (ansi: ansiReplacements, wide: wideReplacements)

proc ansiWideProc(identReplacements: openarray[AnsiWideReplacement],
  ansiImportC, wideImportC: NimNode, ast: NimNode): NimNode =
  let replacements = unpackAnsiWideReplacements(identReplacements)
  result = newStmtList(
    modifyAstRecursive(replacements.ansi, ast, ansiImportC),
    modifyAstRecursive(replacements.wide, ast, wideImportC)
  )
  when defined(debugAnsiWide):
    echo result.repr

macro ansiWide*(tIdent, ansiIdent, wideIdent: untyped,
  innerTIdent: untyped, innerAnsiIdent, innerWideIdent: typed,
  ast: untyped): typed =
  #[
    ansiWide(tIdent = StringContainer, ansiIdent = StringContainerA, wideIdent = StringContainerW,
      innerTIdent = LPTStr, innerAnsiIdent = cstring, innerWideIdent = WideCString):
      type StringContainer = object
        f1: LPTStr
    #[
      Generates:
      type StringContainerA = object
        f1: cstring
      type StringContainerW = object
        f1: WideCString
    ]#
  ]#
  ansiWideProc([
      (tIdent.getIdentOrSymString, ansiIdent.getIdentOrSymString, wideIdent.getIdentOrSymString),
      (innerTIdent.getIdentOrSymString, innerAnsiIdent.getIdentOrSymString, innerWideIdent.getIdentOrSymString)
    ], nil, nil, ast)

macro ansiWideImportC*(tIdent, ansiIdent, wideIdent: untyped,
  innerTIdent: untyped, innerAnsiIdent, innerWideIdent: typed,
  ansiImportC, wideImportC: typed, ast: untyped): typed =
  ansiWideProc([
      (tIdent.getIdentOrSymString, ansiIdent.getIdentOrSymString, wideIdent.getIdentOrSymString),
      (innerTIdent.getIdentOrSymString, innerAnsiIdent.getIdentOrSymString, innerWideIdent.getIdentOrSymString)
    ], ansiImportC, wideImportC, ast)

macro ansiWideMulti*(identReplacements: static[openarray[AnsiWideReplacement]], ast: untyped): typed =
  ansiWideProc(identReplacements, nil, nil, ast)

macro ansiWideMultiImportC*(identReplacements: static[openarray[AnsiWideReplacement]],
  ansiImportC, wideImportC: typed, ast: untyped): typed =
  ansiWideProc(identReplacements, ansiImportC, wideImportC, ast)

proc ansiWideWhenProc(identReplacements: openarray[AnsiWideReplacement],
  ansiImportC, wideImportC: NimNode, ast: NimNode): NimNode =
  let replacements = unpackAnsiWideReplacements(identReplacements)
  var whenStmt = newNimNode(nnkWhenStmt)
  var ansiBranch = newNimNode(nnkElifBranch)
  var ansiCond = newCall(!"defined", newIdentNode("useWinAnsi"))
  var ansiBody = modifyAstRecursive(replacements.ansi, ast, ansiImportC)
  ansiBranch.add(ansiCond, ansiBody)
  var wideBranch = newNimNode(nnkElse)
  var wideBody = modifyAstRecursive(replacements.wide, ast, wideImportC)
  wideBranch.add(wideBody)
  whenStmt.add(ansiBranch, wideBranch)
  result = newStmtList(whenStmt)
  when defined(debugAnsiWide):
    echo result.repr

macro ansiWideWhen*(tIdent: untyped, ansiIdent, wideIdent: typed, ast: untyped): typed =
  ansiWideWhenProc([
      (tIdent.getIdentOrSymString, ansiIdent.getIdentOrSymString, wideIdent.getIdentOrSymString)
    ], nil, nil, ast)

macro ansiWideWhenImportC*(tIdent: untyped, ansiIdent, wideIdent: typed,
  ansiImportC, wideImportC: typed, ast: untyped): typed =
  ansiWideWhenProc([
      (tIdent.getIdentOrSymString, ansiIdent.getIdentOrSymString, wideIdent.getIdentOrSymString)
    ], ansiImportC, wideImportC, ast)

macro ansiWideWhenMulti*(identReplacements: static[openarray[AnsiWideReplacement]], ast: untyped): typed =
  ansiWideWhenProc(identReplacements, nil, nil, ast)

macro ansiWideWhenMultiImportC*(identReplacements: static[openarray[AnsiWideReplacement]],
ansiImportC, wideImportC: typed, ast: untyped): typed =
  ansiWideWhenProc(identReplacements, ansiImportC, wideImportC, ast)

proc ansiWideAllProc*(replacements: openarray[AnsiWideReplacement],
  ansiImportC, wideImportC: NimNode, ast: NimNode): NimNode =
  newStmtList(
    ansiWideProc(replacements, ansiImportC, wideImportC, ast),
    ansiWideWhenProc([], ansiImportC, wideImportC, ast)
    )

macro ansiWideAll*(tIdent, ansiIdent, wideIdent: untyped,
  innerTIdent: untyped, innerAnsiIdent, innerWideIdent: typed,
  ast: untyped): typed =
  #[
    ansiWideAll(tIdent = StringContainer, ansiIdent = StringContainerA, wideIdent = StringContainerW,
      innerTIdent = LPTStr, innerAnsiIdent = cstring, innerWideIdent = WideCString):
      type StringContainer = object
        f1: LPTStr
    #[
      Generates:
      type StringContainerA = object
        f1: LPStr
      type StringContainerW = object
        f1: LPWStr
      when defined(useWinAnsi):
        type StringContainer = object
          f1: LPStr
      else:
        type StringContainer = object
          f1: LPWStr
    ]#
  ]#
  ansiWideAllProc([
    (tIdent.getIdentOrSymString, ansiIdent.getIdentOrSymString, wideIdent.getIdentOrSymString),
    (innerTIdent.getIdentOrSymString, innerAnsiIdent.getIdentOrSymString, innerWideIdent.getIdentOrSymString)
    ], nil, nil, ast)

macro ansiWideAllImportC*(tIdent, ansiIdent, wideIdent: untyped,
  innerTIdent: untyped, innerAnsiIdent, innerWideIdent: typed,
  ansiImportC, wideImportC: typed, ast: untyped): typed =
  #[
    ansiWideAll(tIdent = foobar, ansiIdent = foobarA, wideIdent = foobarW,
      innerTIdent = LPTStr, innerAnsiIdent = cstring, innerWideIdent = WideCString,
      ansiImportC = "FoobarA", wideImportC = "FoobarW"):
      proc foobar(str: LPTStr) {.importc.}
    #[
      Generates:
      proc foobarA(str: LPStr) {.importc: "FoobarA".}
      proc foobarW(str: LPWStr) {.importc: "FoobarW".}
      when defined(useWinAnsi):
        proc foobar(str: LPStr) {.importc: "FoobarA".}
      else:
        proc foobar(str: LPWStr) {.importc: "FoobarW".}
    ]#
  ]#
  ansiWideAllProc([
    (tIdent.getIdentOrSymString, ansiIdent.getIdentOrSymString, wideIdent.getIdentOrSymString),
    (innerTIdent.getIdentOrSymString, innerAnsiIdent.getIdentOrSymString, innerWideIdent.getIdentOrSymString)
    ], ansiImportC, wideImportC, ast)

macro ansiWideAllMulti*(tIdent, ansiIdent, wideIdent: untyped,
  innerReplacements: static[openarray[AnsiWideReplacement]], ast: untyped): typed =
  var replacements = newSeq[AnsiWideReplacement](innerReplacements.len + 1)
  replacements[0] = (tIdent.getIdentOrSymString, ansiIdent.getIdentOrSymString, wideIdent.getIdentOrSymString)
  replacements[1..^1] = innerReplacements
  ansiWideAllProc(replacements, nil, nil, ast)

macro ansiWideAllMultiImportC*(tIdent, ansiIdent, wideIdent: untyped,
  innerReplacements: static[openarray[AnsiWideReplacement]],
  ansiImportC, wideImportC: typed, ast: untyped): typed =
  var replacements = newSeq[AnsiWideReplacement](innerReplacements.len + 1)
  replacements[0] = (tIdent.getIdentOrSymString, ansiIdent.getIdentOrSymString, wideIdent.getIdentOrSymString)
  replacements[1..^1] = innerReplacements
  ansiWideAllProc(replacements, ansiImportC, wideImportC, ast)

#[
ansiWideAll(tIdent = StringContainer, ansiIdent = StringContainerA, wideIdent = StringContainerW,
  innerTIdent = LpTStr, innerAnsiIdent = cstring, innerWideIdent = WideCString):
  type StringContainer = object
    f1: LpTStr
  ------------------------------------
  Generates:
  type StringContainerA = object
    f1: cstring
  type StringContainerW = object
    f1: WideCString
]#

#[
ansiWideAllImportC(tIdent = foobar, ansiIdent = foobarA, wideIdent = foobarW,
  innerTIdent = LPTStr, innerAnsiIdent = cstring, innerWideIdent = WideCString,
  ansiImportC = "FoobarA", wideImportC = "FoobarW"):
  proc foobar(str: LPTStr) {.importc.}
  ------------------------------------
  Generates:
  proc foobarA(str: LPStr) {.importc: "FoobarA".}
  proc foobarW(str: LPWStr) {.importc: "FoobarW".}
]#
