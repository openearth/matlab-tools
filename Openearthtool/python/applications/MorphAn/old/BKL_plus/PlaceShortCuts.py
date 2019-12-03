#region imports
from Libraries.Utils.Project import *
from Libraries.Utils.Shortcuts import *

from BKL_plus.Dialog.BklPlusDialog import *
from BKL_plus.Dialog.RunBklDialog import *

from BKL_plus.Functions.AddNewBklToOverview import *
from BKL_plus.Functions.PlotNewBklInTklPlot import *
from BKL_plus.Functions.PlotMklDevelopment import *
#endregion

#region Remove old shortcuts with the same name
RemoveShortcut("MKL langs de kust","BKL herziening")
RemoveShortcut("MKL ontwikkeling","BKL herziening")
RemoveShortcut("Kaart","BKL herziening")
#endregion

baseDir = GetToolboxDir() + "\\BKL_plus\\Functions\\"

#region Add new shortcuts
AddShortcut("MKL langs de kust","BKL herziening",lambda f1=CreateMklAlongshorePlot:RunDialog(f1),baseDir + "graph-lines.png")
AddShortcut("MKL ontwikkeling","BKL herziening",lambda f1=OpenAndInitializeTklPlot:RunDialog(f1),baseDir + "graph-scatter.png")
AddShortcut("Kaart","BKL herziening",lambda f1=CreateBklMap:RunDialog(f1),baseDir + "map.png")
#endregion

