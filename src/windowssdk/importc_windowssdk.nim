import macros

macro whenUseWindowsSdk*(ast: untyped): typed =
  ast.expectKind({nnkStmtList})
  result = ast.copyNimTree()
  let
    useWindowsSdkCond = newCall(ident("defined"), ident("useWinSdk"))
  var lastPragma = newEmptyNode()
  for i in 0 ..< result.len:
    var child = result[i]
    case child.kind
    of nnkPragma:
      lastPragma = child
      result[i] = newEmptyNode()
    of nnkProcDef:
      var windowsSdkProcDef = child.copyNimTree()
      if lastPragma.len > 0:
        for pragmaChild in lastPragma:
          windowsSdkProcDef.addPragma(pragmaChild)
      windowsSdkProcDef.body = newEmptyNode()
      var whenStmt = newNimNode(nnkWhenStmt)
      var whenTrueBranch = newNimNode(nnkElifBranch)
      whenTrueBranch.add(useWindowsSdkCond)
      whenTrueBranch.add(newStmtList(windowsSdkProcDef))
      var whenElseBranch = newNimNode(nnkElse)
      whenElseBranch.add(newStmtList(child))
      whenStmt.add(whenTrueBranch)
      whenStmt.add(whenElseBranch)
      result[i] = whenStmt
    of nnkVarSection, nnkLetSection, nnkConstSection:
      var windowsSdkVarSection = newNimNode(nnkVarSection)
      child.copyChildrenTo(windowsSdkVarSection)
      for j in 0 ..< windowsSdkVarSection.len:
        var varChild = windowsSdkVarSection[j]
        case varChild.kind
        of nnkIdentDefs, nnkConstDef:
          if varChild.kind == nnkConstDef:
            var newVarChild = newNimNode(nnkIdentDefs)
            varChild.copyChildrenTo(newVarChild)
            windowsSdkVarSection[j] = newVarChild
            varChild = newVarChild
          varChild.expectLen(3)
          var identDefPragma = newEmptyNode()
          case varChild[0].kind
          of nnkPragmaExpr:
            for k in 0 ..< varChild[0].len:
              if varChild[0][k].kind == nnkPragma:
                identDefPragma = varChild[0][k]
                break
          else:
            var varPragmaExpr = newNimNode(nnkPragmaExpr)
            varPragmaExpr.add(varChild[0])
            identDefPragma = newNimNode(nnkPragma)
            varPragmaExpr.add(identDefPragma)
            varChild[0] = varPragmaExpr
          for k in 0 ..< lastPragma.len:
            var pragmaChild = lastPragma[k]
            if identDefPragma.kind == nnkPragma:
              identDefPragma.add(pragmaChild)
          varChild[2] = newEmptyNode()
        else: discard
      var whenStmt = newNimNode(nnkWhenStmt)
      var whenTrueBranch = newNimNode(nnkElifBranch)
      whenTrueBranch.add(useWindowsSdkCond)
      whenTrueBranch.add(windowsSdkVarSection)
      var whenElseBranch = newNimNode(nnkElse)
      whenElseBranch.add(newStmtList(child))
      whenStmt.add(whenTrueBranch)
      whenStmt.add(whenElseBranch)
      result[i] = whenStmt
    else: discard
