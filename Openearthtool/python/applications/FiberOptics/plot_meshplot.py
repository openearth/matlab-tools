from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
from matplotlib import cm
from matplotlib.ticker import LinearLocator, FormatStrFormatter
import numpy as np

# Author: Joan Sala Calero
# CLASS to generate Meshplot3d for Fiber optics data
class mesh_Plot:
    def __init__(self, xin, yin, zin):
        self.x = xin
        self.y = yin
        self.z = zin

    def mesh3D(self, title, outfile, xsize=15, ysize=8, minTemp=0, maxTemp=50):
        # Plot matrix [flip indicates if pole is upside down]
        fig = plt.figure(figsize=(xsize, ysize))
        ax = fig.gca(projection='3d')

        # Plot the surface.
        X, Y = np.meshgrid(self.x, self.y)
        print X.shape
        print Y.shape
        print self.z.shape
        surf = ax.plot_surface(X, Y, self.z,cmap='rainbow', vmin=minTemp, vmax=maxTemp, linewidth=0, antialiased=False)

        # Create colorbar
        cbar = ax.figure.colorbar(surf, ax=ax)
        cbar.ax.set_ylabel('Temperature [deg]', rotation=-90, va="bottom")

        # Labels
        plt.xlabel('Elapsed time [s]')
        plt.ylabel('Distance [m]')
        plt.title(title)

        # Save or Show
        fig.tight_layout()
        if outfile is None:
            plt.show()
        else:
            plt.savefig(outfile)
            print 'Saving {}'.format(outfile)
