# Libs
from plot_lineplot import *
from plot_heatmap import *
from plot_video import *
from plot_rectangles import *
from plot_meshplot import *
from FloorFile import *

# aux function
def createSubdir(root, name):
    subdir = os.path.join(root, name)
    if not os.path.exists(subdir):  os.mkdir(subdir)
    return subdir

# Inputs config
cut_begin = 34
cut_end = 61
minT=15
maxT=25
inputs_dir = r'D:\sala\Documents\Fiber_Optics\adts\data'
subexperiments = r'D:\sala\Documents\Fiber_Optics\adts\heating_periods\on_off.csv'

# Outputs config
outputDir = r'D:\sala\Documents\Fiber_Optics\adts\output'
outputDir = createSubdir(outputDir, 'output_{}_{}'.format(minT, maxT))

# For every experiment, read all data
datafiles = [f for f in os.listdir(inputs_dir) if f.endswith('.csv')]
datadict = {}
for expFile in datafiles:
    fn = os.path.join(inputs_dir, expFile)
    expDate = expFile.replace('.csv', '')

    # Parse data and cut to begin/end experiment [distance cut]
    print 'Processing file = {}'.format(fn)
    pf = FloorFile(fn, cut_begin, cut_end, time_offset=-1) # read and apply -1h offset
    datadict[expDate] = pf

    # HEATMAP plot / image
    subdir = createSubdir(outputDir, 'heatmap_plots')
    hm = heatmap_Plot(pf, height=False, minTemp=minT, maxTemp=maxT)
    hm.heatmap('Heatmap on '+ os.path.basename(fn).replace('.csv', ''),
               os.path.join(subdir, os.path.basename(fn).replace('.csv', '_cut_HEATMAP_Time_vs_Distance.png')))
    
    # Plot for every distance
    subdir = createSubdir(outputDir, 'line_plots_dist')
    for d in range(cut_begin, cut_end):
        base = os.path.basename(fn).replace('.csv', '')
        tempvals = pf.selDist(d)
        lp = line_Plot()
        lp.generate_plot_multi([(pf.elapsedTime, tempvals)],
                               'Elapsed time [s]', 'Temperature [deg]', ['{} Fixed distance={}m'.format(base, d)],
                               os.path.join(subdir, '{}_{}m.html'.format(base, d)),
                               tit='min={}, max={}, mean={}'.format(tempvals.min(), tempvals.max(), tempvals.mean()))

    # MESH plot
    subdir = createSubdir(outputDir, 'mesh3D_plots')
    mp = mesh_Plot(pf.elapsedTime, pf.distance_cut, pf.tempmatrix_cut)
    mp.mesh3D('Temperature over Distance/Time [date={}]'.format(os.path.basename(fn).replace('.csv', '')),
              os.path.join(subdir, os.path.basename(fn).replace('.csv', '_cut_MESH3D_Time_vs_Distance.png')), minTemp=minT, maxTemp=maxT)

# For every sub-experiment [on/off]
df = pd.read_csv(subexperiments, sep=';')
allexperiments = []
allexpnames = []
alldata = []

