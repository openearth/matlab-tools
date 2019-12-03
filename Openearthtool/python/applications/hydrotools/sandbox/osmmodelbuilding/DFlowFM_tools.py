#!/usr/bin/python
"""
set of utilities for to parse combine vector and raster data to create and parse D-Flow FM objects
"""

import os, shutil
import logging
import shapely
import fiona
from fiona import crs, collection
import numpy as np
from collections import OrderedDict
from configobj import ConfigObj
from shapely.geometry import (Point, LineString, Polygon, shape, LinearRing,
                              MultiLineString, MultiPoint, MultiPolygon, GeometryCollection)
from shapely import affinity
# import local modules
from gdal_sample_points import gdal_sample_points
import shapely_tools as st
import copy

# base internal class for general methods
class _Base(object):
    """
    Base D-Flow FM object.
    Contains some general functions that are used in the specific D-Flow FM objects
    """
    def __init__(self, geom, ids, sname, **kwargs):
        if not isinstance(ids, str):
            raise ValueError('invalid id {}, should be string'.format(ids))
        if not geom <= shapely.geometry.base:  # check if geometry is a shapely geometry object
            raise ValueError('invalid geometry type for {:s}'.format(ids))

        # set object geometries
        self.geom = geom
        self.id = ids  # unique id
        self.id_org = kwargs.get("ids_org", ids)  # original id, e.g. OSM id; if not given duplicate unique id
        self.name = sname
        self.geom_edit = kwargs.get('geom_edit', None)
        self.attr_edit = kwargs.get('attr_edit', None)

    def feature(self, **kwargs):
        """make geosjon feature from object"""
        if (self.attr_edit is not None) and (self.geom_edit is not None):
            ft = create_feature(self.geom, id=self.id, id_org=self.id_org, name=self.name, geom_edit=self.geom_edit,
                                attr_edit=self.attr_edit)
        elif self.attr_edit is not None:
            ft = create_feature(self.geom, id=self.id, id_org=self.id_org, name=self.name, attr_edit=self.attr_edit)
        elif self.geom_edit is not None:
            ft = create_feature(self.geom, id=self.id, id_org=self.id_org, name=self.name, geom_edit=self.geom_edit)
        else:
            ft = create_feature(self.geom, id=self.id, id_org=self.id_org, name=self.name)
        return add_properties(ft, **kwargs)

    def fmt_pli(self, ordkwargs):
        """
        Args:
            name:  name of feature to write
            feature: feature to write (1st and 2nd field goes to geometry)
            keys: keys to write to 3rd, 4th and xth fields

        Returns:

        """
        pli_row_fmt = str('{:15.3f}{:15.3f}' + '{:15.3f}'*len(ordkwargs) + '\n').format
        pli_header_fmt = """{:s}\n{:6d}{:6d}\n""".format
        pli_header = pli_header_fmt(self.name, len(self.geom.xy[0]), 2+len(ordkwargs))
        pli_rows = ''
        vals = [float(ordkwargs[key]) for key in ordkwargs]
        for n, (x, y) in enumerate(zip(*self.geom.xy)):
            pli_rows += pli_row_fmt(x, y, *vals)
        return pli_header + pli_rows

    def to_pli(self, fn, ordkwargs={}, append=True):
        """
        write pli file to file fn

        Args:
            fn: filename
            name: name of the feature
            ordkwargs: an orderDict object with values to write in addition to x&y cols
            append=True
        Returns:
        """
        if append:
            write_mode = 'a'
        else:
            write_mode = 'w'
        with open(fn, write_mode) as text_file:
            text_file.write(self.fmt_pli(ordkwargs))
        pass

    def fmt_xyz(self, geom, values):
        if type(values[0]).__name__ == 'str':
            xyz_row_fmt = """{:f} {:f} {:s}\n""".format
        elif type(values[0]).__name__ == 'int':
            xyz_row_fmt = """{:f} {:f} {:d}\n""".format
        else:
            xyz_row_fmt = """{:f} {:f} {:f}\n""".format
        xyz_rows = ''
        for value, x, y in zip(values, *geom.xy):
            if value is not None:
                if type(value).__name__ == 'str':
                    xyz_rows += xyz_row_fmt(x, y, value)
                elif not(np.isnan(value)):
                    xyz_rows += xyz_row_fmt(x, y, value)
        return xyz_rows

    def to_xyz(self, fn, values, geom=None, append=True):
        """write xyz dtm samples to file fn
        if geom is None(default) use self.geom """
        if geom is None:  # in case of multigeometry allow for possibility to handle this outside function
            geom = self.geom

        if append:
            write_mode = 'a'
        else:
            write_mode = 'w'
        with open(fn, write_mode) as text_file:
            text_file.write(self.fmt_xyz(geom, values))


