# -*- coding: utf-8 -*-
'''
Auto start logging.

From https://github.com/ipython/ipython/wiki/Cookbook:-Dated-logging

TODO: It might be possible to make this a proper IPython extension.
'''
from time import strftime
import os.path

ip = get_ipython() # NOQA: From IPython context.

ldir = ip.profile_dir.log_dir
fname = 'log-' + ip.profile + '-' + strftime('%Y-%m-%d') + ".py"
filename = os.path.join(ldir, fname)
notnew = os.path.exists(filename)

try:
    ip.magic('logstart -o %s append' % filename)
    if notnew:
        ip.logger.log_write(u"# =================================\n")
    else:
        ip.logger.log_write(u"#!/usr/bin/env python\n")
        ip.logger.log_write(u"# " + fname + "\n")
        ip.logger.log_write(u"# IPython automatic logging file\n")
    ip.logger.log_write(u"# " + strftime('%H:%M:%S') + "\n")
    ip.logger.log_write(u"# =================================\n")
    print(" Logging to "+filename)
except RuntimeError:
    print(" Already logging to "+ip.logger.logfname)
