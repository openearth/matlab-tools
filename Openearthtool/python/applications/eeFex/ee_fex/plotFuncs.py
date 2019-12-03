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
#
# =========================================
#Plotting Functions for Feature Extraction
#=========================================
#JFriedman
#Apr 20/2016
#=========================================

#import all necessary packages
#=============================
import os
import datetime as dt
import matplotlib.pyplot as plt
import matplotlib.colors as colors
import matplotlib.cm as cm

#function for visualizing extracted features
#===========================================  
def clickFeatures(name, img, dater, xlims, ylims, tempdir, printFlag):
	plt.ion()  #turn ON plots popping on screen

	#visualize the satellite image
	fig = plt.figure(figsize=(6, 6), dpi=150, facecolor='w', edgecolor='k')
	ax = fig.add_subplot(111)
	plt.tick_params(axis='both', which='major', labelsize=7)
	plt.imshow(img, aspect='equal', extent=[xlims[0], xlims[1], ylims[0], ylims[1]])
	plt.title('Extracted Feature', size=10)
	plt.xlim(xlims)
	plt.ylim(ylims)
	plt.xlabel('X-coordinate [m]', size=8)
	plt.ylabel('Y-coordinate [m]', size=8)

	#add information about image acquisition date
	date_out = dt.datetime.strftime(dater, '%Y/%m/%d %H:%M:%S')
	props = dict(boxstyle='round', facecolor='white', alpha=0.85)
	plt.text(0.95, 0.05, 'Image date = ' + date_out, fontsize=8, ha='right', transform=ax.transAxes, bbox=props)

	#allow user to click desired points
	temp = plt.ginput(n=0, timeout=120, show_clicks=True)

	#add clicked points on satellite image
	plt.plot([t[0] for t in temp], [t[1] for t in temp], '-r', lw=0.75)

	#save "feature extraction" clicking via the plot
	date_out = dt.datetime.strftime(dater, '%Y%m%d_%H%M%S')

	if printFlag:
		fname = os.path.join(tempdir, "%s_Features_%s.png" % (name, date_out))
		fig.savefig(fname, dpi=300, bbox_inches='tight')

	plt.close('all')

	return temp, date_out


#function for visualizing extracted features
#===========================================
def plotFeatures(name, img, X, xlims, ylims, tempdir):
	plt.ioff()  #turn OFF plots popping on screen

	fig = plt.figure(figsize=(6, 6), dpi=150, facecolor='w', edgecolor='k')
	ax = fig.add_subplot(111)
	plt.tick_params(axis='both', which='major', labelsize=7)
	plt.imshow(img, aspect='equal', extent=[xlims[0], xlims[1], ylims[0], ylims[1]])

	cmapper = cm.get_cmap('rainbow')
	cNorm = colors.Normalize(vmin=0, vmax=len(X))
	scalarMap = cm.ScalarMappable(norm=cNorm, cmap=cmapper)

	#get dates from hash table
	dater = []
	for key in X:
		dater.append(key)
	dater.sort()

	for ind, date in enumerate(dater):
		colorVal = scalarMap.to_rgba(ind)
		plt.plot([x[0] for x in X[date]], [x[1] for x in X[date]], c=colorVal, lw=1, label=date)

	plt.title('All Extracted Features', size=10)
	plt.xlim(xlims)
	plt.ylim(ylims)
	plt.xlabel('X-coordinate [m]', size=8)
	plt.ylabel('Y-coordinate [m]', size=8)
	plt.legend(fontsize=8)

	#add information about image acquisition date
	date_out = dt.datetime.strftime(dt.datetime.strptime(date, '%Y%m%d_%H%M%S'), '%Y/%m/%d %H:%M:%S')
	props = dict(boxstyle='round', facecolor='white', alpha=0.85)
	plt.text(0.95, 0.05, 'Image date = ' + date_out, fontsize=8, ha='right', transform=ax.transAxes, bbox=props)

	#save "feature extraction" clicking
	fname = os.path.join(tempdir, "%s_Features.png" % name)
	fig.savefig(fname, dpi=300, bbox_inches='tight')
	plt.close('all')
