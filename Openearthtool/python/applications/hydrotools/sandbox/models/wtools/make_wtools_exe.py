from distutils.core import setup
from bbfreeze import Freezer
from subprocess import call
import ctypes

nrbits = str(ctypes.sizeof(ctypes.c_voidp) * 8)



f = Freezer("wtools")
f.addScript("scripts\CatchRiver.py")
f.addScript("scripts\CheckInput.py")
f.addScript("scripts\CreateGrid.py")
f.addScript("scripts\StaticMaps.py")
f()    # starts the freezing process

