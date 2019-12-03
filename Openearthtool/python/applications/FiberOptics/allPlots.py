import os
import json

# Libs
from plot_lineplot import *
from plot_heatmap import *
from plot_video import *
from PoleFile import *
from smoothingFunctions import *

# aux function
def createSubdir(root, name):
    subdir = os.path.join(root, name)
    if not os.path.exists(subdir):  os.mkdir(subdir)
    return subdir

# Inputs config
video = False
off_begin = 200
off_end = 300
config_file = r"N:\Projects\11202000\11202277\B. Measurements and calculations\016_Fibre_Optics_kleirijperij\data\layout_length_depth_poles\configuration.json"
with open(config_file) as f:
    config = json.load(f)

# Outputs config
outputDir = r'N:\Projects\11202000\11202277\B. Measurements and calculations\016_Fibre_Optics_kleirijperij\data\outputs'

# For every experiment
for poleName, exp in config.iteritems():
    print '------------------------------------------'
    print 'Processing experiment = {}'.format(poleName)
    print '------------------------------------------'

    # Pole dimensions
    h0 = exp["poleDimensions"][0]
    h1 = exp["poleDimensions"][1]

    # For every file
    lp = line_Plot()
    allplotH = []
    legend = []
    for poleExpData in exp['poleExpFiles']:
        # Parse data and cut to pole height + Cut by on/off times and offsets
        fn = poleExpData['datafile']
        print 'Processing file = {}'.format(fn)
        pf = PoleFile(fn, exp['poleHeightFile'], poleExpData['start'], poleExpData['end'], poleExpData['stop'], off_begin, off_end, cut_begin=h0, cut_end=h1) # start/end times, bottom/top end of pole

        '''
        # VIDEO plot
        if video:
            subdir = createSubdir(outputDir, 'videos_plots')
            vp = video_Plot(poleName, pf, rows=True)
            vp.videoPlot(subdir, os.path.basename(fn).replace('.csv', '_cut_VIDEO_temp_vs_height.html'))
            vp = video_Plot(poleName, pf, rows=False)
            vp.videoPlot(subdir, os.path.basename(fn).replace('.csv', '_cut_VIDEO_temp_vs_time.html'))

        # RAW plot / line / average temperature over time
        subdir = createSubdir(outputDir, 'all_data_plots')
        lp.generate_plot(pf.distance, pf.meantemp, 'Distance [m]', 'Temperature [C]',
                         os.path.join(subdir, os.path.basename(fn).replace('.csv', '_alldata_raw_meanT_vs_Dist.html')), xsize=1200)
        lp.generate_plot(pf.meantemp, pf.height, 'Temperature [C]', 'Height [m]',
                         os.path.join(subdir, os.path.basename(fn).replace('.csv', '_alldata_raw_meanT_vs_Height.html')), xsize=900, ysize=900)
        '''
        # HEATMAP plot / image
        subdir = createSubdir(outputDir, 'heatmap_plots')
        hm = heatmap_Plot(pf)
        hm.heatmap('Heatmap for '+ os.path.basename(fn).replace('.csv', '') + ' on ' + pf.date + ' cut[t0,t1] = [{}, {}]'.format(pf.cut_t0, pf.cut_t1),
                   os.path.join(subdir, os.path.basename(fn).replace('.csv', '_FULL_HEATMAP_Time_vs_Height.png')))

        # LINE plot
        subdir = createSubdir(outputDir, 'cut_data_plots')
        t0_off_tempseries = savitzky_golay(pf.tempmatrix_cut[:, pf.idt0_off], 11, 3)
        t0_tempseries = savitzky_golay(pf.tempmatrix_cut[:, pf.idt0], 11, 3)
        t1_tempseries = savitzky_golay(pf.tempmatrix_cut[:, pf.idt1], 11, 3)
        t1_off_tempseries = savitzky_golay(pf.tempmatrix_cut[:, pf.idt1_off], 11, 3)
        lp.generate_plot_multi([(t0_off_tempseries, pf.height_cut), (t0_tempseries, pf.height_cut), (t1_tempseries, pf.height_cut), (t1_off_tempseries, pf.height_cut)],
                               'Temperature [C]', 'Height [m]',
                               ['Before heating', 'Start heating', 'Stop heating', 'After heating'],
                               os.path.join(subdir, os.path.basename(fn).replace('.csv', '_cut_Temp_vs_Height.html')), xsize=1500)

        '''
        # ALL / gather data
        allplotH.append((pf.meantemp_cut, pf.height_cut))
        allplotH.append((meantempsmooth, pf.height_cut))
        legend.append(pf.date)
        legend.append(pf.date+'_smooth')
        '''

    # All plots [per pole]
    '''
    subdir = createSubdir(outputDir, 'summary_plots')
    lp.generate_plot_multi(allplotH, 'Temperature [C]', 'Height [m]', legend,
                           os.path.join(subdir, poleName + '_comparison_meanT_vs_Height.html'), xsize=900, ysize=900)
    '''
