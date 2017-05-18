import .. / .. / src / windowssdk / cdefine_to_string

type SpecialInt = distinct int
const
  a = 42.SpecialInt
  b = 32.SpecialInt
  c = 24.SpecialInt
  `d` = 23.SpecialInt

defineDistinctToStringProc(SpecialInt, int, a, b, c, `d`)

assert($a == "A", $a)
assert($b == "B", $b)
assert($c == "C", $c)
assert($`d` == "D", $`d`)
