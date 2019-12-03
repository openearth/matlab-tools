#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Deltares
#       Gerben Hagenaars
#
#       Gerben.Hagenaars@deltares.nl
#       
#       Wiebe de Boer
#
#       Wiebe.deBoer@deltares.nl
#
#       P.O. Box 177
#       2600 MH Delft
#       The Netherlands
#
#   This library is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Lesser General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This library is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this library.  If not, see <http://www.gnu.org/licenses/>.
#   --------------------------------------------------------------------
#
# This tool is developed as part of the research cooperation between
# Deltares and the Korean Institute of Science and Technology (KIOST).
# The development is funded by the CoMIDAS project of the South Korean
# government and the Deltares strategic research program Coastal and
# Offshore Engineering. This financial support is highly appreciated.

# import all necessary packages/modules + initialize EE
# ======================================================
import sys
import os

curr = os.getcwd()
sys.path.append(curr)  # add to system path

import ee
ee.Initialize()  # initialize Earth Engine
import datetime as dt
import matplotlib as mpl

mpl.rcParams['axes.formatter.useoffset'] = False
from ee_fex.gui import Ui_Dialog
import ee_fex.downloadFuncs as DL
import ee_fex.collectionFuncs as C
import ee_fex.ioFuncs as IO
from PyQt4 import QtGui, QtCore
from matplotlib.backends.backend_qt4agg import NavigationToolbar2QT as NavigationToolbar


# "dangerous" way to opt out of ssl verification (https://www.python.org/dev/peps/pep-0476/#opting-out)
# =====================================================================================================
import ssl

try:
    _create_unverified_https_context = ssl._create_unverified_context
except AttributeError:
    # Legacy Python that doesn't verify HTTPS certificates by default
    pass
else:
    # Handle target environment that doesn't support HTTPS verification
    ssl._create_default_https_context = _create_unverified_https_context

# function to get satellite images
# ================================
def getImages(name, satellites, imbounds, date_range, cc):
    # load the all applicable image collection based on spatial/temporal filters
    aoi = ee.Geometry.Polygon(imbounds)  # build spatial search bounds
    imcoll, d, c, num = C.combineCollections(satellites, date_range[0], date_range[1], aoi, cc)

    return imcoll, num, aoi, d, c

# function to download satellite images
# =====================================
def dlImages(im, name, imbounds, epsg, tempdir):
    #  extract date for image filenames
    dater = ee.Date(im.get('system:time_start')).format('yyyyMMdd_HHmmss').getInfo()  # format date
    outname = '_'.join([name, dater])

    # download a true colour image (TC)
    url = DL.buildEEImage(im, 'TC', outname, 10, 'png', imbounds, epsg)

    if url != 0:
        DL.downloadEEImage(tempdir, url)

# function to move to next image
# ==============================
def nextIm(ii, fids, H, T, N, ax, tempdir, name, fname):

    if ii + 1 <= len(fids) - 1:
        ii += 1
        [img, dater, xlims, ylims] = IO.getImage(fids[ii], tempdir)
        H.set_data(img)

        xlims = [x / 1000. for x in xlims]
        ylims = [y / 1000. for y in ylims]
        extent = [xlims[0], xlims[1], ylims[0], ylims[1]]
        H.set_extent(extent)
        ax.set_xlim(xlims)
        ax.set_ylim(ylims)

        T.set_text(dt.datetime.strftime(dater, '%Y/%m/%d %H:%M:%S'))
        N.set_text('%d of %d' % (ii + 1, len(fids)))
        ax.figure.canvas.draw()

        # name for saving image
        fname = "%s_Features_%s.png" % (name, dt.datetime.strftime(dater, '%Y%m%d_%H%M%S'))

    return ii, fname

# function to move to previous image
# ==================================
def prevIm(ii, fids, H, T, N, ax, tempdir, name, fname):

    if ii - 1 >= 0:
        ii -= 1
        [img, dater, xlims, ylims] = IO.getImage(fids[ii], tempdir)
        H.set_data(img)

        xlims = [x / 1000. for x in xlims]
        ylims = [y / 1000. for y in ylims]
        extent = [xlims[0], xlims[1], ylims[0], ylims[1]]
        H.set_extent(extent)
        ax.set_xlim(xlims)
        ax.set_ylim(ylims)

        T.set_text(dt.datetime.strftime(dater, '%Y/%m/%d %H:%M:%S'))
        N.set_text('%d of %d' % (ii + 1, len(fids)))
        ax.figure.canvas.draw()

        # name for saving image
        fname = "%s_Features_%s.png" % (name, dt.datetime.strftime(dater, '%Y%m%d_%H%M%S'))

    return ii, fname

