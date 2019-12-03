import os

# Libs
from plot_lineplot import *
from plot_heatmap import *
from smoothingFunctions import *
from PoleFile import *

## INPUTS
poleHeightFile = 'D:\sala\Documents\Fiber_Optics\data\layout_length_depth_poles\pole3.csv'
poleName = os.path.basename(poleHeightFile).replace('.csv', '')
poleExpFiles = [
    'D:\sala\Documents\Fiber_Optics\data\pole3\ch2_pole3_exp1.csv',
    'D:\sala\Documents\Fiber_Optics\data\pole3\ch2_pole3_exp2.csv',
    'D:\sala\Documents\Fiber_Optics\data\pole3\ch2_pole3_exp3.csv'
]

## OUTPUTS
outputDir = 'D:\sala\Documents\Fiber_Optics\data\outputs'

## For every file
lp = line_Plot()
allplotH = []
legend = []
for poleExpFile in poleExpFiles:
    ## READ FILE + CUT
    pf = PoleFile(poleExpFile, poleHeightFile, cut_begin=0, cut_end=1.5) # bottom/top end of pole

    ## RAW PLOT / LINE / average temperature over time
    lp.generate_plot(pf.distance, pf.meantemp, 'Distance [m]', 'Temperature [C]', os.path.join(outputDir, os.path.basename(poleExpFile).replace('.csv', '_alldata_raw_meanT_vs_Dist.html')), xsize=1200)
    lp.generate_plot(pf.meantemp, pf.height, 'Temperature [C]', 'Height [m]', os.path.join(outputDir, os.path.basename(poleExpFile).replace('.csv', '_alldata_raw_meanT_vs_Height.html')), xsize=700)

    ## CUT + SMOOTH PLOT / LINE / average temperature over time
    meantempsmooth = savitzky_golay(pf.meantemp_cut, 11, 4)
    lp.generate_plot_multi([(pf.distance_cut, pf.meantemp_cut), (pf.distance_cut, meantempsmooth)], 'Distance [m]', 'Temperature [C]', [pf.date, pf.date+'_smooth'], os.path.join(outputDir, os.path.basename(poleExpFile).replace('.csv', '_cut_raw_meanT_vs_Dist.html')), xsize=1200)
    lp.generate_plot_multi([(pf.meantemp_cut, pf.height_cut), (meantempsmooth, pf.height_cut)], 'Temperature [C]', 'Height [m]', [pf.date, pf.date+'_smooth'], os.path.join(outputDir, os.path.basename(poleExpFile).replace('.csv', '_cut_raw_meanT_vs_Height.html')), xsize=700)

    ## HEATMAP
    hm = heatmap_Plot(pf)
    hm.heatmap('Heatmap '+ os.path.basename(poleExpFile).replace('.csv', '') + ' on ' + pf.date,
               os.path.join(outputDir, os.path.basename(poleExpFile).replace('.csv', '_cut_HEATMAP_Time_vs_Height.png')))

    ## ALL
    allplotH.append((pf.meantemp_cut, pf.height_cut))
    allplotH.append((meantempsmooth, pf.height_cut))
    legend.append(pf.date)
    legend.append(pf.date+'_smooth')

## 3 experiment plots
lp.generate_plot_multi(allplotH, 'Temperature [C]', 'Height [m]', legend, os.path.join(outputDir, poleName+'comparison_meanT_vs_Height.html'), xsize=700)

