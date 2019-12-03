from DelftTools.Utils import *
from Libraries.Utils.Project import PrintMessage

def SelectionChanged(o,e,s) : 
	PrintMessage("Hello world!",2)
	PrintMessage("You passed the message: %s" % (s),1)
	PrintMessage("Current selection = %s" % (Gui.Selection),0)
	
callback = lambda o, eventargs, s="str": SelectionChanged(o,eventargs,s)

Gui.SelectionChanged += callback
Gui.SelectionChanged -= callback