for index, row in df.iterrows():
    # Cut on t0/t1
    pf = datadict[row['Date']]
    pf.cutTime(row['Date'], row['on'], row['off'])
    allexperiments.append(pf)
    allexpnames.append(row)

    print '------------------------------------------'
    print 'Processing experiment = {}, {} : elapsed=[{}s, {}s]  cut_time=[{}, {}] cut_dist=[{}, {}]'.\
        format(row['Number'], row['Date'],pf.t0, pf.t1, pf.idt0, pf.idt1, pf.idx0, pf.idx1)
    print 'Data: {}'.format(pf.floorExpFile)
    print '------------------------------------------'

    # HEATMAP plot / image
    subdir = createSubdir(outputDir, 'heatmap_plots_on_off')
    hm = heatmap_Plot(pf, height=False, minTemp=minT, maxTemp=maxT)
    hm.heatmapTimeslice('Heatmap for {}, {} {} [ start = {} end = {} ]'.format(row['Number'], row['Date'], row['Time'], row['on'], row['off']),
               os.path.join(subdir, '{}_cut_HEATMAP_Time_vs_Distance.png'.format(row['Number'])))

    # LINE plot / start-end heating comparison
    subdir = createSubdir(outputDir, 'line_plots_on_off')
    lp = line_Plot()
    lp.generate_plot_multi([(pf.distance_cut, pf.tempt0_timeslice), (pf.distance_cut, pf.tempt1_timeslice)],
                           'Elapsed time [s]', 'Temperature [deg]', ['start measuring', 'end measuring'],
                           os.path.join(subdir, '{}_cut_Temp_vs_Distance.html'.format(row['Number'])))
    lp.generate_plot_multi([(pf.elapsedTime_timeslice, pf.meantemp_timeslice)],
                           'Elapsed time [s]', 'Temperature [deg]', ['Experiment {}'.format(row['Number'])],
                           os.path.join(subdir, '{}_cut_MTemp_vs_Time.html'.format(row['Number'])))

    # MESH plot

    subdir = createSubdir(outputDir, 'mesh3D_plots_on_off')
    mp = mesh_Plot(pf.elapsedTime_timeslice, pf.distance_cut, pf.tempmatrix_timeslice)
    mp.mesh3D('Temperature over Distance/Time [exp={}]'.format(row['Number']),
              os.path.join(subdir, '{}_cut_mesh3D.png'.format(row['Number'])), minTemp=minT, maxTemp=maxT)

    # Save experiment data [XYZ]
    alldata.append((pf.elapsedTime_timeslice[:], pf.distance_cut[:], pf.tempmatrix_timeslice.copy()))


print '------------------------------------------'
print 'Summary plots '
print '------------------------------------------'

# OVERVIEW plots/time
rp = rectangles_Plot(allexperiments, allexpnames, alldata)
rp.generate_plot(os.path.join(outputDir, 'summary_experiments_MeanTemp_over_time.html'), 'mean', minT=minT, maxT=maxT, axis=1)
rp.generate_plot(os.path.join(outputDir, 'summary_experiments_MinTemp_over_time.html'), 'min', minT=minT, maxT=maxT, axis=1)
rp.generate_plot(os.path.join(outputDir, 'summary_experiments_MaxTemp_over_time.html'), 'max', minT=minT, maxT=maxT, axis=1)

# OVERVIEW plots/distance
rp = rectangles_Plot(allexperiments, allexpnames, alldata)
rp.generate_plot(os.path.join(outputDir, 'summary_experiments_MeanTemp_over_distance.html'), 'mean', minT=minT, maxT=maxT, axis=0)
rp.generate_plot(os.path.join(outputDir, 'summary_experiments_MinTemp_over_distance.html'), 'min', minT=minT, maxT=maxT, axis=0)
rp.generate_plot(os.path.join(outputDir, 'summary_experiments_MaxTemp_over_distance.html'), 'max', minT=minT, maxT=maxT, axis=0)

diffs = [(1,3), (1,4), (1,5), (1,6), (2,6), (2,8)]
for d in diffs:
    mind=d[0]
    maxd=d[1]
    rp.generate_plot(os.path.join(outputDir, '{}_{}_summary_experiments_DiffTemp_T0_T1_over_distance.html'.format(d[0],d[1])), 'difft0t1',
                     minT=minT, maxT=maxT, axis=0, minD=d[0], maxD=d[1])
    rp.generate_plot(os.path.join(outputDir, '{}_{}_summary_experiments_DiffTemp_MIN_MAX_over_distance.html'.format(d[0],d[1])), 'diffminmax',
                     minT=minT, maxT=maxT, axis=0, minD=d[0], maxD=d[1])