import hashes

const EPS = 1.0e-8;

proc nearZero*(value: float): bool {.inline.} = abs(value) < EPS

when defined(js):
  var idCounter = 0
  proc hash*(o: ref object): Hash =
    var id = 0
    var cnt = idCounter
    {.emit: """
    if (`o`.__kiwi_objid === undefined) {
      `o`.__kiwi_objid = ++`cnt`;
    }
    `id` = `o`.__kiwi_objid;
    """.}
    idCounter = cnt
    hash(id)
else:
  proc hash*(o: ref object): Hash {.inline.} = hash(cast[int](o))