class Dam(_Base):
    """class for D-Flow FM Dam objects

    includes to
    """

    def __init__(self, geom, ids, dtm_fn=None, crest_level=None, **kwargs):
        """
        Construction of D-Flow FM Dam object. Construction includes the following steps:
        1) if constant crest_level not given the maximum elevation is read from a dtm file along LineString geometry

        required
        geom            geometry [Shapely geometry] in utm coordinates
        ids              unique ids [string

        one of both is required
        crest_level     elevation of dam crest  [float]
        dtm_fn          filename of DTM GTiff to sample crest elevation [string]

        optional:
        sname:          name of feature [string]
        """
        # set name and initialize object
        if kwargs.get('sname', None) is None:
            super(Dam, self).__init__(geom=geom, ids=ids, sname='dam{:s}'.format(ids), **kwargs)
        else:
            super(Dam, self).__init__(geom=geom, ids=ids, **kwargs)

        if crest_level is None:
            # get elevation from dtm grid
            x, y = self.geom.xy
            # depth is estimated as average depth at culvert LineString nodes
            z_samples = gdal_sample_points(np.array(y), np.array(x), dtm_fn, win_size=20, func=np.max)
            if not np.isnan(z_samples).all():
                self.crest_level = np.nanmax(z_samples)
            else:
                Warning('no elevation data derived from DTM at object {:s}'.format(self.id))
                self.crest_level = -999
        else:
            self.crest_level = crest_level

    def to_dh(self, ini_fn, pli_dir, append=True):
        """write 'damlevel' structure file and polyline pli file"""
        # administration filenames
        pli_fn = os.path.join(pli_dir, "{}.pli".format(self.name))  # absolute path
        rel_pli_fn = os.path.relpath(pli_fn, start=os.path.dirname(ini_fn))  # rel. path

        if append:
            write_mode = 'a'
        else:
            write_mode = 'w'

        # write structure ini file
        dam_fmt = "[structure]\ntype=damlevel\nid={:s}\npolylinefile={:s}\ncrest_level={:.3f}\n\n".format
        with open(ini_fn, write_mode) as text_file:
            text_file.write(dam_fmt(str(self.name), rel_pli_fn, float(self.crest_level)))

        # write new pli per structure
        self.to_pli(pli_fn, append=False)  # one pli file per structure
        pass

    def feature(self):
        return super(Dam, self).feature(crest_level=self.crest_level)


