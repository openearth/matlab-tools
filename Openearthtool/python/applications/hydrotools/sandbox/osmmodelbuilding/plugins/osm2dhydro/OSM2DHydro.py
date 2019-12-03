# -*- coding: utf-8 -*-
"""
/***************************************************************************
 osm2dhydro
                                 A QGIS plugin
 OSM to D-HYDRO conversion
                              -------------------
        begin                : 2016-12-20
        git sha              : $Format:%H$
        copyright            : (C) 2016 by Deltares
        email                : hessel.winsemius@deltares.nl
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
"""
from PyQt4.QtCore import QSettings, QTranslator, qVersion, QCoreApplication
from PyQt4.QtGui import QAction, QIcon
# Initialize Qt resources from file resources.py
import resources
# Import the code for the dialog
from OSM2DHydro_dialog import osm2dhydroDialog
import os.path

def resources_path(*args):
    """Get the path to our resources folder.

    .. versionadded:: 3.0

    Note that in version 3.0 we removed the use of Qt Resource files in
    favour of directly accessing on-disk resources.

    :param args List of path elements e.g. ['img', 'logos', 'image.png']
    :type args: list

    :return: Absolute path to the resources folder.
    :rtype: str
    """
    path = os.path.dirname(__file__)
    path = os.path.abspath(
        os.path.join(path, os.path.pardir, os.path.pardir, 'resources'))
    for item in args:
        path = os.path.abspath(os.path.join(path, item))

    return path


def _create_analysis_extent_action(self):
    """Create action for analysis extent dialog."""
    icon = resources_path('img', 'icons', 'set-extents-tool.svg')
    self.action_extent_selector = QAction(
        QIcon(icon),
        self.tr('Set Analysis Area'),
        self.iface.mainWindow())
    self.action_extent_selector.setStatusTip(self.tr(
        'Set the analysis area for OSM2D-HYDRO'))
    self.action_extent_selector.setWhatsThis(self.tr(
        'Set the analysis area for OSM2D-HYDRO'))
    self.action_extent_selector.triggered.connect(
        self.show_extent_selector)
    self.add_action(self.action_extent_selector)


