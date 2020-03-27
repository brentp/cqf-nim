##
##  ============================================================================
##
##         Authors:  Prashant Pandey <ppandey@cs.stonybrook.edu>
##                   Rob Johnson <robj@vmware.com>
##
##  ============================================================================
##
{.passC:"-Icqf-src/include/ -Icqf-src/ -Icqf-src/src/".}
{.compile:"cqf-src/src/gqf.c".}
{.compile:"cqf-src/src/partitioned_counter.c".}
{.compile:"cqf-src/src/hashutil.c".}
{.passL:"-lpthread -lssl -lcrypto -lm".}

type QF* {.incompleteStruct.} = object
type QFi* {.incompleteStruct.} = object

type qf_hashmode* {.pure.} = enum
      QF_HASH_DEFAULT, QF_HASH_INVERTIBLE, QF_HASH_NONE

const
  QF_NO_SPACE* = (-1)
  QF_COULDNT_LOCK* = (-2)
  QF_DOESNT_EXIST* = (-3)
  QF_INVALID* = (-4)
  QFI_INVALID* = (-5)

const
  QF_NO_LOCK* = (0x00000001)
  QF_TRY_ONCE_LOCK* = (0x00000002)
  QF_WAIT_FOR_LOCK* = (0x00000004)
  QF_KEY_IS_HASH* = (0x00000008)

##  Initialize the CQF and allocate memory for the CQF.
proc qf_malloc*(qf: ptr QF; nslots: uint64; key_bits: uint64; value_bits: uint64;
               hash: qf_hashmode; seed: uint32): bool {.cdecl, importc.}
proc qf_free*(qf: ptr QF): bool {.cdecl, importc.}

proc qf_set_auto_resize*(qf: ptr QF; enabled: bool) {.cdecl, importc.}

proc qf_destroy*(qf: ptr QF): pointer {.cdecl, importc.}


##  Increment the counter for this key/value pair by count.
##  Return value:
##     >= 0: distance from the home slot to the slot in which the key is
##           inserted (or 0 if count == 0).
##     == QF_NO_SPACE: the CQF has reached capacity.
##     == QF_COULDNT_LOCK: TRY_ONCE_LOCK has failed to acquire the lock.
proc qf_insert*(qf: ptr QF; key: uint64; value: uint64; count: uint64; flags: uint8): cint {.
    cdecl, importc.}

##  Remove up to count instances of this key/value combination.
##  If the CQF contains <= count instances, then they will all be
##  removed, which is not an error.
##  Return value:
##     >=  0: number of slots freed.
##     == QF_DOESNT_EXIST: Specified item did not exist.
##     == QF_COULDNT_LOCK: TRY_ONCE_LOCK has failed to acquire the lock.
##
proc qf_remove*(qf: ptr QF; key: uint64; value: uint64; count: uint64; flags: uint8): cint {.
    cdecl, importc.}

##  Remove all instances of this key/value pair.
proc qf_delete_key_value*(qf: ptr QF; key: uint64; value: uint64; flags: uint8): cint {.
      cdecl, importc.}

##  Lookup the value associated with key.  Returns the count of that
##     key/value pair in the QF.  If it returns 0, then, the key is not
##     present in the QF. Only returns the first value associated with key
##     in the QF.  If you want to see others, use an iterator.
##     May return QF_COULDNT_LOCK if called with QF_TRY_LOCK.
proc qf_query*(qf: ptr QF; key: uint64; value: ptr uint64; flags: uint8): uint64 {.cdecl, importc.}

proc qf_get_total_size_in_bytes*(qf: ptr QF): uint64 {.cdecl, importc.}
proc qf_get_nslots*(qf: ptr QF): uint64 {.cdecl, importc.}
proc qf_get_num_occupied_slots*(qf: ptr QF): uint64 {.cdecl, importc.}

# TODO iterator stuff

when isMainModule:

  var qf:QF

  var bits = 30'u64
  echo qf_malloc(qf.addr, 1'u64 shl bits, bits + 9, 0,
               qf_hashmode.QF_HASH_DEFAULT, 0)
  qf_set_auto_resize(qf.addr, true)


  for k in countup(0, (1 shl bits), 1000):
    var ret = qf_insert(qf.addr, k.uint64, 0'u64, 1'u64, 0'u8)
    doAssert ret >= 0, $(ret, k)
    ret = qf_insert(qf.addr, k.uint64, 0'u64, 1'u64, 0'u8)
    doAssert ret >= 0, $(ret, k)
    ret = qf_insert(qf.addr, k.uint64, 0'u64, 1'u64, 0'u8)
    doAssert ret >= 0, $(ret, k)
    ret = qf_insert(qf.addr, k.uint64, 0'u64, 1'u64, 0'u8)
    doAssert ret >= 0, $(ret, k)

  var val:uint64
  for k in countup(0, (1 shl bits), 1000):
    echo k, "=>", qf_query(qf.addr, k.uint64, val.addr, QF_NO_LOCK.uint8)

  echo qf.addr.qf_get_total_size_in_bytes