class Culvert(_Base):
    """class for Culvert D-Flow FM object."""
    def __init__(self, geom, ids, dtm_fn, width, depth, **kwargs):
        """
        construct D-Flow FM culvert object. Construction includes the following steps:
        1) conversion from depth and with to hydraulic radius assuming squared culvert
        2) read bed elevation for culvert form DTM without excavated channels, assuming horizontal culvert
        3) create gate (D-Flow FM DAM object) perpendicular to culvert to simulate blocked culverts

        required:
        geom            geometry [Shapely geometry] in utm coordinates
        ids              unique ids [string]
        depth           depth of culvert assuming rectangular profile [float]
        width           width of profile assuming rectangular profile [float]
        dtm_fn          filename of DTM GTiff to sample crest elevation [string]

        optional:
        blocked         boolean to indicate if culvert is blocked
        sname:          name of feature [string]
        """
        # set name and initialize object
        if kwargs.get('sname', None) is None:
            super(Culvert, self).__init__(geom=geom, ids=ids, sname='culvert{:s}'.format(ids), **kwargs)
        else:
            super(Culvert, self).__init__(geom=geom, ids=ids, **kwargs)

        # construct profile information
        self._width = width
        self._depth = depth
        self.length = kwargs['length']
        # translate to hydraulic diameter assuming a fully filled rectangular duct with width and depth
        print 'width: ', width, ' depth: ', depth
        if width + depth != 0:
            self.hydraulic_diameter = 2 * (self._width * self._depth) / (self._width + self._depth)
        else:
            # culvert is completely closed! make its dimensions zero (prevent zero division error)
            self.hydraulic_diameter = 0
        # set 'blocked' attribute, False by default
        self.blocked = kwargs.get('blocked', False)

        # get depth from dtm grid (channels not excavated)
        # TODO: max win_size configurable
        x, y = self.geom.xy
        # depth is estimated as average depth at culvert LineString nodes
        z_samples = gdal_sample_points(np.array(y), np.array(x), dtm_fn, win_size=20, func=np.min)
        if not np.isnan(z_samples).all():
            self.bed_level = np.nanmean(z_samples) - depth
        else:
            self.bed_level = -999
            Warning('no elevation data derived from DTM at id: {:s}'.format(self.id))

    def create_gate(self, dtm_fn):
        # make gate feature = perpendicular line with length = width
        gate_geom = st.perpendicular_line(self.geom, length=self._width)
        return create_gate(geom=gate_geom, ids=self.id, dtm_fn=dtm_fn, blocked=self.blocked,
                           type_name='gate', bed_level=self.bed_level)

    def to_dh(self, fn, append=True):
        # pli with 5 columns: x, y, level, diameter, <other>
        ordkwargs = OrderedDict([('level', self.bed_level),
                                 ('diameter', self.hydraulic_diameter),
                                 ('other', self.length)])
        self.to_pli(fn=fn, ordkwargs=ordkwargs, append=append)
        pass

    def feature(self):
        return super(Culvert, self).feature(level=self.bed_level, diameter=self.hydraulic_diameter,
                                            blocked=self.blocked)


class Channel(_Base):
    """class for D-Flow FM Channel objects.

    Not included yet (also required: make suggestions for taxonomy in OSM):
    bank_level (where is exchange between 1D and 2D occurring? not sure how this is handled in FM)
    calculation distance (distance between calculation nodes, FM can arrange this internally, but would be good to make this explicit)
    type diversification: Now only type 2 is supported (rectangular).
            Other profiles like triangular, xyz etc. not supported yet but can easily be extended.

    """

    def __init__(self, geom, ids, depth, width, proftype, profnr, dtm_fn, **kwargs):
        """
        construction of D-Flow FM Channel object. includes following steps:
        1) set general depth, width, proftype and ids settings
        2) create profile definitions
        3) if intersection with bbox, create boundary conditions

        required
        geom: shapely geometry LineString
        ids:        unique id (string)
        dtm_fn:     path to digital terrain model (bare earth)
        depth:      depth in meters (float)
        width:      width in meters (float)
        proftype:   Type of profile. In Delft3D-Flexible Mesh, proftype 2 is a rectangular channel. We only support this for now
        profnr:     number of profile definition

        optional:
        sname: name of element
        bbox: bounding box (shapely polygon)

        """
        # set name and initialize object
        if kwargs.get('sname', None) is None:
            super(Channel, self).__init__(geom=geom, ids=ids, sname='channel{:s}'.format(ids), **kwargs)
        else:
            super(Channel, self).__init__(geom=geom, ids=ids, **kwargs)

        # construct profile information
        self.width = width
        self.depth = depth  # probably not used as this is sampled from the excavated DTM
        self.profnr = profnr

        # get dtm samples from dtm grid
        # TODO: max win_size configurable
        x, y = self.geom.xy
        self.dtm_samples = gdal_sample_points(np.array(y), np.array(x), dtm_fn, win_size=20, func=np.min) - depth
        # make profile definitions at endpoints
        proflocs = MultiPoint([Point(coords) for coords in zip(*self.profile_location())])
        self.profile_definition = ProfileDefinition(geom=proflocs, ids=str(profnr), sname=str(profnr),
                                                    profdef_type=proftype, parameters=self.width)
        # number of boundary conditions. is updated in create_boundary_condition method
        self.bnd_cnd = 0

    def create_boundary_condition(self, bnd_type, bnd_fn, bbox, **kwargs):
        # create lines for boundary conditions perpendicular to line at the line's endpoints
        boundaries = st.cap_lines(self.geom, offset=0.01, length=2.)  # we make a boundary condition extremely close to the edge of the 1d network
        i = 0
        bc_ojbects = []
        for bnd in boundaries:
            if bbox.disjoint(bnd):  # check if boundary polyline outside bbox
                i += 1
                bnd_id = '{:s}_{:d}'.format(self.id, i)
                bc_ojbects.append(BoundaryCondition(geom=bnd, ids=bnd_id, sname=bnd_id,
                                                    bound_type=bnd_type, bound_fn=bnd_fn, **kwargs))
                # update no of boundary conditions for channel type
                self.bnd_cnd = i
        return bc_ojbects

    def profile_location(self):
        """return arrays with x and y of end points"""
        end_points = [Point(self.geom.coords[0]), Point(self.geom.coords[-1])]
        x, y = zip(*list((p.x, p.y) for p in end_points))
        return np.array(x), np.array(y)

    def to_dh(self, pli_fn, ldb_fn, xyz_fn, append=True):
        """write channel D-Flow files for 1D elements
        per channel object an .xyz with elevation samples, .pli and .ldb file are appended

        to write the boundary condition and profile definition files,
        use object.boundary_condition.to_dh() and object.profile_definition.to_dh() resp."""
        # write pli file
        self.to_pli(pli_fn, append=append)
        # write lbd file
        self.to_pli(ldb_fn, append=append)
        # write xyz file
        self.to_xyz(xyz_fn, values=self.dtm_samples, append=append)
        pass

    def feature(self):
        return super(Channel, self).feature(width=self.width, depth=self.depth, prof_nr=self.profnr,
                                            bnd_cnd=self.bnd_cnd)