class osm2dhydro:
    """QGIS Plugin Implementation."""

    def __init__(self, iface):
        """Constructor.

        :param iface: An interface instance that will be passed to this class
            which provides the hook by which you can manipulate the QGIS
            application at run time.
        :type iface: QgsInterface
        """
        # Save reference to the QGIS interface
        self.iface = iface
        # initialize plugin directory
        self.plugin_dir = os.path.dirname(__file__)
        # initialize locale
        locale = QSettings().value('locale/userLocale')[0:2]
        locale_path = os.path.join(
            self.plugin_dir,
            'i18n',
            'osm2dhydro_{}.qm'.format(locale))

        if os.path.exists(locale_path):
            self.translator = QTranslator()
            self.translator.load(locale_path)

            if qVersion() > '4.3.3':
                QCoreApplication.installTranslator(self.translator)


        # Declare instance attributes
        self.actions = []
        self.menu = self.tr(u'&osm2dhydro')
        # TODO: We are going to let the user set this up in a future iteration
        self.toolbar = self.iface.addToolBar(u'osm2dhydro')
        self.toolbar.setObjectName(u'osm2dhydro')

    # noinspection PyMethodMayBeStatic
    def tr(self, message):
        """Get the translation for a string using Qt translation API.

        We implement this ourselves since we do not inherit QObject.

        :param message: String for translation.
        :type message: str, QString

        :returns: Translated version of message.
        :rtype: QString
        """
        # noinspection PyTypeChecker,PyArgumentList,PyCallByClass
        return QCoreApplication.translate('osm2dhydro', message)


    def add_action(
        self,
        icon_path,
        text,
        callback,
        enabled_flag=True,
        add_to_menu=True,
        add_to_toolbar=True,
        status_tip=None,
        whats_this=None,
        parent=None):
        """Add a toolbar icon to the toolbar.

        :param icon_path: Path to the icon for this action. Can be a resource
            path (e.g. ':/plugins/foo/bar.png') or a normal file system path.
        :type icon_path: str

        :param text: Text that should be shown in menu items for this action.
        :type text: str

        :param callback: Function to be called when the action is triggered.
        :type callback: function

        :param enabled_flag: A flag indicating if the action should be enabled
            by default. Defaults to True.
        :type enabled_flag: bool

        :param add_to_menu: Flag indicating whether the action should also
            be added to the menu. Defaults to True.
        :type add_to_menu: bool

        :param add_to_toolbar: Flag indicating whether the action should also
            be added to the toolbar. Defaults to True.
        :type add_to_toolbar: bool

        :param status_tip: Optional text to show in a popup when mouse pointer
            hovers over the action.
        :type status_tip: str

        :param parent: Parent widget for the new action. Defaults None.
        :type parent: QWidget

        :param whats_this: Optional text to show in the status bar when the
            mouse pointer hovers over the action.

        :returns: The action that was created. Note that the action is also
            added to self.actions list.
        :rtype: QAction
        """

        # Create the dialog (after translation) and keep reference
        self.dlg = osm2dhydroDialog()

        icon = QIcon(icon_path)
        action = QAction(icon, text, parent)
        action.triggered.connect(callback)
        action.setEnabled(enabled_flag)

        if status_tip is not None:
            action.setStatusTip(status_tip)

        if whats_this is not None:
            action.setWhatsThis(whats_this)

        if add_to_toolbar:
            self.toolbar.addAction(action)

        if add_to_menu:
            self.iface.addPluginToMenu(
                self.menu,
                action)

        self.actions.append(action)

        return action

    def initGui(self):
        """Create the menu entries and toolbar icons inside the QGIS GUI."""

        self._create_analysis_extent_action()
        #
        # icon_path = ':/plugins/osm2dhydro/icon.png'
        # self.add_action(
        #     icon_path,
        #     text=self.tr(u'OSM to DHydro Flood model'),
        #     callback=self.run,
        #     parent=self.iface.mainWindow(),
        #     status_tip='Setup your model domain here',
        #     whats_this='Setup your model domain here')


    def unload(self):
        """Removes the plugin menu item and icon from QGIS GUI."""
        for action in self.actions:
            self.iface.removePluginMenu(
                self.tr(u'&osm2dhydro'),
                action)
            self.iface.removeToolBarIcon(action)
        # remove the toolbar
        del self.toolbar


    def run(self):
        """Run method that performs all the real work"""
       # Populate the input and join layer combo boxes
       #  self.dlg.inputVectorLayer.clear()
       #  # select defaults for CRS and input layer based on active layer
        activelayer = self.iface.activeLayer()
        if activelayer:
            # selected crs is active layer's crs
            self.dlg.inputProjection.setCrs(activelayer.crs())
            # selected layer (first entry) is the active layer
            # if activelayer.type() == QgsMapLayer.VectorLayer:
            #     self.dlg.inputVectorLayer.addItem(activelayer.name(), activelayer.id())
        else:
            # fall back to project crs if no layer is selected
            fallbacksrs = self.iface.mapCanvas().mapSettings().destinationCrs()
            self.dlg.inputProjection.setCrs(fallbacksrs)
        # for alayer in self.iface.legendInterface().layers():
        #     if (alayer.type() == QgsMapLayer.VectorLayer) and alayer != activelayer:
        #         self.dlg.inputVectorLayer.addItem(alayer.name(), alayer.id())

        # prefill output path
        # TODO: remote testing code
        self.dlg.outShape.clear()
        self.dlg.outShape.insert("C:/tmp/domain.shp")

        # show the dialog
        self.dlg.show()
        # Run the dialog event loop
        result = self.dlg.exec_()
        # See if OK was pressed
        if result:
            # Do something useful here - delete the line containing pass and
            # substitute with your code.
            pass


def show_extent_selector(self):
    """Show the extent selector widget for defining analysis extents."""
    # import here only so that it is AFTER i18n set up
    from gui.extent_selector_dialog import ExtentSelectorDialog

    widget = ExtentSelectorDialog(
        self.iface,
        self.iface.mainWindow(),
        extent=self.dock_widget.extent.user_extent,
        crs=self.dock_widget.extent.user_extent_crs)
    widget.clear_extent.connect(
        self.dock_widget.extent.clear_user_analysis_extent)
    widget.extent_defined.connect(
        self.dock_widget.define_user_analysis_extent)
    # This ensures that run button state is updated on dialog close
    widget.extent_selector_closed.connect(
        self.dock_widget.show_next_analysis_extent)
    # Needs to be non modal to support hide -> interact with map -> show
    widget.show()  # non modal
