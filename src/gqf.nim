import ./gqf_wrapper

type CQF* = object
  c: QF

proc init*(c:var CQF, bits:uint64=24, hash_mode:qf_hashmode=qf_hashmode.QF_HASH_DEFAULT, value_bits:uint64=0, seed:uint32=42): bool =
  result = qf_malloc(c.c.addr, 1'u64 shl bits, bits + 9, value_bits,
               qf_hashmode.QF_HASH_DEFAULT, seed)
  if result: qf_set_auto_resize(c.c.addr, true)

proc free*(c:var CQF) =
  discard qf_free(c.c.addr)

proc inc*(c:var CQF, key:uint64, count:uint64=1, value:uint64=0, flags:uint8=0) {.inline.} =
  ## increment the key (, value) by count. returns
  let r = qf_insert(c.c.addr, key, value, count, flags)
  if r == 0: return
  if r == QF_NO_SPACE:
    raise newException(KeyError, "no space left in CQF")
  if r == QF_COULDNT_LOCK:
    raise newException(KeyError, "couldn't get lock for CQF")

proc get*(c:var CQF, key:uint64, value:var uint64=0, flags:uint8=0): uint64 {.inline.} =
  qf_query(c.c.addr, key, value.addr, flags)

proc `[]`*(c:var CQF, key:uint64): uint64 {.inline.} =
  var val:uint64
  qf_query(c.c.addr, key, val.addr, 0)


when isMainModule:

  import times
  import tables
  var t = cpuTime()

  #var cqf:CQF
  #doAssert cqf.init(bits=30)
  var cqf = initCountTable[uint64](32768)

  var n = 0
  for i in 0'u64..100_000_000:
    cqf.inc(i)
    n.inc
  for i in countup(0'u64, 100_000_000, 10000):
    cqf.inc(i)

  for i in countup(0'u64, 10_000_000, 1000):
    echo "i:", i, " -> ", cqf[i]

  echo n

  echo cpuTime() - t
