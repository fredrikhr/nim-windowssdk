import macros

type
  ImportCTuple = tuple[ansi, wide: string]
  ReplaceRule = tuple[src, target: string]
  AnsiWideReplaceRule = tuple[src, ansi, wide: string]

proc unpackReplaceRules(replacements: varargs[AnsiWideReplaceRule]
  ): tuple[ansi, wide: seq[ReplaceRule]] =
  var ansiReplace: seq[ReplaceRule] = @[]
  var wideReplace: seq[ReplaceRule] = @[]
  for replace in replacements:
    ansiReplace.add((src: replace.src, target: replace.ansi))
    wideReplace.add((src: replace.src, target: replace.wide))
  result = (ansi: ansiReplace, wide: wideReplace)

proc pragmaImportcReplace(pragma, importc: NimNode): NimNode =
  var foundImportc = false
  var newPragma = copyNimNode(pragma)
  for pragmaChild in pragma.children:
    var addPragmaChild = true
    case pragmaChild.kind
    of nnkIdent:
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

proc recursiveIdentReplace(replacements: openArray[ReplaceRule], decl: NimNode,
  importcValue: NimNode): NimNode =
  if decl.isNil(): return
  result = copyNimNode(decl)
  if decl.kind == nnkIdent:
    for replace in replacements:
      if decl.eqIdent(replace.src):
        result = newIdentNode(replace.target)
        break
  if decl.len > 0:
    for declChild in decl.children:
      result.add(recursiveIdentReplace(replacements, declChild, importcValue))
  if not(importcValue.isNil) and result.kind == nnkPragma and result.len > 0:
    result = pragmaImportcReplace(result, importcValue)

proc expectKindMultiple(kind: set[NimNodeKind], nodes: varargs[NimNode]): void =
  for n in nodes:
    expectKind(n, kind)

proc identSymNodeToStr(n: NimNode): string =
  if n.isNil(): return nil
  case n.kind
  of nnkIdent:
    result = $n.ident
  of nnkSym:
    result = $n.symbol
  else:
    expectKind(n, {nnkIdent, nnkSym})

proc nimNodesToReplaceRule(src, target: NimNode): ReplaceRule =
  (src: src.identSymNodeToStr, target: target.identSymNodeToStr)

proc ansiWideCommonMacroProc(ansiReplace, wideReplace: openArray[ReplaceRule],
  importcAnsi, importcWide: NimNode,
  decl: NimNode): NimNode =
  result = newStmtList()
  result.add(recursiveIdentReplace(ansiReplace, decl, importcAnsi))
  result.add(recursiveIdentReplace(wideReplace, decl, importcWide))

macro ansiWideMulti*(replacements: static[openArray[AnsiWideReplaceRule]],
  importc: static[ImportCTuple], decl: untyped): typed =
  let (ansiReplace, wideReplace) = unpackReplaceRules(replacements)
  var importcAnsi, importcWide: NimNode
  if not(importc.ansi.isNil()):
    importcAnsi = newStrLitNode(importc.ansi)
  if not(importc.wide.isNil()):
    importcWide = newStrLitNode(importc.wide)
  ansiWideCommonMacroProc(ansiReplace, wideReplace,
  importcAnsi, importcWide, decl)

proc ansiWideMacroProc(outerSrc, outerAnsi, outerWide: NimNode,
  innerSrc, innerAnsi, innerWide: NimNode,
  importcAnsi: NimNode, importcWide: NimNode,
  decl: NimNode): NimNode =
  expectKindMultiple({nnkSym, nnkIdent}, outerSrc, outerAnsi, outerWide, innerSrc, innerAnsi, innerWide)
  let
    ansiReplace = [nimNodesToReplaceRule(outerSrc, outerAnsi), nimNodesToReplaceRule(innerSrc, innerAnsi)]
    wideReplace = [nimNodesToReplaceRule(outerSrc, outerWide), nimNodesToReplaceRule(innerSrc, innerWide)]
  ansiWideCommonMacroProc(ansiReplace, wideReplace, importcAnsi, importcWide, decl)

macro ansiWideImportC*(outerSrc, outerAnsi, outerWide, innerSrc: untyped, innerAnsi, innerWide: typed,
  importcAnsi, importcWide: typed,
  decl: untyped): typed =
  ansiWideMacroProc(outerSrc, outerAnsi, outerWide, 
    innerSrc, innerAnsi, innerWide,
    importcAnsi, importcWide, decl)

macro ansiWide*(outerSrc, outerAnsi, outerWide, innerSrc: untyped, innerAnsi, innerWide: typed,
  decl: untyped): typed =
  ansiWideMacroProc(outerSrc, outerAnsi, outerWide, 
    innerSrc, innerAnsi, innerWide,
    nil, nil, decl)

proc ansiWideWhenCommonMacroProc(ansiReplace, wideReplace: openArray[ReplaceRule],
  importcAnsi, importcWide, decl: NimNode): NimNode =
  result = newStmtList()
  var resultWhen = newNimNode(nnkWhenStmt)
  var whenAnsiBranch = newNimNode(nnkElifBranch)
  var whenAnsiCond = newCall(newIdentNode(!"defined"), newIdentNode(!"useWinAnsi"))
  var whenAnsiBody = recursiveIdentReplace(ansiReplace, decl, importcAnsi)
  whenAnsiBranch.add(whenAnsiCond, whenAnsiBody)
  var whenWideBranch = newNimNode(nnkElse)
  whenWideBranch.add(recursiveIdentReplace(wideReplace, decl, importcWide))
  resultWhen.add(whenAnsiBranch, whenWideBranch)
  result.add(resultWhen)