# class for drawing the line on the map
# ======================================
class Picker:
    def __init__(self, fig, ax, path):
        self.fig = fig
        self.path = path
        self.ax = ax
        self.xs = []
        self.ys = []
        self.cid = self.fig.canvas.mpl_connect('button_press_event', self)

        # make sure all previous lines are removed when initialized
        while self.ax.lines:
            for l in self.ax.lines:
                l.remove()
        self.ax.figure.canvas.draw()

    def __call__(self, event):
        print event.button
        if event.button == 3: # right mouse button, store feature

            self.cid = self.ax.figure.canvas.mpl_disconnect(self.cid)
            self.fig.savefig(self.path, dpi=300, bbox_inches='tight')

            IO.writeLDB(self.path.replace('.png', '.ldb'), zip(self.xs, self.ys))

        elif event.button == 2: # scroll wheel, add coordinate
            self.xs.append(event.xdata)
            self.ys.append(event.ydata)
            self.ax.plot(self.xs, self.ys, '-or', ms=3)  # plot each point
            self.ax.figure.canvas.draw()

# class for the GUI
# =================
class Main(QtGui.QDialog):
    # initialize the GUI
    # ==================
    def __init__(self, parent=None):

		QtGui.QWidget.__init__(self, parent)
		self.ui = Ui_Dialog()
		self.ui.setupUi(self)

		# set up dynamic end date to current date
		y = dt.datetime.now().year
		m = dt.datetime.now().month
		d = dt.datetime.now().day
		self.ui.edate.setDate(QtCore.QDate(y, m, d))

		# add project names to list widget (for selecting desired extraction)
		projs = os.listdir(os.path.join(curr, '~PROJECTS'))
		[self.ui.projList.addItem(p) for p in projs]  # add to list

		# initialize feature extraction plot with labels
		self.fig = self.ui.plotter.figure
		self.fig.set_facecolor('w')
		self.fig.subplots_adjust(wspace=0, hspace=0)
		self.ax = self.fig.add_subplot(111)
		self.ax.hold(True)
		self.ax.set_xlabel('X-coordinate', fontsize=10)
		self.ax.set_ylabel('Y-coordinate', fontsize=10)

		# add navigation widget for panning + zooming in plot
		self.navi_toolbar = NavigationToolbar(self.ax.figure.canvas, self)
		self.ui.toolbar.addWidget(self.navi_toolbar)

		# add textbox in the middle of the plot
		props = dict(boxstyle='round', facecolor='red', alpha=0.6)
		self.ax.text(0.5, 0.5, 'Select an Available Project', fontsize=12,
		             ha='center', va='center', transform=self.ax.transAxes, bbox=props)

		# initialize cloud cover plot with labels
		self.figc = self.ui.ccplotter.figure
		self.figc.set_facecolor('w')
		self.figc.subplots_adjust(left=0.05, right=0.925, bottom=0.125, top=0.95)
		self.axc = self.figc.add_subplot(111)
		self.axc.hold(True)
		self.axc.set_ylim([0, 50])
		self.axc.set_xlim([1985, 2020])
		self.axc.set_ylabel('Cloud Cover [%]', fontsize=10)

		# add textbox in the middle of the plot
		props = dict(boxstyle='round', facecolor='red', alpha=0.6)
		self.axc.text(0.5, 0.5, 'Waiting for Cloud Analysis', fontsize=12,
		             ha='center', va='center', transform=self.axc.transAxes, bbox=props)

		# make sure output folder is created
		self.mkdir = True

		# disable buttons on download page (need to first complete cloud analysis)
		self.ui.cc.setEnabled(False)
		self.ui.epsg.setEnabled(False)
		self.ui.dl_button.setEnabled(False)

		# disable buttons on extract page
		self.ui.extract_button.setEnabled(False)
		self.ui.prev_button.setEnabled(False)
		self.ui.kml_button.setEnabled(False)
		self.ui.resetProj_button.setEnabled(False)

		# connect each button
		self.ui.cc_button.clicked.connect(self.clouds)
		self.ui.dl_button.clicked.connect(self.download)
		self.ui.extract_button.clicked.connect(self.extract)
		self.ui.prev_button.clicked.connect(self.prv)
		self.ui.next_button.clicked.connect(self.nxt)
		self.ui.kml_button.clicked.connect(self.kml)
		self.ui.resetProj_button.clicked.connect(self.reset)

    # function for detecting cloud cover
    # ==================================
    def clouds(self):

		# get the required inputs from the GUI
		name = str(self.ui.name.text())
		date_range = [dt.datetime.strftime(self.ui.sdate.date().toPyDate(), '%Y-%m-%d'),
                      dt.datetime.strftime(self.ui.edate.date().toPyDate(), '%Y-%m-%d')]

		coords = self.ui.webView.page().mainFrame().evaluateJavaScript("saver();")
		coords = [float(unicode(i.toString())) for i in coords.toList()]
		x = [round(a, 5) for a in coords[1::2]]
		y = [round(b, 5) for b in coords[::2]]
		imbounds = [[a, b] for a, b in zip(x, y)]

		# get the desired satellites to use for FEX
		satellites = []
		if self.ui.L4_check.isChecked():
			satellites.append('IM_L4')
		if self.ui.L5_check.isChecked():
			satellites.append('IM_L5')
		if self.ui.L7_check.isChecked():
			satellites.append('IM_L7')
		if self.ui.L8_check.isChecked():
			satellites.append('IM_L8')
		if self.ui.S2_check.isChecked():
			satellites.append('S2')

		#  get image collection based on inputs
		cc = 50 # HARD-CODE AT 50%
		[_, _, _, d, c] = getImages(name, satellites, imbounds, date_range, cc)

		# plot the images in time based on cloud cover
		self.axc.clear()
		for k in d:
			for ii in range(len(d[k])):
				self.axc.plot([d[k][ii], d[k][ii]], [0, c[k][ii]], '-b', lw=0.5)

		sx = self.ui.sdate.date().toPyDate()
		ex = self.ui.edate.date().toPyDate()

		# add textbox to indicate number of images at X%
		for pct in [5, 10, 15, 25, 50]:
			nummer = 0
			for k in c:
				nummer += len(filter(lambda x: x <= pct, c[k]))
			if pct != 50:
				self.axc.plot([sx, ex], [pct, pct], ':r', lw=0.4)
			self.axc.text(1.01, pct/50., 'N = %d' % nummer, fontsize=8, transform=self.axc.transAxes, ha='left', va='center')

		self.axc.set_ylim([0, 50])
		self.axc.set_ylabel('Cloud Cover [%]', fontsize=10)

		# set the new plot by "drawing"
		self.axc.figure.canvas.draw()

		# enable buttons on download page (need to first complete cloud analysis)
		self.ui.cc.setEnabled(True)
		self.ui.epsg.setEnabled(True)
		self.ui.dl_button.setEnabled(True)

	# function for downloading satellite images
    # =========================================
    def download(self):

        # disable the "Download" button
        self.ui.dl_button.setEnabled(False)

        # enable the "Progress bar"
        self.ui.progressBar.setEnabled(True)

        # get the required inputs from the GUI
        name = str(self.ui.name.text())
        date_range = [dt.datetime.strftime(self.ui.sdate.date().toPyDate(), '%Y-%m-%d'),
                      dt.datetime.strftime(self.ui.edate.date().toPyDate(), '%Y-%m-%d')]

        cc = float(self.ui.cc.value())
        epsg = int(str(self.ui.epsg.text()))
        coords = self.ui.webView.page().mainFrame().evaluateJavaScript("saver();")
        coords = [float(unicode(i.toString())) for i in coords.toList()]
        x = [round(a, 5) for a in coords[1::2]]
        y = [round(b, 5) for b in coords[::2]]
        imbounds = [[a, b] for a, b in zip(x, y)]

        # get the desired satellites to use for FEX
        satellites = []
        if self.ui.L4_check.isChecked():
            satellites.append('IM_L4')
        if self.ui.L5_check.isChecked():
            satellites.append('IM_L5')
        if self.ui.L7_check.isChecked():
            satellites.append('IM_L7')
        if self.ui.L8_check.isChecked():
            satellites.append('IM_L8')
        if self.ui.S2_check.isChecked():
            satellites.append('S2')

        if not satellites:  # if there isn't any data from the desired satellites

            # clean up after downloading (enable "Download" button)
            self.ui.dl_button.setEnabled(True)

            # update "Progress bar" + process events to update GUI
            self.ui.progressBar.setProperty("value", 100)  # "fake" finished
            app.processEvents()

            # update "Progress bar" + process events to update GUI
            self.ui.progressBar.setProperty("value", 0)  #  reset
            app.processEvents()

            return

        #  get image collection based on inputs
        [imcoll, num, aoi, _, _] = getImages(name, satellites, imbounds, date_range, cc)

        #  build folder for saving images
        tempdir = IO.PathBuilder(os.path.join(os.getcwd(), '~PROJECTS'), name)

        #  loop through collection -> download images
        for n in range(num):
            im = ee.Image(imcoll.toList(1, n).get(0)).clip(aoi)  # get nth image
            dlImages(im, name, imbounds, epsg, tempdir)  # download image locally

            #  update "Progress bar" + process events to update GUI
            self.ui.progressBar.setProperty("value", int(100 * (n + 1) / num))
            app.processEvents()

        #  clean up after downloading (enable "Download" button)
        self.ui.progressBar.setProperty("value", 100)
        self.ui.dl_button.setEnabled(True)

        # write epsg code to directory (needed for later conversions)
        f = open(os.path.join(tempdir, '%d.epsg' % epsg), 'w')
        f.close()

        # add project names to list widget (for selecting desired extraction)
        self.ui.projList.clear()
        projs = os.listdir(os.path.join(curr, '~PROJECTS'))
        [self.ui.projList.addItem(p) for p in projs]  # add to list

    # function for downloading satellite images
    # =========================================
    def extract(self):

        # build output folder
        if self.mkdir:
            date_out = dt.datetime.strftime(dt.datetime.now(), '%Y%m%d_%H%M%S')
            self.outdir = IO.PathBuilder(self.tempdir, 'Analysis_' + date_out)
            self.mkdir = False

        # name for saving image
        self.path = os.path.join(self.outdir, self.fname)

        # call class for clicking/exporting images + features
        Picker(self.fig, self.ax, self.path)

        # only enable *.kml functionality AFTER clicking at least one feature
        self.ui.kml_button.setEnabled(True)

    # function for switching to NEXT image
    # =====================================
    def nxt(self):

        if not hasattr(self, 'ii'):  # initial creation of plot

            # clear the plot
            self.ax.clear()

            # get the selected project location
            self.name = str(self.ui.projList.currentItem().text())
            self.ui.projList.setEnabled(False)
            self.ui.resetProj_button.setEnabled(True)

            # get filenames of all satellite images (by folder)
            self.tempdir = IO.PathBuilder(os.path.join(os.getcwd(), '~PROJECTS'), self.name)
            self.fids = [f for f in os.listdir(self.tempdir) if (f.endswith('.png') or f.endswith('.tif'))]

            # get image, date, bounds
            self.ii = 0
            [img, dater, xlims, ylims] = IO.getImage(self.fids[self.ii], self.tempdir)

            # name for saving image
            self.fname = "%s_Features_%s.png" % (self.name, dt.datetime.strftime(dater, '%Y%m%d_%H%M%S'))

            xlims = [x / 1000. for x in xlims]
            ylims = [y / 1000. for y in ylims]

            # set the plot with new data
            self.H = self.ax.imshow(img, aspect='equal', extent=[xlims[0], xlims[1],
                                                                 ylims[0], ylims[1]])
            self.ax.set_xlabel('X-coordinate', fontsize=10)
            self.ax.set_ylabel('Y-coordinate', fontsize=10)
            self.ax.set_xlim(xlims)
            self.ax.set_ylim(ylims)

            # add information about image acquisition date
            props = dict(boxstyle='round', facecolor='white', alpha=0.75)
            self.T = self.ax.text(0.975, 0.05, dt.datetime.strftime(dater, '%Y/%m/%d %H:%M:%S'),
                                  fontsize=10, ha='right', transform=self.ax.transAxes, bbox=props)

            # add information about image NUMBER
            props = dict(boxstyle='round', facecolor='white', alpha=0.75)
            self.N = self.ax.text(0.975, 0.95, '%d of %d' % (self.ii + 1, len(self.fids)),
                                  fontsize=10, ha='right', transform=self.ax.transAxes, bbox=props)

            # set the new plot by "drawing"
            self.ax.figure.canvas.draw()

            # enable the remaining buttons
            self.ui.extract_button.setEnabled(True)
            self.ui.prev_button.setEnabled(True)
            app.processEvents()

        else:

            self.ii, self.fname = nextIm(self.ii, self.fids, self.H,
                                         self.T, self.N, self.ax,
                                         self.tempdir, self.name, self.fname)

            # function for switching to PREVIOUS image

    # ========================================
    def prv(self):

        self.ii, self.fname = prevIm(self.ii, self.fids, self.H,
                                     self.T, self.N, self.ax,
                                     self.tempdir, self.name, self.fname)

        # function for scanning *.ldb -> combined into single *.kml

    # =========================================================
    def kml(self):

        IO.buildKML(self.name, self.tempdir, self.outdir)

    def reset(self):

        del self.ii
        self.mkdir = True

        # disable buttons on extract page
        self.ui.projList.setEnabled(True)
        self.ui.extract_button.setEnabled(False)
        self.ui.prev_button.setEnabled(False)
        self.ui.kml_button.setEnabled(False)
        self.ui.resetProj_button.setEnabled(False)

# if function is run as script
# ============================
if __name__ == "__main__":
    app = QtGui.QApplication(sys.argv)
    myapp = Main()
    myapp.show()
    app.exec_()