class Obs(_Base):
    """class for observation points in FM domain"""
    def __init__(self, geom, ids, names):
        """
        Construction of observation point objects
        Args:
            geom: geometry (points)
            ids:
            names:

        Returns:

        """
        super(Obs, self).__init__(geom=geom, ids=ids, sname=names)

    def to_dh(self, xyz_fn, append=True):
        """write observations to xyn file D-Flow-FM"""
        # write xyz file
        self.to_xyz(xyz_fn, values=[str(self.name)], append=append)
        pass


class Domain(_Base):
    """class for D-Flow FM Domain objects. A domain object is an extended line along one of the sides of a bounding box"""

    def __init__(self, geom, ids, **kwargs):
        """
        Construction of D-Flow FM Domain object.

        required
        geom            geometry [Shapely geometry] in utm coordinates
        ids              unique ids [string

        optional:
        sname:          name of feature [string]
        """
        # set name and initialize object
        if kwargs.get('sname', None) is None:
            super(Domain, self).__init__(geom=geom, ids=ids, sname='bbox{:s}'.format(ids), **kwargs)
        else:
            super(Domain, self).__init__(geom=geom, ids=ids, **kwargs)

    def to_dh(self, fn, append=True):
        """write D-Flow FM files for domain"""
        self.to_pli(fn, append=append)
        pass


