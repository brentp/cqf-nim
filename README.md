this is incomplete, but the usage is show below

```Nim
import times
import tables
var t = cpuTime()

var cqf:CQF
doAssert cqf.init(bits=30)
#var cqf = initCountTable[uint64](32768)

var n = 0
for i in 0'u64..100_000_000:
cqf.inc(i)
n.inc
for i in countup(0'u64, 100_000_000, 10000):
cqf.inc(i)

for i in countup(0'u64, 10_000_000, 1000):
echo "i:", i, " -> ", cqf[i]

echo n
```
