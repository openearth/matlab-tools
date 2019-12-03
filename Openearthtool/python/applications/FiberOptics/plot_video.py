import matplotlib.pyplot as plt
from matplotlib import animation
import os

# Author: Joan Sala Calero
# CLASS to generate HeatMap for Fiber optics data
class video_Plot:
    def __init__(self, title, pfin, rows=True, xsize=15, ysize=8):
        self.header = title
        self.pf = pfin
        self.rows = rows

        # First set up the figure, the axis, and the plot element we want to animate
        self.fig = plt.figure(figsize=(xsize, ysize))

        # 2 types of plots
        if self.rows:
            self.ax = plt.axes(xlim=(min(self.pf.elapsedTime), max(self.pf.elapsedTime)),
                               ylim=(0, 50))
            plt.xlabel('Elapsed time [s]')
            plt.ylabel('Temperature [deg]')
        else:
            self.ax = plt.axes(xlim=(min(self.pf.height_cut), max(self.pf.height_cut)),
                               ylim=(0, 50))
            plt.xlabel('Height [m]')
            plt.ylabel('Temperature [deg]')

        self.ttl = self.ax.text(.5, 1.05, '', transform=self.ax.transAxes, va='center')
        self.line, = self.ax.plot([], [], lw=2)

    # initialization function: plot the background of each frame
    def initPlot(self):
        self.line.set_data([], [])
        return self.line,

    # animation function.  This is called sequentially
    def animatePlot(self, i):
        if self.rows:
            x = self.pf.elapsedTime
            y = self.pf.tempmatrix_cut[i] # row i
            self.ttl.set_text(self.header + ' [Height = {} meters]'.format(round(self.pf.height_cut[i], 3))
                              + ' [Distance = {} meters]'.format(round(self.pf.distance_cut[i], 3)))
        else:
            x = self.pf.height_cut
            y = self.pf.tempmatrix_cut[:, i] # column j
            self.ttl.set_text(self.header + ' [Elapsed time = {} seconds]'.format(round(self.pf.elapsedTime[i], 3)))

        self.line.set_data(x, y)
        return self.line,

    # Video plot
    def videoPlot(self, outdir, outfile, xsize=15, ysize=8):
        # Change dir to output dir
        os.chdir(outdir)

        # Call the animator.  blit=True means only re-draw the parts that have changed.
        if self.rows:
            numframes = len(self.pf.height_cut)
        else:
            numframes = len(self.pf.elapsedTime)
        anim = animation.FuncAnimation(self.fig, self.animatePlot, init_func=self.initPlot,
                                       frames=numframes, interval=5, blit=True)
        # Save or Show
        anim.save(outfile, fps=30, extra_args=['-vcodec', 'libx264'])
        print 'Saving {}'.format(outfile)

