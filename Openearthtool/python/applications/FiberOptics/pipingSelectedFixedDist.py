import os

# Libs
from plot_lineplot import *
from FloorFile import *

# Inputs config
cut_begin = 34
cut_end = 61
fn = r"D:\sala\Documents\Fiber_Optics\adts\data\31-05-18.csv"

# Outputs config
outputDir = r'D:\sala\Documents\Fiber_Optics\adts\output\line_plots_dist'

# Plot for every distance
for d in range(cut_begin, cut_end):
    base = os.path.basename(fn).replace('.csv', '')
    print 'Processing file = {}'.format(fn)
    pf = FloorFile(fn, cut_begin, cut_end, time_offset=-1)  # read and apply -1h offset
    tempvals = pf.selDist(d)
    lp = line_Plot()
    lp.generate_plot_multi([(pf.elapsedTime, tempvals)],
                           'Elapsed time [s]', 'Temperature [deg]', ['{} Fixed distance={}m'.format(base, d)],
                           os.path.join(outputDir, '{}_{}m.html'.format(fn, d)),
                           tit='min={}, max={}, mean={}'.format(tempvals.min(), tempvals.max(), tempvals.mean()))
