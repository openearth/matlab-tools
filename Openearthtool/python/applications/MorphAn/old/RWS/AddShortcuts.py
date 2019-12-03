from Libraries.Utils.Shortcuts import *
from Libraries.Utils.Project import *
from RWS.CombineModelResultsDialog import *
from RWS.TrendComparisonDialog import *
from RWS.BklTklView import *

pt = GetToolboxDir()

# Remove old shortcuts (if they exist)
RemoveShortcut("Vergelijk modeluitkomsten","B&O Kust")
RemoveShortcut("Vergelijk trends","B&O Kust")
RemoveShortcut("TKL - BKL","B&O Kust")

# Create new shortcuts
AddShortcut("Vergelijk modeluitkomsten","B&O Kust",ShowCombinedFigureDialog,pt + r"\RWS\QL.jpg")
AddShortcut("Vergelijk trends","B&O Kust",ShowTrendComparisonDialog,pt + r"\RWS\Gemma.jpg")
AddShortcut("TKL - BKL","B&O Kust",ShowBklTklView,pt + r"\RWS\Rena.png")