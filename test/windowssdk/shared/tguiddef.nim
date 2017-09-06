import .. / .. / .. / src / windowssdk / shared / guiddef

import strutils

static:
  let g {.used.} = newGuid("B41463C3-8866-43B5-BC33-2B0676F7F42E")
  doAssert(g.data1 == 0xB41463C3'u32, "Actual: " & toHex(g.data1))
  doAssert(g.data2 == 0x8866'u16, "Actual: " & toHex(g.data2))
  doAssert(g.data3 == 0x43B5'u16, "Actual: " & toHex(g.data3))
  doAssert(g.data4[0] == 0xBC'u8, "Actual: " & toHex(g.data4[0]))
  doAssert(g.data4[1] == 0x33'u8, "Actual: " & toHex(g.data4[1]))
  doAssert(g.data4[2] == 0x2B'u8, "Actual: " & toHex(g.data4[2]))
  doAssert(g.data4[3] == 0x06'u8, "Actual: " & toHex(g.data4[3]))
  doAssert(g.data4[4] == 0x76'u8, "Actual: " & toHex(g.data4[4]))
  doAssert(g.data4[5] == 0xF7'u8, "Actual: " & toHex(g.data4[5]))
  doAssert(g.data4[6] == 0xF4'u8, "Actual: " & toHex(g.data4[6]))
  doAssert(g.data4[7] == 0x2E'u8, "Actual: " & toHex(g.data4[7]))