proc ansiWideWhenMacroProc(src, ansi, wide, importcAnsi, importcWide, decl: NimNode): NimNode =
  expectKindMultiple({nnkSym, nnkIdent}, src, ansi, wide)
  let
    ansiReplace = [nimNodesToReplaceRule(src, ansi)]
    wideReplace = [nimNodesToReplaceRule(src, wide)]
  ansiWideWhenCommonMacroProc(ansiReplace, wideReplace, importcAnsi, importcWide, decl)

macro ansiWideWhenImportC*(src: untyped, ansi, wide: typed,
  importcAnsi, importcWide: typed, decl: untyped): typed =
  ansiWideWhenMacroProc(src, ansi, wide, importcAnsi, importcWide, decl)

macro ansiWideWhen*(src: untyped, ansi, wide: typed, decl: untyped): typed =
  ansiWideWhenMacroProc(src, ansi, wide, nil, nil, decl)

macro ansiWideWhenMulti*(replacements: static[openArray[AnsiWideReplaceRule]],
  importc: static[ImportCTuple], decl: untyped): typed =
  let (ansiReplace, wideReplace) = unpackReplaceRules(replacements)
  var importcAnsi, importcWide: NimNode
  if not(importc.ansi.isNil()):
    importcAnsi = newStrLitNode(importc.ansi)
  if not(importc.wide.isNil()):
    importcWide = newStrLitNode(importc.wide)
  ansiWideWhenCommonMacroProc(ansiReplace, wideReplace,
    importcAnsi, importcWide, decl)

proc ansiWideAllCommonMacroProc(outerAnsiReplace, outerWideReplace,
  innerAnsiReplace, innerWideReplace: openArray[ReplaceRule],
  importcAnsi, importcWide, decl: NimNode): NimNode =
  var
    ansiReplace: seq[ReplaceRule] = @[]
    wideReplace: seq[ReplaceRule] = @[]
  ansiReplace.add(outerAnsiReplace)
  wideReplace.add(outerWideReplace)
  ansiReplace.add(innerAnsiReplace)
  wideReplace.add(innerWideReplace)
  let
    ansiWideStmt = ansiWideCommonMacroProc(ansiReplace, wideReplace,
      importcAnsi, importcWide, decl)
    ansiWideWhen = ansiWideWhenCommonMacroProc(innerAnsiReplace, innerWideReplace,
      importcAnsi, importcWide, decl)
  result = newStmtList(ansiWideStmt, ansiWideWhen)

macro ansiWideAllMulti*(outerReplacement: static[AnsiWideReplaceRule],
  innerReplacements: static[openArray[AnsiWideReplaceRule]],
  importc: static[ImportCTuple], decl: untyped): typed =
  let 
    (outerAnsiReplace, outerWideReplace) = unpackReplaceRules(outerReplacement)
    (innerAnsiReplace, innerWideReplace) = unpackReplaceRules(innerReplacements)
  var importcAnsi, importcWide: NimNode
  if not(importc.ansi.isNil()):
    importcAnsi = newStrLitNode(importc.ansi)
  if not(importc.wide.isNil()):
    importcWide = newStrLitNode(importc.wide)
  ansiWideAllCommonMacroProc(outerAnsiReplace, outerWideReplace,
    innerAnsiReplace, innerWideReplace,
    importcAnsi, importcWide, decl)

proc ansiWideAllMacroProc(outerSrc, outerAnsi, outerWide: NimNode,
  innerSrc, innerAnsi, innerWide: NimNode,
  importcAnsi, importcWide, decl: NimNode): NimNode =
  let
    outerAnsiReplace = [nimNodesToReplaceRule(outerSrc, outerAnsi)]
    outerWideReplace = [nimNodesToReplaceRule(outerSrc, outerWide)]
    innerAnsiReplace = [nimNodesToReplaceRule(innerSrc, innerAnsi)]
    innerWideReplace = [nimNodesToReplaceRule(innerSrc, innerWide)]
  result = ansiWideAllCommonMacroProc(outerAnsiReplace, outerWideReplace,
    innerAnsiReplace, innerWideReplace, importcAnsi, importcWide, decl)

macro ansiWideAllImportC*(outerSrc, outerAnsi, outerWide, innerSrc: untyped, innerAnsi, innerWide: typed,
  importcAnsi, importcWide: typed,
  decl: untyped): typed =
  ansiWideAllMacroProc(outerSrc, outerAnsi, outerWide,
    innerSrc, innerAnsi, innerWide,
    importcAnsi, importcWide, decl)

macro ansiWideAll*(outerSrc, outerAnsi, outerWide, innerSrc: untyped, innerAnsi, innerWide: typed,
  decl: untyped): typed =
  ansiWideAllMacroProc(outerSrc, outerAnsi, outerWide,
    innerSrc, innerAnsi, innerWide, nil, nil, decl)

#[
ansiWideAllImportC(foobar, foobarA, foobarW, LpTStr, cstring, WideCString,
  "foobarA", "foobarW", "foobar"):
  proc foobar*(str: LpTStr): int32 {.stdcall, dynlib: "Foobar.dll", importC.}

ansiwide.nim(212, 19) template/generic instantiation from here
ansiwide.nim(41, 6) Error: type mismatch: got (NimNode) but expected 'cstring = CString'
]#