class BoundaryCondition(_Base):
    """class for D-Flow FM Boundary condition ono 1D element objects.
    """

    def __init__(self, geom, ids, bound_type, bound_fn="", bound_filetype=9, bound_method=3, **kwargs):
        """
        Construction of D-Flow FM BoundaryCondition object.

        required
        geom            geometry [Shapely geometry] in utm coordinates
        ids              unique ids [string]
        bound_type      D-Flow FM boundary type

        optional:
        sname:          name of feature [string]
        """
        # set name and intitialize object
        if kwargs.get('sname', None) is None:
            super(BoundaryCondition, self).__init__(geom=geom, ids=ids, sname='boundary{:s}'.format(ids), **kwargs)
        else:
            super(BoundaryCondition, self).__init__(geom=geom, ids=ids, **kwargs)

        # set properties of feature
        # TODO: check bound types and make decision on how to do formatting here
        if bound_type in ["waterlevel", "outflow", "discharge"]:
            bound_type = "{:s}bnd".format(bound_type)
        self.type = bound_type
        self.fn = bound_fn
        self.filetype = int(bound_filetype)
        self.method = int(bound_method)

    # TODO: check if this is being used
    def fmt_xyz_bounds(self, values):
        xyz_row_fmt = """{:f} {:f} {:s}\n""".format
        xyz_rows = ''
        for value, x, y in zip(values, *self.geom.xy):
            xyz_rows += xyz_row_fmt(x, y, value)
        return xyz_rows

    def to_dh(self, fn, bnd_path=None, append=True):
        """write boundary condition D-Flow FM files for 1D elements
        per boundary condition append .ext file and write .pli and .cmp file"""
        # file names administration
        root_path = os.path.split(fn)[0]
        if bnd_path is None:
            bnd_path = root_path
        pli_fn = os.path.join(bnd_path, '{:s}_bnd.pli'.format(self.name))  # pli file fn
        rel_pli_fn = os.path.relpath(pli_fn, start=root_path)  # relative path of .pli to boundary cond (.ext) file
        # TODO check rationale behind postfix naming of tim files per boundary type
        if self.type == "discharge_salinity_temperature_sorsin":
            postfix = ""
        else:
            postfix = "_0001"

        if self.fn == '':
            # make a simple component file with only zeroes as forcing
            cmp_fn = os.path.join(bnd_path, '{:s}_bnd{}.cmp'.format(self.name, postfix))  # const bound file
        else:
            bnd_fn = os.path.join(bnd_path, '{:s}_bnd{}.tim'.format(self.name, postfix))

        # write boundary conditions (.ext) file
        if append:
            write_mode = 'a'
        else:
            write_mode = 'w'
        bnd_cnds_fmt = """QUANTITY={:s}\nFILENAME={:s}\nFILETYPE={:d}\nMETHOD={:d}\nOPERAND=O\n\n""".format
        with open(fn, write_mode) as text_file:
            text_file.write(bnd_cnds_fmt('{:s}'.format(self.type), rel_pli_fn, self.filetype, self.method))

        # write the accompanying .pli file!
        self.to_pli(pli_fn, append=False)

        # write constant boundary condition (_0001.cmp) file
        if self.fn == '':
            const_bnd_cond_fmt = '{:.1f} {:.1f} {:.1f}'.format(0, 0, 0)
            with open(cmp_fn, 'w') as text_file:
                text_file.write(const_bnd_cond_fmt)
            pass
        else:
            shutil.copy(self.fn, bnd_fn)

    def feature(self):
        return super(BoundaryCondition, self).feature(type=self.type)


class ProfileDefinition(_Base):
    """class for D-Flow FM Profile definition objects.
    """

    def __init__(self, geom, ids, profdef_type, parameters, **kwargs):
        """
        Construction of D-Flow FM Domain object.

        required
        geom            geometry [Shapely Point of MultiPoint geometry] in utm coordinates
        ids              unique ids [string
        profdef_type
        parameters

        optional:
        sname:          name of feature [string]
        """
        # create ProfileDefinition object with geom
        if isinstance(geom, Point):
            geom = MultiPoint([Point])
        elif isinstance(geom, MultiPoint):
            pass
        else:
            raise ValueError("Profile definition geometry should be shapely Point or MultiPoint")

        # set name and intitialize object
        if kwargs.get('sname', None) is None:
            super(ProfileDefinition, self).__init__(geom=geom, ids=ids, sname='profdef{:s}'.format(ids), **kwargs)
        else:
            super(ProfileDefinition, self).__init__(geom=geom, ids=ids, **kwargs)

        # set properties of feature
        self.type = profdef_type
        self.parameters = parameters

    def to_dh(self, profdef_fn, profloc_fn, append=True):
        """write D-Flow FM files for profile definition: profdef.txt and profloc.xyz"""
        if append:
            write_mode = 'a'
        else:
            write_mode = 'w'

        # write profdef.txt
        # TODO: make profdef dictionary
        profdef_row_fmt = """PROFNR={:s}     TYPE={:d}             WIDTH={:f}\n""".format
        with open(profdef_fn, write_mode) as text_file:
            text_file.write(profdef_row_fmt(self.id, self.type, self.parameters))

        # write profloc.xyz
        for p in self.geom:  # one line per point
            self.to_xyz(profloc_fn, [self.id], geom=p, append=append)
        pass

    def feature(self):
        return super(ProfileDefinition, self).feature(type=self.type, parameters=self.parameters)


