import matplotlib.pyplot as plt
import numpy as np

# Author: Joan Sala Calero
# CLASS to generate HeatMap for Fiber optics data
class heatmap_Plot:
    def __init__(self, pfin, minTemp=0, maxTemp=50):
        self.pf = pfin
        self.minTemp = minTemp
        self.maxTemp = maxTemp

    def heatmap(self, title, outfile, xsize=15, ysize=8, full=True):
        # Plot matrix [flip indicates if pole is upside down]
        fig, ax = plt.subplots(figsize=(xsize, ysize))
        if self.pf.flippedPole:
            data = np.flip(self.pf.tempmatrix_cut, 0)
            print 'Flipping rows ... '
        else:
            data = self.pf.tempmatrix_cut

        # Heatmap showing cuts
        im = ax.imshow(data,
                       extent=[min(self.pf.elapsedTime), max(self.pf.elapsedTime), self.pf.height_cut.min(), self.pf.height_cut.max()],
                       interpolation='bilinear',
                       cmap='rainbow',
                       vmin=self.minTemp, vmax=self.maxTemp,
                       aspect='auto')
        plt.ylabel('Height [m]')
        plt.axvline(x=self.pf.val0, color='#007700')
        plt.axvline(x=self.pf.val1, color='#007700')
        plt.axvline(x=self.pf.val2, color='#007700')

        # Create colorbar
        cbar = ax.figure.colorbar(im, ax=ax)
        cbar.ax.set_ylabel('Temperature [deg]', rotation=-90, va="bottom")

        # Labels
        plt.xlabel('Elapsed time [s]')
        plt.title(title)

        # Save or Show
        fig.tight_layout()
        if outfile is None:
            plt.show()
        else:
            plt.savefig(outfile)
            print 'Saving {}'.format(outfile)

