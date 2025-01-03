local ffi = require("ffi")
local jit = require("jit")

dofile("../common/ffi_util.inc")

do
  local fp = assert(io.open("/tmp/__tmp.c", "w"))
  fp:write[[
#define __float128 double

#ifndef __LCC__
#define _Float32 float
#define _Float32x float
#define _Float64 double
#define _Float64x double
#define _Float128 long double
#endif

#include <sqlite3.h>
#include <thread_db.h>
#include <resolv.h>
#include <mpfr.h>
#include <mpc.h>
#include <curses.h>
#include <form.h>
#include <aio.h>
#include <unistd.h>
#include <zlib.h>
#include <netdb.h>
#include <math.h>
#include <tgmath.h>
#include <complex.h>
#include <elf.h>
#include <mqueue.h>
#ifndef __LCC__
#include <regex.h>
#endif
#include <fcntl.h>
]]
  fp:close()

  local flags
  if jit.arch == "arm64" then
    flags = ""
  else
    flags = ffi.abi("32bit") and "-m32" or "-m64"
  end
  fp = assert(io.popen("cc -E -P -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_GNU_SOURCE /tmp/__tmp.c "..flags))
  local s = fp:read("*a")
  fp:close()
  os.remove("/tmp/__tmp.c")
  s = s:gsub("__uint128_t", "unsigned long long")
  ffi.cdef(s)
end

