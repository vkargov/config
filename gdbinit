set history save on
set max-completions 5000

python
import sys, os
sys.path.insert(0, os.path.expanduser("~/derp/chromium/src/tools/gdb/"))
import gdb_chrome