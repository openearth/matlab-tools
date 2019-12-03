from Libraries.Utils.Shortcuts import *
from Examples.ShortcutsExample.Functions.VergelijkDuros import VergelijkDuros
from Examples.ShortcutsExample.Functions.PostMessage import PostMessage
from Examples.ShortcutsExample.Functions.AddXBeachModel import AddXBeachModel

basePath = r"c:\src\openearthtools\python\applications\MorphAn\Examples\ShortcutsExample"

# Remove old shortcuts (if they exist)
RemoveShortcut("Hello world!","General")
RemoveShortcut("Vergelijk DUROS+","DUROS+")
RemoveShortcut("Add XBeach model","XBeach")

# Create new shortcuts
AddShortcut("Hello world!","General",PostMessage,basePath + r"\Letter-T-pink-icon.png")
AddShortcut("Vergelijk DUROS+","DUROS+",VergelijkDuros,basePath + r"\Letter-D-pink-icon.png")
AddShortcut("Add XBeach model","XBeach",AddXBeachModel,basePath + r"\Letter-X-pink-icon.png")