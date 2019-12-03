import time
import threading
import platform


from openearthtools.modelapi.bmi import BMIFortran

# Default osx libs
LIBFMNAME = '/Users/fedorbaart/Documents/checkouts/dflowfm_esmf/src/.libs/libdflowfm.dylib'
rundir = '/Users/fedorbaart/Documents/checkouts/cases_unstruc/e00_unstruc/f04_bottomfriction/c016_2DConveyance_bend/input'

# Windows dll link
if platform.system().lower() == 'windows':
    LIBFMNAME = r'd:\checkouts\dflowfm_esmf\bin\Debug\unstruc.dll'
    import ctypes
    import os
    ctypes.windll.LoadLibrary(os.path.join(os.path.dirname(LIBFMNAME), 'netcdf.dll'))
    rundir = r'd:\checkouts\cases_unstruc\e00_unstruc\f04_bottomfriction\c016_2DConveyance_bend\input'

# fm = BMIFortran(libname=LIBFMNAME, rundir=rundir)
# fm.initialize('bendprof.mdu')

def update(fm):
    dt = 0.1
    while True:
        fm.update(dt*5)
        time.sleep(dt)

# update fm in a background thread.

# I would like to do this in a gevent, but can't get it to work....
# gevent.spawn(update, fm)

# thread = threading.Thread(target=update, args=(fm,))
# thread.setDaemon(True)
# thread.start()


