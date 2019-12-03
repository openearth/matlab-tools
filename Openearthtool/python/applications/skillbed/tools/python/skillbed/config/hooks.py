###############################################################################
# import modules                                                              #
###############################################################################

import os, sys, imp

import config

hooks    = {}
hookpath = os.path.join(config.get_root(), 'tools', 'python', 'hooks')

if os.path.exists(hookpath):

    for fname in os.listdir(hookpath):

        module, ext = os.path.splitext(fname)

        if fname == '__init__.py' or ext != '.py':
            continue

        fd, modulepath, description = imp.find_module(module, [hookpath])

        try:
            hooks[module] = imp.load_module(module, fd, modulepath, description)
        finally:
            if fd:
                fd.close()

def call(fcn, *args, **kwargs):
    'Call hook function'

    for name, module in hooks.iteritems():
        if hasattr(module, fcn):
            return getattr(module, fcn)(*args, **kwargs)
    
    return False

def ishook(fcn):
    'Check if hook is available'

    for name, module in hooks.iteritems():
        if hasattr(module, fcn):
            return True

    return False