def create_gate(geom, ids, dtm_fn, blocked=False, type_name='blockage', **kwargs):
    # make dam feature as structure with type is "gate_level" to simulate blocking
    gate_name = '{:s}{:s}'.format(type_name, ids)

    # check if culvert is blocked; by default the gate is open
    if not blocked:  # open, thus crest level at bed level
        # either depth or bed_level is required in DTM
        depth_is_known = kwargs.get('depth', None) is not None
        bedlevel_is_known = kwargs.get('bed_level', None) is not None
        assert depth_is_known or bedlevel_is_known, "no depth or bed level provided for id {:s}".format(ids)
        # elevation across gate
        if bedlevel_is_known:
            gate_level = kwargs.get('bed_level')
        else:
            x_gate, y_gate = geom.xy
            gate_samples = gdal_sample_points(np.array(y_gate), np.array(x_gate), dtm_fn, win_size=20, func=np.min)
            gate_level = np.nanmin(gate_samples) - kwargs.get('depth')

    else:
        if kwargs.get('gate_level', None) is None:
            # elevation across gate:
            x_gate, y_gate = geom.xy
            gate_samples = gdal_sample_points(np.array(y_gate), np.array(x_gate), dtm_fn, win_size=20, func=np.max)
            # closed, crest level is max terrain level in window of dam level; sample at midpoint gate geom
            gate_level = np.nanmax(gate_samples)
        else:
            gate_level = kwargs.get('gate_level')

    return Dam(geom=geom, ids=ids, sname=gate_name, crest_level=gate_level)


# functions for D-Flow objects
def polygon2domain(poly, ids, boundary_2d):
    """oonvert polygon geom into a set of lines, slightly extended,
    then create domain objects of extended lines"""
    xoffsets = [-1, 0, 1, 0]  # x-direction offsets for boundary polylines
    yoffsets = [0, -1, 0, 1]  # y-direction offsets for boundary polylines
    domain_lines = st.explode_polygons(poly)
    domain_obj = []  # make a list of domain lines
    domain_bnd = []  # make a list of west, south, east, north boundary conditions
    for i, (line, xoff, yoff) in enumerate(zip(domain_lines, xoffsets, yoffsets)):
        # extend line slightly
        line_extend = st.extend_line(line, 1.)
        # only save the first and last coordinates
        line_extend = LineString([line_extend.coords[0], line_extend.coords[-1]])
        line_bnd = affinity.translate(line_extend, xoff=xoff, yoff=yoff)
        domain_obj.append(Domain(geom=line_extend, ids="{}_{:03d}".format(ids, i)))
        domain_bnd.append(BoundaryCondition(line_bnd, ids="{}_{:03d}".format(ids, i), bound_type=boundary_2d['type'][i], bound_fn=""))
    return domain_obj, domain_bnd


def read_layer(fn, bbox=None):
    """
    reads to shapely geometries to features using fiona collection
    feature = dict('geometry': <shapely geometry>, 'properties': <dict with properties>
    """
    ft_list = []
    with collection(fn, "r") as c:
        for i, ft in c.items(bbox=bbox):
            if ft['geometry'] is not None:
                ft['geometry'] = shape(ft['geometry'])
                ft_list.append(ft)
    return ft_list

