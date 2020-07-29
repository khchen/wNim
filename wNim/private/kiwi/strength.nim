proc createStrength*(a: float; b: float, c: float, w: float = 1.0): float =
  result += max(0.0, min(1000.0, a * w)) * 1000000.0;
  result += max(0.0, min(1000.0, b * w)) * 1000.0;
  result += max(0.0, min(1000.0, c * w));

const REQUIRED* = createStrength(1000.0, 1000.0, 1000.0)
const STRONG* = createStrength(1.0, 0.0, 0.0)
const MEDIUM* = createStrength(0.0, 1.0, 0.0)
const WEAK* = createStrength(0.0, 0.0, 1.0)

proc clipStrength*(value: float): float {.inline.} = clamp(value, 0, REQUIRED)
