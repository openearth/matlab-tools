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

from distutils.core import setup
import matplotlib as mpl
import py2exe

setup(
	windows=['main.py'],
	data_files=mpl.get_py2exe_datafiles(),
	options={
		"py2exe": {
		'includes': ['matplotlib.backends.backend_wxagg', 'sip'],
		'bundle_files': 1,
		'compressed': True}
	})