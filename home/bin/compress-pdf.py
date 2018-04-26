#!/usr/bin/env python
import sys
import subprocess
import os.path

filename_pdf  = sys.argv[1]
filename_ps = "%s.ps" % (os.path.splitext(filename_pdf)[0])
subprocess.check_call(["pdf2ps", filename_pdf])
subprocess.check_call(["trash", filename_pdf])
subprocess.check_call(["ps2pdf", filename_ps])
subprocess.check_call(["trash", filename_ps])
