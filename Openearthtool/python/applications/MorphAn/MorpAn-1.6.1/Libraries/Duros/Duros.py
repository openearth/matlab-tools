#region import
from Libraries.Utils.Charting import *
from DeltaShell.Plugins.MorphAn.TRDA.Calculators import *
from DeltaShell.Plugins.MorphAn.Domain import *
from DeltaShell.Plugins.MorphAn.TRDA import *
from DeltaShell.Plugins.MorphAn.Gui.Forms.DuneSafetyModelViews import ChartingHelper
#endregion

#region Duros

def Duros(x,z,waterLevel=5.0,Hs=9,Tp=16,D50=0.000250):
	"""
	Calculates an erosion profile according to the DUROS+ model
	@param x: Array of X coordinats describing the initial profile
	@param z: Array of Z coordinats describing the initial profile
	@param waterLevel: The maximum storm surge level that is taken into account (optional, default = 5.0)
	@param Hs: The significant wave height during the peak of the storm that is used to calculate the erosion profile (optional, default = 9)
	@param Tp: The wave peak period during the peak of the storm that is used to calculate the erosion profile (optional, default = 16)
	@param D50: The median grain size (in meters) used to calculate an erosion profile (optional, default = 0.000250)
	"""
	
	#region specify input
	
	input = TRDAInputParameters()
	input.MaximumStormSurgeLevel = waterLevel
	input.SignificantWaveHeight = Hs
	input.PeakPeriod = Tp
	input.D50 = D50
	input.InputProfile = Transect(x,z)
	
	#endregion
	
	return CoastalSafetyAssessment.AssessDuneProfile(input)
	
#endregion

#region PlotDuros

def PlotDuros(result,name="Duros result", plot = True):
	"""
	Opens a figure that shows the Duros result in the interface and returns the chart
	@param result: The CoastalSafetyAssessmentResult of a DUROS+ calculation as returned by the Duros function
	@param name: The name of the figure. If not specified, the title of the figure will be "Duros result" (optional, default = "Duros result")
	@param plot: Whether the created chart should be shown in the GUI (if false, the function will only return the created chart as an object) (optional, default = True)
	"""
	
	#region Create chartview
	
	chartView = CreateChartView()
	allSeries = ChartingHelper.InitializeErosionResultSeries(chartView)
	ChartingHelper.PopulateChartWithErosionResult(chartView , allSeries, result)
	chartView.Chart.Name = name
	chartView.Chart.Title = name
	
	#endregion
	
	#region open view in GUI
	
	if (plot):
		ShowChart(chartView.Chart)
		
	#endregion
	
	return chartView.Chart

#endregion

#region PlotBoundaryProfile

def PlotBoundaryProfile(bp,name="Duros result", show = True, gapSize = 5000, chartView = None) :
	if (chartView == None):
		chartView = CreateChartView()
	
	allSeries = ChartingHelper.InitializeBoundaryProfileSeries(chartView)
	ChartingHelper.PopulateBoundaryProfileSeries(chartView , allSeries, bp)
	chartView.Chart.Name = name
	chartView.Chart.Title = name
	if (show):
		ShowChart(Gui, chartView.Chart)
	
	return chartView.Chart

#endregion