def write_mdu(options, logger=logging):
    """write D-Flow FM configuration (mdu) file"""
    logger.info('Write D-Flow FM configuration file to {:s}'.format(options.mdu_fn))
    config = ConfigObj(options.mdu_template)
    # add relevant files as a relative path (without their base path)

    config['geometry']['NetFile'] = os.path.relpath(options.mesh_2d_fn, start=options.fm_path)
    config['geometry']['ProflocFile'] = os.path.relpath(options.channel_profloc_xyz_fn, start=options.fm_path)
    config['geometry']['ProfdefFile'] = os.path.relpath(options.channel_profdef_txt_fn, start=options.fm_path)
    if os.path.isfile(options.channel_lbd_fn):
        config['geometry']['LandBoundaryFile'] = os.path.relpath(options.channel_lbd_fn, start=options.fm_path)
    if np.logical_and(options.culverts['key'] is not None, options.culverts['value'] is not None):
        config['geometry']['PipeFile'] = os.path.relpath(options.culverts_pli_fn, start=options.fm_path)

    if os.path.isfile(options.culverts_gates_fn):
        config['geometry']['StructureFile'] = os.path.relpath(options.culverts_gates_fn, start=options.fm_path)
    # %Y%m%d of the start time (hour offset is provided elsewhere)
    config['time']['RefDate'] = options.start_time.strftime('%Y%m%d')
    TStart = options.start_time.hour + options.start_time.minute/60. + options.start_time.second/3600.
    config['time']['TStart'] = TStart  # Start time in hours after RefDate
    config['time']['TStop'] = TStart + options.duration  # Stop time in hours after RefDate

    # forcing file with boundary conditions, rainfall etc.
    if os.path.isfile(options.forcing_file):
        config['external forcing']['ExtForceFile'] = os.path.relpath(options.forcing_file, start=options.fm_path)
    # write new configuration to target file
    f = open(options.mdu_fn, 'w')
    config.write(outfile=f)
    f.close()

    # read config as text and modify a few things
    f = open(options.mdu_fn, 'r')
    a = f.read()
    f.close()
    # remove "" signs
    a = a.replace('""', '')

    # add some spaces in front of comments #
    a = a.replace('#', '  #')
    f = open(options.mdu_fn, 'w')
    f.write(a)
    f.close()
    pass


def shp2pli(fn_shape, fn_pli, keys_out=[], append=True):
    """function to convert shape (or any type of fiona readable format) to *.pli or *.pol format
    keys in the list key_out are added as extra columns to the output file

    NOTE: that with append = False and a shape with multiple geometries only the last geometry will be in the resulting
    file as the previous geometries will be overwritten
    """
    # read data
    fts = read_layer(fn_shape)

    # create base  DFlowFM objects and write to pli
    i = 0
    for feat in fts:
        # only single geometry features can be written to pli
        feat = multi2single_geoms(feat)
        # loop through features
        for ft in feat:
            i += 1
            props = ft["properties"]
            geom = ft["geometry"]

            # create the minimal required fields if not exists
            if "ids" not in props.keys():
                props["ids"] = "{:04d}".format(i)
            if "sname" not in props.keys():
                props["sname"] = "{:04d}".format(i)

            # change polygons to linear ring which have same options as LineStrings geometries
            # and are the same in .pli files
            if isinstance(geom, Polygon):
                geom = LinearRing(geom.exterior.coords[:])

            # create output additional fields dictionary
            ordkwargs = OrderedDict()
            for key in keys_out:
                if key in props.keys():
                    ordkwargs[key] = props[key]

            # create base object
            base_object = _Base(geom, **props)

            # write to pli
            base_object.to_pli(fn_pli, ordkwargs=ordkwargs, append=append)


# utils
def create_feature(geom, **kwargs):
    feature = {"geometry": geom,
               "properties": {}}
    return add_properties(feature, **kwargs)


def add_properties(feature, missing_value='', **kwargs):
    for key in kwargs:
        if (not isinstance(kwargs[key], bool)) and (kwargs[key] is not None):
            feature['properties'][key] = kwargs[key]
        elif isinstance(kwargs[key], bool):
            feature['properties'][key] = int(kwargs[key])
        else:
            feature['properties'][key] = missing_value
    return feature


def multi2single_geoms(feature):
    # make separate data object for each geometry in multi geometry
    features = []
    if isinstance(feature['geometry'], (MultiLineString, MultiPoint, MultiPolygon, GeometryCollection)):
        i = 0
        for geom in feature['geometry']:
            # ft['geometry'] = feature['geometry'][i]
            if isinstance(geom, (LineString, Point, Polygon)):
                if geom.length > 0:
                    ft = copy.deepcopy(feature)
                    ft['geometry'] = geom
                    # keep unique id, but add geom_postfix property
                    ft['properties']['geom_postfix'] = "_{:03d}".format(i)
                    features.append(ft)
                    i += 1
            else:
                raise NotImplementedError("unknown geometry type {}".format(type(ft['geometry'])))
    else:
        features = [feature]
    return features
